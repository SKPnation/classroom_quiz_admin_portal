import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_template.dart';

abstract class QuizRepo {
  Future<void> createQuiz();

  Future<void> addToTemplates({
    required PublishedQuizTemplate template,
    required String orgId,
  });

  Future<List<PublishedQuizTemplate>> getTemplates({required String orgId});
}
