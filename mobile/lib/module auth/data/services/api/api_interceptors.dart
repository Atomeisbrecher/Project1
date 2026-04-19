import 'dart:async';

import 'package:dio/dio.dart';
import 'package:shop/module%20auth/data/repository/auth/token_storage.dart';



class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);
  
  bool _isRefreshing = false;
  Completer<String?>? _refreshTokenCompleter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print('intercept');
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = token;
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('intercept');
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/auth/refresh')) {
      String? newAccessToken;

      if (_isRefreshing) {
        newAccessToken = await _refreshTokenCompleter?.future;
      } else {
        _isRefreshing = true;
        _refreshTokenCompleter = Completer<String?>();

      try {
          final refreshToken = await TokenStorage.getRefreshToken();

          final response = await dio.post(
            '/auth/refresh', 
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccess = response.data['access_token'];
            final newRefresh = response.data['refresh_token'];
            print(newRefresh);
            print(newAccess);
            TokenStorage.saveTokens(newAccess, newRefresh);
            _refreshTokenCompleter?.complete(newAccessToken);
          }

        } catch (e) {
          await TokenStorage.clear();
          // Тут можно бросить событие в EventBus/Stream, чтобы UI перекинул на Login
          return handler.next(err);
        } finally {
          _isRefreshing = false;
          _refreshTokenCompleter = null;
        }
      }

      if (newAccessToken != null) {
        final options = err.requestOptions;
        options.headers['Authorization'] = newAccessToken;
        
        try {
          final clonedRequest = await dio.fetch(options);
          return handler.resolve(clonedRequest);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
    }
    return handler.next(err);
  }
}