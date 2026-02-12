import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/data/models/school_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/controllers/settings_controller.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/completed_state_widget.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/in_progress_state_widget.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/preferences_card.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/security_card.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({
    super.key,
    required this.profileCompleted,
    required this.completionPercent, // used only when not completed
  });

  final bool profileCompleted;
  final double completionPercent; // 0.0 - 1.0

  final settingsController = SettingsController.instance;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF1F5F9); // slate-100-ish
    const ink = Color(0xFF111827); // gray-900

    final userInfoCache = storage.read(GetStoreKeys.userKey);
    final orgInfoCache = storage.read(GetStoreKeys.orgKey);

    UserModel userModel = UserModel.fromJson(userInfoCache);
    SchoolModel schoolModel = SchoolModel.fromJson(orgInfoCache);

    return Container(
      color: bg,
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: ink,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),

              // Title row (like your pages)
              const Text(
                'Profile Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
              const SizedBox(height: 12),

              // MAIN PROFILE CARD (switch by state)
              if (profileCompleted)
                ProfileCompletedCard(user: userModel, school: schoolModel)
              else
                ProfileInProgressCard(
                  percent: completionPercent.clamp(0.0, 1.0),
                  user: userModel,
                  school: schoolModel
                ),

              const SizedBox(height: 16),

              // Preferences Card (same on both)
              const PreferencesCard(),
              const SizedBox(height: 16),

              // Security Card (same on both)
              const SecurityCard(),

              const SizedBox(height: 24),

              // subtle footer space
              Container(height: 8, color: Colors.transparent),
            ],
          ),
        ),
      ),
    );
  }
}












