import 'package:classroom_quiz_admin_portal/features/grading_insights/data/models/grading_attempt_model.dart';

abstract class GradingRepo {
  Future<List<GradingAttemptModel>> getGradingInsights({required String orgId});
  Future<void> regradeAttempt({
    required String orgId,
    required String attemptId,
  });

  Future<void> saveReviewDraft({
    required String orgId,
    required String attemptId,
    required Map<int, double> scoreOverrides,
    required Map<int, String> feedbackOverrides,
    required String overallFeedback,
  });

  Future<void> approveFinalGrade({
    required String orgId,
    required String attemptId,
    required Map<int, double> scoreOverrides,
    required Map<int, String> feedbackOverrides,
    required String overallFeedback,
  });
}