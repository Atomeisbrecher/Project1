import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/module_chat/domain/message/message.dart';
import 'package:shop/services/dio_service/dio_api_client.dart';
import 'package:shop/services/websocket_service/websocket_service.dart';
import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/io.dart';

class WebSocketServiceRemote implements WebSocketService {
  final DioApiClient _apiClient;
  WebSocketServiceRemote(this._apiClient);

  bool _isConnected = false;
  late String? accessToken;
  late WebSocketChannel? _messageChannel;
  Timer? _reconnectTimer;
  int _retries = 1;

  //Stream, передаёт сообщения в репозитории
  final _messageController = StreamController<Message>.broadcast();

  @override
  Stream<Message> get messages => _messageController.stream;

  @override
  Future<dynamic> connect() async {
    _reconnectTimer?.cancel();
    if (_isConnected) return;
    try {
      accessToken = await FlutterSecureStorage().read(key: 'access_token');

      _messageChannel = IOWebSocketChannel.connect(
        Uri.parse("ws://10.0.2.2:8000/chats/ws"),
        headers: {
          'access-token': '$accessToken',
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
        }
      );

      _messageChannel!.stream.listen(
        (data) {
          _isConnected = true;
          _retries = 1;

          final Map<String, dynamic> json = jsonDecode(data);
          final message = Message.fromJson(json['data'] ?? json);
          print(message);
          _messageController.add(message);

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
    _messageChannel = null;
    final result;
    if (error != null) {
      print("WS Disconnected with error: $error. Attempting to refresh tokens...");
      try {
        result = await _apiClient.dio.get('/auth/me');
        print('Result = $result');
      } catch (_) {
        print("Critical Auth Error: Refresh failed");
        print('Error = $_');
      }
    }
    reconnect();
  }

  @override
  Future<void> disconnect() async {
    try {
      _reconnectTimer?.cancel();
      _messageChannel?.sink.close(status.goingAway);
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
      _messageChannel?.sink.add(message);
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
      _messageChannel?.sink.add('ping');
    }
  }

  void dispose() {
    disconnect();
  }
}
