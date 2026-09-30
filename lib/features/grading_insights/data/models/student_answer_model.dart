class StudentAnswerModel {
  final String question;
  final dynamic answer;

  StudentAnswerModel({
    required this.question,
    required this.answer,
  });

  factory StudentAnswerModel.fromMap(Map<String, dynamic> map) {
    return StudentAnswerModel(
      question: map['question'] ?? '',
      answer: map['answer'],
    );
  }
}