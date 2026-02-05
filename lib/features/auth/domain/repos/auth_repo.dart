import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepo {

  Future<void> sendSignInLink({required String email, required String orgId});
  Future<void> signInWithEmailPassword({required String email, required String password});
  Future<void> registerWithEmailPassword({required String email, required String password});
  void saveUserToStorage(User user);
}