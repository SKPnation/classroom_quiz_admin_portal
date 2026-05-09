import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_template.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/domain/repos/quiz_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizRepoImpl extends QuizRepo {
  final CollectionReference orgsCollections = FirebaseFirestore.instance
      .collection(AppStrings.organisations);
  final CollectionReference templatesCollection = FirebaseFirestore.instance
      .collection(AppStrings.templates);

  @override
  Future<void> createQuiz() {
    // TODO: implement createQuiz
    throw UnimplementedError();
  }

  @override
  Future<void> addToTemplates({
    required PublishedQuizTemplate template,
    required String orgId,
  }) async {
    await orgsCollections
        .doc(orgId)
        .collection(AppStrings.templates)
        .doc(template.id)
        .set(template.toMap(), SetOptions(merge: true));
  }

  @override
  Future<List<PublishedQuizTemplate>> getTemplates({required String orgId}) {
    return orgsCollections
        .doc(orgId)
        .collection(AppStrings.templates)
        .get()
        .then((snapshot) {
          return snapshot.docs.map((doc) {
            return PublishedQuizTemplate.fromMap({...doc.data(), 'id': doc.id});
          }).toList();
        });
  }
}
