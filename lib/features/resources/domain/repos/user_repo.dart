import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';

abstract class UserRepo {
  Future<void> getUserProfile(); //Get from users collection using uid, return if it exists or not.
  Future<void> saveProfile(UserModel userModel, String orgId);
  Future<void> addAsMemberToOrg(UserModel userModel, String orgId);
}
