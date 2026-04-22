import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:shop/module_auth/data/services/api/model/user/user_api_model.dart';
import 'package:shop/services/api_interceptors.dart';
import 'package:shop/module_auth/data/repository/auth/token_storage.dart';
import 'package:shop/services/dio_service/dio_api_client.dart';
import 'package:shop/services/websocket_service/websocket_service_remote.dart';
import 'package:shop/utils/result.dart';
import 'package:dio/dio.dart';

class AuthService {
  AuthService({
    String? authorizationEndpoint,
    String? tokenEndpoint,
    String? endSessionEndpoint,
    String? redirectUrl,
    String? clientID,
    DioApiClient? dioClient,
  }) : 
  _authorizationEndpoint = authorizationEndpoint ?? "http://10.0.2.2:8000/auth",
  _tokenEndpoint = tokenEndpoint ?? "http://10.0.2.2:8000/auth/token",
  _endSessionEndpoint = endSessionEndpoint ?? "http://10.0.2.2:8000/auth/logout",
  _redirectUrl = redirectUrl ?? "com.myapp.auth://oauth",
  _clientID = clientID ?? "my_flutter_app",
  _dioClient = dioClient ?? DioApiClient();


  final String _authorizationEndpoint;
  final String _tokenEndpoint;
  final String _endSessionEndpoint;
  final String _redirectUrl;
  final String _clientID;

  final DioApiClient _dioClient;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  late final AuthorizationServiceConfiguration _serviceConfig =
      AuthorizationServiceConfiguration(
    authorizationEndpoint: _authorizationEndpoint,
    tokenEndpoint: _tokenEndpoint,
    endSessionEndpoint: _endSessionEndpoint,
  );

  Future<Result<AuthorizationTokenResponse>> signIn() async {
    try {
      final AuthorizationTokenResponse result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientID,
          _redirectUrl,
          serviceConfiguration: _serviceConfig,
          scopes: [
            'profile',
            'offline_access',
            'email',
            'openid',
          ],
          allowInsecureConnections:true, //#TODO в это http, убрать при https
        ),
      );
      return Result.ok(result);
    } on FlutterAppAuthUserCancelledException catch (e) {
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  

  Future<Result<TokenResponse>> refreshToken() async {
    throw UnimplementedError();
    // try {
    //   return await _appAuth.token(TokenRequest(
    //   _clientID,
    //   _redirectUrl,
    //   serviceConfiguration: _serviceConfig,
    //   scopes: [
    //     'profile',
    //     'offline_access',
    //     'email',
    //     'openid',
    //   ],
    // ));
    // }
  }

  Future<Null> logout() async {
    // _appAuth.endSession(
    //   EndSessionRequest(
    //     idTokenHint: 'TokenHint',
    //     postLogoutRedirectUrl: 'myapp://callback/logout',
    //     serviceConfiguration: _serviceConfig,
    //   ),
    // );
    //#TODO Доделать правильную реализацию этого говна, правда используется OpaqueToken а не тот, что у меня был изначально.
    await TokenStorage.clear();
    await WebSocketServiceRemote(_dioClient).disconnect();
  }

  Future<UserApiModel> register({
    required String email,
    required String password,
    required String username,
    String? phone,
  }) async {
    try {
      final response = await _dioClient.dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'username': username,
        'phone': phone,
    });
      return UserApiModel.fromJson(response.data);
    } on DioException catch (e) {
    throw Exception(e.response?.data['detail'] ?? 'Registration failed');
  }
  }
}
