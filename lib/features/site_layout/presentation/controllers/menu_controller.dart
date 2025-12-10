import 'package:classroom_quiz_admin_portal/core/data/local/get_store.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/helpers/svg_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class MenController extends GetxController {
  static MenController get instance => Get.find();

  // var activeItem = Routes.dashboardDisplayName.obs;
  var activePageRoute = getStore.get("activePageRoute").toString().obs;
  var hoverItem = "".obs;

  changeActiveItemTo(String itemName, String route) {
    // activeItem.value = itemName;
    activePageRoute.value = route;
    getStore.set("activePageRoute", route);
  }

  onHover(String itemName) {
    hoverItem.value = itemName;

    // if (!isActive(itemName)) hoverItem.value = itemName;
  }

  isHovering(String itemName) => hoverItem.value == itemName;

  isActive(String itemName) => returnRouteName() == itemName;

  Widget returnIconFor(String itemName) {
    switch (itemName) {
      case Routes.dashboardDisplayName:
        return _customIcon(SvgElements.svgDashboard, itemName);
      case Routes.createQuizDisplayName:
        return _customIcon(SvgElements.svgCreateQuiz, itemName);
      case Routes.aiGeneratorDisplayName:
        return _customIcon(SvgElements.svgAiGenerator, itemName);
      case Routes.quizEditorDisplayName:
        return _customIcon(SvgElements.svgQuizEditor, itemName);
      case Routes.questionBankDisplayName:
        return _customIcon(SvgElements.svgQuestionBank, itemName);
      case Routes.templatesDisplayName:
        return _customIcon(SvgElements.svgTemplates, itemName);
      case Routes.schedulesDisplayName:
        return _customIcon(SvgElements.svgSchedules, itemName);
      case Routes.classesDisplayName:
        return _customIcon(SvgElements.svgClasses, itemName);
      case Routes.studentsDisplayName:
        return _customIcon(SvgElements.svgStudents, itemName);
      case Routes.resultsDisplayName:
        return _customIcon(SvgElements.svgResults, itemName);
      case Routes.gradingQueueDisplayName:
        return _customIcon(SvgElements.svgGradingQueue, itemName);
      case Routes.mediaLibraryDisplayName:
        return _customIcon(SvgElements.svgMediaLibrary, itemName);
      default:
        return _customIcon(SvgElements.svgSettings, itemName);
    }
  }

  String returnRouteName() {
    switch (activePageRoute.value) {
      case Routes.dashboardRoute:
        return Routes.dashboardDisplayName;
      case Routes.createQuizRoute:
        return Routes.createQuizDisplayName;
      case Routes.aiGeneratorRoute:
        return Routes.aiGeneratorDisplayName;
      case Routes.quizEditorRoute:
        return Routes.quizEditorDisplayName;
      case Routes.questionBankRoute:
        return Routes.questionBankDisplayName;
      case Routes.templatesRoute:
        return Routes.templatesDisplayName;
      case Routes.schedulesRoute:
        return Routes.schedulesDisplayName;
      case Routes.classesRoute:
        return Routes.classesDisplayName;
      case Routes.studentsRoute:
        return Routes.studentsDisplayName;
      case Routes.resultsRoute:
        return Routes.resultsDisplayName;
      case Routes.gradingQueueRoute:
        return Routes.gradingQueueDisplayName;
      case Routes.mediaLibraryRoute:
        return Routes.mediaLibraryDisplayName;
      default:
        return Routes.dashboardDisplayName;
    }
  }

  Widget _customIcon(String icon, String itemName) {
    if (itemName == returnRouteName()) {
      return SvgPicture.asset(icon, color: AppColors.purple);
    }

    return SvgPicture.asset(
      icon,
      color: isHovering(itemName) ? AppColors.purple : AppColors.grey[900],
    );
  }
}
