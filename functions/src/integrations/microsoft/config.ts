// ═══════════════════════════════════════════════════════════════════════
// FILE: functions/src/integrations/microsoft/config.ts
// ═══════════════════════════════════════════════════════════════════════
//
// Firebase Functions v2 uses defineString() instead of functions.config()
// Create a functions/.env file with:
//   MICROSOFT_CLIENT_ID=your_client_id
//   MICROSOFT_CLIENT_SECRET=your_client_secret
//   MICROSOFT_REDIRECT_URI=your_redirect_uri

import {defineString} from "firebase-functions/params";
import {Configuration} from "@azure/msal-node";

const microsoftClientId = defineString("MICROSOFT_CLIENT_ID");
const microsoftClientSecret = defineString("MICROSOFT_CLIENT_SECRET");
const microsoftRedirectUri = defineString("MICROSOFT_REDIRECT_URI");

export const getMsalConfig = (): Configuration => ({
  auth: {
    clientId: microsoftClientId.value(),
    clientSecret: microsoftClientSecret.value(),
    authority: "https://login.microsoftonline.com/common",
  },
});

export const getRedirectUri = (): string => microsoftRedirectUri.value();

export const SCOPES: string[] = [
  "https://graph.microsoft.com/Forms.Read",
  "https://graph.microsoft.com/Forms.ReadWrite",
  "https://graph.microsoft.com/EduAssignments.ReadWrite",
  "https://graph.microsoft.com/Team.ReadBasic.All",
  "https://graph.microsoft.com/User.Read",
  "offline_access",
];
