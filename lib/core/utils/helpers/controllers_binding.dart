import 'package:classroom_quiz_admin_portal/core/navigation/navigation_controller.dart';
import 'package:classroom_quiz_admin_portal/features/auth/data/repos/auth_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:classroom_quiz_admin_portal/features/delivery/presentation/controllers/schedule_controller.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/data/repos/find_school_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/presentation/controllers/find_school_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/controllers/settings_controller.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:get/get.dart';

class AllControllerBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => NavigationController());
    Get.lazyPut(() => MenController());
    Get.lazyPut(() => QuizEditorController());
    Get.lazyPut(() => ScheduleController());
    Get.lazyPut(() => SettingsController());
    Get.lazyPut(() => FindSchoolController(findSchoolRepo: FindSchoolRepoImpl(), authRepo: AuthRepoImpl()));
  }
}

