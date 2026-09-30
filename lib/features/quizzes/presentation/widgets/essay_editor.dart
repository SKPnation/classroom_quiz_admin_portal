import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:flutter/material.dart';

class BuildEssayEditor extends StatefulWidget {
  const BuildEssayEditor({
    super.key,
    required this.q,
    required this.qEditorController,
  });

  final QuizItemModel q;
  final QuizEditorController qEditorController;

  @override
  State<BuildEssayEditor> createState() => _BuildEssayEditorState();
}

class _BuildEssayEditorState extends State<BuildEssayEditor> {
  final _border = Color(0xFFE5E7EB);
  final _sub = Color(0xFF6B7280);

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

  @override
  Widget build(BuildContext context) {
    const _sub = Color(0xFF111827);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rubric / Guidance',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.qEditorController.essayRubricController,
          maxLines: null,
          minLines: 3,
          decoration: InputDecoration(
            hintText: 'Describe rubric or key points to look for.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _border),
            ),
            contentPadding: const EdgeInsets.all(10),
          ),
          onChanged: (_) => saveFromControllers(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Max Words',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller:
                        widget.qEditorController.essayMaxWordsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
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
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'AI can help score with rubric cues; manual override available.',
          style: TextStyle(fontSize: 11, color: _sub),
        ),
      ],
    );
  }

}
