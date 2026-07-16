import * as admin from "firebase-admin";

admin.initializeApp();

// ======= GOOGLE INTEGRATION IMPORTS ======= //
export {connectGoogle} from "./integrations/google/connectGoogle";
export {googleOAuthCallback} from "./integrations/google/googleOAuthCallback";
export {createGoogleForm} from "./integrations/google/createGoogleForm";
export {onFormResponse} from "./integrations/google/onFormResponse";
export {renewFormWatches} from "./integrations/google/renewFormWatches";
export {syncToGoogleClassroom} from
  "./integrations/google/syncToGoogleClassroom";
export {disconnectGoogle} from "./integrations/google/disconnectGoogle";

// ======= MICROSOFT INTEGRATION IMPORTS ======= //
export {connectMicrosoft} from "./integrations/microsoft/connectMicrosoft";
export {microsoftAuthCallback} from
  "./integrations/microsoft/microsoftAuthCallback";
export {disconnectMicrosoft} from
  "./integrations/microsoft/disconnectMicrosoft";

export {extractNotesText} from "./extractNotesText";
export {saveGradedAttempt} from "./saveGradedAttempt";
export {gradeAndSave} from "./gradeAndSave";
