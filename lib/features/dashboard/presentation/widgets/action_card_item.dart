import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/theme/fonts.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/data/models/action_card_model.dart';
import 'package:flutter/material.dart';

class ActionCardItem extends StatelessWidget {
  const ActionCardItem({super.key, this.isLast, required this.actionCard});

  final bool? isLast;
  final ActionCard actionCard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top-left text
          CustomText(
            text: actionCard.message,
            size: AppFonts.baseSize,
          ),

          SizedBox(height: 16),

          // bottom-right button
          Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: actionCard.cta.length >= 12 ? 180 : null,
              child: Btn(onPressed: () {}, label: actionCard.cta, primary: true),
            ),
          ),
        ],
      ),
    );
  }
}
