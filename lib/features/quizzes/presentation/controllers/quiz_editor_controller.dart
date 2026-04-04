import 'dart:convert';

import 'package:classroom_quiz_admin_portal/core/global/custom_snackbar.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_template.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/question_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_draft_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/templates_controller.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class QuizEditorController extends GetxController {
  static QuizEditorController get instance => Get.find();

  final TextEditingController promptController = TextEditingController();
  final TextEditingController shortKeywordsController = TextEditingController();
  final TextEditingController essayRubricController = TextEditingController();
  final TextEditingController essayMaxWordsController = TextEditingController(
    text: '400',
  );

  var isLoading = false.obs;

  final TextEditingController questionController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();
  final TextEditingController draftTitleController = TextEditingController();

  RxList<GeneratedQuestion> generatedQuestions = <GeneratedQuestion>[].obs;
  var quizItems = <QuizItemModel>[].obs;

  Rx<QuizItemType> newQuestionType = QuizItemType.multipleChoice.obs;
  String apiKey = "";
  var activeId = "".obs;

  final RxList<QuizDraftModel> savedDrafts = <QuizDraftModel>[].obs;

  final RxString currentDraftId = ''.obs;
  final RxString currentDraftTitle = 'Untitled Quiz'.obs;

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

  Future<void> onGenerate() async {
    final text = promptController.text.trim();
    if (text.isEmpty) {
      CustomSnackBar.errorSnackBar('Please enter a prompt first.');

      return;
    }

    isLoading.value = true;
    generatedQuestions.clear();

    try {
      // We instruct the AI to return a JSON list. This makes parsing reliable.
      final systemPrompt = '''
You are a helpful assistant that generates quiz questions.
Respond with a valid JSON list of objects.
Each object must have two keys: "question" (string), "answer" (string), if multi-choice, list the options, question_type (shortAnswer, multipleChoice, trueFalse, essay). 
Do not include any text outside of the JSON list.
''';

      // Create the chat completion request
      final chatCompletion = await OpenAI.instance.chat.create(
        model: 'gpt-3.5-turbo',
        // Or 'gpt-4' if you have access
        responseFormat: {"type": "json_object"},
        // Enforce JSON output
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                systemPrompt,
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(text),
            ],
          ),
        ],
        temperature: 0.7,
        // Adjust for creativity vs. predictability
        maxTokens: 1500,
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
            questionType: item['question_type'],
          );
        }).toList();

        this.generatedQuestions.addAll(generatedQuestions);
      }
    } catch (e) {
      // Handle potential errors from the API call or JSON parsing
      print('Error generating questions: $e');
      CustomSnackBar.errorSnackBar('Error generating questions: $e');
    } finally {
      // Ensure the loading indicator is always turned off
      isLoading.value = false;
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
    // if (quizItems.length == 1) {
    //   CustomSnackBar.errorSnackBar('Keep at least one question.')
    //   return;
    // }
    final idx = quizItems.indexWhere((q) => q.id == id);
    if (idx == -1) return;
    quizItems.removeAt(idx);
    if (activeId.value == id) {
      activeId.value = quizItems[(idx - 1).clamp(0, quizItems.length - 1)].id;
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

  void publishDraft(QuizDraftModel draft) {
    final templatesController = TemplatesController.instance;

    final template = PublishedQuizTemplate(
      id: draft.id,
      title: draft.title.trim().isEmpty ? 'Untitled Quiz' : draft.title.trim(),
      description: 'Published from saved draft',
      subject: 'Mathematics',
      type: 'Quiz',
      level: 'Intro',
      items: draft.items.map((q) => q.copyWith(
        options: List<String>.from(q.options),
        correctOptionIndexes: List<int>.from(q.correctOptionIndexes),
      )).toList(),
      publishedAt: DateTime.now(),
      tags: const ['Published'],
    );

    templatesController.publishTemplate(template);
  }

  void publishQuiz() {
    if (quizItems.isEmpty) {
      CustomSnackBar.errorSnackBar('Add at least one question before publishing.');
      return;
    }

    final hasValidQuestion = quizItems.any((q) => q.question.trim().isNotEmpty);

    if (!hasValidQuestion) {
      CustomSnackBar.errorSnackBar('Enter at least one question before publishing.');
      return;
    }

    final templatesController = TemplatesController.instance;

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

    templatesController.publishTemplate(
      PublishedQuizTemplate(
        id: templateId,
        title: title,
        description: 'Published from quiz editor',
        subject: 'Mathematics',
        type: 'Quiz',
        level: 'Intro',
        items: copiedItems,
        publishedAt: DateTime.now(),
        tags: const ['Published'],
      ),
    );

    CustomSnackBar.successSnackBar(body: 'Quiz published successfully.');
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
