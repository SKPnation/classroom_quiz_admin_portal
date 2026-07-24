import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/data/models/school_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/integration_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/controllers/settings_controller.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/completed_state_widget.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/in_progress_state_widget.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/integrations_card.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/preferences_card.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/security_card.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.profileCompleted,
    required this.completionPercent, // used only when not completed
  });

  final bool profileCompleted;
  final double completionPercent;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final settingsController = SettingsController.instance;
  bool _signingOut = false;

  final ScrollController scrollController = ScrollController();

  final GlobalKey integrationsKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userInfoCache = storage.read(GetStoreKeys.userKey);
      if (userInfoCache == null || !mounted) return;

      final userModel = UserModel.fromJson(userInfoCache);

      await settingsController.loadDefaultIntegrations(userModel);

      if (!mounted) return;
      if (!settingsController.scrollToIntegrations.value) return;

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      final targetContext = integrationsKey.currentContext;

      if (targetContext != null && scrollController.hasClients) {
        settingsController.scrollToIntegrations.value = false;

        await Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          alignment: 0.05,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        );
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF111827);

    final userInfoCache = storage.read(GetStoreKeys.userKey);
    final orgInfoCache = storage.read(GetStoreKeys.orgKey);

    // If data is missing and we haven't already started signing out
    if ((userInfoCache == null || orgInfoCache == null) && !_signingOut) {
      _signingOut = true; // ← prevent re-entry
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return; // ← widget might already be gone
        SettingsController.instance.signOut();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Already signing out — just show loading, don't do anything else
    if (_signingOut) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    try {
      UserModel userModel = UserModel.fromJson(userInfoCache);
      SchoolModel schoolModel = SchoolModel.fromJson(orgInfoCache);

      return Container(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: SingleChildScrollView(
            controller: scrollController,
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
                const Text(
                  'Profile Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.profileCompleted)
                  ProfileCompletedCard(user: userModel, school: schoolModel)
                else
                  ProfileInProgressCard(
                    percent: widget.completionPercent.clamp(0.0, 1.0),
                    user: userModel,
                    school: schoolModel,
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  key: integrationsKey,
                  width: double.infinity,
                  child: Obx(
                    () => IntegrationsCard(
                      integrations: settingsController.integrations.toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const SecurityCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return const Scaffold(
        body: Center(child: Text("Error loading profile settings.")),
      );
    }
  }
}
