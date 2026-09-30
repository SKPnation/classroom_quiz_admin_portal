import 'package:classroom_quiz_admin_portal/core/navigation/local_navigator.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/helpers/responsiveness.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/widgets/large_screen.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/widgets/side_menu.dart';
import 'package:flutter/material.dart';

class SmallScreen extends StatelessWidget {
  const SmallScreen({super.key, required this.scaffoldKey});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar with hamburger
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  color: AppColors.purple, // adjust to your palette
                  onPressed: () {
                    debugPrint('tapped. scaffoldState=${scaffoldKey.currentState}, '
                        'hasDrawer=${scaffoldKey.currentState?.hasDrawer}');
                    scaffoldKey.currentState?.openDrawer();
                  },
                ),
                const SizedBox(width: 8),
                // Optional: brand/title so the bar isn't bare
                Text(
                  'Asseska',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.purple,
                  ),
                ),
              ],
            ),
          ),
          // Same routed content as the large screen
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: localNavigator(),
            ),
          ),
        ],
      ),
    );
  }
}