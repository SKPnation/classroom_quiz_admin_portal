/* ---------------------- COMPLETED STATE ---------------------- */

import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/avatar_circle_widget.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/cardshell_widget.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/small_icon_dot.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/verified_pill_widget.dart';
import 'package:flutter/material.dart';

class ProfileCompletedCard extends StatelessWidget {
  const ProfileCompletedCard({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF111827);
    const sub = Color(0xFF6B7280);
    const border = Color(0xFFE5E7EB);

    return CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // content row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AvatarCircle(size: 72),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Lecturer',
                      style: TextStyle(fontSize: 14, color: sub),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: const [
                        SmallIconDot(icon: Icons.account_balance_outlined),
                        SizedBox(width: 8),
                        Text(
                          'Texas A&M University',
                          style: TextStyle(fontSize: 14, color: ink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: const [
                        SmallIconDot(icon: Icons.email_outlined),
                        SizedBox(width: 8),
                        Text(
                          'john.doe@tamu.edu',
                          style: TextStyle(fontSize: 14, color: ink),
                        ),
                        SizedBox(width: 10),
                        VerifiedPill(),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // CTA
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    // UI only: hook up later
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF2563EB), // blue-600
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFF2563EB)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: border, height: 1),
          const SizedBox(height: 14),

          // Optional: small hint row
          Row(
            children: const [
              Icon(Icons.info_outline, size: 18, color: sub),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your profile is complete. You can edit it anytime.',
                  style: TextStyle(color: sub, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
