import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_snackbar.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/domain/repos/user_repo.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/controllers/settings_controller.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepoImpl extends UserRepo {
  final auth = FirebaseAuth.instance;
  final usersRef = FirebaseFirestore.instance.collection(AppStrings.users);

  CollectionReference<Map<String, dynamic>> membersRef(String orgId) =>
      FirebaseFirestore.instance
          .collection(AppStrings.organisations)
          .doc(orgId)
          .collection(AppStrings.members);
  final orgsRef = FirebaseFirestore.instance.collection(
    AppStrings.organisations,
  );

  @override
  Future getUserProfile() async {
    try {
      final doc = await usersRef.doc(auth.currentUser!.uid).get();

      if (doc.exists) {
        Map<String, dynamic> json = doc.data()!;
        return UserModel.fromJson(json);
      } else {
        CustomSnackBar.errorSnackBar("User profile not found");
        return null;
      }
    } catch (e) {
      CustomSnackBar.errorSnackBar("Failed to fetch user profile: $e");
      return null;
    }
  }

  @override
  Future<void> saveProfile(UserModel userModel, String orgId) async {
    final data = {...userModel.toFirestore()};

    await usersRef
        .doc(auth.currentUser!.uid)
        .set(
          data,
          SetOptions(merge: true), // prevents overwriting existing fields
        );

    await addAsMemberToOrg(userModel, orgId);

    //Cache user info
    storage.write(GetStoreKeys.userKey, userModel.toCache());

    //Update profile completion percentage
    SettingsController.instance.updateCompletion(userModel.toCache());

    CustomSnackBar.successSnackBar(body: "Profile updated");
  }

  @override
  Future<void> addAsMemberToOrg(UserModel userModel, String orgId) async {
    final member = <String, dynamic>{
      "role": AppStrings.lecturer, // or "student"
      "email": userModel.email,
      "joinedAt": userModel.createdAt,
      "isActive": true,
    };

    await membersRef(orgId).doc(userModel.uid).set(
        member,
        SetOptions(merge: true)
    );
  }
}
