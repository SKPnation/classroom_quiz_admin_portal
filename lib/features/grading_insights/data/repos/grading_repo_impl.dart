import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/utils/functions.dart';
import 'package:classroom_quiz_admin_portal/features/grading_insights/data/models/grading_attempt_model.dart';
import 'package:classroom_quiz_admin_portal/features/grading_insights/domain/repos/grading_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GradingRepoImpl extends GradingRepo {
  final CollectionReference orgsCollections = FirebaseFirestore.instance
      .collection(AppStrings.organisations);
  final CollectionReference gradedAttemptsCollections = FirebaseFirestore
      .instance
      .collection(AppStrings.gradedAttempts);

  @override
  Future<List<GradingAttemptModel>> getGradingInsights({
    required String orgId,
  }) async {
    final snapshot = await orgsCollections
        .doc(orgId)
        .collection(AppStrings.gradedAttempts)
        .where('createdBy', isEqualTo: myUID)
        .get();

    return snapshot.docs
        .map(
          (doc) => GradingAttemptModel.fromMap({...doc.data(), 'id': doc.id}),
        )
        .toList();
  }

  @override
  Future<void> approveFinalGrade({required String orgId, required String attemptId, required Map<int, double> scoreOverrides, required Map<int, String> feedbackOverrides, required String overallFeedback}) {
    // TODO: implement approveFinalGrade
    throw UnimplementedError();
  }

  @override
  Future<void> regradeAttempt({required String orgId, required String attemptId}) {
    // TODO: implement regradeAttempt
    throw UnimplementedError();
  }

  @override
  Future<void> saveReviewDraft({required String orgId, required String attemptId, required Map<int, double> scoreOverrides, required Map<int, String> feedbackOverrides, required String overallFeedback}) {
    // TODO: implement saveReviewDraft
    throw UnimplementedError();
  }
}
