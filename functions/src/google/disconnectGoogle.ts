import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const disconnectGoogle = onCall(
  {region: "us-central1"},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be logged in.");
    }
    const {orgId} = request.data;
    if (!orgId) {
      throw new HttpsError("invalid-argument", "Missing orgId.");
    }
    await admin
      .firestore()
      .collection("orgs")
      .doc(orgId)
      .collection("members")
      .doc(request.auth.uid)
      .collection("integrations")
      .doc("google")
      .delete();
    return {success: true};
  }
);
