import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/data/models/school_model.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/presentation/controllers/find_school_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmailPasswordLoginDialog extends StatelessWidget {
  final SchoolModel school;
  final FindSchoolController controller;

  const EmailPasswordLoginDialog({
    super.key,
    required this.school,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sign In'),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your credentials to access your account.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Email Field
            TextField(
              controller: controller.emailTEC,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (val) => controller.typedEmail.value = val,
            ),

            // Error Message Display
            Obx(
              () => controller.dialogErrorMessage.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        controller.dialogErrorMessage.value,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        Obx(() {
          final email = controller.typedEmail.value.trim().toLowerCase();
          // final isEmailValid = email.endsWith('@$domain');

          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 45),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: controller.loading.value
                ? null
                : () =>
                      _handleLogin(school: school),
            child: controller.loading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Login', style: TextStyle(color: Colors.white)),
          );
        }),
      ],
    );
  }

  void _handleLogin({
    required SchoolModel school,
  }) async {
    controller.dialogErrorMessage.value = "";

    await controller.signInWithEmailPassword(school: school);
  }
}
