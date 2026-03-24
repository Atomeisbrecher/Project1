import 'package:shop/utils/result.dart';

import 'auth_repository.dart';

class OAuthRepositoryDev extends OAuthRepository {
  /// User is always authenticated in dev scenarios
  @override
  Future<bool> get isAuthenticated => Future.value(true);

  /// Login is always successful in dev scenarios
  @override
  Future<Result<void>> login() async {
    // TODO: implement local Login
    throw UnimplementedError();
  }

  /// Logout is always successful in dev scenarios
  @override
  Future<Result<void>> logout() async {
    // TODO: implement local Logout later
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    // TODO: implement local Password Reset later
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> signInWithGoogle() {
    // TODO: implement localo Sign In With Google
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> signIn({required String email, required String password}) {
    // TODO: implement local Sign In
    throw UnimplementedError();
  }
}