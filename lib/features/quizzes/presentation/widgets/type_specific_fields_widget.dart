import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/essay_editor.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/multichoice_editor.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/short_answer_editor.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/true_false_editor.dart';
import 'package:flutter/material.dart';

Widget buildTypeSpecificFields(
  QuizItemModel q,
  QuizEditorController qEditorController,
) {
  switch (q.type) {
    case QuizItemType.multipleChoice:
      return BuildMultiChoiceEditor(q: q);
    case QuizItemType.trueFalse:
      return BuildTrueFalseEditor(q: q);
    case QuizItemType.shortAnswer:
      return BuildShortAnswerEditor(q: q, qEditorController: qEditorController);
    case QuizItemType.essay:
      return BuildEssayEditor(q: q, qEditorController: qEditorController);
  }
}
