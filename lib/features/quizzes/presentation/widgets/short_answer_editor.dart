import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:flutter/material.dart';

class BuildShortAnswerEditor extends StatefulWidget {
  const BuildShortAnswerEditor({super.key, required this.q, required this.qEditorController});

  final QuizItemModel q;
  final QuizEditorController qEditorController;

  @override
  State<BuildShortAnswerEditor> createState() => _BuildShortAnswerEditorState();
}

class _BuildShortAnswerEditorState extends State<BuildShortAnswerEditor> {
  final _border = Color(0xFFE5E7EB);
  final _sub = Color(0xFF6B7280);


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expected Keywords (comma-separated)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.qEditorController.shortKeywordsController,
          decoration: InputDecoration(
            hintText: 'e.g. stack, queue, complexity',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
          ),
          onChanged: (_) => saveFromControllers(),
        ),
        const SizedBox(height: 4),
        Text(
          'Used for basic auto-grading; teacher can override.',
          style: TextStyle(fontSize: 11, color: _sub),
        ),
      ],
    );
  }

  void saveFromControllers() {
    final q = widget.qEditorController.activeQuestion;
    if (q == null) return;
    setState(() {
      q.question = widget.qEditorController.promptController.text;
      // q.shortKeywords = quizEditorController.shortKeywordsController.text;
      // q.essayRubric = quizEditorController.essayRubricController.text;
      // q.maxWords = int.tryParse(quizEditorController.essayMaxWordsController.text) ?? 400;
    });
  }
}
