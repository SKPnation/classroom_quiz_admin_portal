import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:flutter/material.dart';

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
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _ring = Color.fromRGBO(37, 99, 235, 0.25);
  static const _radius = 14.0;

  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _shortKeywordsController =
      TextEditingController();
  final TextEditingController _essayRubricController = TextEditingController();
  final TextEditingController _essayMaxWordsController = TextEditingController(
    text: '400',
  );

  final quizEditorController = QuizEditorController.instance;


  String? activeId;
  // QuestionType newQuestionType = QuestionType.multipleChoice;

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
    _promptController.dispose();
    _shortKeywordsController.dispose();
    _essayRubricController.dispose();
    _essayMaxWordsController.dispose();
    super.dispose();
  }

  // QuestionModel _createQuestion(QuestionType type) {
  //   return QuestionModel(
  //     id: DateTime.now().microsecondsSinceEpoch.toString(),
  //     type: type,
  //   );
  // }
  //
  // QuestionModel? get _activeQuestion =>
  //     questions.firstWhere((q) => q.id == activeId, orElse: () => questions[0]);
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
  //
  // void _moveQuestion(String id, int dir) {
  //   final idx = questions.indexWhere((q) => q.id == id);
  //   if (idx == -1) return;
  //   final newIdx = (idx + dir).clamp(0, questions.length - 1);
  //   if (newIdx == idx) return;
  //   setState(() {
  //     final item = questions.removeAt(idx);
  //     questions.insert(newIdx, item);
  //   });
  // }
  //
  // void _duplicateQuestion(String id) {
  //   final idx = questions.indexWhere((q) => q.id == id);
  //   if (idx == -1) return;
  //   setState(() {
  //     final copy = questions[idx].copyWithNewId(
  //       DateTime.now().microsecondsSinceEpoch.toString(),
  //     );
  //     questions.insert(idx + 1, copy);
  //     activeId = copy.id;
  //     _loadCurrentIntoControllers();
  //   });
  // }
  //
  // void _deleteQuestion(String id) {
  //   if (questions.length == 1) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Keep at least one question.')),
  //     );
  //     return;
  //   }
  //   final idx = questions.indexWhere((q) => q.id == id);
  //   if (idx == -1) return;
  //   setState(() {
  //     questions.removeAt(idx);
  //     if (activeId == id) {
  //       activeId = questions[(idx - 1).clamp(0, questions.length - 1)].id;
  //       _loadCurrentIntoControllers();
  //     }
  //   });
  // }

  int get _totalPoints =>
      quizEditorController.items.fold(0, (sum, q) => sum + (q.points < 0 ? 0 : q.points));

  String _typeLabel(QuizItemType t) {
    switch (t) {
      case QuizItemType.multipleChoice:
        return 'Multiple Choice';
      case QuizItemType.trueFalse:
        return 'True/False';
      case QuizItemType.shortAnswer:
        return 'Short Answer';
      case QuizItemType.essay:
        return 'Essay';
    }
  }

  // QuestionType _typeFromLabel(String label) {
  //   switch (label) {
  //     case 'True/False':
  //       return QuestionType.trueFalse;
  //     case 'Short Answer':
  //       return QuestionType.shortAnswer;
  //     case 'Essay':
  //       return QuestionType.essay;
  //     default:
  //       return QuestionType.multipleChoice;
  //   }
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
                        _buildQuestionsCard(),
                        const SizedBox(height: 16),
                        // _buildEditorCard(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 320, child: _buildQuestionsCard()),
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
              style: TextStyle(fontSize: 13, color: _sub),
            ),
          ],
        ),
        Row(
          children: [
            _headerButton('Preview'),
            const SizedBox(width: 8),
            _headerButton('Save Draft'),
            const SizedBox(width: 8),
            // _headerButton('Publish', primary: true, onTap: _onPublish),
          ],
        ),
      ],
    );
  }

  Widget _headerButton(
    String label, {
    bool primary = false,
    VoidCallback? onTap,
  }) {
    final bg = primary ? AppColors.purple : Colors.white;
    final fg = primary ? Colors.white : _ink;
    final borderColor = primary ? Colors.transparent : _border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsCard() {
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
                //TODO: questions should use QuizItemModel from data layer, not QuestionModel from this file - refactor to separate out the editor state management from the UI
                // ...questions.asMap().entries.map(
                //   (entry) => _buildQuestionListItem(
                //     index: entry.key,
                //     question: entry.value,
                //   ),
                // ),
                const SizedBox(height: 10),
                // Row(
                //   children: [
                //     Expanded(
                //       child: Container(
                //         padding: const EdgeInsets.symmetric(horizontal: 10),
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(10),
                //           border: Border.all(color: _border),
                //           color: Colors.white,
                //         ),
                //         child: DropdownButtonHideUnderline(
                //           child: DropdownButton<QuestionType>(
                //             value: newQuestionType,
                //             isExpanded: true,
                //             items: QuizItemType.values.map((type) {
                //               return DropdownMenuItem<QuestionType>(
                //                 value: type,
                //                 child: Text(_typeLabel(type)),
                //               );
                //             }).toList(),
                //             onChanged: (val) {
                //               if (val == null) return;
                //               setState(() => newQuestionType = val);
                //             },
                //           ),
                //         ),
                //       ),
                //     ),
                //     const SizedBox(width: 8),
                //     // _headerButton('+ New', onTap: _addQuestion),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionListItem({
    required int index,
    required QuizItemModel question,
  }) {
    final bool isActive = question.id == activeId;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? AppColors.gold : _border),
        boxShadow: isActive
            ? const [BoxShadow(color: _ring, blurRadius: 0, spreadRadius: 2)]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              // onTap: () => _setActive(question.id),
              onTap: (){},
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
                      'Q${index + 1}: ${_typeLabel(question.type)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Text(
                    //   question.prompt.isEmpty
                    //       ? 'Untitled question'
                    //       : question.prompt,
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: const TextStyle(fontSize: 11, color: _sub),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          // IconButton(
          //   icon: const Text('⬆️'),
          //   onPressed: () => _moveQuestion(question.id, -1),
          //   splashRadius: 18,
          // ),
          // IconButton(
          //   icon: const Text('⬇️'),
          //   onPressed: () => _moveQuestion(question.id, 1),
          //   splashRadius: 18,
          // ),
          // IconButton(
          //   icon: const Text('⎘'),
          //   onPressed: () => _duplicateQuestion(question.id),
          //   splashRadius: 18,
          // ),
          // IconButton(
          //   icon: const Text('🗑️'),
          //   onPressed: () => _deleteQuestion(question.id),
          //   splashRadius: 18,
          // ),
        ],
      ),
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
