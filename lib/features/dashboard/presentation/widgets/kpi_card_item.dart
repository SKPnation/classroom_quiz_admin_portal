import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class KpiCardItem extends StatelessWidget {
  const KpiCardItem({super.key, required this.title, required this.value, this.isLast});

  final bool? isLast;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.4), width: 1)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: title, size: AppFonts.defaultSize,),
          CustomText(text: value, size: AppFonts.baseSize * 2, weight: FontWeight.w700,),
        ],
      ),
    );
  }
}
