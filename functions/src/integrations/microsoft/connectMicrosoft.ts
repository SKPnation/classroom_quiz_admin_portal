// ═══════════════════════════════════════════════════════════════════════
// FILE: functions/src/integrations/microsoft/connectMicrosoft.ts
// ═══════════════════════════════════════════════════════════════════════

import * as functions from "firebase-functions";
import { ConfidentialClientApplication, AuthorizationUrlRequest } from "@azure/msal-node";
import { getMsalConfig, getRedirectUri, SCOPES } from "./config";

export const connectMicrosoft = functions.https.onCall(
  async (data: { orgId: string }, _context) => {
    const { orgId } = data;

    if (!orgId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "orgId is required."
      );
    }

    const cca = new ConfidentialClientApplication(getMsalConfig());

    const authUrlRequest: AuthorizationUrlRequest = {
      scopes: SCOPES,
      redirectUri: getRedirectUri(),
      state: orgId,
      prompt: "select_account",
    };

    const url = await cca.getAuthCodeUrl(authUrlRequest);

    return { url };
  }
);
