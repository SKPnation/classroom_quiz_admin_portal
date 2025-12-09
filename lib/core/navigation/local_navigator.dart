import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/navigation_controller.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:flutter/material.dart';

NavigationController navigationController = NavigationController.instance;

Navigator localNavigator() => Navigator(
  key: navigationController.navigatorKey,
  onGenerateRoute: generateRoute,
  initialRoute: MenController.instance.activePageRoute.value,
);