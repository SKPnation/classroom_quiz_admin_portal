import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:flutter/material.dart';

class HeaderTitle extends StatelessWidget {
  const HeaderTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final large = constraints.maxWidth >= 900;
          final children = [
            CustomText(text: 'Create Quiz', size: 24, weight: FontWeight.w700),
            CustomText(
              text:
                  'Choose how you want to start, use a quick action, or set defaults.',
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Btn(label: 'Help', onPressed: () {}),
                Btn(label: 'Skip to Editor', onPressed: () {}, primary: true),
              ],
            ),
          ];

          return large
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        children[0],
                        children[1],
                      ],
                    ),
                    const SizedBox(width: 16),
                    children[2]
                  ],
                )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              children[0],
              const SizedBox(height: 4),
              children[1],
              const SizedBox(height: 16),
              children[2],
            ],
          );
        },
      ),
    );
  }
}
