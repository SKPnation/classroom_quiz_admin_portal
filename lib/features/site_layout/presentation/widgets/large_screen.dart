import 'package:classroom_quiz_admin_portal/core/navigation/local_navigator.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/widgets/side_menu.dart';
import 'package:flutter/material.dart';

class LargeScreen extends StatelessWidget {
  const LargeScreen({super.key, required this.scaffoldKey});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(flex: 2, child: SideMenu(scaffoldKey: scaffoldKey)),
          SizedBox(width: 16),
          Expanded(
            flex: 7,
            child: Column(
              children: [
                Expanded(flex: 2, child: localNavigator()),
              ],
            ),
          ),
          SizedBox(width: 24),
        ],
      ),
    );
  }
}
