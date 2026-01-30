import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/presentation/pages/dashboard.dart';
import 'package:classroom_quiz_admin_portal/features/delivery/presentation/pages/classes_page.dart';
import 'package:classroom_quiz_admin_portal/features/delivery/presentation/pages/schedules_page.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/presentation/pages/find_school_page.dart';
import 'package:classroom_quiz_admin_portal/features/grading_insights/presentation/pages/grading_queue.dart';
import 'package:classroom_quiz_admin_portal/features/grading_insights/presentation/pages/results_page.dart';
import 'package:classroom_quiz_admin_portal/features/delivery/presentation/pages/students_page.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/pages/ai_generator.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/pages/create_quiz.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/pages/question_bank.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/pages/quiz_editor.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/pages/templates.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/pages/site_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';

abstract class AppPages {
  AppPages._();

  static final String initial = Routes.findSchoolRoute;

  static final pages = [
    GetPage(name: Routes.findSchoolRoute, page: () => FindSchoolPage()),
    GetPage(name: Routes.rootRoute, page: () => SiteLayout()),
  ];

}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.dashboardRoute:
      return _getPageRoute(Dashboard());
    case Routes.createQuizRoute:
      return _getPageRoute(CreateQuizPage());
    case Routes.aiGeneratorRoute:
      return _getPageRoute(AiQuestionGeneratorPage());
    case Routes.quizEditorRoute:
      return _getPageRoute(QuizEditorPage());
    case Routes.questionBankRoute:
      return _getPageRoute(QuestionBankPage());
    case Routes.templatesRoute:
      return _getPageRoute(TemplatesPage());
    case Routes.resultsRoute:
      return _getPageRoute(ResultsPage());
    case Routes.schedulesRoute:
      return _getPageRoute(SchedulesPage());
    case Routes.classesRoute:
      return _getPageRoute(ClassesPage());
    case Routes.studentsRoute:
      return _getPageRoute(StudentsPage());
    case Routes.gradingQueueRoute:
      return _getPageRoute(GradingQueuePage());
    default:
      return _getPageRoute(Dashboard());
  }
}

PageRoute _getPageRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}

abstract class Routes {
  Routes._();

  static const findSchoolRoute = "/find-school";

  ///PRIMARY
  static const dashboardDisplayName = AppStrings.dashboardTitle;
  static const dashboardRoute = "/dashboard";

  static const createQuizDisplayName = AppStrings.createQuizTitle;
  static const createQuizRoute = "/create-quiz";

  //QUIZZES
  static const aiGeneratorDisplayName = AppStrings.aiGeneratorTitle;
  static const aiGeneratorRoute = "/ai-generator";
  static const quizEditorDisplayName = AppStrings.quizEditorTitle;
  static const quizEditorRoute = "/quiz-editor";
  static const questionBankDisplayName = AppStrings.questionBankTitle;
  static const questionBankRoute = "/question-bank";
  static const templatesDisplayName = AppStrings.templatesTitle;
  static const templatesRoute = "/templates";

  //DELIVERY
  static const schedulesDisplayName = AppStrings.schedulesTitle;
  static const schedulesRoute = "/schedules-assignments";
  static const classesDisplayName = AppStrings.classesTitle;
  static const classesRoute = "/classes";
  static const studentsDisplayName = AppStrings.studentsTitle;
  static const studentsRoute = "/students";

  ///GRADING & INSIGHTS
  static const resultsDisplayName = AppStrings.resultsTitle;
  static const resultsRoute = "/results";
  static const gradingQueueDisplayName = AppStrings.gradingQueueTitle;
  static const gradingQueueRoute = "/grading-queue";

  //Analytics
  static const itemAnalysisDisplayName = AppStrings.itemAnalysisTitle;
  static const itemAnalysisRoute = "/item-analysis";
  static const studentProgressDisplayName = AppStrings.studentProgressTitle;
  static const studentProgressRoute = "/student-progress";

  ///RESOURCES
  static const mediaLibraryDisplayName = AppStrings.mediaLibraryTitle;
  static const mediaLibraryRoute = "/media-library";
  static const settingsDisplayName = AppStrings.settingsTitle;
  static const settingsRoute = "/settings";

  //-------
  static const authRoute = "/authentication";

  static const rootRoute = "/";
}

class MenuItem {
  final String name;
  final String route;

  MenuItem(this.name, this.route);
}

List<MenuItem> primaryMenuItemRoutes = [
  MenuItem(Routes.dashboardDisplayName, Routes.dashboardRoute),
  MenuItem(Routes.createQuizDisplayName, Routes.createQuizRoute),
];

List<MenuItem> quizMenuItemRoutes = [
  MenuItem(Routes.aiGeneratorDisplayName, Routes.aiGeneratorRoute),
  MenuItem(Routes.quizEditorDisplayName, Routes.quizEditorRoute),
  MenuItem(Routes.questionBankDisplayName, Routes.questionBankRoute),
  MenuItem(Routes.templatesDisplayName, Routes.templatesRoute),
];

List<MenuItem> deliveryMenuItemRoutes = [
  MenuItem(Routes.schedulesDisplayName, Routes.schedulesRoute),
  MenuItem(Routes.classesDisplayName, Routes.classesRoute),
  MenuItem(Routes.studentsDisplayName, Routes.studentsRoute),
];

List<MenuItem> gradingMenuItemRoutes = [
  MenuItem(Routes.resultsDisplayName, Routes.resultsRoute),
  MenuItem(Routes.gradingQueueDisplayName, Routes.gradingQueueRoute),
];

List<MenuItem> resourcesMenuItemRoutes = [
  MenuItem(Routes.mediaLibraryDisplayName, Routes.mediaLibraryRoute),
  MenuItem(Routes.settingsDisplayName, Routes.settingsRoute),
];
