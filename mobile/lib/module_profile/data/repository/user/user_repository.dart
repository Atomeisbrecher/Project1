import 'package:shop/module_profile/domain/models/user/user.dart';


abstract class UserRepository {
  Future<User> getUser();
}