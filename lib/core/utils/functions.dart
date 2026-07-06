import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

DateTime parseDate(dynamic value) {
  if (value == null) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  if (value is DateTime) {
    return value;
  }

  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  return DateTime.fromMillisecondsSinceEpoch(0);
}

QuizItemType typeFromLabel(String label) {
  switch (label) {
    case 'True/False':
      return QuizItemType.trueFalse;
    case 'Short Answer':
      return QuizItemType.shortAnswer;
    case 'Essay':
      return QuizItemType.essay;
    default:
      return QuizItemType.multipleChoice;
  }
}

String typeLabel(QuizItemType type) {
  switch (type) {
    case QuizItemType.multipleChoice:
      return 'Multiple Choice';
    case QuizItemType.shortAnswer:
      return 'Short Answer';
    case QuizItemType.trueFalse:
      return 'True / False';
    case QuizItemType.essay:
      return 'Essay';
    }
}

bool isProCount(int count) => count == 15 || count == 20;