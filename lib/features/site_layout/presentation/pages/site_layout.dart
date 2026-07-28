import 'package:classroom_quiz_admin_portal/core/navigation/local_navigator.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/helpers/responsiveness.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/controllers/settings_controller.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/widgets/large_screen.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/widgets/side_menu.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/widgets/small_screen.dart';
import 'package:flutter/material.dart';

class SiteLayout extends StatefulWidget {
  const SiteLayout({super.key});

  @override
  State<SiteLayout> createState() => _SiteLayoutState();
}

class _SiteLayoutState extends State<SiteLayout> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  final settingsController = SettingsController.instance;

  @override
  void initState() {
    settingsController.computeProfileCompleted();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveWidget.isSmallScreen(context);

    return Scaffold(
      backgroundColor: AppColors.grey,
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      drawer: isSmall
          ? Drawer(
        backgroundColor: AppColors.white,
        child: SideMenu(scaffoldKey: scaffoldKey),
      )
          : null,
      body: ResponsiveWidget(
        largeScreen: LargeScreen(scaffoldKey: scaffoldKey),
        smallScreen: SmallScreen(scaffoldKey: scaffoldKey),
      ),
    );
  }
}
