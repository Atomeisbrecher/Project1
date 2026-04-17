import 'package:shop/module%20chat/domain/message/message.dart';
import 'package:shop/utils/result.dart';

abstract class MessageApiService {
  // Fetch messages from API
  Future<Result<List<Message>>> fetchMessages(String chatId,
      {int offset = 0, int limit = 50});

  // Sync messages from server starting from a specific message number
  Future<Result<List<Message>>> syncMessages(String chatId,
      {required int fromMessageNumber});

  // Send message to API
  Future<Result<Message>> sendMessage(String chatId, String text,
      {String? replyToMessageId});

  // Edit message from API
  Future<Result<Message>> editMessage(
      String chatId, String messageId, String newText);

  // Delete message from API
  Future<Result<void>> deleteMessage(String chatId, String messageId);

  // Forward message to another chat
  Future<Result<Message>> forwardMessage(
      String sourceChatId, String messageId, String targetChatId);

  // Get a specific message
  Future<Result<Message>> getMessage(String chatId, String messageId);
}
