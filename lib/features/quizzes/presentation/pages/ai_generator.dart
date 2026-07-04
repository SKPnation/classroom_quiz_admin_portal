// ═══════════════════════════════════════════════════════════════════════
// MODIFIED FILE: lib/features/quizzes/presentation/pages/ai_generator.dart
// ═══════════════════════════════════════════════════════════════════════
//
// Changes from original:
// 1. Added file upload button (PDF / Word) above the prompt TextField
// 2. When a file is picked, it's sent to extractNotesText Firebase Function
//    and the returned text is placed into promptController automatically
// 3. Everything else (Generate, Clear, results display) is unchanged
//
// ADD TO pubspec.yaml:
//   file_picker: ^8.0.0
//
// Then run: flutter pub get

import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/navigation_controller.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/config.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/question_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:file_picker/file_picker.dart';
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

  // ── NEW: tracks whether a file is currently being uploaded/extracted ──
  bool _isExtracting = false;
  String? _uploadedFileName;

  @override
  void initState() {
    // OpenAI.apiKey = AppConfig
    //     .openAiApiKey; //TODO: Use for testing only, remove before production
    quizEditorController.getApiKey();
    super.initState();
  }

  void _onClear() {
    quizEditorController.promptController.clear();
    setState(() {
      _uploadedFileName = null;
    });
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

  // ── NEW: pick a file and extract its text via Firebase Function ──────────
  Future<void> _onUploadFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: true, // needed for web
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;

    if (bytes == null) {
      Get.snackbar(
        'Upload Failed',
        'Could not read file bytes.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isExtracting = true;
      _uploadedFileName = file.name;
    });

    try {
      final extractedText = await quizEditorController.extractTextFromFile(
        fileBytes: bytes,
        fileName: file.name,
      );

      if (extractedText.isEmpty) {
        Get.snackbar(
          'Extraction Failed',
          'No readable text found in the file.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Put extracted text into the prompt field so lecturer can review/edit
      quizEditorController.promptController.text = extractedText;

      Get.snackbar(
        'File Loaded',
        '${file.name} — text extracted successfully. Review and click Generate.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Extraction Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isExtracting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Describe the topic below, or upload a PDF/Word file to generate questions from your lecture notes.',
              style: TextStyle(fontSize: 14, color: sub),
            ),
            const SizedBox(height: 24),

            // ── Prompt card ────────────────────────────────────────────────
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
                  // ── NEW: File upload section ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.purple.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.upload_file_rounded,
                          size: 20,
                          color: AppColors.purple,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Upload lecture notes',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: ink,
                                ),
                              ),
                              Text(
                                _uploadedFileName != null
                                    ? '📄 $_uploadedFileName'
                                    : 'PDF or Word (.docx) - text will be extracted automatically',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _uploadedFileName != null
                                      ? AppColors.purple
                                      : sub,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _isExtracting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.purple,
                                ),
                              )
                            : OutlinedButton.icon(
                                onPressed: _onUploadFile,
                                icon: const Icon(Icons.attach_file, size: 16),
                                label: Text(
                                  _uploadedFileName != null
                                      ? 'Change File'
                                      : 'Choose File',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.purple,
                                  side: const BorderSide(
                                    color: AppColors.purple,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Divider with OR label ────────────────────────────────
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR TYPE A PROMPT',
                          style: TextStyle(
                            fontSize: 11,
                            color: sub,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Prompt text field (unchanged) ────────────────────────
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

                  // ── Buttons (unchanged) ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Btn(
                        label: "Clear",
                        width: 100,
                        onPressed: () {
                          if (!isLoading && !_isExtracting) _onClear();
                        },
                      ),
                      const SizedBox(width: 10),
                      Btn(
                        label: "Generate Questions",
                        width: 180,
                        onPressed: () {
                          if (!isLoading && !_isExtracting) {
                            quizEditorController.onGenerate();
                          }
                        },
                        primary: true,
                      ),
                    ],
                  ),
                  if (isLoading || _isExtracting) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        _isExtracting
                            ? '📄 Extracting text from file...'
                            : '🧠 AI is generating your questions...',
                        style: const TextStyle(fontSize: 14, color: sub),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Results card (unchanged from your original) ────────────────
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
                      'No questions yet. Enter a prompt or upload a file and click "Generate Questions".',
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
                                        if (q.questionType ==
                                                'multipleChoice' &&
                                            q.options != null)
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
                                            QuizItemModel quizItemModel =
                                                QuizItemModel(
                                                  id: const Uuid().v4(),
                                                  type: QuizItemType.values
                                                      .firstWhere(
                                                        (e) =>
                                                            e.name ==
                                                            q.questionType,
                                                        orElse: () =>
                                                            QuizItemType
                                                                .shortAnswer,
                                                      ),
                                                  options: q.options ?? [],
                                                  question: q.question,
                                                  answerKey: q.answer,
                                                  points: 1,
                                                  createdAt: DateTime.now(),
                                                );

                                            quizEditorController.addQuestion(
                                              quizItemModel,
                                            );

                                            quizEditorController
                                                .setCurrentQuizItem(
                                                  quizItem: quizItemModel,
                                                );

                                            menuController.changeActiveItemTo(
                                              Routes.quizEditorDisplayName,
                                              Routes.quizEditorRoute,
                                            );

                                            navigationController.navigateTo(
                                              Routes.quizEditorRoute,
                                            );

                                            Future.delayed(
                                              const Duration(milliseconds: 800),
                                              () => Get.snackbar(
                                                'Added',
                                                'Question added to Quiz Editor',
                                              ),
                                            );
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
