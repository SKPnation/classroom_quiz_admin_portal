import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/utils/services/google_integration_service.dart';
import 'package:classroom_quiz_admin_portal/features/auth/data/repos/auth_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/integration_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/repos/user_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  static SettingsController get instance => Get.find();

  final fullNameTEC = TextEditingController();
  final officeTEC = TextEditingController();
  final bioTEC = TextEditingController();
  final departmentTEC = TextEditingController();

  var profileCompleted = true.obs;
  var percentageCompletion = 0.0.obs;

  UserRepoImpl userRepo = UserRepoImpl();
  AuthRepoImpl authRepo = AuthRepoImpl();

  final RxList<IntegrationModel> integrations = <IntegrationModel>[].obs;

  void loadDefaultIntegrations(UserModel user) async {
    final list = await userRepo.getMyIntegrations(user.orgId, user.uid);

    final isGoogleConnected =
    list.any((integration) => integration['id'] == 'google');

    final isCanvasConnected =
    list.any((integration) => integration['id'] == 'canvas');

    final isZoomConnected =
    list.any((integration) => integration['id'] == 'zoom');

    integrations.assignAll([
      IntegrationModel(
        id: 'google',
        name: 'Google',
        description: 'Create Google Forms, connect Sheets, and more.',
        icon: Icons.g_mobiledata_rounded,
        connected: isGoogleConnected,
        actionText: isGoogleConnected ? 'Connected' : 'Connect Google',
        onTap: isGoogleConnected
            ? null
            : () async {
          final org = storage.read(GetStoreKeys.orgKey);
          final orgId = org['code'].toString().toLowerCase();

          await GoogleIntegrationService().connectGoogle(orgId: orgId);
        },
      ),
      IntegrationModel(
        id: 'canvas',
        name: 'Canvas LMS',
        description: 'Sync quizzes with Canvas courses.',
        icon: Icons.school_outlined,
        connected: isCanvasConnected,
        actionText: isCanvasConnected ? 'Connected' : 'Connect Canvas',
        onTap: isCanvasConnected
            ? null
            : () async{
          debugPrint('Canvas integration tapped.');
        },
      ),
      IntegrationModel(
        id: 'zoom',
        name: 'Zoom',
        description: 'Schedule and share class meetings.',
        icon: Icons.videocam_outlined,
        connected: isZoomConnected,
        actionText: isZoomConnected ? 'Connected' : 'Connect Zoom',
        onTap: isZoomConnected
            ? null
            : () async{
          debugPrint('Zoom integration tapped.');
        },
      ),
    ]);
  }

  void computeProfileCompleted() {
    final cached = storage.read(GetStoreKeys.userKey);

    // If nothing in storage yet, profile is not complete
    if (cached == null || cached is! Map) {
      profileCompleted.value = false;
      MenController.instance.activePageRoute.value = Routes.settingsDisplayName;
      return;
    }

    final map = Map<String, dynamic>.from(cached);

    // You can add more required fields later
    profileCompleted.value = validateFields(map);
    MenController.instance.activePageRoute.value = Routes.settingsDisplayName;
  }

  void updateCompletion(Map<String, dynamic> map) {
    if (map.isEmpty) {
      percentageCompletion.value = 0.0;
      return;
    }

    // 1. Define what counts as "filled"
    int filledFields = map.values.where((value) {
      if (value == null) return false;
      if (value is String) return value.trim().isNotEmpty;
      return true; // For non-string types that aren't null (like orgId if it's an int)
    }).length;

    // 2. Calculate the ratio
    // We use .toDouble() to ensure floating point math
    double score = filledFields / map.length;

    // 3. Update the observable variable
    percentageCompletion.value = score;
  }

  bool validateFields(Map<String, dynamic> map) {
    // .values.any checks if at least one element meets the condition
    return !map.values.any(
      (value) => value == null || value.toString().trim().isEmpty,
    );
  }

  saveProfile({required UserModel user, required String orgId}) async {
    await userRepo.saveProfile(user, orgId);
  }

  signOut() {
    authRepo.signOut();
  }

  /// Returns true if the integration with the given id is connected.
  /// Usage: SettingsController.instance.isIntegrationConnected('canvas')
  bool isIntegrationConnected(String integrationId) {
    return integrations
        .firstWhereOrNull((i) => i.id == integrationId)
        ?.connected ??
        false;
  }

  @override
  void onInit() {
    final cached = storage.read(GetStoreKeys.userKey);

    if (cached != null) {
      final map = Map<String, dynamic>.from(cached);
      updateCompletion(map);
    }
    super.onInit();
  }

  resetVariables() {
    fullNameTEC.clear();
    officeTEC.clear();
    bioTEC.clear();
    departmentTEC.clear();
    profileCompleted.value = false;
    percentageCompletion.value = 0.0;
    integrations.clear();
  }
}
