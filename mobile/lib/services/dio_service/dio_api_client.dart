import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:shop/module_auth/data/repository/auth/token_storage.dart';

class DioApiClient {
  static const String baseUrl = 'http://10.0.2.2:8000/';
  
  late Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final _log = Logger('DioApiClient');

  DioApiClient({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  
    _dio.interceptors.addAll([
      AuthInterceptor(_secureStorage, _log, _dio),
      LoggingInterceptor(_log),
    ]);
  }

  Dio get dio => _dio;

  Future<T> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        endpoint,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        if (fromJson != null) {
          return fromJson(response.data);
        }
        return response.data as T;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'GET $endpoint failed: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _log.severe('Dio GET request error: ${e.message}');
      rethrow;
    }
  }

  Future<T> post<T>(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (fromJson != null) {
          return fromJson(response.data);
        }
        return response.data as T;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'POST $endpoint failed: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _log.severe('Dio POST request error: ${e.message}');
      rethrow;
    }
  }

  Future<T> put<T>(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        if (fromJson != null) {
          return fromJson(response.data);
        }
        return response.data as T;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'PUT $endpoint failed: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _log.severe('Dio PUT request error: ${e.message}');
      rethrow;
    }
  }

  Future<T> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        endpoint,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (fromJson != null && response.data != null) {
          return fromJson(response.data);
        }
        return response.data as T? ?? null as T;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'DELETE $endpoint failed: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _log.severe('Dio DELETE request error: ${e.message}');
      rethrow;
    }
  }
}

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Logger _log;
  final Dio _dio;
  AuthInterceptor(this._secureStorage, this._log, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final accessToken = await _secureStorage.read(
        key: 'access_token',
      );

      if (accessToken != null && accessToken.isNotEmpty) {
        //options.headers['Authorization'] = 'Bearer $accessToken';
        if (options.headers['Authorization'] == null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        options.headers['Accept'] = 'application/json';
        options.headers['Content-Type'] = 'application/json';   
        _log.info('Auth token added to request: ${options.path}');
      } else {
        _log.warning('No access token found in secure storage for: ${options.path}');
      }
    } catch (e) {
      _log.severe('Error reading access token from secure storage', e);
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    String? newAccessToken;
    String? newRefreshToken;
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/auth/refresh')) {

      final oldRefreshToken = await TokenStorage.getRefreshToken();
      final oldAccessToken = await TokenStorage.getAccessToken();
      final response = await _dio.post(
        "/auth/refresh", 
        options: Options(
          headers: {
            "Authorization": "$oldAccessToken",
            'X-Refresh-Token': oldRefreshToken,
          }
        )
      );
      if (response.statusCode == 200) {
        newAccessToken = response.data['access_token'];
        newRefreshToken = response.data['refresh_token'];
        await TokenStorage.clear();
        await TokenStorage.saveTokens(newAccessToken, newRefreshToken);
      }
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccessToken';
      final cloneReq = await _dio.request(
        opts.path,
        options: Options(method: opts.method, headers: opts.headers),
        data: opts.data,
        queryParameters: opts.queryParameters,
      );
      return handler.resolve(cloneReq);
    }
  }


  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await TokenStorage.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': '$token'},
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}

class LoggingInterceptor extends Interceptor {
  final Logger _log;

  LoggingInterceptor(this._log);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log.info('Dio Request: ${options.method} ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log.info('Dio Response: ${response.statusCode} ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.severe('Dio Error: ${err.message} ${err.requestOptions.path}');
    super.onError(err, handler);
  }
}