import 'package:shop/module_profile/domain/models/user/user.dart';
import 'package:shop/utils/result.dart';


abstract class UserRepository {

  Future<void> cacheCurrentUser(User user);
  Future<User?> getCachedCurrentUser();
  void clear();
  User? get cachedUser;



  Future<Result<User>> getCurrentUser({bool forceRefresh = false});

  Future<Result<String>> getCurrentUserId();

  Future<Result<User>> getUser(String userId);
}