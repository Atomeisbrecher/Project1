import 'package:logging/logging.dart';
import 'package:shop/utils/result.dart';

//Сделать описание или реализацию всех нужных методов тупо, повторить для SharedPreferences
class SecureStorageService {
  final _log = Logger('SecureStorageService');

  Future<Result<String?>> fetchAuthState() async {
    _log.info('Fetching Auth state');
    
    throw UnimplementedError();
  }

  Future<Result<void>> saveAuthState(String? token) async {
    _log.info('Saving Auth state');
    throw UnimplementedError();
  }
}