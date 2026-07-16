import {HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {google} from "googleapis";
import * as admin from "firebase-admin";

const GOOGLE_CLIENT_ID = defineSecret("GOOGLE_CLIENT_ID");
const GOOGLE_CLIENT_SECRET = defineSecret("GOOGLE_CLIENT_SECRET");

export async function getLecturerAuthClient(orgId: string, uid: string) {
  const doc = await admin.firestore()
    .doc(`orgs/${orgId}/members/${uid}/integrations/google`)
    .get();

  const refreshToken = doc.data()?.refreshToken;
  if (!doc.exists || !refreshToken) {
    throw new HttpsError("failed-precondition", "Google not connected", {
      reason: "GOOGLE_NOT_CONNECTED",
    });
  }

  const client = new google.auth.OAuth2(
    GOOGLE_CLIENT_ID.value(),
    GOOGLE_CLIENT_SECRET.value()
  );
  client.setCredentials({refresh_token: refreshToken});

  try {
    await client.getAccessToken();
  } catch {
    throw new HttpsError("failed-precondition", "Reauthorization required", {
      reason: "GOOGLE_REAUTH_REQUIRED",
      requiresGoogleReconnect: true,
    });
  }
  return client;
}
