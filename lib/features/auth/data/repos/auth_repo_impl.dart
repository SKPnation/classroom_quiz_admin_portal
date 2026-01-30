import 'package:classroom_quiz_admin_portal/features/auth/domain/repos/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:html' as html; // To save email to local storage

class AuthRepoImpl extends AuthRepo {
  final auth = FirebaseAuth.instance;

  @override
  Future<void> sendSignInLink({required String email, required String orgId}) async {
    final auth = FirebaseAuth.instance;

    // 1. Define the settings (Web-only)
    final actionCodeSettings = ActionCodeSettings(
      // We pass orgId in the URL so it's available when the user returns
      url: 'https://lecturer-quiz-portal.netlify.app/#/finish-sign-in?orgId=$orgId',
      handleCodeInApp: true,
    );

    try {
      // 2. IMPORTANT: Save the email locally
      // This allows the app to complete sign-in automatically when the user clicks the link
      html.window.localStorage['emailForSignIn'] = email;

      // 3. Send the link
      await auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      print("Sign-in link sent to $email");
    } catch (e) {
      print("Error sending email link: $e");
      rethrow;
    }
  }
}
