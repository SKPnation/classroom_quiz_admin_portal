import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {google} from "googleapis";

const GOOGLE_CLIENT_ID = defineSecret("GOOGLE_CLIENT_ID");
const GOOGLE_CLIENT_SECRET = defineSecret("GOOGLE_CLIENT_SECRET");
const GOOGLE_REDIRECT_URI = defineSecret("GOOGLE_REDIRECT_URI");

export const connectGoogle = onCall(
  {
    region: "us-central1",
    secrets: [
      GOOGLE_CLIENT_ID,
      GOOGLE_CLIENT_SECRET,
      GOOGLE_REDIRECT_URI,
    ],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be logged in.");
    }

    const orgId = request.data.orgId;

    if (!orgId) {
      throw new HttpsError("invalid-argument", "Missing orgId.");
    }

    const oauth2Client = new google.auth.OAuth2(
      GOOGLE_CLIENT_ID.value(),
      GOOGLE_CLIENT_SECRET.value(),
      GOOGLE_REDIRECT_URI.value()
    );

    const state = Buffer.from(
      JSON.stringify({
        uid: request.auth.uid,
        orgId,
      })
    ).toString("base64");

    const url = oauth2Client.generateAuthUrl({
      access_type: "offline",
      prompt: "consent",
      scope: [
        "openid",
        "email",
        "profile",
        "https://www.googleapis.com/auth/forms.body",
        "https://www.googleapis.com/auth/forms.responses.readonly",
        "https://www.googleapis.com/auth/drive.file",
        "https://www.googleapis.com/auth/spreadsheets",
        // FOR GOOGLE CLASSROOM
        "https://www.googleapis.com/auth/classroom.coursework.students",
        "https://www.googleapis.com/auth/classroom.courses.readonly",
      ],
      state,
    });

    return {
      success: true,
      url,
    };
  }
);
