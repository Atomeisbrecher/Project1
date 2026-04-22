import 'package:shop/module_auth/data/repository/auth/auth_repository.dart';
import 'package:logging/logging.dart';
import 'package:shop/utils/command.dart';
import 'package:shop/utils/result.dart';

class SignInViewModel {
  SignInViewModel({required OAuthRepository oAuthRepository})
      : _oAuthRepository = oAuthRepository {
    signIn = Command1<void, (String username, String email, String password)>(_signIn);
    signInWithGoogle = Command0(_signInWithGoogle);
  }
  final OAuthRepository _oAuthRepository;
  final _log = Logger('LoginViewModel');

  late Command1 signIn;
  late Command0 signInWithGoogle;

  Future<Result<void>> _signIn((String, String, String) credentials) async {
    print("smth");
    final (username, email, password) = credentials;
    final result = await _oAuthRepository.signIn(
      username: username,
      email: email, 
      password: password,
      );

    if (result is Error<void>) {
      _log.severe('Sign Up failed!');
    }
    
    return result;
  }

  Future<Result<void>> _signInWithGoogle() async {
    final result = await _oAuthRepository.signInWithGoogle();
    if (result is Error<void>) {
      _log.severe("Login failed!");
      }
      return result;
  }
}
