import 'package:shop/module%20chat/domain/message/message.dart';
import 'package:shop/module%20chat/domain/message/message_repository.dart';
import 'package:shop/module%20chat/data/services/message%20service/message_api_service.dart';
import 'package:shop/module%20chat/data/services/websocket%20service/websocket_service.dart';
import 'package:shop/utils/result.dart';
import 'package:logging/logging.dart';

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl({
    required MessageApiService messageApiService,
    required WebSocketService webSocketService,
  })  : _messageApiService = messageApiService,
        _webSocketService = webSocketService;

  final MessageApiService _messageApiService;
  final WebSocketService _webSocketService;
  final _log = Logger('MessageRepository');

  @override
  Future<Result<List<Message>>> getMessages(String chatId,
      {int offset = 0, int limit = 50}) async {
    try {
      final result = await _messageApiService.fetchMessages(chatId,
          offset: offset, limit: limit);
      switch (result) {
        case Ok<List<Message>>():
          _log.info('Loaded ${result.value.length} messages for chat: $chatId');
          return result;
        case Error():
          _log.warning('Failed to load messages from API, returning empty list');
          return Result.ok([]);
      }
    } catch (e) {
      _log.severe('Error loading messages', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override
  Future<Result<List<Message>>> syncMessages(String chatId,
      {required int fromMessageNumber}) async {
    try {
      final result = await _messageApiService.syncMessages(chatId,
          fromMessageNumber: fromMessageNumber);
      switch (result) {
        case Ok<List<Message>>():
          _log.info(
              'Synced ${result.value.length} new messages for chat: $chatId');
          return result;
        case Error():
          _log.warning('Failed to sync messages from API, returning empty list');
          return Result.ok([]);
      }
    } catch (e) {
      _log.severe('Error syncing messages', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override
  Future<Result<Message>> sendMessage(String chatId, String text,
      {String? replyToMessageId}) async {
    try {
      final result = await _messageApiService.sendMessage(chatId, text,
          replyToMessageId: replyToMessageId);
      switch (result) {
        case Ok<Message>():
          _log.info('Message sent to chat: $chatId');
          return result;
        case Error():
          _log.warning('Failed to send message to API');
          return Result.error(Exception('Failed to send message'));
      }
    } catch (e) {
      _log.severe('Error sending message', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override
  Future<Result<Message>> editMessage(
      String chatId, String messageId, String newText) async {
    try {
      final result =
          await _messageApiService.editMessage(chatId, messageId, newText);
      switch (result) {
        case Ok<Message>():
          _log.info('Message edited: $messageId in chat: $chatId');
          return result;
        case Error():
          _log.warning('Failed to edit message via API');
          return Result.error(Exception('Failed to edit message'));
      }
    } catch (e) {
      _log.severe('Error editing message', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override
  Future<Result<void>> deleteMessage(String chatId, String messageId) async {
    try {
      final result = await _messageApiService.deleteMessage(chatId, messageId);
      switch (result) {
        case Ok():
          _log.info('Message deleted: $messageId from chat: $chatId');
          break;
        case Error():
          _log.warning('Failed to delete message via API');
          return Result.error(Exception('Failed to delete message'));
      }
    } catch (e) {
      _log.severe('Error deleting message', e);
      return Result.error(Exception('Error: $e'));
    }
    return Result.ok(null);
  }

  @override
  Future<Result<Message>> forwardMessage(
      String sourceChatId, String messageId, String targetChatId) async {
    try {
      final result = await _messageApiService.forwardMessage(
          sourceChatId, messageId, targetChatId);
      switch (result) {
        case Ok<Message>():
          _log.info(
              'Message forwarded from $sourceChatId to $targetChatId: $messageId');
          return result;
        case Error():
          _log.warning('Failed to forward message via API');
          return Result.error(Exception('Failed to forward message'));
      }
    } catch (e) {
      _log.severe('Error forwarding message', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override
  Future<Result<Message>> getMessage(
      String chatId, String messageId) async {
    try {
      final result = await _messageApiService.getMessage(chatId, messageId);
      switch (result) {
        case Ok<Message>():
          _log.info('Retrieved message: $messageId from chat: $chatId');
          return result;
        case Error():
          _log.warning('Failed to get message from API');
          return Result.error(Exception('Failed to get message'));
      }
    } catch (e) {
      _log.severe('Error getting message', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override
  Stream<Message> watchMessages(String chatId) {
    return _webSocketService.onNewMessage(chatId).map((event) {
      // Parse and map the event to Message object
      // Implementation depends on your WebSocket event format
      return event as Message;
    });
  }

  @override
  Stream<Message> watchMessageUpdates(String chatId) {
    return _webSocketService.onMessageUpdate(chatId).map((event) {
      // Parse and map the event to Message object
      // Implementation depends on your WebSocket event format
      return event as Message;
    });
  }
}
