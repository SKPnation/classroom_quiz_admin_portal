import 'package:classroom_quiz_admin_portal/core/navigation/navigation_controller.dart';
import 'package:classroom_quiz_admin_portal/features/ai_generator/presentation/controllers/ai_generator_controller.dart';
import 'package:classroom_quiz_admin_portal/features/create_quiz/presentation/controllers/create_quiz_controller.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:get/get.dart';

class AllControllerBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => NavigationController());
    Get.lazyPut(() => MenController());
    Get.lazyPut(() => CreateQuizController());
    Get.lazyPut(() => AiGeneratorController());
  }
}

