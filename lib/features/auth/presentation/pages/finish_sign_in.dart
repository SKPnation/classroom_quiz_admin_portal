import 'dart:html' as html;
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

      print("EMAIL RETRIEVED: $email");

      // If the email is missing (e.g. user opened link in a different browser)
      // you must prompt them to enter it manually.
      if (email == null) {
        Get.snackbar(
          "Email Required",
          "Please re-enter your email to finish signing in.",
        );
        // Get.offAllNamed(Routes.findSchoolRoute);

        print("Email is required: $email");
        // Send them back so they aren't stuck on the loading screen
        return;
      }

      try {
        // 3. The Handshake: Complete the sign-in
        final UserCredential userCredential = await auth.signInWithEmailLink(
          email: email,
          emailLink: currentUrl,
        );

        // 4. Grab your custom orgId parameter from the URL
        final uri = Uri.parse(html.window.location.href);

        // Try standard parameters
        String? orgId = uri.queryParameters['orgId'];

        // FALLBACK: If orgId is null, it's probably trapped after the '#'
        if (orgId == null && uri.hasFragment) {
          // uri.fragment usually looks like "/finish-sign-in?orgId=pvamu"
          final fragmentUri = Uri.parse(uri.fragment);
          orgId = fragmentUri.queryParameters['orgId'];
        }

        print("Signed in user: ${userCredential.user?.uid}");
        print("✅ Verified Organization ID: $orgId");

        // 5. Clear the email from storage and navigate to Dashboard
        html.window.localStorage.remove('emailForSignIn');

        Get.offAllNamed(Routes.rootRoute, arguments: {'orgId': orgId});
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
