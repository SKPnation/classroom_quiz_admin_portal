
import 'package:cloud_firestore/cloud_firestore.dart';

enum QuizItemType { shortAnswer, multipleChoice, trueFalse, essay }

class QuizItemModel {
  final String id;
  final QuizItemType type;
  final String question;

  /// For short-answer: store expected answer (or rubric key)
  final String? answerKey;

  /// For MCQ: list options + correct option indexes
  final List<String> options;
  final List<int> correctOptionIndexes;

  final int points;
  final DateTime createdAt;

  const QuizItemModel({
    required this.id,
    required this.type,
    required this.question,
    this.answerKey,
    this.options = const [],
    this.correctOptionIndexes = const [],
    this.points = 1,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name, // "shortAnswer" | "multipleChoice"
      'question': question,
      'answerKey': answerKey,
      'options': options,
      'correctOptionIndexes': correctOptionIndexes,
      'points': points,
      // Firestore-friendly:
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory QuizItemModel.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    DateTime createdAt;

    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is String) {
      createdAt = DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0);
    } else {
      createdAt = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return QuizItemModel(
      id: (json['id'] ?? '') as String,
      type: QuizItemType.values.firstWhere(
            (e) => e.name == (json['type'] ?? 'shortAnswer'),
        orElse: () => QuizItemType.shortAnswer,
      ),
      question: (json['question'] ?? '') as String,
      answerKey: json['answerKey'] as String?,
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      correctOptionIndexes: (json['correctOptionIndexes'] as List?)
          ?.map((e) => int.tryParse(e.toString()) ?? 0)
          .toList() ??
          const [],
      points: (json['points'] is int) ? json['points'] as int : int.tryParse('${json['points']}') ?? 1,
      createdAt: createdAt,
    );
  }
}
