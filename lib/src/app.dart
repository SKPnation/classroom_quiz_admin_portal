import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/helpers/controllers_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  App({super.key});

  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Asseska Portal',
      navigatorKey: navigatorKey,
      initialRoute: AppPages.initial,
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const Scaffold(body: Center(child: Text("Page Not Found"))),
      ),
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.white,
        fontFamily: 'NotoSans',
      ),
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,

      initialBinding: AllControllerBinding(),
    );
  }
}
