import {onRequest} from "firebase-functions/v2/https";

export const exportToGoogleForms = onRequest(
  {region: "us-central1"},
  async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({
        success: false,
        error: "Method not allowed",
      });
      return;
    }

    try {
      const body = req.body;

      console.log("Received payload:", JSON.stringify(body, null, 2));

      res.status(200).json({
        success: true,
        message: "Export started successfully",
        received: body,
      });
    } catch (e) {
      console.error("Export error:", e);

      res.status(500).json({
        success: false,
        error: e instanceof Error ? e.message : String(e),
      });
    }
  }
);
