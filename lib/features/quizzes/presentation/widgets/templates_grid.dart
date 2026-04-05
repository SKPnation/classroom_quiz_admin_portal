import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_template.dart';
import 'package:flutter/material.dart';

class TemplatesGrid extends StatelessWidget {
  const TemplatesGrid({super.key, required this.templates, required this.columns});

  final List<PublishedQuizTemplate> templates;
  final int columns;

  static const _card = Colors.white;
  static const _radius = 16.0;
  static const _border = Color(0xFFE5E7EB);
  static const _sub = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
      ),
      child: const Text(
        'No templates match your filters yet.',
        style: TextStyle(color: _sub),
      ),
    );
  }
}
