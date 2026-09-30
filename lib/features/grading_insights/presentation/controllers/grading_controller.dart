import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_snackbar.dart';
import 'package:classroom_quiz_admin_portal/features/grading_insights/data/models/grading_attempt_model.dart';
import 'package:classroom_quiz_admin_portal/features/grading_insights/data/repos/grading_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:get/get.dart';

class GradingInsightsController extends GetxController {
  static GradingInsightsController get instance =>
      Get.find<GradingInsightsController>();

  final GradingRepoImpl gradingRepo = GradingRepoImpl();

  final RxBool isLoading = false.obs;
  final RxBool isRegrading = false.obs;
  final RxBool isSavingReview = false.obs;
  final RxBool isApprovingReview = false.obs;

  RxList<GradingAttemptModel> attempts = <GradingAttemptModel>[].obs;

  Future<void> loadGradingInsights() async {
    try {
      isLoading.value = true;

      final userInfoCache = storage.read(GetStoreKeys.userKey);
      final userModel = UserModel.fromJson(userInfoCache);

      attempts.assignAll(
        await gradingRepo.getGradingInsights(orgId: userModel.orgId),
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<GradingAttemptModel> get results =>
      attempts.where((e) => e.aiConfidence != 0.0).toList();

  List<GradingAttemptModel> get gradingQueue => attempts
      .where(
        (e) =>
            e.aiConfidence > 0.0 &&
            (e.status == GradingStatus.pending ||
                e.status == GradingStatus.needsReview ||
                e.status == GradingStatus.flagged ||
                e.aiConfidence < 0.7),
      )
      .toList();

  int get totalStudents => attempts.map((e) => e.studentEmail).toSet().length;

  double get averageScore {
    if (attempts.isEmpty) return 0;

    return attempts.map((e) => e.percentage).reduce((a, b) => a + b) /
        attempts.length;
  }

  double get averageAiConfidence {
    final validAttempts = results;

    if (validAttempts.isEmpty) return 0;

    return validAttempts
        .map((e) => e.aiConfidence)
        .reduce((a, b) => a + b) /
        validAttempts.length;
  }

  int get manualOverrides =>
      attempts.where((e) => e.gradingMethod == 'manual').length;

  Future<void> regradeAttempt(String attemptId) async {
    if (attemptId.trim().isEmpty || isRegrading.value) return;

    try {
      isRegrading.value = true;

      final userModel = _getCurrentUser();

      await gradingRepo.regradeAttempt(
        orgId: userModel.orgId,
        attemptId: attemptId,
      );

      await loadGradingInsights();

      Get.snackbar(
        'Regrading completed',
        'The submission has been regraded successfully.',
      );
    } catch (error) {
      Get.snackbar('Regrading failed', error.toString());

      rethrow;
    } finally {
      isRegrading.value = false;
    }
  }

  UserModel _getCurrentUser() {
    final userInfoCache = storage.read(GetStoreKeys.userKey);

    if (userInfoCache == null) {
      throw Exception('User session was not found.');
    }

    return UserModel.fromJson(userInfoCache);
  }

  Future<void> saveReviewDraft({
    required String attemptId,
    required Map<int, double> scoreOverrides,
    required Map<int, String> feedbackOverrides,
    required String overallFeedback,
  }) async {}

  Future<void> approveFinalGrade({
    required String attemptId,
    required Map<int, double> scoreOverrides,
    required Map<int, String> feedbackOverrides,
    required String overallFeedback,
  }) async {}
}
