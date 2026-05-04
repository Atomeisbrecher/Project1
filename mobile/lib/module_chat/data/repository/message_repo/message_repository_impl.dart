import 'dart:async';

import 'package:shop/module_chat/data/services/chat_cache/chat_cache_service.dart';
import 'package:shop/module_chat/domain/message/message.dart';
import 'package:shop/module_chat/data/repository/message_repo/message_repository.dart';
import 'package:shop/module_chat/data/services/message_service/message_api_service.dart';
import 'package:shop/services/websocket_service/websocket_service.dart';
import 'package:shop/utils/result.dart';
import 'package:logging/logging.dart';

// TODO: implement pagination for messages, to load messages in batches and improve performance
// TODO: implement message reactions, to allow users to react to messages and improve user engagement
// TODO: implement message threads, to allow users to reply to specific messages and improve conversation organization
// TODO: implement message search, to allow users to search for specific messages and improve usability
// TODO: implement message attachments, to allow users to send and receive files and improve functionality
// TODO: implement message editing and deletion, to allow users to correct mistakes and improve user experience
// TODO: implement message forwarding, to allow users to share messages with other chats and improve functionality
// TODO: implement message read receipts, to allow users to see when their messages have been read and improve communication transparency
// TODO: implement message typing indicators, to allow users to see when others are typing and improve communication flow
// TODO: implement message quoting, to allow users to quote specific messages in their replies and improve conversation context
// TODO: implement message pinning, to allow users to pin important messages and improve conversation organization
// TODO: implement message scheduling, to allow users to schedule messages to be sent at a later time and improve functionality
// TODO: implement message translation, to allow users to translate messages into different languages and improve accessibility
// TODO: implement message encryption, to allow users to send secure messages and improve privacy
// TODO: implement message notifications, to allow users to receive notifications for new messages
// TODO: implement error handling and retry mechanisms, to improve reliability and user experience

// TODO: implement caching strategies and logic here later on, cache service will handle local DB



class MessageRepositoryImpl extends MessageRepository {
  MessageRepositoryImpl({
    required MessageApiService messageApiService,
    required WebSocketService webSocketService,
    required ChatCacheService chatCacheService,
  })  : _messageApiService = messageApiService,
        _webSocketService = webSocketService,
        _chatCacheService = chatCacheService {
          _initListenToMessage();
        }

  final MessageApiService _messageApiService;
  final WebSocketService _webSocketService;
  final ChatCacheService _chatCacheService;
  final _messageStreamController = StreamController<Message>.broadcast();
  final _log = Logger('MessageRepository');

  @override
  Stream<Message> get messagesStream => _messageStreamController.stream;

  void _updateLocalCache(Message message) {
    _chatCacheService.cacheMessage(message.chatId, message);
    _chatCacheService.saveLastMessageNumber(message.chatId, message.messageNumber);
  }

  void _initListenToMessage() {
    _webSocketService.messages.listen((message) {
      _log.info('Received new message from WebSocket');
      _messageStreamController.add(message);
      _updateLocalCache(message);
      notifyListeners();
    });
  }

  @override
  Future<void> cacheMessage(String chatId, Message message) async {
    await _chatCacheService.cacheMessage(chatId, message);
  }

  @override
  Future<Result<List<Message>>> getCachedMessages(String chatId) async {
    return await _chatCacheService.getCachedMessages(chatId);
  }

  @override
  int? getLastMessageNumber(String chatId) {
    return _chatCacheService.getLastMessageNumber(chatId);
  }

  @override
  Future<void> saveLastMessageNumber(String chatId, int messageNumber) async {
    await _chatCacheService.saveLastMessageNumber(chatId, messageNumber);
  }

  @override
  Future<void> clearCache(String chatId) async {
    await _chatCacheService.clearChatCache(chatId);
  }

  @override
  Future<Result<List<Message>>> getMessages(String chatId, {int offset = 0, int limit = 50}) async {
    // TODO: Orchestrize "smart" remote data fetching and local cache fetching
    try {
      final cached = await _chatCacheService.getCachedMessages(chatId);
      final result = await _messageApiService.fetchMessages(chatId, offset: offset, limit: limit);
      switch (cached) {
        case Ok<List<Message>>():
          //_log.info('Loaded ${result.value.length} messages for chat: $chatId');
          return cached;
          return result;
        case Error():
          _log.warning('Failed to load messages from API, returning empty list');
          print("fail");
          return Result.ok([]);
      }
    } catch (e) {
      _log.severe('Error loading messages', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override // Fetch database data and local Cache. Sync it all and avoid data duplication
  Future<Result<List<Message>>> syncMessages(String chatId, {required int fromMessageNumber}) async {
    try {
      final result = await _messageApiService.syncMessages(chatId, fromMessageNumber: fromMessageNumber);
      switch (result) {
        case Ok<List<Message>>():
          _log.info('Synced ${result.value.length} new messages for chat: $chatId');
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

  // @override
  // Future<Result<Message>> sendMessage(String chatId, String text,
  //     {String? replyToMessageId}) async {
  //   try {
  //     final result = await _messageApiService.sendMessage(chatId, text,
  //         replyToMessageId: replyToMessageId);
  //     switch (result) {
  //       case Ok<Message>():
  //         _log.info('Message sent to chat: $chatId');
  //         return result;
  //       case Error():
  //         _log.warning('Failed to send message to API');
  //         return Result.error(Exception('Failed to send message'));
  //     }
  //   } catch (e) {
  //     _log.severe('Error sending message', e);
  //     return Result.error(Exception('Error: $e'));
  //   }
  // }

  @override
  Future<Result<Message>> sendMessage(String chatId, String text, {String? replyToMessageId}) async {
    final response = await _messageApiService.sendMessage(
      chatId,
      text,
      replyToMessageId: replyToMessageId,
    );

    switch (response) {
      case Ok<Message>():
        print('Message sent successfully: ${response.value}');
        return Result.ok(response.value);
      case Error<Message>():
        print('Failed to send message: ${response.error}');
        return Result.error(response.error);
    }
  }

  @override
  Future<Result<Message>> editMessage(String chatId, String messageId, String newText) async {
    try {
      final result = await _messageApiService.editMessage(chatId, messageId, newText);
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
  Future<Result<Message>> forwardMessage(String sourceChatId, String messageId, String targetChatId) async {
    try {
      final result = await _messageApiService.forwardMessage(
          sourceChatId, messageId, targetChatId);
      switch (result) {
        case Ok<Message>():
          _log.info('Message forwarded from $sourceChatId to $targetChatId: $messageId');
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
  Future<Result<Message>> getMessage(String chatId, String messageId) async {
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

  void dispose() {
    _messageStreamController.close();
  }
}
