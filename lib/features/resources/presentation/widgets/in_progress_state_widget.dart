/* ---------------------- IN-PROGRESS STATE ---------------------- */

import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/data/models/school_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/controllers/settings_controller.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/avatar_circle_widget.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/cardshell_widget.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/department_dialog.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/field_widgets.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/small_icon_dot.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/verified_pill_widget.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileInProgressCard extends StatefulWidget {
  const ProfileInProgressCard({
    super.key,
    required this.percent,
    required this.user,
    required this.school,
  });

  final double percent;
  final UserModel user;
  final SchoolModel school;

  @override
  State<ProfileInProgressCard> createState() => _ProfileInProgressCardState();
}

class _ProfileInProgressCardState extends State<ProfileInProgressCard> {
  final settingsController = SettingsController.instance;

  void updateFields() {
    settingsController.fullNameTEC.text = widget.user.fullName ?? "";
    settingsController.bioTEC.text = widget.user.bio ?? "";
    settingsController.departmentTEC.text = widget.user.department ?? "";
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      updateFields();
    });
  }

  @override
  void didUpdateWidget(covariant ProfileInProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the incoming user changes, update fields again safely
    if (oldWidget.user.uid != widget.user.uid ||
        oldWidget.user.fullName != widget.user.fullName ||
        oldWidget.user.bio != widget.user.bio) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        updateFields();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF111827);
    const sub = Color(0xFF6B7280);
    const border = Color(0xFFE5E7EB);

    final pctLabel = (widget.percent * 100).round();

    return CardShell(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top progress bar strip
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Row(
              children: [
                Text(
                  'Profile $pctLabel% complete',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: widget.percent,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF10B981), // emerald-500
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: border, height: 1),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header row (avatar + identity + upload)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const AvatarCircle(size: 72),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.fullName ?? 'Full name',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.lecturer.capitalizeFirst!,
                            style: TextStyle(color: sub),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SmallIconDot(
                                icon: Icons.account_balance_outlined,
                              ),
                              SizedBox(width: 8),
                              Text(
                                widget.school.name,
                                style: TextStyle(fontSize: 14, color: ink),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Upload button (UI only)
                    OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF111827),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: const Text(
                        'Upload New',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Full name
                const FieldLabel('Full Name'),
                const SizedBox(height: 6),
                TextFieldShell(
                  hintText: 'John Doe',
                  textEditingController: settingsController.fullNameTEC,
                ),

                const SizedBox(height: 14),

                // Email row read-only + verified
                Row(
                  children: const [
                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '(read-only)',
                      style: TextStyle(fontSize: 13, color: sub),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldShell(
                        hintText: widget.user.email,
                        enabled: false,
                        prefixIcon: Icons.email_outlined,
                      ),
                    ),
                    SizedBox(width: 10),
                    VerifiedPill(),
                  ],
                ),

                const SizedBox(height: 14),

                // Department + Office (two columns)
                Row(
                  children: [
                    Expanded(
                      child: LabeledField(
                        label: 'Department (Optional)',
                        hint: 'Computer Science',
                        textEditingController: settingsController.departmentTEC,
                        suffixIcon: Icons.keyboard_arrow_down_rounded,
                        onSuffixTap: () => showDepartmentDialog(
                          context,
                          onSelected: (v) =>
                              settingsController.departmentTEC.text = v,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: LabeledField(
                        label: 'Office (Optional)',
                        hint: 'CS Building, Room 101',
                        textEditingController: TextEditingController(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Bio
                const FieldLabel('Bio (Optional)'),
                const SizedBox(height: 6),
                TextAreaShell(
                  hintText:
                      'Experienced lecturer in computer science, specializing in AI and machine learning.',
                  textEditingController: settingsController.bioTEC,
                ),

                const SizedBox(height: 16),
                Divider(color: border, height: 1),
                const SizedBox(height: 16),

                // actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ink,
                        side: const BorderSide(color: border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        UserModel userModel = UserModel(
                          uid: widget.user.uid,
                          email: widget.user.email,
                          fullName: settingsController.fullNameTEC.text,
                          role: AppStrings.lecturer,
                          orgId: widget.user.orgId,
                          bio: settingsController.bioTEC.text,
                          profileCompleted: false,
                          department: settingsController.departmentTEC.text,
                          isActive: true,
                          createdAt: widget.user.createdAt,
                          updatedAt: DateTime.now(),
                        );

                        settingsController.saveProfile(user: userModel, orgId: userModel.orgId);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
