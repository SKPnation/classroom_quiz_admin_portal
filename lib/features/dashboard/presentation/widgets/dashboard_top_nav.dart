// ignore_for_file: prefer_const_constructors
import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/presentation/widgets/create_quiz_button.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Container dashboardTopNavigationBar(
  BuildContext context,
) => Container(
  height: 72,
  padding:  EdgeInsets.only(left: 24, right: 24),

  decoration: BoxDecoration(
    color: AppColors.white,
    borderRadius: const BorderRadius.all(
      Radius.circular(12),
    ),
  ),
  child: Row(
    children: [
      CustomText(
        text: MenController.instance.returnRouteName(),
        weight: FontWeight.w700,
        size: 24,
      ),
      Expanded(child: Container()),
      CreateQuizButton()
    ],
  ),
);
