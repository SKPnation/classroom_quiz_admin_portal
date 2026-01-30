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
    // Start the verification process immediately
    _completeSignIn();
  }

  Future<void> _completeSignIn({String? manualEmail}) async {
    final auth = FirebaseAuth.instance;
    final currentUrl = html.window.location.href;

    // 1. Check if the URL is a valid Firebase sign-in link
    if (auth.isSignInWithEmailLink(currentUrl)) {

      // 2. Retrieve email: Priority to manual input, then local storage
      String? email = manualEmail ?? html.window.localStorage['emailForSignIn'];

      print("DEBUG: Attempting sign-in with email: $email");

      // 3. Handle missing email (Common when switching browsers/apps)
      if (email == null || email.isEmpty) {
        print("EMAIL MISSING: Prompting user for manual input.");
        _showEmailManualDialog();
        return;
      }

      try {
        // 4. The Firebase Handshake
        final UserCredential userCredential = await auth.signInWithEmailLink(
          email: email,
          emailLink: currentUrl,
        );

        // 5. Robust parsing for orgId (Handles Path and Hash strategies)
        final uri = Uri.parse(currentUrl);
        String? orgId = uri.queryParameters['orgId'];

        // Fallback if orgId is trapped in the hash fragment
        if (orgId == null && uri.hasFragment) {
          final fragmentUri = Uri.parse('https://dummy.com${uri.fragment}');
          orgId = fragmentUri.queryParameters['orgId'];
        }

        print("✅ Signed in user: ${userCredential.user?.uid}");
        print("✅ Verified Organization ID: $orgId");

        // 6. Cleanup storage and navigate to the root/home route
        html.window.localStorage.remove('emailForSignIn');

        // Pass the orgId as an argument to your next page
        Get.offAllNamed(Routes.rootRoute, arguments: {'orgId': orgId});

      } catch (e) {
        print("❌ Error during sign-in: $e");
        Get.snackbar(
          "Verification Failed",
          "The link may have expired or the email is incorrect.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    }
  }

  // Helper to show dialog if local storage is empty
  void _showEmailManualDialog() {
    final TextEditingController emailController = TextEditingController();

    Get.defaultDialog(
      title: "Confirm Your Email",
      barrierDismissible: false, // Force them to enter email to proceed
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            const Text(
              "We couldn't find your session. Please enter the email where you received the link:",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          final input = emailController.text.trim();
          if (GetUtils.isEmail(input)) {
            Get.back(); // Close the dialog
            _completeSignIn(manualEmail: input);
          } else {
            Get.snackbar("Invalid Email", "Please enter a valid email address.");
          }
        },
        child: const Text("Verify & Login"),
      ),
    );
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
            Text(
              "Verifying your link, please wait...",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}