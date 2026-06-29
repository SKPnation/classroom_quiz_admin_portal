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

  RxBool isLoading = false.obs;

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

  List<GradingAttemptModel> get results => attempts;

  List<GradingAttemptModel> get gradingQueue => attempts
      .where(
        (e) =>
    e.status == GradingStatus.pending ||
        e.status == GradingStatus.aiSuggested ||
        e.status == GradingStatus.flagged ||
        e.aiConfidence < 70,
  )
      .toList();

  int get totalStudents => attempts.map((e) => e.studentId).toSet().length;

  double get averageScore {
    if (attempts.isEmpty) return 0;

    return attempts.map((e) => e.percentage).reduce((a, b) => a + b) /
        attempts.length;
  }

  double get averageAiConfidence {
    if (attempts.isEmpty) return 0;

    return attempts.map((e) => e.aiConfidence).reduce((a, b) => a + b) /
        attempts.length;
  }

  int get manualOverrides =>
      attempts.where((e) => e.gradingMethod == 'manual').length;
}
