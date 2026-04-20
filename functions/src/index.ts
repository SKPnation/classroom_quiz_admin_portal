import {onRequest} from "firebase-functions/v2/https";
import {google} from "googleapis";

export const exportToGoogleForms = onRequest(
  {region: "us-central1"},
  async (req, res) => {
    // 1. Mandatory Headers for Flutter Web/Mobile
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    try {
      // 2. Setup Google Auth
      const auth = new google.auth.GoogleAuth({
        scopes: ["https://www.googleapis.com/auth/forms.body"],
      });

      // Safe debug log
      const projectId = await auth.getProjectId();
      console.log(`Executing request for Project ID: ${projectId}`);

      const forms = google.forms({version: "v1", auth});

      // 3. The "Bare Minimum" Action: Create a Form with just a Title
      const createResponse = await forms.forms.create({
        requestBody: {
          info: {
            title: "Short Test Title",
          },
        },
      });
      // 4. Return the ID
      res.status(200).json({
        success: true,
        formId: createResponse.data.formId,
        message: "Auth and Create are working!",
      });
    } catch (e: unknown) {
      console.error("Test Error:", e);

      let errorMessage = "An unknown error occurred";
      let errorDetails: unknown = "No extra details";

      if (e instanceof Error) {
        errorMessage = e.message;

        // Cast to a structural object to access 'response' safely without 'any'
        const err = e as { response?: { data?: unknown } };
        if (err.response?.data) {
          errorDetails = err.response.data;
        }
      }

      res.status(500).json({
        success: false,
        error: errorMessage,
        details: errorDetails,
      });
    }
  }
);
