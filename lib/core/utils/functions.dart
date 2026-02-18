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

String typeLabel(QuizItemType t) {
  switch (t) {
    case QuizItemType.multipleChoice:
      return 'Multiple Choice';
    case QuizItemType.trueFalse:
      return 'True/False';
    case QuizItemType.shortAnswer:
      return 'Short Answer';
    default:
      return 'Essay';
  }
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
