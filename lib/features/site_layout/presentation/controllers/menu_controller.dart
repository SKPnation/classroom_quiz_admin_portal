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
        return _customIcon(SvgElements.svgCreateQuiz, itemName);
      case Routes.quizEditorDisplayName:
        return _customIcon(SvgElements.svgQuizEditor, itemName);
      case Routes.questionBankDisplayName:
        return _customIcon(SvgElements.svgQuestionBank, itemName);
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
