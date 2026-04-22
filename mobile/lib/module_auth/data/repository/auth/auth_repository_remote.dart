import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:shop/module_auth/data/repository/auth/token_storage.dart';
import 'package:shop/services/websocket_service/websocket_service.dart';
import 'package:shop/utils/result.dart';


import '../../services/api/auth_api_client.dart';
import 'auth_repository.dart';

class OAuthRepositoryRemote extends OAuthRepository {
  OAuthRepositoryRemote({
    required AuthService authService,
    required TokenStorage secureStorage,
    required WebSocketService webSocketServiceRemote,
  }):
  _authService = authService,
  _secureStorage = secureStorage,
  _webSocketServiceRemote = webSocketServiceRemote;

  final WebSocketService _webSocketServiceRemote;
  final AuthService _authService;
  final TokenStorage _secureStorage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _log = Logger('OAuthRepositoryRemote');
  bool? _isAuthenticated;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> _fetch() async {
    try {
      _log.info('Fetching auth state from secure storage...');
      final isAuth = await FlutterSecureStorage().containsKey(key: _refreshTokenKey);
      _isAuthenticated = isAuth;
      _log.info('Auth state fetched successfully: $_isAuthenticated');
    } catch (e) {
      _log.severe('Error restoring auth state: $e');
      _isAuthenticated = false;
    }
  }
  
  @override
  Future<bool> get isAuthenticated async {
    _log.fine('Checking isAuthenticated property');
    if (_isAuthenticated != null) {
      if (_isAuthenticated == true) await _webSocketServiceRemote.connect();
      _log.fine('Auth state is cached: $_isAuthenticated');
      return _isAuthenticated!;
    }
    _log.info('Auth state not cached, fetching from storage...');
    await _fetch();
    final result = _isAuthenticated ?? false;
    _log.info('isAuthenticated getter returning: $result');
    if (_isAuthenticated == true) await _webSocketServiceRemote.connect();
    return result;
  }

  @override
  Future<Result<void>> signIn({ //register это блять
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
      _isAuthenticated = true;
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
      _log.info('Starting login process...');
      final token = await _authService.signIn();
      switch (token) {
        case Ok():
          _log.info('SignIn successful, storing tokens to secure storage');
          await TokenStorage.clear();
          await TokenStorage.saveTokens(token.value.accessToken, token.value.refreshToken);
          _isAuthenticated = true;
          _log.info('User authenticated, setting _isAuthenticated = true');
          
          return const Result.ok(null);
        case Error():
          _log.severe('Error during login: ${token.error}');
          _isAuthenticated = false;
          _log.warning('Setting _isAuthenticated = false due to login error');
          return Result.error(token.error);
      }
    } finally {
      _log.fine('Login process completed, notifying listeners');
      notifyListeners();
    }
  }

  @override
  Future<Result<User?>> signInWithGoogle() async {
    try {
      _log.info('Starting Google Sign-In process...');
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate(scopeHint: ['email', 'profile']);

      if (googleUser == null) {
        _log.warning("Google Sign-In cancelled or user is null");
        return Result.ok(null);
      }
      
      _log.info('Google user authenticated: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken,);
      
      _log.info('Creating Firebase credential from Google auth...');
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        _log.severe('Firebase credential sign-in returned null user');
        return Result.ok(null);
      }
      
      _isAuthenticated = true;
      _log.info('Firebase authentication successful for user: ${user.email}, setting _isAuthenticated = true');
      await FlutterSecureStorage().deleteAll();
      
      // Save auth state to secure storage
      if (googleAuth.idToken != null) {
        await FlutterSecureStorage().write(key: _accessTokenKey, value: googleAuth.idToken!);
      }
      
      return Result.ok(user);

    } on FirebaseAuthException catch (error) {
      _log.severe('FirebaseAuthException during Google Sign-In: ${error.code} - ${error.message}');
      _isAuthenticated = false;
      return Result.error(error);
    } on Exception catch (e) {
      _log.severe('Unexpected error during Google Sign-In: $e');
      _isAuthenticated = false;
      return Result.error(e);
    } finally {
      _log.fine('Google Sign-In process completed, notifying listeners');
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> logout() async { //сделать нормально, согласно архитектуре mvvm, сделать бэкенд т.е.
    try {
      _log.info('Starting logout process...');
      _log.fine('Signing out from Firebase...');
      await _auth.signOut();
      
      _log.fine('Calling auth service logout method...');
      await _authService.logout();
      
      _log.fine('Clearing all tokens from secure storage...');
      await TokenStorage.clear();
      
      _isAuthenticated = false;
      _log.info('User logged out successfully, setting _isAuthenticated = false');
      
      return Result.ok(null);
    } on Exception catch (error) {
      _log.severe("Error during logout: $error");
      _isAuthenticated = false;
      return Result.error(error);
    } finally {
      _log.fine('Logout process completed, notifying listeners');
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