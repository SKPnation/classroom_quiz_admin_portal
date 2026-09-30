// ═══════════════════════════════════════════════════════════════════════
// FILE: functions/src/quiz/gradeAndSave.ts
// ═══════════════════════════════════════════════════════════════════════
//
// Called by Apps Script immediately when a student submits a quiz.
// Grades answers using OpenAI then saves results to Firestore.
//
// SETUP:
//   Set Firebase env config:
//   firebase functions:config:set openai.api_key="YOUR_KEY"
//   Or add to functions/.env: OPENAI_API_KEY=your_key
//
// Export from index.ts:
//   export { gradeAndSave } from "./quiz/gradeAndSave";
// ═══════════════════════════════════════════════════════════════════════

import * as admin from "firebase-admin";
import {onRequest} from "firebase-functions/v2/https";
import OpenAI from "openai";
// import {defineString} from "firebase-functions/params";
import {v4 as uuidv4} from "uuid";
import {defineSecret} from "firebase-functions/params";

const openaiApiKey = defineSecret("OPENAI_API_KEY");

interface QuizAnswer {
question: string;
answer: string;
}

interface QuizQuestion {
question: string;
answerKey?: string;
answer?: string;
question_type?: string;
type?: string;
points?: number;
}

interface QuestionResult {
question: string;
studentAnswer: string;
earnedPoints: number;
maxPoints: number;
isCorrect: boolean;
feedback: string;
}

interface GradingResult {
aiConfidence: number;
status: string;
flagged: boolean;
feedback: string;
questionResults: QuestionResult[];
score: number;
maxScore: number;
percentage: number;
}

export const gradeAndSave = onRequest(
  {
    timeoutSeconds: 120,
    memory: "512MiB",
    cors: true,
    secrets: ["OPENAI_API_KEY"], // ← add this line
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({
        status: "error",
        message: "Use POST.",
      });
      return;
    }

    try {
      const data = req.body as {
orgId: string;
createdBy: string;
publishedQuizId: string;
quizTitle: string;
questions: QuizQuestion[];
schoolEmail: string;
answers: QuizAnswer[];
submittedAt: string;
formId: string;
spreadsheetId: string;
rowNumber: number;
};

      // ── Validate ──
      if (!data.orgId || !data.publishedQuizId) {
        res.status(400).json( {
          status: "error",
          message: "orgId and publishedQuizId are required.",
        });
        return;
      }

      if (!data.answers || data.answers.length === 0) {
        res.status(400).json( {
          status: "error",
          message: "No answers provided.",
        });
        return;
      }

      // ── Grade with OpenAI ──
      const gradingResult = await gradeWithOpenAI(
        data.questions,
        data.answers
      );

      // ── Save to Firestore ──
      const attemptId = uuidv4();

      await admin
        .firestore()
        .collection("orgs")
        .doc(data.orgId)
        .collection("gradedAttempts")
        .doc(attemptId)
        .set({
          id: attemptId,
          orgId: data.orgId,
          createdBy: data.createdBy,
          publishedQuizId: data.publishedQuizId,
          quizTitle: data.quizTitle,
          schoolEmail: data.schoolEmail,
          answers: data.answers,
          questions: data.questions,
          grading: gradingResult,
          score: gradingResult.score,
          maxScore: gradingResult.maxScore,
          percentage: gradingResult.percentage,
          feedback: gradingResult.feedback,
          aiConfidence: gradingResult.aiConfidence,
          status: gradingResult.status,
          flagged: gradingResult.flagged,
          questionResults: gradingResult.questionResults,
          submittedAt: data.submittedAt,
          gradedAt: new Date().toISOString(),
          gradingMethod: "ai",
          formId: data.formId,
          spreadsheetId: data.spreadsheetId,
          rowNumber: data.rowNumber,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      console.log(
        `Graded and saved attempt ${attemptId} for quiz ` +
`$ {data.publishedQuizId} — ${data.schoolEmail} scored ` +
`$ {gradingResult.score}/${gradingResult.maxScore}`
      );

      res.status(200).json( {
        status: "success",
        attemptId,
        score: gradingResult.score,
        maxScore: gradingResult.maxScore,
        percentage: gradingResult.percentage,
      });
    } catch (error) {
      const err = error as Error;
      console.error("gradeAndSave error:", err);
      res.status(500).json( {
        status: "error",
        message: err.message || "Grading failed.",
      });
    }
  }
);

// ── OpenAI grading ──

async function gradeWithOpenAI(
  questions: QuizQuestion[],
  answers: QuizAnswer[]
): Promise<GradingResult> {
  const openai = new OpenAI({
    apiKey: openaiApiKey.value(),
  });

  const prompt =
"You are an academic grading assistant.\n\n" +

"Grade each student's answer using the provided quiz question, " +
"answer key, and point value.\n\n" +

"IMPORTANT RULES:\n" +
"- Grade every question individually.\n" +
"- Use the provided answerKey/answer as the expected answer.\n" +
"- Use the question's points value as maxPoints.\n" +
"- earnedPoints must never exceed maxPoints.\n" +
"- For objective questions, compare the student's answer " +
"with the answer key.\n" +
"- For essay or short-answer questions, evaluate the response" +
"fairly based on correctness and relevance.\n" +
"- Do NOT calculate the overall score.\n" +
"- Do NOT calculate maxScore.\n" +
"- Do NOT calculate percentage.\n" +
"- aiConfidence must be a decimal number from 0.0 to 1.0.\n" +
"- aiConfidence represents confidence in the grading decision.\n" +
"- Set flagged to true when the answer requires lecturer attention.\n" +
"- Set status to needs_review when grading confidence is low.\n\n" +

"Return JSON in exactly this structure:\n" +
"{\n" +
"  \"aiConfidence\": 0.95,\n" +
"  \"status\": \"graded\",\n" +
"  \"flagged\": false,\n" +
"  \"feedback\": \"Overall feedback for the student.\",\n" +
"  \"questionResults\": [\n" +
"    {\n" +
"      \"question\": \"Question text\",\n" +
"      \"studentAnswer\": \"Student answer\",\n" +
"      \"earnedPoints\": 1,\n" +
"      \"maxPoints\": 1,\n" +
"      \"isCorrect\": true,\n" +
"      \"feedback\": \"Feedback for this question\"\n" +
"    }\n" +
"  ]\n" +
"}\n\n" +

"QUIZ QUESTIONS AND ANSWER KEYS:\n" +
JSON.stringify(questions, null, 2) +

"\n\nSTUDENT ANSWERS:\n" +
JSON.stringify(answers, null, 2);

  const completion = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [
      {
        role: "user",
        content: prompt,
      },
    ],
    temperature: 0.2,
    response_format: {
      type: "json_object",
    },
  });

  const content = completion.choices[0]?.message?.content;

  if (!content) {
    throw new Error("No grading response returned from OpenAI.");
  }

  const grading = JSON.parse(content);

  if (
    !grading.questionResults ||
!Array.isArray(grading.questionResults)
  ) {
    throw new Error(
      "Invalid grading response: questionResults is missing."
    );
  }

  // ─────────────────────────────────────────────
  // Calculate score ourselves instead of trusting AI
  // ─────────────────────────────────────────────

  const score = grading.questionResults.reduce(
    (sum: number, q: QuestionResult) => {
      const earned = Number(q.earnedPoints || 0);
      const maximum = Number(q.maxPoints || 0);

      // Prevent AI from awarding more than max points
      return sum + Math.min(
        Math.max(earned, 0),
        Math.max(maximum, 0)
      );
    },
    0
  );

  const maxScore = grading.questionResults.reduce(
    (sum: number, q: QuestionResult) => {
      return sum + Math.max(Number(q.maxPoints || 0), 0);
    },
    0
  );

  const percentage =
maxScore > 0 ?
  Math.round((score / maxScore) * 100) :
  0;

  // ─────────────────────────────────────────────
  // Normalize AI confidence
  // ─────────────────────────────────────────────

  let aiConfidence = Number(grading.aiConfidence);

  if (!Number.isFinite(aiConfidence)) {
    aiConfidence = 0;
  }

  // In case AI accidentally returns 95 instead of 0.95
  if (aiConfidence > 1 && aiConfidence <= 100) {
    aiConfidence = aiConfidence / 100;
  }

  aiConfidence = Math.max(
    0,
    Math.min(1, aiConfidence)
  );

  // ─────────────────────────────────────────────
  // Determine status ourselves
  // ─────────────────────────────────────────────

  let status = "graded";

  if (grading.flagged === true) {
    status = "flagged";
  } else if (aiConfidence < 0.7) {
    status = "needs_review";
  }

  return {
    aiConfidence,
    status,
    flagged: grading.flagged === true,
    feedback: grading.feedback || "",
    questionResults: grading.questionResults,
    score,
    maxScore,
    percentage,
  };
}
