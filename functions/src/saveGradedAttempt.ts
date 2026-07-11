// ═══════════════════════════════════════════════════════════════════════
// FILE: functions/src/saveGradedAttempt.ts
// ═══════════════════════════════════════════════════════════════════════
//
// NOTE: With the new event-driven architecture, grading now happens in
// gradeAndSave.ts. This function is kept for backwards compatibility
// (e.g. if any old quiz forms still use the old onFormSubmit path).
//
// Export from index.ts:
//   export { saveGradedAttempt } from "./saveGradedAttempt";
// ═══════════════════════════════════════════════════════════════════════

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";

export const saveGradedAttempt = onRequest(
  {
    timeoutSeconds: 60,
    memory: "512MiB",
    cors: true,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({status: "error", message: "Use POST."});
      return;
    }

    try {
      const data = req.body as Record<string, unknown>;

      if (!data.orgId || !data.publishedQuizId) {
        res.status(400).json({
          status: "error",
          message: "orgId and publishedQuizId are required.",
        });
        return;
      }

      const attemptId = (data.id as string) || uuidv4();

      await admin
        .firestore()
        .collection("orgs")
        .doc(data.orgId as string)
        .collection("gradedAttempts")
        .doc(attemptId)
        .set({
          ...data,
          id: attemptId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      res.status(200).json({
        status: "success",
        attemptId,
      });
    } catch (error) {
      const err = error as Error;
      console.error("saveGradedAttempt error:", err);
      res.status(500).json({
        status: "error",
        message: err.message || "Failed to save.",
      });
    }
  }
);
