// ═══════════════════════════════════════════════════════════════════════
// FILE: functions/src/integrations/microsoft/microsoftAuthCallback.ts
// ═══════════════════════════════════════════════════════════════════════

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  ConfidentialClientApplication,
  AuthorizationCodeRequest,
} from "@azure/msal-node";
import {getMsalConfig, getRedirectUri, SCOPES} from "./config";
import {Request, Response} from "express";

export const microsoftAuthCallback = onRequest(
  async (req: Request, res: Response) => {
    const code = req.query["code"] as string | undefined;
    const orgId = req.query["state"] as string | undefined;
    const error = req.query["error"] as string | undefined;

    if (error || !code || !orgId) {
      res.redirect(
        "https://asseska.ai/settings?integration=microsoft&status=error"
      );
      return;
    }

    try {
      const cca = new ConfidentialClientApplication(getMsalConfig());

      const tokenRequest: AuthorizationCodeRequest = {
        code,
        scopes: SCOPES,
        redirectUri: getRedirectUri(),
      };

      const tokenResponse = await cca.acquireTokenByCode(tokenRequest);

      if (!tokenResponse) {
        throw new Error("No token response from Microsoft.");
      }

      await admin
        .firestore()
        .collection("organisations")
        .doc(orgId)
        .collection("integrations")
        .doc("microsoft")
        .set(
          {
            id: "microsoft",
            connected: true,
            accessToken: tokenResponse.accessToken,
            accountEmail: tokenResponse.account?.username ?? null,
            accountName: tokenResponse.account?.name ?? null,
            connectedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true}
        );

      res.redirect(
        "https://asseska.ai/settings?integration=microsoft&status=connected"
      );
    } catch (err) {
      console.error("Microsoft token exchange error:", err);
      res.redirect(
        "https://asseska.ai/settings?integration=microsoft&status=error"
      );
    }
  }
);
