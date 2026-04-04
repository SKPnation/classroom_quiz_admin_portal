import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';

class PublishedQuizTemplate {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String type;
  final String level;
  final List<QuizItemModel> items;
  final DateTime publishedAt;
  final List<String> tags;

  PublishedQuizTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.type,
    required this.level,
    required this.items,
    required this.publishedAt,
    this.tags = const [],
  });

  int get questionCount => items.length;

  int get estimatedMinutes {
    final count = items.length;
    if (count <= 10) return 15;
    if (count <= 20) return 30;
    if (count <= 30) return 45;
    return 60;
  }

  String get lastUsed => 'Never';

  PublishedQuizTemplate copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    String? type,
    String? level,
    List<QuizItemModel>? items,
    DateTime? publishedAt,
    List<String>? tags,
  }) {
    return PublishedQuizTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      type: type ?? this.type,
      level: level ?? this.level,
      items: items ?? this.items,
      publishedAt: publishedAt ?? this.publishedAt,
      tags: tags ?? this.tags,
    );
  }
}