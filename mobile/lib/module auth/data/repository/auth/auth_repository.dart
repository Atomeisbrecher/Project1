import 'package:flutter/foundation.dart';
import 'package:shop/utils/result.dart';

abstract class OAuthRepository extends ChangeNotifier {
  Future<bool> get isAuthenticated;

  Future<Result<void>> login();
  Future<Result<void>> signInWithGoogle();
  Future<Result<void>> logout();
  Future<Result<void>> signIn({required String username, required String email, required String password, String? phone});
  Future<Result<void>> resetPassword(String email);
}