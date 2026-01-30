import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/theme/fonts.dart';
import 'package:classroom_quiz_admin_portal/core/utils/helpers/size_helpers.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/card_scaffold.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/shadow_theme.dart';
import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {

    return CardScaffold(
      title: AppStrings.quickActionsTitle,
      child: Column(children: [
        QuickActionItem(
          secWidth: 100,
          priWidth: 160,
          title: 'From Template',
          hint: 'Pick from saved templates',
          secBtnTitle: 'Manage',
          primaryBtnTitle: 'Choose Template',
          onPressedSecBtn: () {},
          onPressedPrimaryBtn: () {},
        ),
        SizedBox(height: 12),
        QuickActionItem(
          secWidth: 100,
          priWidth: 130,
          title: 'Import',
          hint: 'CSV, QTI, GIFT, Google Forms',
          secBtnTitle: 'Guide',
          primaryBtnTitle: 'Import File',
          onPressedSecBtn: () {},
          onPressedPrimaryBtn: () {},
        ),
        SizedBox(height: 12),
        QuickActionItem(
          secWidth: 100,
          priWidth: 130,
          title: 'Continue Draft',
          hint:
          'Unit 4 Practice - Nov 2, 2:15 PM • CSE 101 Chapter 3 - Oct 28, 10:02 AM • PHY 202 Midterm B - Oct 20, 7:44 PM',
          secBtnTitle: 'View All',
          primaryBtnTitle: 'Open Latest',
          onPressedSecBtn: () {},
          onPressedPrimaryBtn: () {},
        ),
      ]),
    );

  }
}

class QuickActionItem extends StatelessWidget {
  const QuickActionItem({
    super.key,
    required this.title,
    required this.hint,
    this.trailingPrimary,
    required this.secBtnTitle,
    required this.primaryBtnTitle,
    required this.onPressedSecBtn,
    required this.onPressedPrimaryBtn,
    this.secWidth,
    this.priWidth,
  });

  final String title;
  final String hint;
  final String? trailingPrimary;
  final String secBtnTitle;
  final String primaryBtnTitle;
  final double? secWidth;
  final double? priWidth;
  final Function() onPressedSecBtn;
  final Function() onPressedPrimaryBtn;

  @override
  Widget build(BuildContext context) {
    final border = AppColors.grey[300]!.withValues(alpha: .2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // TwoLineLabel(title: title, hint: hint),
          Expanded(
            child: TwoLineLabel(title: title, hint: hint),
          ),
          const SizedBox(width: 8),
          Btn(
            label: secBtnTitle,
            onPressed: () => onPressedSecBtn,
            width: secWidth,
          ),
          const SizedBox(width: 8),
          Btn(
            label: primaryBtnTitle,
            onPressed: () => onPressedPrimaryBtn,
            primary: true,
            width: priWidth,
          ),
        ],
      ),
    );
  }
}

class TwoLineLabel extends StatelessWidget {
  const TwoLineLabel({super.key, required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final muted = Colors.grey.shade600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}
