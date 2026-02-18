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
  var isLoading = false.obs;

  RxList<GeneratedQuestion> generatedQuestions = <GeneratedQuestion>[].obs;
  var quizItems = <QuizItemModel>[].obs;

  // In ai_generator.dart
  // Use this instead of AppConfig.openAiApiKey
  String apiKey = "";

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

    //-----------------------------------------------------

    // Simulate AI call
    // await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
    //
    // final mock = <_GeneratedQuestion>[
    //   _GeneratedQuestion(
    //     question:
    //         'What process converts light energy into chemical energy in plants?',
    //     answer: 'Photosynthesis',
    //   ),
    //   _GeneratedQuestion(
    //     question: 'Which pigment in leaves captures light energy?',
    //     answer: 'Chlorophyll',
    //   ),
    //   _GeneratedQuestion(
    //     question: 'In which cell organelle does photosynthesis occur?',
    //     answer: 'Chloroplast',
    //   ),
    //   _GeneratedQuestion(
    //     question: 'Name the gas released during photosynthesis.',
    //     answer: 'Oxygen',
    //   ),
    //   _GeneratedQuestion(
    //     question: 'What is the main product of photosynthesis?',
    //     answer: 'Glucose',
    //   ),
    // ];
    //
    // setState(() {
    //   _questions.addAll(mock);
    //   _isLoading = false;
    // });
  }

  // void addItemFromAi({
  //   required String questionText,
  //   required String answerText,
  // }) {
  //   items.add(
  //     QuizItemModel(
  //       id: const Uuid().v4(),
  //       type: QuizItemType.shortAnswer,
  //       question: questionText,
  //       answerKey: answerText,
  //       points: 1,
  //       createdAt: DateTime.now(),
  //     ),
  //   );
  // }

  void addQuestion(QuizItemModel item) {
    quizItems.add(item);
  }

  void removeItem(String id) {
    quizItems.removeWhere((e) => e.id == id);
  }

  void clearItems() => quizItems.clear();
}
