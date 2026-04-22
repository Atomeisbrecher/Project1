import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/services/dio_service/dio_api_client.dart';
import 'package:shop/services/websocket_service/websocket_service.dart';
import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/io.dart';

// WebSocket implementation using custom WebSocket protocol
// This should be implemented to connect to your backend via WebSocket/Redis pub-sub
class WebSocketServiceRemote implements WebSocketService {
  // static final WebSocketServiceRemote _instance = WebSocketServiceRemote._internal();

  // factory WebSocketServiceRemote() => _instance;
  // WebSocketServiceRemote._internal();
  
  // static DioApiClient? _dio;
  // static void setClient(DioApiClient client) => _dio = client;
  // final client = _dio;
  final DioApiClient _apiClient;
  WebSocketServiceRemote(this._apiClient);

  bool _isConnected = false;
  late String? accessToken;
  late WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  int _retries = 1;

  //Stream, передаёт сообщения в репозитории
  final _messageController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get messages => _messageController.stream;

  @override
  Future<dynamic> connect() async {
    _reconnectTimer?.cancel();
    if (_isConnected) return;
    print("WS: Попытка вызвать GET /auth/me...");
    try {
      print("Проверка _dio: $_apiClient");
      final response = await _apiClient.dio.get('/auth/me');
      print("WS: Ответ от сервера: ${response.statusCode}");
      return;
    } catch  (e) {
      print(e);
      return;
    }
    try {
      accessToken = await FlutterSecureStorage().read(key: 'access_token');
      _channel = IOWebSocketChannel.connect(
        Uri.parse("ws://10.0.2.2:8000/chats/ws"),
        headers: {
          'access-token': '$accessToken',
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
        }
        );

      _channel!.stream.listen(
        (message) {
          _isConnected = true;
          _retries = 1;
          _messageController.add(message);
          print(message);
        },
        onDone: () {
          print("WS: Connection closed by server (onDone)");
          _handleDisconnect(); 
        },
        onError: (error) {
          print("WS: Connection error: $error");
          _handleDisconnect(error: error);
        }
      );
    } catch (e) {
      _handleDisconnect(error: e);
    }
  }

  void _handleDisconnect({dynamic error}) async {
    _isConnected = false;
    _channel = null;

    // Если ошибка похожа на 401 (бэкенд закрыл соединение)
    // Мы делаем проверочный легкий запрос через Dio.
    // Если токен протух, AuthInterceptor сам запустит refresh.
    final result;
    if (error != null) {
      print("WS Disconnected with error: $error. Attempting to refresh tokens...");
      try {
        // Вызываем любой защищенный эндпоинт, например /auth/me или просто /refresh вручную
        // Это заставит Interceptor обновить токены, если они протухли
        result = await _apiClient?.dio.get('/auth/me');
        print('Result = $result');
      } catch (_) {
        // Если даже здесь ошибка — значит рефреш-токен тоже сдох, идем на логин
        print("Critical Auth Error: Refresh failed");
        print('Error = $_');
        return reconnect(); 
      }
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      _reconnectTimer?.cancel();
      _channel?.sink.close(status.goingAway);
      _isConnected = false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void reconnect() {
    if (_reconnectTimer?.isActive ?? false) return;

    _retries++;
    int delay = (1 << _retries).clamp(1, 5);
    print("Reconnecting in $delay seconds...");
    _reconnectTimer = Timer(Duration(seconds: delay), () => connect());


  }

  @override
  void sendMessage(String message) {
    if (_isConnected) {
      _channel?.sink.add(message);
    } else {
    }
  }

  @override
  bool get isConnected => _isConnected;
  
  @override
  Stream<dynamic> onNewMessage(String chatId) {
    // TODO: Implement listening to new messages for a specific chat
    // Channel: chat:$chatId:messages
    return Stream.empty();
  }

  @override
  Stream<dynamic> onMessageUpdate(String chatId) {
    // TODO: Implement listening to message updates (delivery, read status)
    // Channel: chat:$chatId:updates
    return Stream.empty();
  }

  @override
  Stream<dynamic> onChatUpdate() {
    // TODO: Implement listening to chat updates
    // Channel: user:current_user:chats
    return Stream.empty();
  }

  @override
  void ping() {
    if (_isConnected) {
      // TODO: Send a ping message to keep connection alive
      _channel?.sink.add('ping');
    }
  }

  void dispose() {
    disconnect();
  }
}
