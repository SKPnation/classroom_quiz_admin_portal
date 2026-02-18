class GeneratedQuestion {
  final String question;
  final String answer;
  final List<String>? options;
  final String questionType;

  final bool isEmptyMessage;

  const GeneratedQuestion({
    required this.question,
    required this.answer,
    this.isEmptyMessage = false,
    this.options,
    this.questionType = 'shortAnswer',
  });
}