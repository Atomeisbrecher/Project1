import 'package:shop/module%20auth/data/repository/auth/auth_repository.dart';
import 'package:logging/logging.dart';
import 'package:shop/module%20auth/domain/use_cases/google_sign_in.dart';
import 'package:shop/utils/command.dart';
import 'package:shop/utils/result.dart';

class LoginViewModel {
  LoginViewModel({
    required OAuthRepository oAuthRepository,
    required GoogleSignInUseCase googleSignIn,
    }) : 
    _oAuthRepository = oAuthRepository,
    _googleSignIn = googleSignIn {
      login = Command0(_login);
      signInWithGoogle = Command0(_googleSignIn.call);
  }

  final GoogleSignInUseCase _googleSignIn;
  final OAuthRepository _oAuthRepository;
  final _log = Logger('LoginViewModel');

  late Command0 login;
  late Command0 signInWithGoogle;

  Future<Result<void>> _login() async {
    final result = await _oAuthRepository.login();

    if (result is Error<void>) {
      _log.severe('Login failed!');
    }
    
    return result;
  }

  // Future<Result<void>> _signInWithGoogle() async {
  //   final result = await _googleSignIn();
  //   if (result is Error<void>) {
  //     _log.severe("Login failed!");
  //     }
  //     return result;
  // }
}
