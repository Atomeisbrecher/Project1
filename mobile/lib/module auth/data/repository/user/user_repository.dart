import 'package:shop/module auth/domain/user/user.dart';


abstract class UserRepository {
  Future<User> getUser();
}