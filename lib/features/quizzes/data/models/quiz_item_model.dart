import 'package:cloud_firestore/cloud_firestore.dart';

enum QuizItemType { shortAnswer, multipleChoice, trueFalse, essay }

class QuizItemModel {
  String id;
  QuizItemType type;
  String question;
  final String? answerKey;

  // Lists are no longer final so they can be modified in the editor
  List<String> options;
  List<int> correctOptionIndexes;

  int points;
  final DateTime createdAt;

  QuizItemModel({
    required this.id,
    required this.type,
    required this.question,
    this.answerKey,
    this.options = const [],
    this.correctOptionIndexes = const [],
    this.points = 1,
    required this.createdAt,
  }) {
    // CRITICAL: Converts potential 'const' lists into growable lists
    options = List.from(options);
    correctOptionIndexes = List.from(correctOptionIndexes);
  }

  // Helper for Single-Choice UI (Radio Buttons)
  int get correctIndex => correctOptionIndexes.isNotEmpty ? correctOptionIndexes.first : 0;

  set correctIndex(int value) {
    correctOptionIndexes = [value];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'question': question,
      'answerKey': answerKey,
      'options': options,
      'correctOptionIndexes': correctOptionIndexes,
      'points': points,
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
      // Use .toList() to ensure Firestore data becomes a modifiable list
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      correctOptionIndexes: (json['correctOptionIndexes'] as List?)
          ?.map((e) => int.tryParse(e.toString()) ?? 0)
          .toList() ?? [],
      points: (json['points'] is int) ? json['points'] as int : int.tryParse('${json['points']}') ?? 1,
      createdAt: createdAt,
    );
  }

  QuizItemModel copyWith({
    String? id,
    QuizItemType? type,
    String? question,
    String? answerKey,
    List<String>? options,
    List<int>? correctOptionIndexes,
    int? points,
    DateTime? createdAt,
  }) {
    return QuizItemModel(
      id: id ?? this.id,
      type: type ?? this.type,
      question: question ?? this.question,
      answerKey: answerKey ?? this.answerKey,
      options: options ?? this.options,
      correctOptionIndexes: correctOptionIndexes ?? this.correctOptionIndexes,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}