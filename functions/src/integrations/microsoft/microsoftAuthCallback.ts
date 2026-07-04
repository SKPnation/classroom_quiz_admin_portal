// ═══════════════════════════════════════════════════════════════════════
// FILE: functions/src/integrations/microsoft/microsoftAuthCallback.ts
// ═══════════════════════════════════════════════════════════════════════
//
// HTTP function — Microsoft redirects here after the educator approves
// access. Exchanges the auth code for tokens and saves them to Firestore.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {
  ConfidentialClientApplication,
  AuthorizationCodeRequest,
} from '@azure/msal-node';
import { getMsalConfig, getRedirectUri, SCOPES } from './config';

export const microsoftAuthCallback = functions.https.onRequest(
  async (req, res) => {
    const code = req.query['code'] as string | undefined;
    const orgId = req.query['state'] as string | undefined;
    const error = req.query['error'] as string | undefined;

    if (error || !code || !orgId) {
      console.error('Microsoft auth callback error:', error);
      res.redirect(
        'https://asseska.ai/settings?integration=microsoft&status=error'
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
        throw new Error('No token response from Microsoft.');
      }

      await admin
        .firestore()
        .collection('organisations')
        .doc(orgId)
        .collection('integrations')
        .doc('microsoft')
        .set(
          {
            id: 'microsoft',
            connected: true,
            accessToken: tokenResponse.accessToken,
            accountId: tokenResponse.account?.homeAccountId ?? null,
            accountName: tokenResponse.account?.name ?? null,
            accountEmail: tokenResponse.account?.username ?? null,
            tenantId: tokenResponse.account?.tenantId ?? null,
            connectedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );

      console.log(`Microsoft connected for org: ${orgId}`);

      res.redirect(
        'https://asseska.ai/settings?integration=microsoft&status=connected'
      );
    } catch (err) {
      console.error('Microsoft token exchange error:', err);
      res.redirect(
        'https://asseska.ai/settings?integration=microsoft&status=error'
      );
    }
  }
);
