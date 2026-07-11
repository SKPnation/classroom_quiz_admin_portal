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
        .set( {
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
  const openai = new OpenAI({apiKey: openaiApiKey.value()});

  const prompt = "You are an academic grading assistant.\n\n" +
"Grade the student's answers fairly.\n\n" +
"Return raw JSON only.\n" +
"Do not use markdown.\n" +
"Do not wrap the response in backticks.\n\n" +
"IMPORTANT:\n" +
"* Do NOT calculate overall score.\n" +
"* Do NOT calculate maxScore.\n" +
"* Do NOT calculate percentage.\n" +
"* Grade each question individually.\n" +
"* earnedPoints must never exceed maxPoints.\n\n" +
"Return JSON in this format:\n\n" +
"{\n" +
"  \"aiConfidence\": number,\n" +
"  \"status\": \"graded\" | \"needs_review\" | \"flagged\",\n" +
"  \"flagged\": boolean,\n" +
"  \"feedback\": string,\n" +
"  \"questionResults\": [\n" +
"    {\n" +
"      \"question\": string,\n" +
"      \"studentAnswer\": string,\n" +
"      \"earnedPoints\": number,\n" +
"      \"maxPoints\": number,\n" +
"      \"isCorrect\": boolean,\n" +
"      \"feedback\": string\n" +
"    }\n" +
"  ]\n" +
"}\n\n" +
"Student answers:\n" +
JSON.stringify(answers, null, 2);

  const completion = await openai.chat.completions.create( {
    model: "gpt-4o-mini",
    messages: [{role: "user", content: prompt}],
    temperature: 0.2,
    response_format: {type: "json_object"},
  });

  const content = completion.choices[0]?.message?.content;
  if (!content) throw new Error("No response from OpenAI.");

  const grading = JSON.parse(content) as GradingResult;

  // Calculate totals
  const score = grading.questionResults.reduce(
    (sum, q) => sum + Number(q.earnedPoints || 0),
    0
  );
  const maxScore = grading.questionResults.reduce(
    (sum, q) => sum + Number(q.maxPoints || 0),
    0
  );
  const percentage = maxScore > 0 ? Math.round((score / maxScore) * 100) : 0;
  const aiConfidence = Number(grading.aiConfidence || 0);

  let status = "graded";
  if (grading.flagged === true) {
    status = "flagged";
  } else if (aiConfidence <= 70) {
    status = "needs_review";
  }

  return {
    ...grading,
    aiConfidence,
    status,
    score,
    maxScore,
    percentage,
  };
}
