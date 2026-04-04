import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_template.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class TemplatesController extends GetxController {
  static TemplatesController get instance => Get.find<TemplatesController>();

  final RxList<PublishedQuizTemplate> publishedTemplates =
      <PublishedQuizTemplate>[].obs;

  List<QuizItemModel> cloneQuizItems(List<QuizItemModel> source) {
    return source.map((q) {
      return QuizItemModel(
        id: q.id,
        type: q.type,
        question: q.question,
        answerKey: q.answerKey,
        options: List<String>.from(q.options),
        correctOptionIndexes: List<int>.from(q.correctOptionIndexes),
        points: q.points,
        createdAt: q.createdAt,
      );
    }).toList();
  }

  void publishTemplate(PublishedQuizTemplate template) {
    final existingIndex = publishedTemplates.indexWhere(
          (t) => t.id == template.id,
    );

    if (existingIndex != -1) {
      publishedTemplates[existingIndex] = template;
    } else {
      publishedTemplates.insert(0, template);
    }

    publishedTemplates.refresh();
  }

  void deleteTemplate(String id) {
    publishedTemplates.removeWhere((t) => t.id == id);
  }
}