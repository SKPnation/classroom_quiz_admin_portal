import 'package:classroom_quiz_admin_portal/core/global/custom_snackbar.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/draft_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SavedDraftsSection extends StatelessWidget {
  const SavedDraftsSection({
    super.key,
    required this.quizEditorController,
  });

  final QuizEditorController quizEditorController;

  static const _card = Colors.white;
  static const _border = Color(0xFFE5E7EB);
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _radius = 14.0;
  static const _blue = Color(0xFF2563EB);
  static const _badgeBg = Color(0xFFEEF2FF);
  static const _badgeText = Color(0xFF3730A3);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final drafts = quizEditorController.savedDrafts;

      return Container(
        width: double.infinity,
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Drafts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Continue editing unpublished quizzes.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _sub,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          quizEditorController.saveCurrentDraft();
                          CustomSnackBar.successSnackBar(body: 'Draft saved');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Save Draft', style: TextStyle(color: _ink)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          quizEditorController.startNewQuiz();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('+ New Quiz'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: _border),
              const SizedBox(height: 14),

              if (drafts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                    color: const Color(0xFFF9FAFB),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.description_outlined,
                          size: 32, color: _sub),
                      SizedBox(height: 10),
                      Text(
                        'No saved drafts yet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your saved quiz drafts will appear here.',
                        style: TextStyle(
                          fontSize: 12,
                          color: _sub,
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 210,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: drafts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final draft = drafts[index];
                      final isActive =
                          quizEditorController.currentDraftId.value == draft.id;

                      return DraftCard(
                        draft: draft,
                        isActive: isActive,
                        onOpen: () {
                          quizEditorController.loadDraft(draft);
                          CustomSnackBar.successSnackBar(
                            body: 'Draft loaded: ${draft.title}',
                          );
                        },
                        onDuplicate: () {
                          quizEditorController.duplicateDraft(draft);
                          CustomSnackBar.successSnackBar(body: 'Draft duplicated');
                        },
                        onDelete: () {
                          quizEditorController.deleteDraft(draft.id);
                          CustomSnackBar.successSnackBar(body: 'Draft deleted');
                        },
                        onPublish: () {
                          quizEditorController.publishDraft(draft);
                          CustomSnackBar.successSnackBar(body: 'Quiz published');
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}