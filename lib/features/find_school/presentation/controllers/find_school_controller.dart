import 'dart:async';

import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/auth/data/repos/auth_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/auth/presentation/widgets/email_passed_login_dialog.dart';
import 'package:classroom_quiz_admin_portal/features/auth/presentation/widgets/passwordless_login_dialog.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/data/models/school_model.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/data/repos/find_school_repo_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindSchoolController extends GetxController {
  static FindSchoolController get instance => Get.find();

  final emailTEC = TextEditingController();
  final passwordTEC = TextEditingController();

  final isPasswordHidden = true.obs;
  final typedEmail = ''.obs; // This will track the email in real-time
  final loading = false.obs;
  final errorMessage = ''.obs;
  final dialogErrorMessage = ''.obs;
  final schools = <SchoolModel>[].obs;

  final FindSchoolRepoImpl findSchoolRepo;
  final AuthRepoImpl authRepo;

  FindSchoolController({required this.authRepo, required this.findSchoolRepo});

  Timer? debounce;
  String latestQuery = '';

  // Email-link flow states
  final linkSent = false.obs;
  final emailVerified = false.obs;
  final selectedOrgId = ''.obs;

  // 🕒 Timer & Pivot States
  Timer? countdownTimer;
  final secondsRemaining = 60.obs;
  final showPivotOption = false.obs;
  final isGmailAllowed = false.obs; // For testing/bypass

  @override
  void onInit() {
    super.onInit();
    search(query: '');
  }

  @override
  void onClose() {
    debounce?.cancel();
    countdownTimer?.cancel(); // Clean up timer
    emailTEC.dispose();
    passwordTEC.dispose();
    super.onClose();
  }

  // --- Timer Logic ---
  void _startCountdown() {
    showPivotOption.value = false;
    secondsRemaining.value = 60;
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        showPivotOption.value = true;
        timer.cancel();
      }
    });
  }

  void onSearchChanged(String value) {
    latestQuery = value;
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 350), () {
      search(query: latestQuery);
    });
  }

  Future<void> search({String? query}) async {
    final q = (query ?? latestQuery).trim();
    errorMessage.value = '';

    try {
      loading.value = true;
      final results = await findSchoolRepo.getSchoolsByName(query: q);
      schools.assignAll(results);
    } catch (e, st) {
      debugPrint('FindSchool error: $e');
      debugPrintStack(stackTrace: st);
      errorMessage.value = 'Failed to load schools. Try again.';
    } finally {
      loading.value = false;
    }
  }

  Future<void> submitCode(String code) async {
    final c = code.trim();
    if (c.isEmpty) {
      errorMessage.value = 'Please enter a school code.';
      return;
    }

    errorMessage.value = '';
    try {
      loading.value = true;
      final school = await findSchoolRepo.getSchoolByCode(code: c);

      if (school == null) {
        errorMessage.value = 'School code not found.';
        return;
      }

      selectSchool(school);
    } catch (_) {
      errorMessage.value = 'Could not verify code. Try again.';
    } finally {
      loading.value = false;
    }
  }

  void selectSchool(SchoolModel school) {
    final domain = (school.allowedDomains.isNotEmpty)
        ? school.allowedDomains.first.trim().toLowerCase()
        : '';

    if (domain.isEmpty) {
      Get.snackbar('Missing domain', 'This school has no allowedDomains set.');
      return;
    }

    // Reset all states for the new dialog
    resetAllVariables(keepSchools: true);
    selectedOrgId.value = school.id;

    ///Login with email and password
    openEmailPasswordLogin(school);

    ///Passwordless login dialog
    // Get.dialog(
    //   PasswordLessLoginDialog(
    //     school: school,
    //     controller: this,
    //   ),
    //   barrierDismissible: false,
    // );
  }

  void openEmailPasswordLogin(SchoolModel school) {
    // Clear previous inputs if necessary
    emailTEC.clear();
    passwordTEC.clear();
    dialogErrorMessage.value = '';

    Get.dialog(
      EmailPasswordLoginDialog(controller: this, school: school),
      barrierDismissible: true,
    );
  }

  Future<void> sendVerificationLink({required String domain}) async {

    final email = emailTEC.text.trim().toLowerCase();
    dialogErrorMessage.value = ''; // Reset error on new attempt

    //reset pivot on a fresh attempt
    showPivotOption.value = false;

    // Check validation based on current mode
    if (!isGmailAllowed.value && !_isValidSchoolEmail(email, domain)) {
      Get.snackbar(
        'Invalid email',
        'Use your school email ending with @$domain',
      );
      return;
    }

    try {
      loading.value = true;
      await authRepo.sendSignInLink(email: email, orgId: selectedOrgId.value);

      linkSent.value = true;
      _startCountdown(); // Start the 60 timer!
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code}');

      if (e.code == 'quota-exceeded') {
        //show pivot UI
        showPivotOption.value = true;

        dialogErrorMessage.value =
            "Daily email limit reached for this project.";
        // Automatically switch to personal mode so they can at least change the input
        isGmailAllowed.value = true;
        linkSent.value = false;
      } else {
        dialogErrorMessage.value =
            e.message ?? "An error occurred. Please try again.";
      }
    } catch (e) {
      dialogErrorMessage.value = "Could not send link. Check your connection.";
    } finally {
      loading.value = false;
    }
  }

  Future<void> signInWithEmailPassword() async {
    await authRepo.signInWithEmailPassword(
      email: emailTEC.text,
      password: passwordTEC.text,
    );

    print(emailTEC.text);
    print(passwordTEC.text);
  }

  bool _isValidSchoolEmail(String email, String domain) {
    return RegExp(r'^[^@]+@' + RegExp.escape(domain) + r'$').hasMatch(email);
  }

  void resetAllVariables({bool keepSchools = false}) {
    countdownTimer?.cancel();
    emailTEC.clear();
    passwordTEC.clear();
    loading.value = false;
    errorMessage.value = '';
    latestQuery = '';
    linkSent.value = false;
    emailVerified.value = false;
    selectedOrgId.value = '';
    showPivotOption.value = false;
    isGmailAllowed.value = false;
    dialogErrorMessage.value = '';
    secondsRemaining.value = 60;

    if (!keepSchools) schools.clear();
  }
}
