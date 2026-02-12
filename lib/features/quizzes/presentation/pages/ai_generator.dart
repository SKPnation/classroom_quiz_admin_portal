import 'dart:convert';

import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

class AiQuestionGeneratorPage extends StatefulWidget {
  const AiQuestionGeneratorPage({super.key});

  @override
  State<AiQuestionGeneratorPage> createState() =>
      _AiQuestionGeneratorPageState();
}

class _AiQuestionGeneratorPageState extends State<AiQuestionGeneratorPage> {
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;

  final List<_GeneratedQuestion> _questions = [];

  // In ai_generator.dart
// Use this instead of AppConfig.openAiApiKey
  final apiKey = const String.fromEnvironment('OPENAI_API_KEY');

  @override
  void initState() {
    // OpenAI.apiKey = AppConfig.openAiApiKey;
    OpenAI.apiKey = apiKey;

    super.initState();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _onGenerate() async {
    final text = _promptController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _questions.clear();
    });

    try {
      // We instruct the AI to return a JSON list. This makes parsing reliable.
      final systemPrompt = '''
You are a helpful assistant that generates quiz questions.
Respond with a valid JSON list of objects.
Each object must have two keys: "question" (string) and "answer" (string).
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
          return _GeneratedQuestion(
            question: item['question'] ?? 'No question text',
            answer: item['answer'] ?? 'No answer text',
          );
        }).toList();

        setState(() {
          _questions.addAll(generatedQuestions);
        });
      }
    } catch (e) {
      // Handle potential errors from the API call or JSON parsing
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating questions: $e')));
    } finally {
      // Ensure the loading indicator is always turned off
      setState(() {
        _isLoading = false;
      });
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

  void _onClear() {
    setState(() {
      _promptController.clear();
      _questions
        ..clear()
        ..add(
          const _GeneratedQuestion(
            question: 'Prompt cleared. Enter a new one to start again.',
            answer: '',
            isEmptyMessage: true,
          ),
        );
    });
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
            'Describe the topic or objectives below, and the AI will generate multiple quiz questions you can review and add to your quiz.',
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
                  controller: _promptController,
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
                      onPressed: () => _isLoading ? null : _onClear,
                    ),
                    const SizedBox(width: 10),

                    Btn(
                      label: "Generate Questions",
                      width: 180,
                      onPressed: (){
                        if(!_isLoading){
                          _onGenerate();
                        }
                      },
                      // onPressed: () => _isLoading ? null : _onGenerate,
                      primary: true,
                    ),
                  ],
                ),
                if (_isLoading) ...[
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
                if (_questions.isEmpty)
                  const Text(
                    'No questions yet. Enter a prompt and click “Generate Questions”.',
                    style: TextStyle(fontSize: 14, color: sub),
                  )
                else
                  Column(
                    children: _questions
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
                                          // TODO: hook into your quiz editor
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          side: const BorderSide(color: border),
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
  }
}

class _GeneratedQuestion {
  final String question;
  final String answer;
  final bool isEmptyMessage;

  const _GeneratedQuestion({
    required this.question,
    required this.answer,
    this.isEmptyMessage = false,
  });
}
