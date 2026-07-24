import {onMessagePublished} from "firebase-functions/v2/pubsub";
import {defineSecret} from "firebase-functions/params";
// eslint-disable-next-line camelcase
import {google, forms_v1 as formsV1} from "googleapis";
import * as admin from "firebase-admin";
import {getLecturerAuthClient} from "./googleAuth";


const GOOGLE_CLIENT_ID = defineSecret("GOOGLE_CLIENT_ID");
const GOOGLE_CLIENT_SECRET = defineSecret("GOOGLE_CLIENT_SECRET");
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

const OBJECTIVE_TYPES = ["multipleChoice", "trueFalse"];

export const onFormResponse = onMessagePublished(
  {
    topic: "form-responses",
    region: "us-central1",
    secrets: [GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, OPENAI_API_KEY],
    retry: false,
  },
  async (event) => {
    // Pub/Sub attributes carry the formId
    const formId = event.data.message.attributes?.formId;
    if (!formId) return;

    // 1. Find the quiz this form belongs to (collectionGroup needs a
    //    composite index on formId — Firestore will print the create link
    //    on first run)
    const quizSnap = await admin.firestore()
      .collectionGroup("templates")
      .where("formId", "==", formId)
      .limit(1)
      .get();
    if (quizSnap.empty) {
      console.error(`No quiz found for formId ${formId}`);
      return;
    }
    const quizDoc = quizSnap.docs[0];
    const quiz = quizDoc.data();
    const orgRef = quizDoc.ref.parent.parent;
    if (!orgRef) {
      console.error(`Unexpected doc path (no org parent): ${quizDoc.ref.path}`);
      return; // inside onFormResponse's handler - just bail on this event
    }
    const orgId = orgRef.id;
    const createdBy = quiz.createdBy as string;
    const publishedQuizId = quizDoc.id;

    // 2. Lecturer's auth (same helper as createGoogleForm — move it to a
    //    shared file, e.g. functions/src/googleAuth.ts)
    const auth = await getLecturerAuthClient(orgId, createdBy);
    const forms = google.forms({version: "v1", auth});

    // 3. Form structure → map questionId -> title (answers are keyed by id)
    const formData = await forms.forms.get({formId});
    const qTitleById = new Map<string, string>();
    for (const item of formData.data.items ?? []) {
      const qid = item.questionItem?.question?.questionId;
      if (qid) qTitleById.set(qid, item.title ?? "");
    }

    // 4. All responses; process any not yet saved (idempotent by responseId)
    const respList = await forms.forms.responses.list({formId});
    const responses = respList.data.responses ?? [];

    for (const response of responses) {
      await processResponse({
        response, quiz, orgId, createdBy, publishedQuizId,
        formId, qTitleById,
      });
    }
  }
);

interface QuizQuestion {
type: string;
question: string;
options?: string[];
answerKey?: string;
points?: number;
}

async function processResponse(ctx: {
response: formsV1.Schema$FormResponse;
quiz: FirebaseFirestore.DocumentData;
orgId: string;
createdBy: string;
publishedQuizId: string;
formId: string;
qTitleById: Map<string, string>;
}) {
  const {response, quiz, orgId, createdBy, publishedQuizId, formId,
    qTitleById} = ctx;

  const responseId = response.responseId;
  if (!responseId) return;

  const attemptRef = admin.firestore()
    .collection("orgs").doc(orgId)
    .collection("gradedAttempts")
    .doc(responseId);

  if ((await attemptRef.get()).exists) return; // already graded

  // Flatten answers: question title -> {text, googleScore, googleCorrect}
  const byTitle = new Map<string, {
text: string; googleScore: number; googleCorrect: boolean | null;
}>();
  for (const [qid, ans] of Object.entries(response.answers ?? {})) {
    const title = qTitleById.get(qid) ?? qid;
    byTitle.set(title, {
      text: (ans.textAnswers?.answers ?? [])
        .map((a) => a.value ?? "").join(", "),
      googleScore: ans.grade?.score ?? 0,
      googleCorrect: ans.grade?.correct ?? null,
    });
  }

  const schoolEmail =
(byTitle.get("Your School Email")?.text ?? "").trim().toLowerCase();

  // Dedupe: first submission per email per quiz wins
  const dupSnap = await admin.firestore()
    .collection("orgs").doc(orgId)
    .collection("gradedAttempts")
    .where("publishedQuizId", "==", publishedQuizId)
    .where("schoolEmail", "==", schoolEmail)
    .limit(1)
    .get();
  const isDuplicate = !dupSnap.empty && schoolEmail !== "";

  // ── Hybrid grading ──────────────────────────────────────────────
  const questions = (quiz.items ?? quiz.questions ?? []) as QuizQuestion[];
  const questionResults: Record<string, unknown>[] = [];
  const subjectiveQueue: {q: QuizQuestion; answer: string; idx: number}[] = [];
  let objectiveScore = 0;
  let maxScore = 0;
  let hasSubjective = false;

  questions.forEach((q, idx) => {
    const points = q.points ?? 1;
    maxScore += points;
    const ans = byTitle.get(q.question);
    const studentAnswer = ans?.text ?? "";

    if (OBJECTIVE_TYPES.includes(q.type)) {
      // Rule 1: Google is authoritative for MC + true/false
      const earned = ans?.googleScore ?? 0;
      const isCorrect = ans?.googleCorrect ??
(studentAnswer === q.answerKey); // fallback if grade absent
      objectiveScore += earned;
      questionResults.push({
        question: q.question, studentAnswer,
        earnedPoints: earned, maxPoints: points,
        isCorrect, gradedBy: "google",
        feedback: isCorrect ?
          "Correct." :
          `Incorrect. Correct answer: ${q.answerKey ?? "see rubric"}.`,
      });
    } else {
      // Rule 2: shortAnswer + essay → AI
      hasSubjective = true;
      subjectiveQueue.push({q, answer: studentAnswer, idx});
      questionResults.push({
        question: q.question, studentAnswer,
        earnedPoints: 0, maxPoints: points,
        isCorrect: null, gradedBy: "ai", feedback: "",
      });
    }
  });

  // AI grading pass (skip for pure-objective quizzes — zero OpenAI cost)
  let aiScore = 0;
  let aiConfidence: number | null = null;
  let overallFeedback = "";
  // !isDuplicate is dedupe guard
  if (hasSubjective && !isDuplicate) {
    const ai = await gradeSubjectiveWithAI(subjectiveQueue);
    aiConfidence = ai.confidence;
    overallFeedback = ai.overallFeedback;
    for (const g of ai.perQuestion) {
      const slot = questionResults[g.idx] as Record<string, unknown>;
      slot.earnedPoints = g.earnedPoints;
      slot.isCorrect = g.earnedPoints >= (slot.maxPoints as number);
      slot.feedback = g.feedback;
      aiScore += g.earnedPoints;
    }
  }

  const score = objectiveScore + aiScore;

  // ── Save (Rule 3) — same shape your portal already reads ────────
  await attemptRef.set({
    id: responseId,
    orgId,
    createdBy, // teacher-scoped filtering
    publishedQuizId,
    quizTitle: quiz.title ?? "Untitled Quiz",
    formId,
    schoolEmail,
    submittedAt: response.lastSubmittedTime ?? new Date().toISOString(),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    gradedAt: new Date().toISOString(),
    questionResults,
    score,
    objectiveScore,
    aiScore,
    maxScore,
    percentage: maxScore > 0 ? Math.round((score / maxScore) * 100) : 0,
    gradingMethod: hasSubjective ? "hybrid" : "google",
    aiConfidence,
    feedback: overallFeedback,
    duplicate: isDuplicate, // Rule 4: later submissions flagged, not counted
    flagged: isDuplicate,
    status: isDuplicate ?
      "duplicate" :
      hasSubjective ? "needs_review" : "graded",
  });
}

// ── AI grader: port your existing OpenAI prompt into here ─────────
async function gradeSubjectiveWithAI(
  items: {q: QuizQuestion; answer: string; idx: number}[]
): Promise<{
perQuestion: {idx: number; earnedPoints: number; feedback: string}[];
confidence: number;
overallFeedback: string;
}> {
  const prompt = `You are grading student quiz answers. For each item return
earnedPoints (0..maxPoints, partial credit allowed for essays) and one-sentence
feedback. Respond ONLY with JSON:
{"perQuestion":[{"idx":0,"earnedPoints":1,"feedback":"..."}],
"confidence":0.95,"overallFeedback":"..."}

Items:
${JSON.stringify(items.map(({q, answer, idx}) => ({
    idx, type: q.type, question: q.question,
    expectedAnswer: q.answerKey ?? null,
    maxPoints: q.points ?? 1, studentAnswer: answer,
  })))}`;

  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${OPENAI_API_KEY.value()}`,
    },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      messages: [{role: "user", content: prompt}],
      response_format: {type: "json_object"},
    }),
  });
  const data = await res.json();
  return JSON.parse(data.choices[0].message.content);
}
