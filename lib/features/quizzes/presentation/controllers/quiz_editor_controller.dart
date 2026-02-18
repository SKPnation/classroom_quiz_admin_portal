import 'dart:convert';

import 'package:classroom_quiz_admin_portal/core/global/custom_snackbar.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/question_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizEditorController extends GetxController {
  static QuizEditorController get instance => Get.find();

  final TextEditingController promptController = TextEditingController();
  final TextEditingController shortKeywordsController = TextEditingController();
  final TextEditingController essayRubricController = TextEditingController();
  final TextEditingController essayMaxWordsController = TextEditingController(
    text: '400',
  );

  var isLoading = false.obs;

  RxList<GeneratedQuestion> generatedQuestions = <GeneratedQuestion>[].obs;
  var quizItems = <QuizItemModel>[].obs;

  Rx<QuizItemType> newQuestionType = QuizItemType.multipleChoice.obs;
  String apiKey = "";
  var activeId = "".obs;

  QuizItemModel? get _activeQuestion =>
      quizItems.firstWhere((q) => q.id == activeId, orElse: () => quizItems[0]);

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
        maxTokens: 500,
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
      CustomSnackBar.errorSnackBar('Error generating questions: $e');
    } finally {
      // Ensure the loading indicator is always turned off
      isLoading.value = false;
    }
  }

  void addQuestion(QuizItemModel item) {
    quizItems.add(item);
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
    final idx = quizItems.indexWhere((q) => q.id == id);
    if (idx == -1) return;
    final copy = quizItems[idx].copyWithNewId(
      DateTime.now().microsecondsSinceEpoch.toString(),
    );
    quizItems.insert(idx + 1, copy);
    activeId = copy.id;
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
    final q = _activeQuestion;
    if (q == null) return;
    promptController.text = q.question;

    //TODO: uncomment after you've added these fields to the QuizItemModel
    // shortKeywordsController.text = q.shortKeywords;
    // essayRubricController.text = q.essayRubric;
    // essayMaxWordsController.text = q.maxWords.toString();
  }

  void removeItem(String id) {
    quizItems.removeWhere((e) => e.id == id);
  }

  void clearItems() => quizItems.clear();
}
