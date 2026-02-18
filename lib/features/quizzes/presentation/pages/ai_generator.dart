import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/navigation_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/question_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class AiQuestionGeneratorPage extends StatefulWidget {
  const AiQuestionGeneratorPage({super.key});

  @override
  State<AiQuestionGeneratorPage> createState() =>
      _AiQuestionGeneratorPageState();
}

class _AiQuestionGeneratorPageState extends State<AiQuestionGeneratorPage> {
  final quizEditorController = QuizEditorController.instance;
  final menuController = MenController.instance;
  final navigationController = NavigationController.instance;

  @override
  void initState() {
    // OpenAI.apiKey = AppConfig.openAiApiKey;
    quizEditorController.getApiKey();

    super.initState();
  }

  @override
  void dispose() {
    quizEditorController.promptController.dispose();
    super.dispose();
  }

  void _onClear() {
    quizEditorController.promptController.clear();
    quizEditorController.generatedQuestions
      ..clear()
      ..add(
        const GeneratedQuestion(
          question: 'Prompt cleared. Enter a new one to start again.',
          answer: '',
          options: null,
          isEmptyMessage: true,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F7FB);
    const card = Colors.white;
    const ink = Color(0xFF111827);
    const sub = Color(0xFF6B7280);
    const border = Color(0xFFE5E7EB);
    const blue = Color(0xFF2563EB);
    const radius = 14.0;

    return Obx(() {
      final isLoading = quizEditorController.isLoading.value;
      final generatedQuestions = quizEditorController.generatedQuestions;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & description
            const Text(
              'AI Question Generator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Describe the topic or objectives below, and the AI will generate multiple quiz generatedQuestions you can review and add to your quiz.',
              style: TextStyle(fontSize: 14, color: sub),
            ),
            const SizedBox(height: 24),

            // Prompt card
            Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: border),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 3,
                    offset: Offset(0, 1),
                    color: Color.fromARGB(10, 0, 0, 0),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prompt',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: quizEditorController.promptController,
                    maxLines: null,
                    minLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'e.g. Generate 5 multiple-choice questions about photosynthesis for first-year biology students.',
                      hintStyle: const TextStyle(fontSize: 15, color: sub),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: blue, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Btn(
                        label: "Clear",
                        width: 100,
                        onPressed: () => isLoading ? null : _onClear,
                      ),
                      const SizedBox(width: 10),

                      Btn(
                        label: "Generate Questions",
                        width: 180,
                        onPressed: () {
                          if (!isLoading) {
                            quizEditorController.onGenerate();
                          }
                        },
                        primary: true,
                      ),
                    ],
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        '🧠 AI is generating your questions...',
                        style: TextStyle(fontSize: 14, color: sub),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Results card
            Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: border),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 3,
                    offset: Offset(0, 1),
                    color: Color.fromARGB(10, 0, 0, 0),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Generated Questions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (generatedQuestions.isEmpty)
                    const Text(
                      'No generatedQuestions yet. Enter a prompt and click “Generate Questions”.',
                      style: TextStyle(fontSize: 14, color: sub),
                    )
                  else
                    Column(
                      children: generatedQuestions
                          .map(
                            (q) => Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: border),
                              ),
                              child: q.isEmptyMessage
                                  ? Text(
                                      q.question,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: sub,
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          q.question,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: ink,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        if(q.questionType == 'multipleChoice' && q.options != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Options:',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: ink,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              ...q.options!.map(
                                                (opt) => Text(
                                                  '- $opt',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: sub,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                            ],
                                          ),
                                        Text(
                                          'AI Answer: ${q.answer}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: sub,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        OutlinedButton(
                                          onPressed: () {
                                            quizEditorController.addQuestion(
                                              QuizItemModel(
                                                id: const Uuid().v4(),
                                                type: QuizItemType.values.firstWhere(
                                                  (e) =>
                                                      e.name ==
                                                      q.questionType,
                                                  orElse: () =>
                                                      QuizItemType.shortAnswer,
                                                ),
                                                options: q.options ?? [],
                                                question: q.question,
                                                answerKey: q.answer,
                                                points: 1,
                                                createdAt: DateTime.now(),
                                              ),
                                            );

                                            //Example; For multi-choice
                                            // aiGeneratorController.addQuestion(
                                            //   QuizItemModel(
                                            //     id: const Uuid().v4(),
                                            //     type: QuizItemType.multipleChoice,
                                            //     question: "Which is correct?",
                                            //     options: ["A", "B", "C", "D"],
                                            //     correctOptionIndexes: [1],
                                            //     createdAt: DateTime.now(),
                                            //   ),
                                            // );

                                            Get.snackbar(
                                              'Added',
                                              'Question added to Quiz Editor',
                                            );

                                            menuController.changeActiveItemTo(
                                              Routes.quizEditorDisplayName,
                                              Routes.quizEditorRoute,
                                            );

                                            navigationController.navigateTo(Routes.quizEditorRoute);

                                            print(quizEditorController.quizItems);

                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            side: const BorderSide(
                                              color: border,
                                            ),
                                            foregroundColor: ink,
                                          ),
                                          child: const Text(
                                            '+ Add to Quiz',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          )
                          .toList(),
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
