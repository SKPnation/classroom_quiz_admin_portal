import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FinishSignInPage extends StatefulWidget {
  const FinishSignInPage({super.key});

  @override
  State<FinishSignInPage> createState() => _FinishSignInPageState();
}

class _FinishSignInPageState extends State<FinishSignInPage> {
  @override
  void initState() {
    super.initState();
    _completeSignIn();
  }

  Future<void> _completeSignIn() async {
    final auth = FirebaseAuth.instance;
    final currentUrl = html.window.location.href;

    // 1. Check if the URL is actually a sign-in link
    if (auth.isSignInWithEmailLink(currentUrl)) {

      // 2. Retrieve the email we saved earlier in local storage
      String? email = html.window.localStorage['emailForSignIn'];

      // If the email is missing (e.g. user opened link in a different browser)
      // you must prompt them to enter it manually.
      if (email == null) {
        // Show a dialog asking for email or redirect to login
        print("Email not found in local storage. Prompting user...");
        return;
      }

      try {
        // 3. The Handshake: Complete the sign-in
        final UserCredential userCredential = await auth.signInWithEmailLink(
          email: email,
          emailLink: currentUrl,
        );

        // 4. Grab your custom orgId parameter from the URL
        final uri = Uri.parse(currentUrl);
        String? orgId = uri.queryParameters['orgId'];

        print("Signed in user: ${userCredential.user?.uid}");
        print("Organization ID: $orgId");

        // 5. Clear the email from storage and navigate to Dashboard
        html.window.localStorage.remove('emailForSignIn');

        // Example: Navigator.of(context).pushReplacementNamed('/dashboard');

      } catch (e) {
        print("Error finishing sign-in: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Verifying your link, please wait..."),
          ],
        ),
      ),
    );
  }
}