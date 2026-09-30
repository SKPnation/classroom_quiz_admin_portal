import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class PublishedQuiz {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String type;
  final String level;
  final List<QuizItemModel> items;
  final DateTime publishedAt;
  final String createdBy;
  final List<String> tags;
  final String? formUrl;
  final String? classroomCourseId;
  final String? classroomCourseWorkId;

  PublishedQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.type,
    required this.level,
    required this.items,
    required this.publishedAt,
    required this.createdBy,
    this.tags = const [],
    this.formUrl,
    this.classroomCourseId,
    this.classroomCourseWorkId,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'type': type,
      'level': level,
      'items': items.map((item) => item.toJson()).toList(),
      'publishedAt': Timestamp.fromDate(publishedAt),
      'createdBy': createdBy,
      'tags': tags,
      'questionCount': questionCount,
      'estimatedMinutes': estimatedMinutes,
      if (formUrl != null) 'formUrl': formUrl,                            // ADD
      if (classroomCourseId != null) 'classroomCourseId': classroomCourseId,           // ADD
      if (classroomCourseWorkId != null) 'classroomCourseWorkId': classroomCourseWorkId, // ADD
    };
  }

  factory PublishedQuiz.fromMap(Map<String, dynamic> map) {
    return PublishedQuiz(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      type: map['type'] ?? '',
      level: map['level'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((item) =>
          QuizItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      publishedAt: map['publishedAt'] is Timestamp
          ? (map['publishedAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: map['createdBy'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      formUrl: map['formUrl'] as String?,               // ADD
      classroomCourseId: map['classroomCourseId'] as String?,       // ADD
      classroomCourseWorkId: map['classroomCourseWorkId'] as String?, // ADD
    );
  }

  PublishedQuiz copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    String? type,
    String? level,
    List<QuizItemModel>? items,
    DateTime? publishedAt,
    String? createdBy,
    List<String>? tags,
    String? formUrl,               // ADD
    String? classroomCourseId,     // ADD
    String? classroomCourseWorkId, // ADD
  }) {
    return PublishedQuiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      type: type ?? this.type,
      level: level ?? this.level,
      items: items ?? this.items,
      publishedAt: publishedAt ?? this.publishedAt,
      createdBy: createdBy ?? this.createdBy,
      tags: tags ?? this.tags,
      formUrl: formUrl ?? this.formUrl,                           // ADD
      classroomCourseId: classroomCourseId ?? this.classroomCourseId,         // ADD
      classroomCourseWorkId: classroomCourseWorkId ?? this.classroomCourseWorkId, // ADD
    );
  }
}