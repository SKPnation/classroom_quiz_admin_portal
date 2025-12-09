import 'package:classroom_quiz_admin_portal/core/navigation/navigation_controller.dart';
import 'package:classroom_quiz_admin_portal/features/ai_generator/presentation/controllers/ai_generator_controller.dart';
import 'package:classroom_quiz_admin_portal/features/create_quiz/presentation/controllers/create_quiz_controller.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:classroom_quiz_admin_portal/src/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  // await SentryFlutter.init(
  //       (options) {
  //     options.dsn = OtherConstants.sentryDSN;
  //     options.tracesSampleRate = 1.0;
  //     options.profilesSampleRate = 1.0;
  //   },
  // );

  Get.put<DashboardController>(DashboardController());
  Get.put<NavigationController>(NavigationController());
  Get.put<MenController>(MenController());
  Get.put<CreateQuizController>(CreateQuizController());
  Get.put<AiGeneratorController>(AiGeneratorController());

  runApp(const App());
}
