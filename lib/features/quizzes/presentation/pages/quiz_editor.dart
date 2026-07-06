import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_template.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/published_quizzes_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/editor_card.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/generated_questions_panel.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/quiz_editor_question_card.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/saved_drafts_section.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

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
  final publishedQuizController = PublishedQuizzesController.instance;

  @override
  void dispose() {
    // quizEditorController.shortKeywordsController.dispose();
    // quizEditorController.essayRubricController.dispose();
    // quizEditorController.essayMaxWordsController.dispose();
    super.dispose();
  }

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
              SavedDraftsSection(quizEditorController: quizEditorController),
              const SizedBox(height: 16),

              // AI generated questions — visible only when generatedQuestions is non-empty
              Obx(() {
                if (quizEditorController.generatedQuestions.isEmpty) {
                  return const SizedBox.shrink();
                }
                return const GeneratedQuestionsPanel();
              }),

              Obx(
                () => publishedQuizController.isLoading.value
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox.shrink(),
              ),

              isNarrow
                  ? Column(
                      children: [
                        QuizEditorQuestionCard(),
                        const SizedBox(height: 16),
                        BuildEditorCard(
                          quizEditorController: quizEditorController,
                        ),
                      ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: quizEditorController.draftTitleController,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Untitled Quiz',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (val) {
                    quizEditorController.currentDraftTitle.value =
                        val.trim().isEmpty ? 'Untitled Quiz' : val.trim();
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () async {
                    if (quizEditorController.quizItems.isEmpty) return;

                    // Ensure controller is initialised before using it
                    if (!Get.isRegistered<PublishedQuizzesController>()) {
                      Get.put(PublishedQuizzesController());
                    }

                    final userInfoCache = storage.read(GetStoreKeys.userKey);
                    final userModel = UserModel.fromJson(userInfoCache);
                    final title = quizEditorController.currentDraftTitle.value.trim().isEmpty
                        ? 'Untitled Quiz'
                        : quizEditorController.currentDraftTitle.value.trim();

                    final quiz = PublishedQuiz(
                      id: quizEditorController.currentDraftId.value.isNotEmpty
                          ? quizEditorController.currentDraftId.value
                          : const Uuid().v4(),
                      title: title,
                      description: 'Published from quiz editor',
                      subject: 'Mathematics',
                      type: 'Quiz',
                      level: 'Intro',
                      items: quizEditorController.quizItems
                          .map(
                            (q) => q.copyWith(
                          options: List<String>.from(q.options),
                          correctOptionIndexes: List<int>.from(q.correctOptionIndexes),
                        ),
                      )
                          .toList(),
                      publishedAt: DateTime.now(),
                      createdBy: userModel.uid,
                      tags: const ['Published'],
                    );

                    PublishedQuizzesController.instance.onUseTemplate(quiz, context);
                  },
                  child: const Text('Publish Quiz'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          const Text(
            'Build questions, set answers & points, then publish.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
