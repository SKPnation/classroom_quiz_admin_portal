// ═══════════════════════════════════════════════════════════════════════
// FILE: functions/src/integrations/microsoft/connectMicrosoft.ts
// ═══════════════════════════════════════════════════════════════════════

import {onCall, CallableRequest} from "firebase-functions/v2/https";
import {
  ConfidentialClientApplication,
  AuthorizationUrlRequest,
} from "@azure/msal-node";
import {getMsalConfig, getRedirectUri, SCOPES} from "./config";

export const connectMicrosoft = onCall(
  async (request: CallableRequest) => {
    const orgId = request.data?.orgId as string;

    if (!orgId) {
      throw new Error("orgId is required.");
    }

    const cca = new ConfidentialClientApplication(getMsalConfig());

    const authUrlRequest: AuthorizationUrlRequest = {
      scopes: SCOPES,
      redirectUri: getRedirectUri(),
      state: orgId,
      prompt: "select_account",
    };

    const url = await cca.getAuthCodeUrl(authUrlRequest);

    return {url};
  }
);
