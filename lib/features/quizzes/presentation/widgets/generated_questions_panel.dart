// ═══════════════════════════════════════════════════════════════════════
// NEW FILE: lib/features/quizzes/presentation/widgets/generated_questions_panel.dart
// ═══════════════════════════════════════════════════════════════════════
//
// WHAT: Shows AI-generated questions (from QuizEditorController.generatedQuestions)
// as a list, with an "Add" button per question and an "Add All" button.
// Drop this widget into your Quiz Editor screen — likely near or above
// where the question list (QuestionListItem list) is rendered, since both
// read from the same QuizEditorController instance.
//
// USAGE (in your Quiz Editor screen body):
//   Obx(() {
//     if (quizEditorController.generatedQuestions.isEmpty) {
//       return const SizedBox.shrink();
//     }
//     return const GeneratedQuestionsPanel();
//   })

import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/functions.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/question_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneratedQuestionsPanel extends StatelessWidget {
  const GeneratedQuestionsPanel({super.key});

  static const _border = Color(0xFFE5E7EB);
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final quizEditorController = QuizEditorController.instance;

    return Obx(() {
      final questions = quizEditorController.generatedQuestions;

      if (questions.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.purple.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.purple.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 18, color: AppColors.purple),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'AI Generated (${questions.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _ink,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      quizEditorController.addAllGeneratedQuestionsToEditor(),
                  child: const Text('Add All'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Review and add these to your quiz below.',
              style: TextStyle(fontSize: 11, color: _sub),
            ),
            const SizedBox(height: 10),
            ...questions.map(
                  (gq) => _GeneratedQuestionTile(
                question: gq,
                onAdd: () =>
                    quizEditorController.addGeneratedQuestionToEditor(gq),
                onDismiss: () =>
                    quizEditorController.dismissGeneratedQuestion(gq),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _GeneratedQuestionTile extends StatelessWidget {
  const _GeneratedQuestionTile({
    required this.question,
    required this.onAdd,
    required this.onDismiss,
  });

  final GeneratedQuestion question;
  final VoidCallback onAdd;
  final VoidCallback onDismiss;

  static const _border = Color(0xFFE5E7EB);
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _green = Color(0xFF065F46);
  static const _greenBg = Color(0xFFD1FAE5);

  @override
  Widget build(BuildContext context) {
    final hasOptions = question.options != null && question.options!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question text
                Text(
                  question.question,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 4),

                // Question type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    typeLabel(QuizItemType.values.byName(question.questionType)),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Options (for multiple choice and true/false)
                if (hasOptions) ...[
                  const SizedBox(height: 8),
                  ...question.options!.map((opt) {
                    final isAnswer = opt.trim().toLowerCase() ==
                        question.answer.trim().toLowerCase();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAnswer ? _greenBg : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isAnswer
                              ? const Color(0xFF6EE7B7)
                              : _border,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (isAnswer)
                            const Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.check_circle,
                                size: 12,
                                color: _green,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 12,
                                color: isAnswer ? _green : _sub,
                                fontWeight: isAnswer
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // Answer (for short answer and essay)
                if (!hasOptions && question.answer.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _greenBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF6EE7B7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Answer',
                          style: TextStyle(
                            fontSize: 10,
                            color: _green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          question.answer,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: _sub),
                tooltip: 'Discard',
                onPressed: onDismiss,
                splashRadius: 18,
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 22,
                  color: AppColors.purple,
                ),
                tooltip: 'Add to quiz',
                onPressed: onAdd,
                splashRadius: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}