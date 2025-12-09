import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class HeroText extends StatelessWidget {
  const HeroText({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.grey[400];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: AppStrings.startNewQuiz, weight: FontWeight.w700, size: AppFonts.baseSize+2,),
        const SizedBox(height: 6),
        CustomText(
          text: 'Use AI for auto-generation or build manually with the editor.', color: muted!,
        ),
      ],
    );
  }
}