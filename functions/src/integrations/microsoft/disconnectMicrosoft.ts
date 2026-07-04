// ═══════════════════════════════════════════════════════════════════════
// FILE: functions/src/integrations/microsoft/disconnectMicrosoft.ts
// ═══════════════════════════════════════════════════════════════════════

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const disconnectMicrosoft = functions.https.onCall(
  async (data: { orgId: string }, _context) => {
    const { orgId } = data;

    if (!orgId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "orgId is required."
      );
    }

    await admin
      .firestore()
      .collection("organisations")
      .doc(orgId)
      .collection("integrations")
      .doc("microsoft")
      .delete();

    console.log(`Microsoft disconnected for org: ${orgId}`);

    return { success: true };
  }
);
