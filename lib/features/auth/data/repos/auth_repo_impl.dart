import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_snackbar.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/features/auth/domain/repos/auth_repo.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/data/models/school_model.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/presentation/controllers/find_school_controller.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/repos/user_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/controllers/settings_controller.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

class AuthRepoImpl extends AuthRepo {
  final auth = FirebaseAuth.instance;
  UserRepoImpl userRepo = UserRepoImpl();

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

      web.window.localStorage.setItem('token', '123');
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
    required SchoolModel school,
    required Function(String) onError,
  }) async {
    const defaultPassword = "Asseska@SecureDefault2025!";

    final emailDomain = email.trim().toLowerCase().split('@').last;
    final allowedDomains = school.allowedDomains
        .map((d) => d.trim().toLowerCase())
        .toList();

    final isDomainAllowed = allowedDomains.any(
          (domain) => emailDomain == domain || emailDomain.endsWith('.$domain'),
    );

    if (!isDomainAllowed) {
      onError('Please use your ${school.name} institution email address.');
      return;
    }

    try {
      UserCredential result;

      try {
        result = await auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: defaultPassword,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          result = await auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: defaultPassword,
          );
        } else {
          rethrow;
        }
      }

      final user = result.user!;
      await saveUserToStorage(user);
      saveSchoolToStorage(school);
      Get.offNamed(Routes.rootRoute);

    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'invalid-email'             => 'Please enter a valid email address.',
        'user-disabled'             => 'This account has been disabled.',
        'invalid-credential'        => 'Sign in failed. Please try again.',
        'invalid-login-credentials' => 'Sign in failed. Please try again.',
        'network-request-failed'    => 'No internet connection.',
        'too-many-requests'         => 'Too many attempts. Try again later.',
        _                           => 'Sign in failed. Please try again.',
      };
      onError(message);
    } catch (e) {
      onError('Something went wrong. Please try again.');
    }
  }

  // @override
  // Future<void> registerWithEmailPassword({
  //   required String email,
  //   required String password,
  // }) async {
  //   final result = await auth.createUserWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   );
  //   final user = result.user!;
  //
  //   //save user info to local storage
  //   saveUserToStorage(user);
  //
  //   result.user;
  // }

  @override
  Future saveUserToStorage(User user) async {
    final settingsController = SettingsController.instance;
    final findSchoolController = FindSchoolController.instance;

    final orgId = findSchoolController.selectedOrgId.value;
    final createdAt = user.metadata.creationTime ?? DateTime.now();

    UserModel? userModel = await userRepo.getUserProfile();

    if (userModel == null) {
      userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        role: AppStrings.lecturer,
        orgId: orgId,
        profileCompleted: false,
        isActive: true,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

      await userRepo.createUserProfile(userModel);
    }

    final data = {...userModel.toCache(), "orgId": orgId};

    storage.write(GetStoreKeys.userKey, data);
    settingsController.updateCompletion(data);
  }

  @override
  void saveSchoolToStorage(SchoolModel school) {
    storage.write(GetStoreKeys.orgKey, school.toJson());
  }

  @override
  void signOut() {
    try {
      auth.signOut();
      storage.erase();
      SettingsController.instance.resetVariables();

      // Defer navigation until after the current build frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(Routes.findSchoolRoute);
      });

      print("User signed out successfully");
    } catch (e) {
      print("Error during sign out: $e");
    }
  }
}
