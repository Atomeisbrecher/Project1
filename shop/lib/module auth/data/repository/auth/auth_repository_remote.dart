import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:shop/module%20auth/data/services/api/api_client.dart';
import 'package:shop/utils/result.dart';


import '../../services/api/auth_api_client.dart';
import 'auth_repository.dart';

// class AuthRepositoryRemote extends AuthRepository {
//   AuthRepositoryRemote({
//     required ApiClient apiClient,
//     required AuthApiClient authApiClient,
//     required FlutterSecureStorage SecureStorage,
//   }) : _apiClient = apiClient,
//        _authApiClient = authApiClient,
//        _SecureStorage = SecureStorage {
//     _apiClient.authHeaderProvider = _authHeaderProvider;
//   }
//
//   final AuthApiClient _authApiClient;
//   final ApiClient _apiClient;
//   final FlutterSecureStorage _SecureStorage;
//
//   bool? _isAuthenticated;
//   String? _authToken;
//   final _log = Logger('AuthRepositoryRemote');
//
//   /// Fetch token from shared preferences
//   Future<void> _fetch() async {
//     final result = await _SecureStorage.fetchToken();
//     switch (result) {
//       case Ok<String?>():
//         _authToken = result.value;
//         _isAuthenticated = result.value != null;
//       case Error<String?>():
//         _log.severe(
//           'Failed to fech Token from SharedPreferences',
//           result.error,
//         );
//     }
//   }
//
//   @override
//   Future<bool> get isAuthenticated async {
//     // Status is cached
//     if (_isAuthenticated != null) {
//       return _isAuthenticated!;
//     }
//     // No status cached, fetch from storage
//     await _fetch();
//     return _isAuthenticated ?? false;
//   }
//
//   @override
//   Future<Result<void>> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final result = await _authApiClient.login(
//         LoginRequest(email: email, password: password),
//       );
//       switch (result) {
//         case Ok<LoginResponse>():
//           _log.info('User logged int');
//           // Set auth status
//           _isAuthenticated = true;
//           _authToken = result.value.token;
//           // Store in Shared preferences
//           return await _SecureStorage.saveToken(result.value.token);
//         case Error<LoginResponse>():
//           _log.warning('Error logging in: ${result.error}');
//           return Result.error(result.error);
//       }
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   @override
//   Future<Result<void>> logout() async {
//     _log.info('User logged out');
//     try {
//       // Clear stored auth token
//       final result = await _SecureStorage.saveToken(null);
//       if (result is Error<void>) {
//         _log.severe('Failed to clear stored auth token');
//       }
//
//       // Clear token in ApiClient
//       _authToken = null;
//
//       // Clear authenticated status
//       _isAuthenticated = false;
//       return result;
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   String? _authHeaderProvider() =>
//       _authToken != null ? 'Bearer $_authToken' : null;
// }



class OAuthRepositoryRemote extends OAuthRepository {
  OAuthRepositoryRemote({
    required AuthService authService,
    required ApiClient apiClient,
    required FlutterSecureStorage secureStorage,  
  }):
  _authService = authService,
  _apiClient = apiClient,
  _secureStorage = secureStorage;

  final AuthService _authService;
  final ApiClient _apiClient; //похуй потом убрать мб
  final FlutterSecureStorage _secureStorage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _log = Logger('OAuthRepositoryRemote');
  bool? _isAuthenticated;


  Future<void> _fetch() async {
      _isAuthenticated = false; //TO DO, хранение в просто sharedpreferences
      return;
  }
  
  @override
  Future<bool> get isAuthenticated async {
    if (_isAuthenticated != null) {
      return _isAuthenticated!;
    }
    await _fetch();
    return _isAuthenticated ?? false;
  }

  @override
  Future<Result<void>> signIn({
    required String username,
    required String email, 
    required String password,
    String? phone
    }
    ) async {
    try {
      //TODO проверка на существование мыла (вывод виджета, соотв. состояние, валидация мыла, пароля и т.п. на всех уровнях ебаных крч), 
      //TODO переход на экран с подтверждением почты (если юзер не подтвердил почту, то акк имеет соотв. статус и нельзя войти)
      _authService.register(
        email: email,
        password: password,
        username: username,
        phone: phone = null,
      );
      return Result.ok(null);
    } on Exception catch (error) {
      _log.severe(error);
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> login() async {
    try {
      final token = await _authService.signIn();
      switch (token) {
        case Ok():
          _log.info('User loggen in');

          _isAuthenticated = true;
          await _secureStorage.deleteAll();
          await _secureStorage.write(key: 'access_token', value: token.value.accessToken);
          await _secureStorage.write(key: 'refresh_token', value: token.value.refreshToken);
          return const Result.ok(null);
        case Error():
          _log.severe('Error logging in: ${token.error}');
          return Result.error(token.error);
      }

      } finally {
        notifyListeners();
      }
  }

  @override
  Future<Result<User?>> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate(scopeHint: ['email', 'profile']);

      if (googleUser == null) {
        _log.warning("Google User is null");
        return Result.ok(null);
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken,);
      
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      _isAuthenticated = true;
      _log.info('Sign in with Google');
      await _secureStorage.deleteAll();
      return Result.ok(user);

    } on FirebaseAuthException catch (error) {
      _log.severe(error);
      return Result.error(error);
    } on Exception catch (e) {
      _log.severe(e);
      return Result.error(e);
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> logout() async { //сделать нормально, согласно архитектуре mvvm, сделать бэкенд т.е.
    try {
      await _auth.signOut();
      await _authService.logout();
      await _secureStorage.deleteAll();
      _isAuthenticated = false;
      _log.info('Logged out');
      return Result.ok(null);
    } on Exception catch (error) {
      _log.severe("Error logging out: $error");
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async { //TO DO password reset states
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Result.ok(null);
    } on Exception catch (error) {
      _log.severe("Error reset password: $error");
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }

}