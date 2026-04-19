abstract class WebSocketService {
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
