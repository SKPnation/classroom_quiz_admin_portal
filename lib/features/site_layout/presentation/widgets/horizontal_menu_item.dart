// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HorizontalMenuItem extends StatelessWidget {
  final String? itemName;
  final Function()? onTap;

  HorizontalMenuItem({this.itemName, this.onTap, super.key});

  final menuController = MenController.instance;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap!,
        onHover: (value){
          if (value) {
            menuController.onHover(itemName!);
          } else {
            menuController.onHover(""); // or null
          }
          },
        child: Obx(() =>
            Container(
                color: menuController.isHovering(itemName!)
                    ? Colors.grey.withValues(alpha: 0.4)
                    : Colors.transparent,
            child: Row(
              children: [

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: menuController.returnIconFor(itemName!),
                ),

                if(!menuController.isActive(itemName!))
                  Flexible(
                      child: CustomText(
                        text: itemName!,
                        color: menuController.isHovering(itemName!) ? AppColors.grey[400] : AppColors.grey[500],
                        weight: FontWeight.normal,
                        size: 16,
                      ))
                else
                  Flexible(
                      child: CustomText(
                        text: itemName!,
                        color: AppColors.black,
                        size: 18,
                        weight: FontWeight.bold,
                      ))

              ],
            ))
        )

    );
  }
}