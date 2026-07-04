import * as functions from "firebase-functions";
import { Configuration } from "@azure/msal-node";

export const getMsalConfig = (): Configuration => ({
  auth: {
    clientId: functions.config().microsoft.client_id as string,
    clientSecret: functions.config().microsoft.client_secret as string,
    authority: "https://login.microsoftonline.com/common",
  },
});

export const getRedirectUri = (): string =>
  functions.config().microsoft.redirect_uri as string;

export const SCOPES: string[] = [
  "https://graph.microsoft.com/Forms.Read",
  "https://graph.microsoft.com/Forms.ReadWrite",
  "https://graph.microsoft.com/EduAssignments.ReadWrite",
  "https://graph.microsoft.com/Team.ReadBasic.All",
  "https://graph.microsoft.com/User.Read",
  "offline_access",
];
