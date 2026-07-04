import * as admin from "firebase-admin";

admin.initializeApp();

// ======= GOOGLE INTEGRATION IMPORTS ======= //
export {connectGoogle} from "./integrations/google/connectGoogle";
export {googleOAuthCallback} from "./integrations/google/googleOAuthCallback";
export {saveGradedAttempt} from "./integrations/saveGradedAttempt";
export {syncToGoogleClassroom} from
"./integrations/google/syncToGoogleClassroom";
export {disconnectGoogle} from "./integrations/google/disconnectGoogle";

// ======= MICROSOFT INTEGRATION IMPORTS ======= //
export { connectMicrosoft } from "./connectMicrosoft";
export { microsoftAuthCallback } from "./microsoftAuthCallback";
export { disconnectMicrosoft } from "./disconnectMicrosoft";