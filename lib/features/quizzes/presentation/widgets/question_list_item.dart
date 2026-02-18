import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/functions.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:flutter/material.dart';

class QuestionListItem extends StatefulWidget {
  const QuestionListItem({super.key, required this.question, required this.index});

  final QuizItemModel question;
  final int index;


  @override
  State<QuestionListItem> createState() => _QuestionListItemState();
}

class _QuestionListItemState extends State<QuestionListItem> {
  final quizEditorController = QuizEditorController.instance;

  static const border = Color(0xFFE5E7EB);
  static const ring = Color.fromRGBO(37, 99, 235, 0.25);
  static const ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {

    final bool isActive = widget.question.id == quizEditorController.activeId.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? AppColors.gold : border),
        boxShadow: isActive
            ? const [BoxShadow(color: ring, blurRadius: 0, spreadRadius: 2)]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              // onTap: () => _setActive(question.id),
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q${widget.index + 1}: ${typeLabel(widget.question.type)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.question.question.isEmpty
                          ? 'Untitled question'
                          : widget.question.question,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: _sub),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Text('⬆️'),
            onPressed: () => quizEditorController.moveQuestion(widget.question.id, -1),
            splashRadius: 18,
          ),
          IconButton(
            icon: const Text('⬇️'),
            onPressed: () => quizEditorController.moveQuestion(widget.question.id, 1),
            splashRadius: 18,
          ),
          IconButton(
            icon: const Text('⎘'),
            onPressed: () =>
                quizEditorController.duplicateQuestion(widget.question.id),
            splashRadius: 18,
          ),
          IconButton(
            icon: const Text('🗑️'),
            onPressed: () => quizEditorController.deleteQuestion(widget.question.id),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}
