import 'dart:async';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/module%20chat/data/services/websocket%20service/websocket_service.dart';
import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/io.dart';

// WebSocket implementation using custom WebSocket protocol
// This should be implemented to connect to your backend via WebSocket/Redis pub-sub
class WebSocketServiceRemote implements WebSocketService {
  static final WebSocketServiceRemote _instance = WebSocketServiceRemote._internal();
  factory WebSocketServiceRemote({
    bool isConnected = false,
    }) => _instance;
  WebSocketServiceRemote._internal();

  late bool _isConnected;
  late String? accessToken;
  late WebSocketChannel? _channel;

  int _retries = 1;
  @override
  Future<void> connect() async {
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
          print(message);
          //_messageController.add(message);
        },
        onDone: reconnect,
        onError: (error) {
          reconnect();
        },
      );
    } catch (e) {
      return reconnect();
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      _channel?.sink.close(status.goingAway);
      _isConnected = false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void reconnect() {
    _retries++;
    int delay = (1 << _retries).clamp(1, 5);
    print("Reconnecting in $delay seconds...");
    Timer(Duration(seconds: delay), () =>connect());


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

  @override
  void dispose() {
    disconnect();
  }
}
