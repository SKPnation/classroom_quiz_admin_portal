import * as admin from "firebase-admin";

admin.initializeApp();

export {connectGoogle} from "./google/connectGoogle";
export {googleOAuthCallback} from "./google/googleOAuthCallback";
export {saveGradedAttempt} from "./saveGradedAttempt";
