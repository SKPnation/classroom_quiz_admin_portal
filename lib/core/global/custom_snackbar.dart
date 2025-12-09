import 'dart:math';

import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static void showSnackBar({
    required BuildContext? context,
    required String title,
    required String message,
    required Color backgroundColor,
  }) {
    Get.snackbar(
      title,
      message,
      borderRadius: 12,
      colorText: Colors.white,
      backgroundColor: backgroundColor,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      duration: Duration(milliseconds: max(1000, message.length * 40)),
      animationDuration: const Duration(milliseconds: 400),
      titleText: Text(
        title,
        style: const TextStyle(fontSize: 16.5, color: AppColors.white),
      ),
      messageText: Text(
        message,
        style: const TextStyle(fontSize: 14, color: AppColors.white),
      ),
    );
  }

  static void errorSnackBar(String errorMsg) {
    return CustomSnackBar.showSnackBar(
        context: Get.context!,
        title: "Error",
        message: errorMsg,
        backgroundColor: AppColors.red);
    // if (errorMsg.contains(ApiService.certVerifyFailed)) {
    //   return showSnackBar(
    //       context: Get.context!,
    //       title: "Internet Error",
    //       message: "Please change your network provider",
    //       backgroundColor: AppColors.red);
    // } else if(errorMsg.toLowerCase().contains('unauthenticated')){
    //   AuthController().signOut();
    // } else {
    //   return CustomSnackBar.showSnackBar(
    //       context: Get.context!,
    //       title: "Error",
    //       message: errorMsg,
    //       backgroundColor: AppColors.red);
    // }
  }

  static void successSnackBar({String? title, required String body}) {
    return CustomSnackBar.showSnackBar(
        context: Get.context!,
        title: title ?? "Success",
        message: body,
        backgroundColor: Colors.green);
  }
}
