import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_template.dart';

abstract class QuizRepo {
  Future<void> addToTemplates({
    required PublishedQuiz template,
    required String orgId,
  });

  Future<List<PublishedQuiz>> getTemplates({required String orgId});
  Future<void> deleteTemplate({required String templateId, required String orgId});
}
