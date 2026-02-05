abstract class UserRepo{
  Future<void> getUserProfile(); //Get from users collection using uid, return if it exists or not.
}