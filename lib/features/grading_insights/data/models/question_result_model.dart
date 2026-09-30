class QuestionResultModel {
  final String question;
  final String studentAnswer;
  final double earnedPoints;
  final double maxPoints;
  final bool isCorrect;
  final String feedback;

  QuestionResultModel({
    required this.question,
    required this.studentAnswer,
    required this.earnedPoints,
    required this.maxPoints,
    required this.isCorrect,
    required this.feedback,
  });

  factory QuestionResultModel.fromMap(Map<String, dynamic> map) {
    return QuestionResultModel(
      question: map['question'] ?? '',
      studentAnswer: map['studentAnswer']?.toString() ?? '',
      earnedPoints: (map['earnedPoints'] ?? 0).toDouble(),
      maxPoints: (map['maxPoints'] ?? 0).toDouble(),
      isCorrect: map['isCorrect'] ?? false,
      feedback: map['feedback'] ?? '',
    );
  }
}