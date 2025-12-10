import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/hero_link.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/hero_text.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/shadow_theme.dart';
import 'package:flutter/material.dart';

class HeroStrip extends StatelessWidget {
  const HeroStrip({
    super.key,
    required this.onStartAI,
    required this.onStartManual,
  });

  final VoidCallback onStartAI;
  final VoidCallback onStartManual;

  @override
  Widget build(BuildContext context) {
    final border = AppColors.grey[200];
    final bgGrad = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, Color(0xFFFAFBFE)],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: bgGrad,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border!),
        boxShadow: Shadows.card,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final large = constraints.maxWidth >= 900;
          final children = [
            HeroText(),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                HeroLink(label: '✨ Start with AI', onTap: onStartAI),
                HeroLink(
                  label: '✏️ Start manually',
                  onTap: onStartManual,
                ),
              ],
            ),
          ];

          return large
              ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [children[0], children[1]])
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [children[0], SizedBox(height: 16), children[1]],
                );
        },
      ),
    );
  }
}
