import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';

class QuizDraftModel {
  final String id;
  String title;
  final List<QuizItemModel> items;
  final DateTime savedAt;

  QuizDraftModel({
    required this.id,
    required this.title,
    required this.items,
    required this.savedAt,
  });

  int get totalPoints {
    return items.fold<int>(0, (sum, item) => sum + item.points);
  }

  int get questionCount => items.length;

  QuizDraftModel copyWith({
    String? id,
    String? title,
    List<QuizItemModel>? items,
    DateTime? savedAt,
  }) {
    return QuizDraftModel(
      id: id ?? this.id,
      title: title ?? this.title,
      items: items ?? this.items,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}