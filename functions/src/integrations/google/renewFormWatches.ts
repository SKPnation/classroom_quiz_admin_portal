import {onSchedule} from "firebase-functions/v2/scheduler";
import {defineSecret} from "firebase-functions/params";
import {google} from "googleapis";
import * as admin from "firebase-admin";
import {getLecturerAuthClient} from "./googleAuth";

const GOOGLE_CLIENT_ID = defineSecret("GOOGLE_CLIENT_ID");
const GOOGLE_CLIENT_SECRET = defineSecret("GOOGLE_CLIENT_SECRET");

export const renewFormWatches = onSchedule(
  {
    schedule: "every 24 hours",
    region: "us-central1",
    secrets: [GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET],
  },
  async () => {
    const snap = await admin.firestore()
      .collectionGroup("templates")
      .where("watchId", "!=", null)
      .get();

    for (const doc of snap.docs) {
      const {formId, watchId, createdBy} = doc.data();
      const orgRef = doc.ref.parent.parent;
      if (!orgRef) continue;
      const orgId = orgRef.id;
      try {
        const auth = await getLecturerAuthClient(orgId, createdBy);
        const forms = google.forms({version: "v1", auth});
        const renewed = await forms.forms.watches.renew({
          formId, watchId, requestBody: {},
        });
        await doc.ref.set(
          {watchExpireTime: renewed.data.expireTime}, {merge: true});
      } catch (e) {
        console.error(`Watch renew failed for form ${formId}:`, e);
      }
    }
  }
);
