import 'package:logging/logging.dart';
import 'package:shop/module%20auth/data/repository/auth/auth_repository.dart';
import 'package:shop/utils/result.dart';

class GoogleSignInUseCase {
  final OAuthRepository _repository;
  final Logger _log = Logger('GoogleSignInUseCase');

  GoogleSignInUseCase(this._repository);

  Future<Result<void>> call() async {
    final result = await _repository.signInWithGoogle();
    if (result is Error<void>) {
      _log.severe("Google Sign-In failed: ${result.error}");
    }
    return result;
  }
}