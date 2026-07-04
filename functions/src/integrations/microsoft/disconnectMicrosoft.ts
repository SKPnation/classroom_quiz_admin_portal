// ═══════════════════════════════════════════════════════════════════════
// FILE: functions/src/integrations/microsoft/disconnectMicrosoft.ts
// ═══════════════════════════════════════════════════════════════════════

import {onCall, CallableRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const disconnectMicrosoft = onCall(
  async (request: CallableRequest) => {
    const orgId = request.data?.orgId as string;

    if (!orgId) {
      throw new Error("orgId is required.");
    }

    await admin
      .firestore()
      .collection("organisations")
      .doc(orgId)
      .collection("integrations")
      .doc("microsoft")
      .delete();

    return {success: true};
  }
);
