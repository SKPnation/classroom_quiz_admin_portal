import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";
import {google} from "googleapis";

const GOOGLE_CLIENT_ID = defineSecret("GOOGLE_CLIENT_ID");
const GOOGLE_CLIENT_SECRET = defineSecret("GOOGLE_CLIENT_SECRET");
const GOOGLE_REDIRECT_URI = defineSecret("GOOGLE_REDIRECT_URI");

type GoogleApiError = {
code?: number | string;
status?: number | string;
message?: string;
response?: {
status?: number;
data?: {
error?: string | {
code?: number;
status?: string;
message?: string;
errors?: Array<{
reason?: string;
message?: string;
}>;
};
};
};
};

function isGoogleReauthenticationError(error: unknown): boolean {
  const googleError = error as GoogleApiError;

  const statusCode =
googleError.response?.status ??
(typeof googleError.code === "number" ? googleError.code : undefined);

  const responseError = googleError.response?.data?.error;

  const oauthError =
typeof responseError === "string" ? responseError : undefined;

  const googleStatus =
typeof responseError === "object" ?
  responseError?.status :
  undefined;

  const reasons =
typeof responseError === "object" ?
  responseError?.errors?.map((item) => item.reason ?? "") ?? [] :
  [];

  const message = [
    googleError.message,
    typeof responseError === "object" ? responseError?.message : undefined,
    oauthError,
    googleStatus,
    ...reasons,
  ]
    .filter(Boolean)
    .join(" ")
    .toLowerCase();

  return (
    oauthError === "invalid_grant" ||
statusCode === 401 ||
googleStatus === "UNAUTHENTICATED" ||
message.includes("invalid_grant") ||
message.includes("token has been expired or revoked") ||
message.includes("invalid credentials") ||
message.includes("login required") ||
message.includes("invalid authentication credentials")
  );
}

export const syncToGoogleClassroom = onCall(
  {
    region: "us-central1",
    memory: "512MiB",
    secrets: [
      GOOGLE_CLIENT_ID,
      GOOGLE_CLIENT_SECRET,
      GOOGLE_REDIRECT_URI,
    ],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be logged in."
      );
    }

    const {orgId, courseId, quiz} = request.data;

    if (!orgId || !quiz) {
      throw new HttpsError(
        "invalid-argument",
        "Missing orgId or quiz data."
      );
    }

    const integrationRef = admin
      .firestore()
      .collection("orgs")
      .doc(orgId)
      .collection("members")
      .doc(request.auth.uid)
      .collection("integrations")
      .doc("google");

    const integrationDoc = await integrationRef.get();

    if (!integrationDoc.exists) {
      throw new HttpsError(
        "failed-precondition",
        "Google account is not connected.",
        {
          reason: "GOOGLE_NOT_CONNECTED",
          requiresGoogleReconnect: true,
        }
      );
    }

    const integration = integrationDoc.data();

    if (
      !integration ||
integration.connected !== true ||
!integration.refreshToken
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Your Google connection is incomplete. Please reconnect Google.",
        {
          reason: "GOOGLE_REAUTH_REQUIRED",
          requiresGoogleReconnect: true,
        }
      );
    }

    const oauth2Client = new google.auth.OAuth2(
      GOOGLE_CLIENT_ID.value(),
      GOOGLE_CLIENT_SECRET.value(),
      GOOGLE_REDIRECT_URI.value()
    );

    oauth2Client.setCredentials({
      access_token: integration.accessToken,
      refresh_token: integration.refreshToken,
      expiry_date: integration.expiryDate,
    });

    /*
* Google may emit new access-token information while making an API
* request. Keep the existing refresh token when Google does not return
* another one.
*/
    oauth2Client.on("tokens", (newTokens) => {
      const update: Record<string, unknown> = {
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (newTokens.access_token) {
        update.accessToken = newTokens.access_token;
      }

      if (newTokens.refresh_token) {
        update.refreshToken = newTokens.refresh_token;
      }

      if (newTokens.expiry_date) {
        update.expiryDate = newTokens.expiry_date;
      }

      integrationRef.update(update).catch((error) => {
        console.error("Unable to save refreshed Google tokens:", error);
      });
    });

    try {
      /*
* Force token validation before doing Classroom work.
* If the access token has expired, this uses the refresh token.
*/
      await oauth2Client.getAccessToken();

      const classroom = google.classroom({
        version: "v1",
        auth: oauth2Client,
      });

      if (!courseId) {
        const coursesResponse = await classroom.courses.list({
          courseStates: ["ACTIVE"],
        });

        const courses = (coursesResponse.data.courses ?? []).map((course) => ({
          id: course.id,
          name: course.name,
          section: course.section ?? "",
        }));

        return {
          success: true,
          requiresCourseSelection: true,
          courses,
        };
      }

      if (!quiz.id) {
        throw new HttpsError(
          "invalid-argument",
          "Missing quiz ID."
        );
      }

      if (!quiz.formUrl) {
        throw new HttpsError(
          "failed-precondition",
          "Create the Google Form before syncing it to Google Classroom."
        );
      }

      const courseWorkResponse =
await classroom.courses.courseWork.create({
  courseId,
  requestBody: {
    title: quiz.title,
    description: quiz.description || "Generated by Asseska",
    workType: "ASSIGNMENT",
    state: "PUBLISHED",
    maxPoints: quiz.maxPoints ?? 100,
    materials: [
      {
        link: {
          url: quiz.formUrl,
          title: `${quiz.title} — Answer Form`,
        },
      },
    ],
  },
});

      /*
* Corrected path:
* orgs/{orgId}/templates/{quizId}
*/
      await admin
        .firestore()
        .collection("orgs")
        .doc(orgId)
        .collection("templates")
        .doc(quiz.id)
        .update({
          classroomCourseId: courseId,
          classroomCourseWorkId: courseWorkResponse.data.id,
          classroomUrl: courseWorkResponse.data.alternateLink ?? null,
          classroomSyncedAt:
admin.firestore.FieldValue.serverTimestamp(),
        });

      return {
        success: true,
        requiresCourseSelection: false,
        classroomUrl: courseWorkResponse.data.alternateLink,
        courseWorkId: courseWorkResponse.data.id,
      };
    } catch (error: unknown) {
      if (error instanceof HttpsError) {
        throw error;
      }

      console.error("Google Classroom synchronization failed:", error);

      if (isGoogleReauthenticationError(error)) {
        /*
* Do not delete the integration automatically. Flutter will ask
* the user before disconnecting it.
*/
        await integrationRef.set(
          {
            connected: false,
            reconnectRequired: true,
            lastError: "GOOGLE_REAUTH_REQUIRED",
            lastErrorAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true}
        );

        throw new HttpsError(
          "failed-precondition",
          "Your Google connection has expired or was "+
          "revoked. Disconnect and reconnect Google to continue.",
          {
            reason: "GOOGLE_REAUTH_REQUIRED",
            requiresGoogleReconnect: true,
          }
        );
      }

      throw new HttpsError(
        "internal",
        "Unable to sync the quiz to Google Classroom.",
        {
          reason: "GOOGLE_CLASSROOM_SYNC_FAILED",
          requiresGoogleReconnect: false,
        }
      );
    }
  }
);
