// import 'dart:async';

// import 'package:dio/dio.dart';
// import 'package:shop/module%20auth/data/repository/auth/token_storage.dart';



// class AuthInterceptor2 extends InterceptorsWrapper {
//   final Dio dio;

//   AuthInterceptor2(this.dio);
  
//   bool _isRefreshing = false;
//   Completer<String?>? _refreshTokenCompleter;

//   Future<void> retry(RequestOptions requestOptions)async{
//     await dio.fetch(requestOptions);
//   }

//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     print('intercept');
//     //return super.onRequest(options, handler);
//     final token = await TokenStorage.getAccessToken();
//     if (token != null) {
//       options.headers['Authorization'] = token;
//     }
//     return handler.next(options);
//   }

//   @override
//   Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
//     return super.onResponse(response, handler);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     print('intercept onError');
//     if (err.response?.statusCode == 401) {
//       String? newAccessToken = "";

//       if (_isRefreshing) {
//         newAccessToken = await _refreshTokenCompleter?.future;
//       } else {
//         _isRefreshing = true;
//         _refreshTokenCompleter = Completer<String?>();

//       try {
//           final refreshToken = await TokenStorage.getRefreshToken();
//           print("post /auth/refresh");
//           final response = await dio.post(
//             '/auth/refresh', 
//             data: {'refresh_token': refreshToken},
//           );

//           if (response.statusCode == 200) {
//             final newAccess = response.data['access_token'];
//             final newRefresh = response.data['refresh_token'];
//             print(newRefresh);
//             print(newAccess);
//             TokenStorage.saveTokens(newAccess, newRefresh);
//             _refreshTokenCompleter?.complete(newAccessToken);
//           }

//         } catch (e) {
//           await TokenStorage.clear();
//           // Тут можно бросить событие в EventBus/Stream, чтобы UI перекинул на Login
//           return handler.next(err);
//         } finally {
//           _isRefreshing = false;
//           _refreshTokenCompleter = null;
//         }
//       }

//       if (newAccessToken != null) {
//         final options = err.requestOptions;
//         options.headers['Authorization'] = newAccessToken;
        
//         try {
//           final clonedRequest = await dio.fetch(options);
//           return handler.resolve(clonedRequest);
//         } on DioException catch (e) {
//           return handler.next(e);
//         }
//       }
//     }
//     //return super.onError(err, handler);
//     return handler.next(err);
//   }
// }