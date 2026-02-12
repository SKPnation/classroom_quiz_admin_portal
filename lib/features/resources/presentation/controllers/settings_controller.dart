import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/features/auth/data/repos/auth_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/repos/user_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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

  void computeProfileCompleted() {
    final cached = storage.read(GetStoreKeys.userKey);

    // If nothing in storage yet, profile is not complete
    if (cached == null || cached is! Map) {
      profileCompleted.value = false;
      MenController.instance.activePageRoute.value =
          Routes.settingsDisplayName;
      return;
    }

    final map = Map<String, dynamic>.from(cached);

    // You can add more required fields later
    profileCompleted.value = validateFields(map);
    MenController.instance.activePageRoute.value =
        Routes.settingsDisplayName;
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
    return !map.values.any((value) => value == null || value.toString().trim().isEmpty);
  }

  saveProfile({required UserModel user, required String orgId}) async{
    await userRepo.saveProfile(user, orgId);
  }

  signOut() {
    authRepo.signOut();
  }


  @override
  void onInit() {
    final cached = storage.read(GetStoreKeys.userKey);

    if(cached != null){
      final map = Map<String, dynamic>.from(cached);
      updateCompletion(map);
    }
    super.onInit();
  }
}
