import 'package:classroom_quiz_admin_portal/core/navigation/navigation_controller.dart';
import 'package:classroom_quiz_admin_portal/features/auth/data/repos/auth_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:classroom_quiz_admin_portal/features/delivery/presentation/controllers/schedule_controller.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/data/repos/find_school_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/presentation/controllers/find_school_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/ai_generator_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/create_quiz_controller.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/controllers/settings_controller.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:classroom_quiz_admin_portal/src/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


final storage = GetStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCrhNo4rSMWGS9_8Sh3Xih8xqwdYpYh75o",
      authDomain: "schoolquizapp-8b07d.firebaseapp.com",
      projectId: "schoolquizapp-8b07d",
      storageBucket: "schoolquizapp-8b07d.firebasestorage.app",
      messagingSenderId: "252487951973",
      appId: "1:252487951973:web:1a3abbd071ee68f402088c",
      measurementId: "G-22KFVWDYDP",
    ),
  );

  await GetStorage.init();

  // Now it's safe to register controllers that may touch Firebase
  Get.put<DashboardController>(DashboardController());
  Get.put<NavigationController>(NavigationController());
  Get.put<MenController>(MenController());
  Get.put<CreateQuizController>(CreateQuizController());
  Get.put<AiGeneratorController>(AiGeneratorController());
  Get.put<ScheduleController>(ScheduleController());
  Get.put<FindSchoolController>(
    FindSchoolController(
      findSchoolRepo: FindSchoolRepoImpl(),
      authRepo: AuthRepoImpl(),
    ),
  );
  Get.put<SettingsController>(SettingsController());


  runApp(const App());
}
