import 'package:thepg/models/user_model.dart';

abstract class UserService {
  Future<UserModel?> getUserById(String id);
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateUser(UserModel user);
  Future<void> deleteUser(String id);
}
