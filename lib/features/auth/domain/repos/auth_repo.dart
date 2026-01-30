abstract class AuthRepo {

  Future<void> sendSignInLink({required String email, required String orgId});
}