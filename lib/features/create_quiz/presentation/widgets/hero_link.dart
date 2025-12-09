import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class HeroLink extends StatelessWidget {
  const HeroLink({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  factory HeroLink.primary({
    required String label,
    required VoidCallback onTap,
  }) => HeroLink(label: label, onTap: onTap, primary: true);

  @override
  Widget build(BuildContext context) {
    final border = primary ? AppColors.purple : AppColors.grey[200];
    final bgColor = primary ? AppColors.purple : AppColors.purple.withValues(alpha: 0.08);
    final textColor = primary ? AppColors.white : AppColors.black;

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: CustomText(text: label, color: AppColors.purple, weight: FontWeight.bold,),
        ),
      ),
    );
  }
}
