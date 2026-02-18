import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
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

  // void _saveFromControllers() {
  //   final q = _activeQuestion;
  //   if (q == null) return;
  //   setState(() {
  //     q.prompt = _promptController.text;
  //     q.shortKeywords = _shortKeywordsController.text;
  //     q.essayRubric = _essayRubricController.text;
  //     q.maxWords = int.tryParse(_essayMaxWordsController.text) ?? 400;
  //   });
  // }

  // void _addQuestion() {
  //   setState(() {
  //     final q = _createQuestion(newQuestionType);
  //     questions.add(q);
  //     activeId = q.id;
  //     _loadCurrentIntoControllers();
  //   });
  // }

  int get _totalPoints => quizEditorController.quizItems.fold(
    0,
    (sum, q) => sum + (q.points < 0 ? 0 : q.points),
  );

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
                  // _buildEditorCard(),
                ],
              )
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 320, child: QuizEditorQuestionCard()),
                  const SizedBox(width: 16),
                  // Expanded(child: _buildEditorCard()),
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

  // Widget _buildEditorCard() {
  //   final q = _activeQuestion;
  //   if (q == null) return const SizedBox.shrink();
  //
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: _card,
  //       borderRadius: BorderRadius.circular(_radius),
  //       border: Border.all(color: _border),
  //       boxShadow: const [
  //         BoxShadow(
  //           blurRadius: 3,
  //           offset: Offset(0, 1),
  //           color: Color.fromARGB(10, 0, 0, 0),
  //         ),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text(
  //             'Edit Question',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //               color: _ink,
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           const Divider(height: 1, color: _border),
  //           const SizedBox(height: 14),
  //
  //           const Text(
  //             'Type',
  //             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  //           ),
  //           const SizedBox(height: 6),
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 10),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(10),
  //               border: Border.all(color: _border),
  //               color: Colors.white,
  //             ),
  //             child: DropdownButtonHideUnderline(
  //               child: DropdownButton<String>(
  //                 value: _typeLabel(q.type),
  //                 isExpanded: true,
  //                 dropdownColor: Colors.white,
  //                 // THIS fixes the menu background
  //                 items: QuestionType.values
  //                     .map(
  //                       (t) => DropdownMenuItem<String>(
  //                         value: _typeLabel(t),
  //                         child: Text(
  //                           _typeLabel(t),
  //                           style: const TextStyle(color: Colors.black),
  //                         ),
  //                       ),
  //                     )
  //                     .toList(),
  //                 onChanged: (val) {
  //                   if (val == null) return;
  //                   setState(() {
  //                     q.type = _typeFromLabel(val);
  //                   });
  //                 },
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 14),
  //           const Text(
  //             'Prompt',
  //             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  //           ),
  //           const SizedBox(height: 6),
  //           TextField(
  //             controller: _promptController,
  //             maxLines: null,
  //             minLines: 4,
  //             decoration: InputDecoration(
  //               hintText: 'Enter the question text',
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //                 borderSide: const BorderSide(color: _border),
  //               ),
  //               focusedBorder: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //                 borderSide: const BorderSide(
  //                   color: AppColors.gold,
  //                   width: 1.5,
  //                 ),
  //               ),
  //               contentPadding: const EdgeInsets.all(10),
  //               filled: true,
  //               fillColor: Colors.white,
  //             ),
  //             onChanged: (_) => _saveFromControllers(),
  //           ),
  //           const SizedBox(height: 14),
  //           _buildTypeSpecificFields(q),
  //
  //           const SizedBox(height: 14),
  //           Row(
  //             children: [
  //               // Points
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const Text(
  //                       'Points',
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 13,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 6),
  //                     TextField(
  //                       keyboardType: TextInputType.number,
  //                       decoration: InputDecoration(
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                           borderSide: const BorderSide(color: _border),
  //                         ),
  //                         contentPadding: const EdgeInsets.symmetric(
  //                           horizontal: 10,
  //                           vertical: 8,
  //                         ),
  //                       ),
  //                       controller: TextEditingController(
  //                         text: q.points.toString(),
  //                       ),
  //                       onChanged: (val) {
  //                         final v = int.tryParse(val) ?? 0;
  //                         setState(() {
  //                           q.points = v;
  //                         });
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //
  //               const SizedBox(width: 12),
  //
  //               // Required
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const Text(
  //                       'Required',
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 13,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 6),
  //                     Row(
  //                       children: [
  //                         Switch(
  //                           value: q.required,
  //                           activeThumbColor: AppColors.gold,
  //                           inactiveThumbColor: AppColors.grey[300],
  //                           onChanged: (val) {
  //                             setState(() {
  //                               q.required = val;
  //                             });
  //                           },
  //                         ),
  //                         const SizedBox(width: 4),
  //                         const Flexible(
  //                           child: Text(
  //                             'Students must answer',
  //                             style: TextStyle(fontSize: 11, color: _sub),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 8),
  //           const Divider(height: 1, color: Colors.transparent),
  //           const SizedBox(height: 8),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               const Expanded(
  //                 child: Text(
  //                   'Tip: Use ⌘/Ctrl+D to duplicate; ⌘/Ctrl+↑/↓ to reorder.',
  //                   style: TextStyle(fontSize: 11, color: _sub),
  //                 ),
  //               ),
  //               Container(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 10,
  //                   vertical: 6,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: Color(0xFFEEF2FF),
  //                   borderRadius: BorderRadius.circular(999),
  //                 ),
  //                 child: Text(
  //                   'Total Points: $_totalPoints',
  //                   style: const TextStyle(
  //                     color: Color(0xFF3730A3),
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildTypeSpecificFields(QuizItemModel q) {
  //   switch (q.type) {
  //     case QuizItemType.multipleChoice:
  //       return _buildMultipleChoiceEditor(q);
  //     case QuizItemType.trueFalse:
  //       return _buildTrueFalseEditor(q);
  //     case QuizItemType.shortAnswer:
  //       return _buildShortAnswerEditor(q);
  //     case QuizItemType.essay:
  //       return _buildEssayEditor(q);
  //   }
  // }

  //  Widget _buildMultipleChoiceEditor(QuizItemModel q) {
  //    return Column(
  //      crossAxisAlignment: CrossAxisAlignment.start,
  //      children: [
  //        const Text(
  //          'Options',
  //          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  //        ),
  //        const SizedBox(height: 6),
  //        RadioGroup<int>(
  //          groupValue: q.correctIndex, //current selected
  //          onChanged: (val) {
  //            if (val == null) return;
  //            setState(() => q.correctIndex = val);
  //          },
  //          child: Column(
  //            children: q.options.asMap().entries.map((entry) {
  //              final idx = entry.key;
  //              final value = entry.value;
  //              final label = String.fromCharCode(65 + idx); // A, B, C...
  //
  //              return Container(
  //                margin: const EdgeInsets.only(bottom: 6),
  //                child: Row(
  //                  children: [
  //                    SizedBox(
  //                      width: 30,
  //                      child: Text(
  //                        '$label.',
  //                        style: const TextStyle(fontSize: 12, color: _sub),
  //                      ),
  //                    ),
  //                    Expanded(
  //                      child: TextField(
  //                        controller: TextEditingController(text: value),
  //                        decoration: InputDecoration(
  //                          hintText: 'Option ${idx + 1}',
  //                          border: OutlineInputBorder(
  //                            borderRadius: BorderRadius.circular(10),
  //                            borderSide: const BorderSide(color: _border),
  //                          ),
  //                          contentPadding: const EdgeInsets.symmetric(
  //                            horizontal: 10,
  //                            vertical: 8,
  //                          ),
  //                        ),
  //                        onChanged: (val) {
  //                          setState(() {
  //                            q.options[idx] = val;
  //                          });
  //                        },
  //                      ),
  //                    ),
  //                    const SizedBox(width: 10),
  //
  //                    // This radio now belongs to the single parent RadioGroup
  //                    Row(
  //                      children: [
  //                        Radio<int>(
  //                          value: idx,
  //                          visualDensity: VisualDensity.compact,
  //                        ),
  //                        const Text(
  //                          'Correct',
  //                          style: TextStyle(fontSize: 11, color: _sub),
  //                        ),
  //                      ],
  //                    ),
  //
  //                    IconButton(
  //                      icon: const Icon(Icons.close, size: 18),
  //                      splashRadius: 18,
  //                      onPressed: () {
  //                        if (q.options.length <= 1) return;
  //                        setState(() {
  //                          q.options.removeAt(idx);
  //
  //                          // keep correctIndex valid
  //                          if (q.correctIndex >= q.options.length) {
  //                            q.correctIndex = 0;
  //                          }
  //                        });
  //                      },
  //                    ),
  //                  ],
  //                ),
  //              );
  //            }).toList(),
  //          ),
  //        ),
  //        const SizedBox(height: 4),
  //        TextButton(
  //          onPressed: () {
  //            setState(() {
  //              q.options.add('');
  //            });
  //          },
  //          child: const Text('+ Add option'),
  //        ),
  //      ],
  //    );
  //  }
  //
  // Widget _buildTrueFalseEditor(QuestionModel q) {
  //    return Column(
  //      crossAxisAlignment: CrossAxisAlignment.start,
  //      children: [
  //        const Text(
  //          'Answer',
  //          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  //        ),
  //        const SizedBox(height: 6),
  //        Row(
  //          children: [
  //            Expanded(
  //              child: ChoiceChip(
  //                label: const Text('True'),
  //                selected: q.tfAnswer,
  //                onSelected: (val) {
  //                  if (val) {
  //                    setState(() => q.tfAnswer = true);
  //                  }
  //                },
  //              ),
  //            ),
  //            const SizedBox(width: 8),
  //            Expanded(
  //              child: ChoiceChip(
  //                label: const Text('False'),
  //                selected: !q.tfAnswer,
  //                onSelected: (val) {
  //                  if (val) {
  //                    setState(() => q.tfAnswer = false);
  //                  }
  //                },
  //              ),
  //            ),
  //          ],
  //        ),
  //      ],
  //    );
  //  }
  //
  //  Widget _buildShortAnswerEditor(QuestionModel q) {
  //    return Column(
  //      crossAxisAlignment: CrossAxisAlignment.start,
  //      children: [
  //        const Text(
  //          'Expected Keywords (comma-separated)',
  //          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  //        ),
  //        const SizedBox(height: 6),
  //        TextField(
  //          controller: _shortKeywordsController,
  //          decoration: InputDecoration(
  //            hintText: 'e.g. stack, queue, complexity',
  //            border: OutlineInputBorder(
  //              borderRadius: BorderRadius.circular(10),
  //              borderSide: const BorderSide(color: _border),
  //            ),
  //            contentPadding: const EdgeInsets.symmetric(
  //              horizontal: 10,
  //              vertical: 8,
  //            ),
  //          ),
  //          onChanged: (_) => _saveFromControllers(),
  //        ),
  //        const SizedBox(height: 4),
  //        const Text(
  //          'Used for basic auto-grading; teacher can override.',
  //          style: TextStyle(fontSize: 11, color: _sub),
  //        ),
  //      ],
  //    );
  //  }
  //
  //  Widget _buildEssayEditor(QuestionModel q) {
  //    return Column(
  //      crossAxisAlignment: CrossAxisAlignment.start,
  //      children: [
  //        const Text(
  //          'Rubric / Guidance',
  //          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  //        ),
  //        const SizedBox(height: 6),
  //        TextField(
  //          controller: _essayRubricController,
  //          maxLines: null,
  //          minLines: 3,
  //          decoration: InputDecoration(
  //            hintText: 'Describe rubric or key points to look for.',
  //            border: OutlineInputBorder(
  //              borderRadius: BorderRadius.circular(10),
  //              borderSide: const BorderSide(color: _border),
  //            ),
  //            contentPadding: const EdgeInsets.all(10),
  //          ),
  //          onChanged: (_) => _saveFromControllers(),
  //        ),
  //        const SizedBox(height: 10),
  //        Row(
  //          children: [
  //            Expanded(
  //              child: Column(
  //                crossAxisAlignment: CrossAxisAlignment.start,
  //                children: [
  //                  const Text(
  //                    'Max Words',
  //                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  //                  ),
  //                  const SizedBox(height: 6),
  //                  TextField(
  //                    controller: _essayMaxWordsController,
  //                    keyboardType: TextInputType.number,
  //                    decoration: InputDecoration(
  //                      border: OutlineInputBorder(
  //                        borderRadius: BorderRadius.circular(10),
  //                        borderSide: const BorderSide(color: _border),
  //                      ),
  //                      contentPadding: const EdgeInsets.symmetric(
  //                        horizontal: 10,
  //                        vertical: 8,
  //                      ),
  //                    ),
  //                    onChanged: (_) => _saveFromControllers(),
  //                  ),
  //                ],
  //              ),
  //            ),
  //            const SizedBox(width: 12),
  //            const Expanded(child: SizedBox.shrink()),
  //          ],
  //        ),
  //        const SizedBox(height: 4),
  //        const Text(
  //          'AI can help score with rubric cues; manual override available.',
  //          style: TextStyle(fontSize: 11, color: _sub),
  //        ),
  //      ],
  //    );
  //  }
  //
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
