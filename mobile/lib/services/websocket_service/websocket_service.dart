import 'package:shop/module_chat/domain/message/message.dart';
import 'package:shop/services/dio_service/dio_api_client.dart';

abstract class WebSocketService {
  final DioApiClient _apiClient;
  WebSocketService(this._apiClient);

  Stream<dynamic> get messages;
  // Connect to WebSocket
  Future<void> connect();

  // Disconnect from WebSocket
  Future<void> disconnect();

  // Is connected
  bool get isConnected;

  // Listen to new messages
  Stream<dynamic> onNewMessage(String chatId);

  // Listen to message updates (delivery status, read status, etc)
  Stream<dynamic> onMessageUpdate(String chatId);

  // Listen to chat updates
  Stream<dynamic> onChatUpdate();

  void reconnect();
  // Send ping to keep connection alive
  void ping();
}
