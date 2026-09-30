import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {google, forms_v1 as formsV1} from "googleapis";
import * as admin from "firebase-admin";
import {getLecturerAuthClient} from "./googleAuth";

const GOOGLE_CLIENT_ID = defineSecret("GOOGLE_CLIENT_ID");
const GOOGLE_CLIENT_SECRET = defineSecret("GOOGLE_CLIENT_SECRET");

const TOPIC = "projects/schoolquizapp-8b07d/topics/form-responses";

interface QuizQuestion {
type: string;
question: string;
options?: string[];
correctOptionIndexes?: number[];
answerKey?: string;
points?: number;
}

export const createGoogleForm = onCall(
  {region: "us-central1", secrets: [GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET]},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be logged in.");
    }

    const {
      orgId,
      title,
      description,
      questions,
      publishedQuizId,
    } = request.data;
    if (!orgId || !title) {
      throw new HttpsError("invalid-argument", "Missing orgId or title.");
    }

    const createdBy = request.auth.uid;
    const auth = await getLecturerAuthClient(orgId, createdBy);
    const forms = google.forms({version: "v1", auth});

    // 1. Create the form (API only allows title at creation)
    const created = await forms.forms.create({
      requestBody: {info: {title, documentTitle: title}},
    });
    const formId = created.data.formId;
    if (!formId) {
      throw new HttpsError(
        "internal",
        "Google Forms API did not return a form ID."
      );
    }

    // 2. Build batchUpdate: quiz mode, description, then items
    const requests: formsV1.Schema$Request[] = [
      {
        updateSettings: {
          settings: {quizSettings: {isQuiz: true}},
          updateMask: "quizSettings.isQuiz",
        },
      },
      {
        updateFormInfo: {
          info: {
            description: (description || "") +
            "\n\n📝 Note: Written answers are graded by your instructor's " +
"grading system after submission. The score shown when you " +
"submit reflects only the multiple-choice and true/false questions - your " +
"final grade may be higher.",
          },
          updateMask: "description",
        },
      },
      // Student info section
      {
        createItem: {
          item: {
            title: "Your School Email",
            questionItem: {
              question: {
                required: true,
                textQuestion: {
                  paragraph: false,
                },
              },
            },
          },
          location: {index: 0},
        },
      },
    ];

    (questions as QuizQuestion[] || []).forEach((q, i) => {
      const index = i + 1; // after the email item
      const points = q.points ?? 1;

      switch (q.type) {
      case "shortAnswer":
        requests.push({
          createItem: {
            item: {
              title: q.question,
              questionItem: {
                question: {
                  required: true,
                  grading: {
                    pointValue: points,
                  }, // graded later by your AI
                  textQuestion: {paragraph: false},
                },
              },
            },
            location: {index},
          },
        });
        break;

      case "essay":
        requests.push({
          createItem: {
            item: {
              title: q.question,
              questionItem: {
                question: {
                  required: true,
                  grading: {pointValue: points}, // graded later by your AI
                  textQuestion: {paragraph: true},
                },
              },
            },
            location: {index},
          },
        });
        break;

      case "multipleChoice":
      case "trueFalse": {
        const options =
q.options && q.options.length > 0 ? q.options : ["True", "False"];

        // Correct answers: union of index-based and answerKey-based
        const correctSet = new Set<string>(
          (q.correctOptionIndexes ?? [])
            .map((i: number) => options[i])
            .filter(Boolean)
        );
        if (q.answerKey) correctSet.add(q.answerKey);

        requests.push({
          createItem: {
            item: {
              title: q.question,
              questionItem: {
                question: {
                  required: true,
                  grading: {
                    pointValue: points,
                    correctAnswers: {
                      answers: [...correctSet].map((value) => ({value})),
                    },
                  },
                  choiceQuestion: {
                    type: "RADIO",
                    options: options.map((o) => ({value: o})),
                  },
                },
              },
            },
            location: {index},
          },
        });
        break;
      }
      }
    });

    await forms.forms.batchUpdate({formId, requestBody: {requests}});

    let watchId: string | null = null;
    let watchExpireTime: string | null = null;
    try {
      const watch = await forms.forms.watches.create({
        formId,
        requestBody: {
          watch: {
            target: {topic: {topicName: TOPIC}},
            eventType: "RESPONSES",
          },
        },
      });
      watchId = watch.data.id ?? null;
      watchExpireTime = watch.data.expireTime ?? null;
    } catch (e) {
      console.error(`Watch creation failed for form ${formId}:`, e);
      // don't rethrow — the lecturer still gets their form
    }

    // 3. Fetch final URLs
    const finalForm = await forms.forms.get({formId});

    // 4. Persist on the quiz doc (server-side, replaces updateQuizFormUrl)
    if (publishedQuizId) {
      await admin.firestore()
        .doc(`orgs/${orgId}/templates/${publishedQuizId}`)
        .set({
          createdBy,
          formId,
          formUrl: finalForm.data.responderUri,
          formEditUrl: `https://docs.google.com/forms/d/${formId}/edit`,
          watchId,
          watchExpireTime,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, {merge: true});
    }

    return {
      status: "success",
      formId,
      publishedUrl: finalForm.data.responderUri, // shareable student link
      formUrl: `https://docs.google.com/forms/d/${formId}/edit`,
    };
  }
);
