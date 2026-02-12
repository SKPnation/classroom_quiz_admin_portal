import 'package:classroom_quiz_admin_portal/features/find_school/data/models/school_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepo {
  Future<void> sendSignInLink({required String email, required String orgId});

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
    required SchoolModel school,
  });

  // Future<void> registerWithEmailPassword({
  //   required String email,
  //   required String password,
  // });

  void saveUserToStorage(User user);

  void saveSchoolToStorage(SchoolModel school);

  void signOut();
}
