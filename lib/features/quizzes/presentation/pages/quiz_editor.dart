import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/functions.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/editor_card.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/question_list_item.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/quiz_editor_header_btn.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/quiz_editor_question_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ---------- Models / enums ----------

// enum QuestionType { multipleChoice, trueFalse, shortAnswer, essay }

// class QuestionModel {
//   final String id;
//   QuestionType type;
//   String prompt;
//   int points;
//   bool required;
//
//   // Multiple choice
//   List<String> options;
//   int correctIndex;
//
//   // True/False
//   bool tfAnswer;
//
//   // Short answer
//   String shortKeywords;
//
//   // Essay
//   String essayRubric;
//   int maxWords;
//
//   QuestionModel({
//     required this.id,
//     required this.type,
//     this.prompt = '',
//     this.points = 1,
//     this.required = false,
//     List<String>? options,
//     this.correctIndex = 0,
//     this.tfAnswer = true,
//     this.shortKeywords = '',
//     this.essayRubric = '',
//     this.maxWords = 400,
//   }) : options = options ?? ['', '', '', ''];
//
//   QuestionModel copyWithNewId(String newId) {
//     return QuestionModel(
//       id: newId,
//       type: type,
//       prompt: prompt,
//       points: points,
//       required: required,
//       options: [...options],
//       correctIndex: correctIndex,
//       tfAnswer: tfAnswer,
//       shortKeywords: shortKeywords,
//       essayRubric: essayRubric,
//       maxWords: maxWords,
//     );
//   }
// }

// ---------- Page ----------

class QuizEditorPage extends StatefulWidget {
  const QuizEditorPage({super.key});

  @override
  State<QuizEditorPage> createState() => _QuizEditorPageState();
}

class _QuizEditorPageState extends State<QuizEditorPage> {
  // Colors from the HTML design
  static const _bg = Color(0xFFF6F7FB);
  static const _card = Colors.white;
  static const _radius = 14.0;
  static const sub = Color(0xFF6B7280);
  static const _ink = Color(0xFF111827);
  static const _border = Color(0xFFE5E7EB);

  final quizEditorController = QuizEditorController.instance;

  @override
  void initState() {
    super.initState();
    // final first = _createQuestion(QuizItemType.multipleChoice);
    // quizEditorController.items = [first];
    // activeId = first.id;
    // _loadCurrentIntoControllers();
  }

  @override
  void dispose() {
    quizEditorController.promptController.dispose();
    quizEditorController.shortKeywordsController.dispose();
    quizEditorController.essayRubricController.dispose();
    quizEditorController.essayMaxWordsController.dispose();
    super.dispose();
  }

  // QuestionModel _createQuestion(QuestionType type) {
  //   return QuestionModel(
  //     id: DateTime.now().microsecondsSinceEpoch.toString(),
  //     type: type,
  //   );
  // }
  //

  //
  // void _setActive(String id) {
  //   setState(() {
  //     activeId = id;
  //     _loadCurrentIntoControllers();
  //   });
  // }

  // void _loadCurrentIntoControllers() {
  //   final q = _activeQuestion;
  //   if (q == null) return;
  //   _promptController.text = q.prompt;
  //   _shortKeywordsController.text = q.shortKeywords;
  //   _essayRubricController.text = q.essayRubric;
  //   _essayMaxWordsController.text = q.maxWords.toString();
  // }



  // void _addQuestion() {
  //   setState(() {
  //     final q = _createQuestion(newQuestionType);
  //     questions.add(q);
  //     activeId = q.id;
  //     _loadCurrentIntoControllers();
  //   });
  // }



  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 980;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              isNarrow
                  ? Column(
                      children: [
                        QuizEditorQuestionCard(),
                        const SizedBox(height: 16),
                        BuildEditorCard(
                          quizEditorController: quizEditorController,
                        ),                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 320, child: QuizEditorQuestionCard()),
                        const SizedBox(width: 16),
                        Expanded(
                          child: BuildEditorCard(
                            quizEditorController: quizEditorController,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Editor',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Build questions, set answers & points, then publish.',
              style: TextStyle(fontSize: 13, color: sub),
            ),
          ],
        ),
        Row(
          children: [
            QuizEditorHeaderBtn(label: 'Preview'),
            const SizedBox(width: 8),
            QuizEditorHeaderBtn(label: 'Save Draft'),
            const SizedBox(width: 8),
            // _headerButton('Publish', primary: true, onTap: _onPublish),
          ],
        ),
      ],
    );
  }




  //  void _onPublish() {
  //    final questions = quizEditorController.items;
  //    // For now just print payload
  //    debugPrint('Quiz payload:');
  //    for (final q in questions) {
  //      debugPrint(
  //        '${_typeLabel(q.type)} | ${q.points} pts | required=${q.required} | prompt="${q.prompt}"',
  //      );
  //    }
  //    ScaffoldMessenger.of(context).showSnackBar(
  //      const SnackBar(
  //        content: Text('Quiz saved (mock). Check console for payload.'),
  //      ),
  //    );
  //  }
}
