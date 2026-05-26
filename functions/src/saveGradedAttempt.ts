import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

export const saveGradedAttempt = onRequest(
  {region: "us-central1"},
  async (req, res) => {
    try {
      const data = req.body;
      await admin.firestore()
        .collection("orgs")
        .doc(data.orgId)
        .collection("gradedAttempts")
        .add(data);
      res.status(200).json({
        success: true,
      });
    } catch (e) {
      console.error(e);

      res.status(500).json({
        success: false,
        error: e,
      });
    }
  }
);
