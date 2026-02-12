import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/features/auth/domain/repos/auth_repo.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/data/models/school_model.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/data/repos/find_school_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/presentation/controllers/find_school_controller.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/repos/user_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/controllers/settings_controller.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:html' as html;

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
    required SchoolModel school,
  }) async {
    final result = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user!;

    //save user info to local storage
    await saveUserToStorage(user);
    // //Save org  info to local storage
    saveSchoolToStorage(school);

    Get.offNamed(Routes.rootRoute);

    result.user;
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
    final createdAt = user.metadata.creationTime;
    print("organisation id: ${findSchoolController.selectedOrgId.value}");

    UserModel? userModel = await userRepo.getUserProfile();
    if (userModel?.toFirestore() != null) {
      //Cache user info

      var data = {
        ...?userModel?.toCache(),
        "orgId": findSchoolController.selectedOrgId.value,
      };
      storage.write(GetStoreKeys.userKey, data);

      //Update profile completion percentage
      settingsController.updateCompletion(userModel!.toCache());
    } else {
      UserModel userModel = UserModel(
        uid: user.uid,
        email: user.email!,
        role: AppStrings.lecturer,
        orgId: findSchoolController.selectedOrgId.value,
        profileCompleted: false,
        isActive: true,
        createdAt: createdAt!,
        updatedAt: DateTime.now(),
      );

      //Cache user info
      storage.write(GetStoreKeys.userKey, userModel.toCache());

      //Update profile completion percentage
      settingsController.updateCompletion(userModel.toCache());
    }
  }

  @override
  void saveSchoolToStorage(SchoolModel school) {
    storage.write(GetStoreKeys.orgKey, school.toJson());
  }

  @override
  void signOut() {
    try {
      // Sign out from Firebase Auth
      auth.signOut();

      // Clear cached user and organization data
      storage.erase();

      // Navigate to the login screen
      Get.offAllNamed(Routes.findSchoolRoute);

      print("User signed out successfully");
    } catch (e) {
      print("Error during sign out: $e");
    }
  }
}
