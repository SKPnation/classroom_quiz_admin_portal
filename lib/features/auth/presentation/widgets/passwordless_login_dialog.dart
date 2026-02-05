import 'package:classroom_quiz_admin_portal/features/find_school/data/models/school_model.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/presentation/controllers/find_school_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordLessLoginDialog extends StatelessWidget {
  final SchoolModel school;
  final FindSchoolController controller;

  const PasswordLessLoginDialog({
    super.key,
    required this.school,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final domain = (school.allowedDomains.isNotEmpty)
        ? school.allowedDomains.first.trim().toLowerCase()
        : '';

    return AlertDialog(
      title: Text('Continue with ${school.name}'),
      scrollable: true,
      content: Obx(
            () => SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.emailTEC,
                enabled: !controller.linkSent.value,
                decoration: InputDecoration(
                  labelText: controller.isGmailAllowed.value
                      ? 'Enter personal email'
                      : 'School email (@$domain)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => controller.typedEmail.value = val,
              ),
              if (controller.dialogErrorMessage.value.isNotEmpty) ...[
                const SizedBox(height: 8),
                _ErrorContainer(message: controller.dialogErrorMessage.value),
              ],
              const SizedBox(height: 12),
              if (!controller.linkSent.value)
                Text(
                  'We will send a verification link to your email.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              if (controller.linkSent.value && !controller.emailVerified.value) ...[
                const Icon(Icons.mark_email_read_outlined, color: Colors.green, size: 40),
                const SizedBox(height: 8),
                Text('Link sent! Check your inbox.',
                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (!controller.showPivotOption.value)
                  Text('Resend available in ${controller.secondsRemaining.value}s',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
              if (controller.showPivotOption.value && !controller.emailVerified.value) ...[
                const Divider(),
                const Text("Haven't received the link?", style: TextStyle(fontSize: 12)),
                TextButton(
                  onPressed: () {
                    controller.isGmailAllowed.value = true;
                    controller.linkSent.value = false;
                    controller.emailTEC.clear();
                    controller.typedEmail.value = '';
                    controller.dialogErrorMessage.value = '';
                  },
                  child: const Text('Try a personal Gmail instead'),
                ),
              ],
              if (controller.emailVerified.value) ...[
                const SizedBox(height: 12),
                const Text("✅ Email Verified!",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.passwordTEC,
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
      actions: [
        TextButton(
          onPressed: () {
            controller.resetAllVariables(keepSchools: true);
            Get.back();
          },
          child: const Text('Cancel'),
        ),
        Obx(() {
          final email = controller.typedEmail.value.trim().toLowerCase();
          final isEmailValid = controller.isGmailAllowed.value
              ? GetUtils.isEmail(email)
              : email.endsWith('@$domain'); // Simplified check

          final canSend = !controller.loading.value && !controller.linkSent.value && isEmailValid;
          final canFinish = !controller.loading.value &&
              controller.emailVerified.value &&
              controller.passwordTEC.text.trim().length >= 6;

          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canSend || canFinish ? Colors.green : Colors.grey,
            ),
            onPressed: () async {
              if (canSend) {
                await controller.sendVerificationLink(domain: domain);
              } else if (canFinish) {
                Get.back();
                // Get.toNamed(Routes.rootRoute); // Handle navigation in controller or here
                controller.resetAllVariables(keepSchools: true);
              }
            },
            child: controller.loading.value
                ? const SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : Text(
              controller.emailVerified.value
                  ? 'Continue'
                  : (controller.linkSent.value ? 'Waiting...' : 'Send link'),
              style: const TextStyle(color: Colors.white),
            ),
          );
        }),
      ],
    );
  }
}

class _ErrorContainer extends StatelessWidget {
  final String message;
  const _ErrorContainer({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}