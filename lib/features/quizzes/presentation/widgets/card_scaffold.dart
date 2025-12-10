import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/shadow_theme.dart';
import 'package:flutter/material.dart';

class CardScaffold extends StatelessWidget {
  const CardScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final border = AppColors.grey[200];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border!),
        borderRadius: BorderRadius.circular(16),
        boxShadow: Shadows.card,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border)),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Padding(padding: const EdgeInsets.all(18), child: child),
        ],
      ),
    );
  }
}