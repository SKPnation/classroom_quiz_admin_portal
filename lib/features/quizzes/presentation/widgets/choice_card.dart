import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/shadow_theme.dart';
import 'package:flutter/material.dart';

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({super.key,
    required this.tag,
    required this.title,
    required this.description,
    required this.secondaryLabel,
    required this.primaryLabel,
    required this.onSecondary,
    required this.onPrimary,
    required this.leading,
  });

  final String tag;
  final String title;
  final String description;
  final String secondaryLabel;
  final String primaryLabel;
  final VoidCallback onSecondary;
  final VoidCallback onPrimary;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    final border = AppColors.grey[200];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Shadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPrimary,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tag(text: tag),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  leading,
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomText(
                      text: title,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              CustomText(
                text: description,
                color: AppColors.grey[400],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Btn(label: secondaryLabel, onPressed: onSecondary),
                  Btn(label: primaryLabel, onPressed: onPrimary, primary: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class Tag extends StatelessWidget {
  const Tag({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.12),
        border: Border.all(color: const Color(0xFFE0E7FF)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.purple,
        ),
      ),
    );
  }
}