import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/utils/functions.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_template.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/domain/repos/quiz_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizRepoImpl extends QuizRepo {
  final CollectionReference orgsCollections = FirebaseFirestore.instance
      .collection(AppStrings.organisations);
  final CollectionReference templatesCollection = FirebaseFirestore.instance
      .collection(AppStrings.templates);

  @override
  Future<void> addToTemplates({
    required PublishedQuiz template,
    required String orgId,
  }) async {

    print('Adding template to Firestore: ${template.title} for orgId: $orgId');

    await orgsCollections
        .doc(orgId)
        .collection(AppStrings.templates)
        .doc(template.id)
        .set(template.toMap(), SetOptions(merge: true));
  }

  @override
  Future<List<PublishedQuiz>> getPublishedQuizzes({
    required String orgId,
  }) async {
    if (orgId.trim().isEmpty) {
      // throw Exception('orgId is empty. Cannot load templates.');
      return [];
    }

    final snapshot = await orgsCollections
        .doc(orgId)
        .collection(AppStrings.templates)
        .where('createdBy', isEqualTo: myUID)
        .get();

    return snapshot.docs
        .map(
          (doc) => PublishedQuiz.fromMap({...doc.data(), 'id': doc.id}),
        )
        .toList();
  }

  @override
  Future<void> deleteTemplate({required String templateId, required String orgId}) {
    return orgsCollections
        .doc(orgId)
        .collection(AppStrings.templates)
        .doc(templateId)
        .delete();
  }
}
