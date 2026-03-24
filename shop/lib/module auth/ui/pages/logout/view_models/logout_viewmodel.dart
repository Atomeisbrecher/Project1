import 'package:shop/module%20auth/data/repository/auth/auth_repository.dart';
import 'package:logging/logging.dart';
import 'package:shop/utils/command.dart';
import 'package:shop/utils/result.dart';

class LogoutViewModel {
  LogoutViewModel({required OAuthRepository oAuthRepository})
      : _oAuthRepository = oAuthRepository {
    logout = Command0(_logout);
  }
  final OAuthRepository _oAuthRepository;
  final _log = Logger('LogoutViewModel');

  late Command0 logout;

  Future<Result<void>> _logout() async {
    final result = await _oAuthRepository.logout();

    if (result is Error<void>) {
      _log.warning('Logout failed!');
    }
    
    return result;
  }
}
