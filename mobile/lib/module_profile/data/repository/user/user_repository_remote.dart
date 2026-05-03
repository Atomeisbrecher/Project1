import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/module_profile/data/repository/user/user_repository.dart';
import 'package:shop/module_profile/data/services/shared_preferences_service.dart';
import 'package:shop/module_profile/data/services/user_api_service.dart';
import 'package:shop/module_profile/domain/models/user/user.dart';
import 'package:shop/utils/result.dart';


class UserRepositoryRemote extends UserRepository{

  UserRepositoryRemote(this._prefs, this._apiService);

  final UserApiService _apiService;
  final SharedPreferencesService _prefs;

  //Cache related
  User? _cachedUser;
  
  @override
  Future<void> cacheCurrentUser(User user) async {
    _cachedUser = user;
    final userJson = jsonEncode(user.toJson());
    await _prefs.setString('current_user', userJson);
  }

  @override
  Future<User?> getCachedCurrentUser() async {
    // inMemory
    if (_cachedUser != null) return _cachedUser;

    // Storage
    final userString = await _prefs.getString('current_user');
    if (userString != null) {
      _cachedUser = User.fromJson(jsonDecode(userString));
      return _cachedUser;
    }
    // Else
    return null;
  }

  void clear() {
    _cachedUser = null;
    _prefs.remove('current_user');
  }

  // Non-cache related

  @override
  User? get cachedUser => _cachedUser;

  @override
  Future<Result<User>> getCurrentUser({bool forceRefresh = false}) async {
    final cached = await getCachedCurrentUser();
    if (cached != null && !forceRefresh) return Result.ok(cached);

    final result = await _apiService.fetchCurrentUser();
    
    switch (result) {
      case Ok():
        return Result.ok(result.value);
      case Error():
        return Result.error(result.error);
    }
  }

@override
  Future<Result<String>> getCurrentUserId() async {
    final user = await getCurrentUser();
    switch(user) {
      case Ok():
        return Result.ok(user.value.id);
      case Error():
        return Result.error(user.error);
    }
  }

  @override
  Future<Result<User>> getUser(String userId) async {
    final result = User(id: '1', picture: '', username: 'username2');
    return Result.ok(result);
  }

}