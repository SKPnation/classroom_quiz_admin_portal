import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/data/models/action_card_model.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/data/models/info_card_model.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/presentation/widgets/kpi_card_item.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController{
  static DashboardController get instance => Get.find();

  final kpiCards = [
    KpiCardItem(title: AppStrings.totalQuizzes, value: "25"),
    KpiCardItem(title: AppStrings.avgClassScore, value: "78%"),
    KpiCardItem(title: AppStrings.pendingGrading, value: "2"),
    KpiCardItem(title: AppStrings.upcomingQuizzes, value: "3"),
  ];

  final actionCards = [
    ActionCard(message: "2 quizzes need manual grading", cta: 'Review now'),
    ActionCard(message: "3 drafts not published", cta: 'Continue editing'),
    ActionCard(message: "AI flagged 5 low performing questions", cta: 'View item analysis'),
  ];
}


