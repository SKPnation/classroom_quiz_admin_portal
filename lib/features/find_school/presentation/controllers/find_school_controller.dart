import 'dart:async';

import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/auth/data/repos/auth_repo_impl.dart';
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
    secondsRemaining.value = 30;
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

    Get.defaultDialog(
      title: 'Continue with ${school.name}',
      barrierDismissible: false,
      content: Obx(
        () => SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailTEC,
                enabled: !linkSent.value,
                // Disable while waiting for link
                decoration: InputDecoration(
                  labelText: isGmailAllowed.value
                      ? 'Enter personal email'
                      : 'School email (@$domain)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => typedEmail.value = val,
              ),
              if (dialogErrorMessage.value.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dialogErrorMessage.value,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),

              if (!linkSent.value)
                Text(
                  'We will send a verification link to your email.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),

              if (linkSent.value && !emailVerified.value) ...[
                const Icon(Icons.mark_email_read_outlined, color: Colors.green, size: 40),
                const SizedBox(height: 8),
                Text('Link sent! Check your inbox.',
                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                if (!showPivotOption.value)
                  Text('Resend available in ${secondsRemaining.value}s',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],

              if (showPivotOption.value && !emailVerified.value) ...[
                const Divider(),
                const Text("Haven't received the link?", style: TextStyle(fontSize: 12)),
                TextButton(
                  onPressed: () {
                    isGmailAllowed.value = true;
                    linkSent.value = false;
                    emailTEC.clear();
                    typedEmail.value = '';
                    dialogErrorMessage.value = '';
                  },
                  child: const Text('Try a personal Gmail instead'),
                ),
              ],

              if (emailVerified.value) ...[
                const SizedBox(height: 12),
                const Text(
                  "✅ Email Verified!",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordTEC,
                  decoration: const InputDecoration(
                    labelText: 'Create password (min 6 chars)',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ],
          ),
        ),
      ),
      confirm: Obx(() {
        final email = typedEmail.value.trim().toLowerCase();

        final isEmailValid = isGmailAllowed.value
            ? GetUtils.isEmail(email)
            : _isValidSchoolEmail(email, domain);

        final canSend = !loading.value && !linkSent.value && isEmailValid;
        final canFinish =
            !loading.value &&
            emailVerified.value &&
            passwordTEC.text.trim().length >= 6;

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: canSend || canFinish ? Colors.green : Colors.grey,
          ),
          onPressed: () async {
            if (canSend) {
              await sendVerificationLink(domain: domain);
            } else if (canFinish) {
              Get.back();
              Get.toNamed(Routes.rootRoute);
              resetAllVariables(keepSchools: true);
            }
          },
          child: loading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  emailVerified.value
                      ? 'Continue'
                      : (linkSent.value ? 'Waiting...' : 'Send link'),
                  style: TextStyle(color: Colors.white),
                ),
        );
      }),
      cancel: TextButton(
        onPressed: () {
          resetAllVariables(keepSchools: true);
          Get.back();
        },
        child: const Text('Cancel'),
      ),
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
      _startCountdown(); // Start the 30s timer!
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code}');

      if (e.code == 'quota-exceeded') {

        //show pivot UI
        showPivotOption.value = true;

        dialogErrorMessage.value = "Daily email limit reached for this project.";
        // Automatically switch to personal mode so they can at least change the input
        isGmailAllowed.value = true;
        linkSent.value = false;
      } else {
        dialogErrorMessage.value = e.message ?? "An error occurred. Please try again.";
      }
    } catch (e) {
      dialogErrorMessage.value = "Could not send link. Check your connection.";
    } finally {
      loading.value = false;
    }
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
    secondsRemaining.value = 30;

    if (!keepSchools) schools.clear();
  }
}
