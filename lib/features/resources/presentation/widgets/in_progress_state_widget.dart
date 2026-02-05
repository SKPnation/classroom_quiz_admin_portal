/* ---------------------- IN-PROGRESS STATE ---------------------- */

import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/avatar_circle_widget.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/cardshell_widget.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/field_widgets.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/small_icon_dot.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/verified_pill_widget.dart';
import 'package:flutter/material.dart';

class ProfileInProgressCard extends StatelessWidget {
  const ProfileInProgressCard({super.key, required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF111827);
    const sub = Color(0xFF6B7280);
    const border = Color(0xFFE5E7EB);

    final pctLabel = (percent * 100).round();

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
                      value: percent,
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
                        children: const [
                          Text(
                            'John Doe',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: ink,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('Lecturer', style: TextStyle(color: sub)),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              SmallIconDot(icon: Icons.account_balance_outlined),
                              SizedBox(width: 8),
                              Text(
                                'Texas A&M University',
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
                const TextFieldShell(
                  hintText: 'John Doe',
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
                  children: const [
                    Expanded(
                      child: TextFieldShell(
                        hintText: 'john.doe@tamu.edu',
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
                  children: const [
                    Expanded(
                      child: LabeledField(
                        label: 'Department (Optional)',
                        hint: 'Computer Science',
                        suffixIcon: Icons.keyboard_arrow_down_rounded,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: LabeledField(
                        label: 'Office (Optional)',
                        hint: 'CS Building, Room 101',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Bio
                const FieldLabel('Bio (Optional)'),
                const SizedBox(height: 6),
                const TextAreaShell(
                  hintText:
                  'Experienced lecturer in computer science, specializing in AI and machine learning.',
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF2563EB),
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