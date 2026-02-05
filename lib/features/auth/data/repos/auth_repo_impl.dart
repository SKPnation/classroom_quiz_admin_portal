import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/features/auth/domain/repos/auth_repo.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/controllers/settings_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:html' as html;

import '../../../../main.dart'; // To save email to local storage

class AuthRepoImpl extends AuthRepo {
  final auth = FirebaseAuth.instance;

  @override
  Future<void> sendSignInLink({
    required String email,
    required String orgId,
  }) async {
    // 1. Define the settings (Web-only)
    final actionCodeSettings = ActionCodeSettings(
      // We pass orgId in the URL so it's available when the user returns
      url:
          'https://lecturer-quiz-portal.netlify.app/finish-sign-in?orgId=$orgId',
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

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final result = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user!;

    //save user info to local storage
    saveUserToStorage(user);

    Get.offNamed(Routes.rootRoute);

    result.user;
  }

  @override
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final result = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user!;

    //save user info to local storage
    saveUserToStorage(user);

    result.user;
  }

  @override
  void saveUserToStorage(User user) {
    final settingsController = SettingsController.instance;
    final createdAt = user.metadata.creationTime;

    // Create a simple Map of the data you actually need
    Map<String, dynamic> userData = {
      'uid': user.uid,
      'email': user.email,
      'avatarUrl': user.photoURL,
      'fullName': user.displayName,
      'isEmailVerified': user.emailVerified,
      'createdAt': createdAt?.toIso8601String(),
    };

    storage.write(GetStoreKeys.userKey, userData);

    settingsController.updateCompletion(userData);

    print(settingsController.percentageCompletion.value);
  }
}
