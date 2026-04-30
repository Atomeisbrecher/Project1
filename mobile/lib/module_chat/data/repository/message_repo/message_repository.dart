import 'package:flutter/foundation.dart';
import 'package:shop/module_chat/domain/message/message.dart';
import 'package:shop/utils/result.dart';

abstract class MessageRepository extends ChangeNotifier {
  // Get messages for a chat
  Future<Result<List<Message>>> getMessages(String chatId,
      {int offset = 0, int limit = 50});

  // Sync messages from server
  Future<Result<List<Message>>> syncMessages(String chatId,
      {required int fromMessageNumber});

  Stream<Message> get messagesStream;

  // Send message
  Future<Result<Message>> sendMessage(String chatId, String text, {String? replyToMessageId});

  // Edit message
  Future<Result<Message>> editMessage(
      String chatId, String messageId, String newText);

  // Delete message
  Future<Result<void>> deleteMessage(String chatId, String messageId);

  // Forward message
  Future<Result<Message>> forwardMessage(
      String sourceChatId, String messageId, String targetChatId);

  // Get message
  Future<Result<Message>> getMessage(String chatId, String messageId);

  // Listen to messages
  Stream<Message> watchMessages(String chatId);

  // Listen to message updates (for real-time delivery status, read status, etc)
  Stream<Message> watchMessageUpdates(String chatId);
}
