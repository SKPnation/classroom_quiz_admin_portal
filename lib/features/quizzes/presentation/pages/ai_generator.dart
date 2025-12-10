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

    // Simulate AI call
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    final mock = <_GeneratedQuestion>[
      _GeneratedQuestion(
        question:
        'What process converts light energy into chemical energy in plants?',
        answer: 'Photosynthesis',
      ),
      _GeneratedQuestion(
        question: 'Which pigment in leaves captures light energy?',
        answer: 'Chlorophyll',
      ),
      _GeneratedQuestion(
        question: 'In which cell organelle does photosynthesis occur?',
        answer: 'Chloroplast',
      ),
      _GeneratedQuestion(
        question: 'Name the gas released during photosynthesis.',
        answer: 'Oxygen',
      ),
      _GeneratedQuestion(
        question: 'What is the main product of photosynthesis?',
        answer: 'Glucose',
      ),
    ];

    setState(() {
      _questions.addAll(mock);
      _isLoading = false;
    });
  }

  void _onClear() {
    setState(() {
      _promptController.clear();
      _questions
        ..clear()
        ..add(
          const _GeneratedQuestion(
            question:
            'Prompt cleared. Enter a new one to start again.',
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
            style: TextStyle(
              fontSize: 14,
              color: sub,
            ),
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
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      color: sub,
                    ),
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
                      borderSide: const BorderSide(
                        color: blue,
                        width: 1.5,
                      ),
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
                    OutlinedButton(
                      onPressed: _isLoading ? null : _onClear,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: border),
                        foregroundColor: ink,
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _onGenerate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Generate Questions',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                  )
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
                        margin:
                        const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(12),
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
                              style:
                              OutlinedButton.styleFrom(
                                padding: const EdgeInsets
                                    .symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                      8),
                                ),
                                side: const BorderSide(
                                    color: border),
                                foregroundColor: ink,
                              ),
                              child: const Text(
                                '+ Add to Quiz',
                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.w600,
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
