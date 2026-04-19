import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

class DioChatClient {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  late Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final _log = Logger('DioChatClient');

  DioChatClient({FlutterSecureStorage? secureStorage})
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

    // Add auth interceptor to include access token in headers
    _dio.interceptors.add(
      AuthInterceptor(_secureStorage, _log),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LoggingInterceptor(_log),
    );
  }

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

  AuthInterceptor(this._secureStorage, this._log);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Read access token from secure storage
      final accessToken = await _secureStorage.read(
        key: 'access_token',
      );

      // Add Authorization header if token exists
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        _log.info('Auth token added to request: ${options.path}');
      } else {
        _log.warning('No access token found in secure storage for: ${options.path}');
      }
    } catch (e) {
      _log.severe('Error reading access token from secure storage', e);
    }

    super.onRequest(options, handler);
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
