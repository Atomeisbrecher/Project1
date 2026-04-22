import 'package:shop/module_auth/domain/user/user.dart';


abstract class UserRepository {
  Future<User> getUser();
}