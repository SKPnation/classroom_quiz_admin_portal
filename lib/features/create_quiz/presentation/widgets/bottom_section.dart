import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/theme/fonts.dart';
import 'package:classroom_quiz_admin_portal/core/utils/helpers/size_helpers.dart';
import 'package:classroom_quiz_admin_portal/features/create_quiz/presentation/widgets/defaults_card.dart';
import 'package:classroom_quiz_admin_portal/features/create_quiz/presentation/widgets/quick_action_card.dart';
import 'package:classroom_quiz_admin_portal/features/create_quiz/presentation/widgets/shadow_theme.dart';
import 'package:flutter/material.dart';

class BottomSection extends StatelessWidget {
  const BottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final large = constraints.maxWidth >= 900;

        if (large) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: QuickActionsCard()
              ),
              SizedBox(width: 12),
              Expanded(
                child: DefaultsCard()
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: AppColors.white,
                child: Row(
                  children: [
                    TwoLineLabel(title: "title", hint: "hint"),
                    const SizedBox(width: 8),
                    Btn(label: 'Guide', onPressed: () {}),
                    const SizedBox(width: 8),
                    Btn.primary(label: "trailingPrimary", onPressed: () {}),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
