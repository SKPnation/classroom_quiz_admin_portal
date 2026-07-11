import 'dart:ui';

import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/navigation_controller.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/helpers/image_elements.dart';
import 'package:classroom_quiz_admin_portal/core/utils/helpers/responsiveness.dart';
import 'package:classroom_quiz_admin_portal/core/utils/helpers/size_helpers.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/widgets/side_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SideMenu extends StatelessWidget {
  final menController = MenController.instance;
  final navigationController = NavigationController.instance;

  final GlobalKey<ScaffoldState> scaffoldKey;

  SideMenu({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: ListView(
        children: [
          // ── Asseska branding — large screen ────────────────────────
          if (!ResponsiveWidget.isSmallScreen(context))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/asseska_logo.png',
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(width: 10),
                  CustomText(
                    text: 'Asseska',
                    size: 20,
                    weight: FontWeight.bold,
                    color: AppColors.purple,
                  ),
                ],
              ),
            ),

          // ── Asseska branding — small screen ────────────────────────
          if (ResponsiveWidget.isSmallScreen(context))
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),
                Row(
                  children: [
                    SizedBox(width: displayWidth(context) / 48),
                    Image.asset(
                      'assets/images/asseska_logo.png',
                      height: 40,
                      width: 40,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: CustomText(
                        text: 'Asseska',
                        size: 20,
                        weight: FontWeight.bold,
                        color: AppColors.purple,
                      ),
                    ),
                    SizedBox(width: displayWidth(context) / 48),
                  ],
                ),
              ],
            ),

          if (ResponsiveWidget.isSmallScreen(context))
            Divider(color: AppColors.grey[100], thickness: 0.25),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: AppStrings.quizzesTitle,
                  color: AppColors.grey[900],
                  weight: FontWeight.w600,
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: quizMenuItemRoutes
                      .map(
                        (item) => SideMenuItem(
                      itemName: item.name,
                      onTap: () {
                        if (!menController.isActive(item.name)) {
                          menController.changeActiveItemTo(
                            item.name,
                            item.route,
                          );
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                          }
                          navigationController.navigateTo(item.route);
                        }
                      },
                    ),
                  )
                      .toList(),
                ),

                SizedBox(height: 16),

                CustomText(
                  text: AppStrings.gradingInsightsTitle,
                  color: AppColors.grey[900],
                  weight: FontWeight.w600,
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: gradingMenuItemRoutes
                      .map(
                        (item) => SideMenuItem(
                      itemName: item.name,
                      onTap: () {
                        if (!menController.isActive(item.name)) {
                          menController.changeActiveItemTo(
                            item.name,
                            item.route,
                          );
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                          }
                          navigationController.navigateTo(item.route);
                        }
                      },
                    ),
                  )
                      .toList(),
                ),

                SizedBox(height: 16),

                CustomText(
                  text: AppStrings.resourcesTitle,
                  color: AppColors.grey[900],
                  weight: FontWeight.w600,
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: resourcesMenuItemRoutes
                      .map(
                        (item) => SideMenuItem(
                      itemName: item.name,
                      onTap: () {
                        if (!menController.isActive(item.name)) {
                          menController.changeActiveItemTo(
                            item.name,
                            item.route,
                          );
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                          }
                          navigationController.navigateTo(item.route);
                        }
                      },
                    ),
                  )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
//sideMenuItemRoutes
//                     .map(
//                       (item) => SideMenuItem(
//                         itemName: item.name,
//                         onTap: () async {
//                           // if (item.route == Routes.authRoute) {
//                           //   //TODO: Uncomment
//                           //   await AuthController.instance.logOut();
//                           //   // menController.changeActiveItemTo(item.name, item.route);
//                           //   Get.offAllNamed(Routes.authRoute);
//                           //   getStore.clearAllData();
//                           // }
//                           //
//                           if (!menController.isActive(item.name)) {
//                             menController.changeActiveItemTo(
//                               item.name,
//                               item.route,
//                             );
//                             if (ResponsiveWidget.isSmallScreen(context)) {
//                               Get.back();
//                             }
//                             navigationController.navigateTo(item.route);
//                           }
//                         },
//                       ),
//                     )
//                     .toList()
