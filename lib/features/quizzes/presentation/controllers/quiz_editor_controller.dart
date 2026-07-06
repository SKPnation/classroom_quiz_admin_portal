import 'dart:convert';

import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_snackbar.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/navigation_controller.dart';
import 'package:classroom_quiz_admin_portal/core/utils/functions.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_template.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/question_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_draft_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/published_quizzes_controller.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:http_parser/http_parser.dart';

class QuizEditorController extends GetxController {
  static QuizEditorController get instance => Get.find();

  final promptController = TextEditingController();
  final shortKeywordsController = TextEditingController();
  final essayRubricController = TextEditingController();
  final essayMaxWordsController = TextEditingController(text: '400');

  var isLoading = false.obs;

  final questionController = TextEditingController();
  final pointsController = TextEditingController();
  final draftTitleController = TextEditingController();

  RxList<GeneratedQuestion> generatedQuestions = <GeneratedQuestion>[].obs;
  var quizItems = <QuizItemModel>[].obs;

  Rx<QuizItemType> newQuestionType = QuizItemType.multipleChoice.obs;
  String apiKey = "";
  var activeId = "".obs;

  final RxList<QuizDraftModel> savedDrafts = <QuizDraftModel>[].obs;

  final RxString currentDraftId = ''.obs;
  final RxString currentDraftTitle = 'Untitled Quiz'.obs;

  String? uploadedPdfText;
  String? uploadedFileName;
  var isExtractingPdf = false.obs;

  QuizItemModel? get activeQuestion {
    // 1. Check if the list is empty first
    if (quizItems.isEmpty) return null;

    // 2. Try to find the active question
    return quizItems.firstWhere(
      (q) => q.id == activeId.value,
      // 3. Fallback to the first item only if the list isn't empty
      orElse: () => quizItems.first,
    );
  }

  int get totalPoints =>
      quizItems.fold(0, (sum, q) => sum + (q.points < 0 ? 0 : q.points));

  void getApiKey() {
    apiKey = const String.fromEnvironment('OPENAI_API_KEY');

    if (apiKey.isEmpty) {
      debugPrint("🚨 Warning: OpenAI API key not found in environment.");
    }

    OpenAI.apiKey = apiKey;
  }

  Future<void> onGenerate({
    QuizItemType? questionType,
    int questionCount = 10,
  }) async {
    final text = promptController.text.trim();

    // Allow generation if either a prompt is typed OR a PDF is uploaded
    if (text.isEmpty && uploadedPdfText == null) {
      CustomSnackBar.errorSnackBar(
        'Please enter a prompt or upload a PDF first.',
      );
      return;
    }

    isLoading.value = true;
    generatedQuestions.clear();

    // Build type instruction
    final typeInstruction = questionType != null
        ? 'Generate ONLY ${typeLabel(questionType)} questions. Do not generate any other type.'
        : 'Generate a mix of question types.';

    // Build full prompt
    final pdfContext = uploadedPdfText != null
        ? 'Use these notes as your PRIMARY source:\n\n$uploadedPdfText\n\n---\n\n'
        : '';

    // If no prompt typed but PDF uploaded, use a default instruction
    final userPrompt = text.isNotEmpty
        ? text
        : 'Generate questions from the provided notes.';

    final fullPrompt =
        '${pdfContext}Generate exactly $questionCount questions. '
        '$typeInstruction\n\n$userPrompt';

    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: 'gpt-3.5-turbo',
        responseFormat: {"type": "json_object"},
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                AppStrings.systemPrompt,
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                fullPrompt,
              ),
            ],
          ),
        ],
        temperature: 0.7,
        maxTokens: uploadedPdfText != null ? 3000 : 1500,
      );

      print("AI Response: ${chatCompletion.choices.first.message.content}");

      final jsonContent =
          chatCompletion.choices.first.message.content?.first.text;

      if (jsonContent != null) {
        final decodedJson = jsonDecode(jsonContent);

        List<dynamic> questionsList;
        if (decodedJson is List) {
          questionsList = decodedJson;
        } else if (decodedJson is Map &&
            decodedJson.values.any((v) => v is List)) {
          questionsList = decodedJson.values.firstWhere((v) => v is List);
        } else {
          throw Exception(
            "Could not find a list of questions in the AI response.",
          );
        }

        final generatedQuestions = questionsList.map((item) {
          return GeneratedQuestion(
            question: item['question'] ?? 'No question text',
            answer: item['answer'] ?? 'No answer text',
            options: item['options'] != null
                ? List<String>.from(item['options'])
                : null,
            questionType: item['question_type'] as String? ?? 'shortAnswer',
          );
        }).toList();

        this.generatedQuestions.addAll(generatedQuestions);
      }
    } catch (e) {
      print('Error generating questions: $e');
      CustomSnackBar.errorSnackBar('Error generating questions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Converts a single AI-generated question into the QuizItemModel shape
  /// used by the editor, and adds it via the existing addQuestion() flow.
  void addGeneratedQuestionToEditor(GeneratedQuestion gq) {
    final item = _generatedQuestionToQuizItem(gq);
    addQuestion(item);
  }

  /// Adds ALL currently generated questions into the editor at once,
  /// then clears generatedQuestions so they don't get added twice.
  void addAllGeneratedQuestionsToEditor() {
    if (generatedQuestions.isEmpty) {
      CustomSnackBar.errorSnackBar('No generated questions to add.');
      return;
    }

    for (final gq in generatedQuestions) {
      final item = _generatedQuestionToQuizItem(gq);
      quizItems.add(item);
    }

    // Select the last one added so the editor jumps to it
    if (quizItems.isNotEmpty) {
      activeId.value = quizItems.last.id;
    }

    quizItems.refresh();

    final addedCount = generatedQuestions.length;
    generatedQuestions.clear();

    CustomSnackBar.successSnackBar(
      body: '$addedCount question(s) added to quiz.',
    );
  }

  /// Removes a single question from the generated (AI) list without
  /// adding it to the editor — lets the lecturer discard ones they don't want.
  void dismissGeneratedQuestion(GeneratedQuestion gq) {
    generatedQuestions.remove(gq);
  }

  /// Internal: maps the AI's GeneratedQuestion shape onto QuizItemModel.
  QuizItemModel _generatedQuestionToQuizItem(GeneratedQuestion gq) {
    final type = _quizItemTypeFromString(gq.questionType);
    final options = gq.options ?? [];

    // For multipleChoice/trueFalse, figure out which option index matches
    // the AI's "answer" text so correctOptionIndexes is populated correctly.
    List<int> correctIndexes = [];
    if ((type == QuizItemType.multipleChoice ||
            type == QuizItemType.trueFalse) &&
        options.isNotEmpty) {
      final matchIndex = options.indexWhere(
        (opt) => opt.trim().toLowerCase() == gq.answer.trim().toLowerCase(),
      );
      if (matchIndex != -1) {
        correctIndexes = [matchIndex];
      }
    }

    return QuizItemModel(
      id: const Uuid().v4(),
      type: type,
      question: gq.question,
      answerKey: gq.answer,
      options: List<String>.from(options),
      correctOptionIndexes: correctIndexes,
      points: 1,
      createdAt: DateTime.now(),
    );
  }

  QuizItemType _quizItemTypeFromString(String value) {
    switch (value) {
      case 'multipleChoice':
        return QuizItemType.multipleChoice;
      case 'trueFalse':
        return QuizItemType.trueFalse;
      case 'essay':
        return QuizItemType.essay;
      case 'shortAnswer':
      default:
        return QuizItemType.shortAnswer;
    }
  }

  void addQuestion(QuizItemModel item) {
    quizItems.add(item);

    activeId.value = item.id;

    questionController.text = item.question;
    pointsController.text = item.points.toString();

    quizItems.refresh();
  }

  void moveQuestion(String id, int dir) {
    final idx = quizItems.indexWhere((q) => q.id == id);
    if (idx == -1) return;
    final newIdx = (idx + dir).clamp(0, quizItems.length - 1);
    if (newIdx == idx) return;
    final item = quizItems.removeAt(idx);
    quizItems.insert(newIdx, item);
  }

  void duplicateQuestion(String id) {
    // 1. Find the existing item
    final idx = quizItems.indexWhere((q) => q.id == id);
    if (idx == -1) return;

    final original = quizItems[idx];

    // 2. Create the copy
    final copy = original.copyWith(id: DateTime.now().toString());

    // 3. Insert and update state
    quizItems.insert(idx + 1, copy);
    activeId.value = copy.id;

    // 4. Refresh the UI controllers
    _loadCurrentIntoControllers();
  }

  void deleteQuestion(String id) {
    final idx = quizItems.indexWhere((q) => q.id == id);
    if (idx == -1) return;

    quizItems.removeAt(idx);

    if (quizItems.isEmpty) {
      // No questions left — clear active selection
      activeId.value = '';
      questionController.clear();
      pointsController.clear();
      return;
    }

    if (activeId.value == id) {
      // Select the previous item, or first if we deleted the first
      final newIdx = (idx - 1).clamp(0, quizItems.length - 1);
      activeId.value = quizItems[newIdx].id;
      _loadCurrentIntoControllers();
    }
  }

  void _loadCurrentIntoControllers() {
    final q = activeQuestion;
    if (q == null) return;
    // promptController.text = q.question;

    //TODO: uncomment after you've added these fields to the QuizItemModel
    // shortKeywordsController.text = q.shortKeywords;
    // essayRubricController.text = q.essayRubric;
    // essayMaxWordsController.text = q.maxWords.toString();
  }

  void removeItem(String id) {
    quizItems.removeWhere((e) => e.id == id);
  }

  void clearItems() => quizItems.clear();

  void setCurrentQuizItem({required QuizItemModel quizItem}) {
    activeId.value = quizItem.id;
  }

  List<QuizItemModel> cloneQuizItems(List<QuizItemModel> source) {
    return source.map((q) {
      return QuizItemModel(
        id: q.id,
        type: q.type,
        question: q.question,
        answerKey: q.answerKey,
        options: List<String>.from(q.options ?? []),
        points: q.points,
        createdAt: q.createdAt,
      );
    }).toList();
  }

  void saveCurrentDraft() {
    final now = DateTime.now();

    final title = currentDraftTitle.value.trim().isEmpty
        ? 'Untitled Quiz'
        : currentDraftTitle.value.trim();

    final itemsCopy = cloneQuizItems(List<QuizItemModel>.from(quizItems));

    if (currentDraftId.value.isNotEmpty) {
      final index = savedDrafts.indexWhere((d) => d.id == currentDraftId.value);
      if (index != -1) {
        savedDrafts[index] = savedDrafts[index].copyWith(
          title: title,
          items: itemsCopy,
          savedAt: now,
        );
        savedDrafts.refresh();
        return;
      }
    }

    final draft = QuizDraftModel(
      id: const Uuid().v4(),
      title: title,
      items: itemsCopy,
      savedAt: now,
    );

    currentDraftId.value = draft.id;
    savedDrafts.insert(0, draft);
  }

  void loadDraft(QuizDraftModel draft) {
    currentDraftId.value = draft.id;
    currentDraftTitle.value = draft.title;
    draftTitleController.text = currentDraftTitle.value;

    final clonedItems = cloneQuizItems(draft.items);

    quizItems.assignAll(clonedItems);

    if (quizItems.isNotEmpty) {
      activeId.value = quizItems.first.id;
    } else {
      activeId.value = '';
    }

    final active = activeQuestion;
    if (active != null) {
      questionController.text = active.question;
      pointsController.text = active.points.toString();
    } else {
      questionController.clear();
      pointsController.clear();
    }

    quizItems.refresh();
  }

  Future<void> publishDraft(
    QuizDraftModel draft,
    NavigationController navigationController,
  ) async {
    final templatesController = PublishedQuizzesController.instance;
    final userInfoCache = storage.read(GetStoreKeys.userKey);
    final userModel = UserModel.fromJson(userInfoCache);

    final template = PublishedQuiz(
      id: draft.id,
      title: draft.title.trim().isEmpty ? 'Untitled Quiz' : draft.title.trim(),
      description: 'Published from saved draft',
      subject: 'Mathematics',
      type: 'Quiz',
      level: 'Intro',
      items: draft.items.map((q) {
        return q.copyWith(
          options: List<String>.from(q.options),
          correctOptionIndexes: List<int>.from(q.correctOptionIndexes),
        );
      }).toList(),
      publishedAt: DateTime.now(),
      tags: const ['Published'],
      createdBy: userModel.uid,
    );

    await templatesController.publishTemplate(template);

    navigationController.navigateTo(Routes.publishedQuizzesRoute);

    Future.delayed(
      Duration(milliseconds: 800),
      () => Get.snackbar('Added', 'Question added to Quiz Editor'),
    );
  }

  Future<void> publishQuiz(NavigationController navigationController) async {
    final userInfoCache = storage.read(GetStoreKeys.userKey);
    final userModel = UserModel.fromJson(userInfoCache);

    if (quizItems.isEmpty) {
      CustomSnackBar.errorSnackBar(
        'Add at least one question before publishing.',
      );
      return;
    }

    final hasValidQuestion = quizItems.any((q) => q.question.trim().isNotEmpty);

    if (!hasValidQuestion) {
      CustomSnackBar.errorSnackBar(
        'Enter at least one question before publishing.',
      );
      return;
    }

    final templatesController = PublishedQuizzesController.instance;

    final title = currentDraftTitle.value.trim().isEmpty
        ? 'Untitled Quiz'
        : currentDraftTitle.value.trim();

    final templateId = currentDraftId.value.isNotEmpty
        ? currentDraftId.value
        : const Uuid().v4();

    final copiedItems = quizItems.map((q) {
      return QuizItemModel(
        id: q.id,
        type: q.type,
        question: q.question,
        answerKey: q.answerKey,
        options: List<String>.from(q.options),
        correctOptionIndexes: List<int>.from(q.correctOptionIndexes),
        points: q.points,
        createdAt: q.createdAt,
      );
    }).toList();

    final template = PublishedQuiz(
      id: templateId,
      title: title,
      description: 'Published from quiz editor',
      subject: 'Mathematics',
      type: 'Quiz',
      level: 'Intro',
      items: copiedItems,
      publishedAt: DateTime.now(),
      createdBy: userModel.uid,
      tags: const ['Published'],
    );

    await templatesController.publishTemplate(template);

    navigationController.navigateTo(Routes.publishedQuizzesRoute);

    Future.delayed(
      Duration(milliseconds: 800),
      () =>
          CustomSnackBar.successSnackBar(body: 'Quiz published successfully.'),
    );
  }

  void duplicateDraft(QuizDraftModel draft) {
    final duplicate = QuizDraftModel(
      id: const Uuid().v4(),
      title: '${draft.title} (Copy)',
      items: cloneQuizItems(draft.items),
      savedAt: DateTime.now(),
    );

    savedDrafts.insert(0, duplicate);
  }

  void deleteDraft(String draftId) {
    savedDrafts.removeWhere((d) => d.id == draftId);

    if (currentDraftId.value == draftId) {
      currentDraftId.value = '';
      currentDraftTitle.value = 'Untitled Quiz';
    }
  }

  void startNewQuiz() {
    currentDraftId.value = '';
    currentDraftTitle.value = 'Untitled Quiz';
    draftTitleController.text = currentDraftTitle.value;

    clearItems();

    final newItem = QuizItemModel(
      id: const Uuid().v4(),
      type: QuizItemType.shortAnswer,
      question: '',
      answerKey: '',
      options: [],
      points: 1,
      createdAt: DateTime.now(),
    );

    quizItems.add(newItem);
    activeId.value = newItem.id;

    questionController.text = '';
    pointsController.text = '1';

    quizItems.refresh();
  }
}
