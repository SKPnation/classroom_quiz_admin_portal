import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {google} from "googleapis";

const oauth2Client = new google.auth.OAuth2(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET,
  process.env.GOOGLE_REDIRECT_URI
);

export const googleOAuthCallback = onRequest(
  {
    region: "us-central1",
    secrets: [
      "GOOGLE_CLIENT_ID",
      "GOOGLE_CLIENT_SECRET",
      "GOOGLE_REDIRECT_URI",
    ],
  },
  async (req, res) => {
    try {
      const code = req.query.code as string | undefined;
      const state = req.query.state as string | undefined;

      if (!code || !state) {
        res.status(400).send("Missing authorization code or state.");
        return;
      }

      const decodedState = JSON.parse(
        Buffer.from(state, "base64").toString("utf8")
      );

      const uid = decodedState.uid;
      const orgId = decodedState.orgId;

      if (!uid || !orgId) {
        res.status(400).send("Invalid OAuth state.");
        return;
      }

      const {tokens} = await oauth2Client.getToken(code);
      oauth2Client.setCredentials(tokens);

      const oauth2 = google.oauth2({
        auth: oauth2Client,
        version: "v2",
      });

      const userInfo = await oauth2.userinfo.get();

      await admin
        .firestore()
        .collection("orgs")
        .doc(orgId)
        .collection("members")
        .doc(uid)
        .collection("integrations")
        .doc("google")
        .set(
          {
            id: "google",
            name: "Google",
            connected: true,
            googleEmail: userInfo.data.email || "",
            googleName: userInfo.data.name || "",
            accessToken: tokens.access_token || "",
            refreshToken: tokens.refresh_token || "",
            expiryDate: tokens.expiry_date || null,
            scopes: tokens.scope || "",
            connectedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true}
        );

      res.status(200).send(`
<html>
<body style="font-family: Arial; text-align: center; padding-top: 60px;">
<h2>Google connected successfully.</h2>
<p>You can close this tab and return to the quiz platform.</p>
</body>
</html>
`);
    } catch (e) {
      console.error("Google OAuth callback error:", e);
      res.status(500).send("Google connection failed.");
    }
  }
);
