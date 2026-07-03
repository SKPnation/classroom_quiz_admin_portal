import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/navigation_controller.dart';
import 'package:flutter/material.dart';

NavigationController navigationController = NavigationController.instance;

// Create once — never recreated on rebuild
final _localNavigator = Navigator(
  key: navigationController.navigatorKey,
  onGenerateRoute: generateRoute,
  initialRoute: Routes.aiGeneratorRoute,
);

Navigator localNavigator() => _localNavigator;