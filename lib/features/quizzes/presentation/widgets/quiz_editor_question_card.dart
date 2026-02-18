import 'package:classroom_quiz_admin_portal/core/utils/functions.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/question_list_item.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/quiz_editor_header_btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizEditorQuestionCard extends StatelessWidget {
  QuizEditorQuestionCard({super.key});

  final quizEditorController = QuizEditorController.instance;

  static const _card = Color(0xFFFFFFFF);
  static const _border = Color(0xFFE5E7EB);
  static const _radius = 14.0;
  static const _ink = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var questions = quizEditorController.quizItems;

      return Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _border),
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              offset: Offset(0, 1),
              color: Color.fromARGB(10, 0, 0, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Questions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: _border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...questions.map((e) {
                    int index = questions.indexOf(e);
                    return QuestionListItem(index: index, question: e);
                  }),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _border),
                            color: Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<QuizItemType>(
                              value: quizEditorController.newQuestionType.value,
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              items: QuizItemType.values.map((type) {
                                return DropdownMenuItem<QuizItemType>(
                                  value: type,
                                  child: Text(typeLabel(type)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val == null) return;
                                quizEditorController.newQuestionType.value =
                                    val;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      QuizEditorHeaderBtn(label: '+ New', onTap: (){}),
                      // QuizEditorHeaderBtn(label: '+ New', onTap: _addQuestion),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
