import 'package:classroom_quiz_admin_portal/features/grading_insights/data/models/grading_attempt_model.dart';

abstract class GradingRepo {
  Future<List<GradingAttemptModel>> getGradingInsights({required String orgId});
}