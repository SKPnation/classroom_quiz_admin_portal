import 'package:classroom_quiz_admin_portal/core/navigation/local_navigator.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/helpers/responsiveness.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/widgets/large_screen.dart';
import 'package:flutter/material.dart';

class SiteLayout extends StatelessWidget {
  SiteLayout({super.key});

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey,
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      // appBar: topNavigationBar(context, scaffoldKey, "Admin"),
      // drawer: Drawer(child: SideMenu()),
      body: ResponsiveWidget(
        largeScreen: LargeScreen(scaffoldKey: scaffoldKey),
        smallScreen: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: localNavigator(),
        ),
      ),
    );
  }
}
