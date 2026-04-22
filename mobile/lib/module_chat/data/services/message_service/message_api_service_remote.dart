import 'package:dio/dio.dart';
import 'package:shop/module_chat/domain/message/message.dart';
import 'package:shop/module_chat/data/services/message_service/message_api_service.dart';
import 'package:shop/services/dio_service/dio_api_client.dart';
import 'package:shop/utils/result.dart';
import 'package:logging/logging.dart';

// This is a remote implementation that communicates with your backend using Dio
class MessageApiServiceRemote implements MessageApiService {
  final DioApiClient _dioClient;
  final _log = Logger('MessageApiServiceRemote');

  MessageApiServiceRemote({
    DioApiClient? dioClient,
  }) : _dioClient = dioClient ?? DioApiClient();

  @override
  Future<Result<List<Message>>> fetchMessages(String chatId,
      {int offset = 0, int limit = 50}) async {
    try {
      _log.info(
          'Fetching messages for chat: $chatId (offset: $offset, limit: $limit)');

      final List<dynamic> data = await _dioClient.get<List<dynamic>>(
        '/chats/$chatId/messages',
        queryParameters: {
          'offset': offset.toString(),
          'limit': limit.toString(),
        },
        fromJson: (data) => data as List<dynamic>,
      );

      final messages = data
          .map((msgData) => Message.fromJson(msgData as Map<String, dynamic>))
          .toList();

      _log.info('Successfully fetched ${messages.length} messages');
      return Result.ok(messages);
    } on DioException catch (e) {
      _log.severe('Dio error fetching messages: ${e.message}');
      return Result.error(Exception('Failed to fetch messages: ${e.message}'));
    } catch (e) {
      _log.severe('Error fetching messages', e);
      return Result.error(Exception('Failed to fetch messages: $e'));
    }
  }

  @override
  Future<Result<List<Message>>> syncMessages(String chatId,
      {required int fromMessageNumber}) async {
    try {
      _log.info(
          'Syncing messages for chat: $chatId from message number: $fromMessageNumber');

      final List<dynamic> data = await _dioClient.get<List<dynamic>>(
        '/chats/$chatId/messages/sync',
        queryParameters: {
          'from': fromMessageNumber.toString(),
        },
        fromJson: (data) => data as List<dynamic>,
      );

      final messages = data
          .map((msgData) => Message.fromJson(msgData as Map<String, dynamic>))
          .toList();

      _log.info('Successfully synced ${messages.length} messages');
      return Result.ok(messages);
    } on DioException catch (e) {
      _log.severe('Dio error syncing messages: ${e.message}');
      return Result.error(Exception('Failed to sync messages: ${e.message}'));
    } catch (e) {
      _log.severe('Error syncing messages', e);
      return Result.error(Exception('Failed to sync messages: $e'));
    }
  }

  @override
  Future<Result<Message>> sendMessage(String chatId, String text,
      {String? replyToMessageId}) async {
    try {
      _log.info('Sending message to chat: $chatId');

      final body = {
        'text': text,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
      };

      final Map<String, dynamic> response =
          await _dioClient.post<Map<String, dynamic>>(
        '/chats/$chatId/messages',
        body,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      final message = Message.fromJson(response);

      _log.info('Successfully sent message: ${message.id}');
      return Result.ok(message);
    } on DioException catch (e) {
      _log.severe('Dio error sending message: ${e.message}');
      return Result.error(Exception('Failed to send message: ${e.message}'));
    } catch (e) {
      _log.severe('Error sending message', e);
      return Result.error(Exception('Failed to send message: $e'));
    }
  }

  @override
  Future<Result<Message>> editMessage(
      String chatId, String messageId, String newText) async {
    try {
      _log.info('Editing message: $messageId in chat: $chatId');

      final body = {
        'text': newText,
      };

      final Map<String, dynamic> response =
          await _dioClient.put<Map<String, dynamic>>(
        '/chats/$chatId/messages/$messageId',
        body,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      final message = Message.fromJson(response);

      _log.info('Successfully edited message: ${message.id}');
      return Result.ok(message);
    } on DioException catch (e) {
      _log.severe('Dio error editing message: ${e.message}');
      return Result.error(Exception('Failed to edit message: ${e.message}'));
    } catch (e) {
      _log.severe('Error editing message', e);
      return Result.error(Exception('Failed to edit message: $e'));
    }
  }

  @override
  Future<Result<void>> deleteMessage(String chatId, String messageId) async {
    try {
      _log.info('Deleting message: $messageId from chat: $chatId');

      await _dioClient.delete<void>(
        '/chats/$chatId/messages/$messageId',
      );

      _log.info('Successfully deleted message: $messageId');
      return Result.ok(null);
    } on DioException catch (e) {
      _log.severe('Dio error deleting message: ${e.message}');
      return Result.error(Exception('Failed to delete message: ${e.message}'));
    } catch (e) {
      _log.severe('Error deleting message', e);
      return Result.error(Exception('Failed to delete message: $e'));
    }
  }

  @override
  Future<Result<Message>> forwardMessage(
      String sourceChatId, String messageId, String targetChatId) async {
    try {
      _log.info(
          'Forwarding message: $messageId from $sourceChatId to $targetChatId');

      final body = {
        'sourceChatId': sourceChatId,
        'messageId': messageId,
      };

      final Map<String, dynamic> response =
          await _dioClient.post<Map<String, dynamic>>(
        '/chats/$targetChatId/messages/forward',
        body,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      final message = Message.fromJson(response);

      _log.info('Successfully forwarded message: ${message.id}');
      return Result.ok(message);
    } on DioException catch (e) {
      _log.severe('Dio error forwarding message: ${e.message}');
      return Result.error(Exception('Failed to forward message: ${e.message}'));
    } catch (e) {
      _log.severe('Error forwarding message', e);
      return Result.error(Exception('Failed to forward message: $e'));
    }
  }

  @override
  Future<Result<Message>> getMessage(
      String chatId, String messageId) async {
    try {
      _log.info('Getting message: $messageId from chat: $chatId');

      final Map<String, dynamic> response =
          await _dioClient.get<Map<String, dynamic>>(
        '/chats/$chatId/messages/$messageId',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      final message = Message.fromJson(response);

      _log.info('Successfully retrieved message: ${message.id}');
      return Result.ok(message);
    } on DioException catch (e) {
      _log.severe('Dio error getting message: ${e.message}');
      return Result.error(Exception('Failed to get message: ${e.message}'));
    } catch (e) {
      _log.severe('Error getting message', e);
      return Result.error(Exception('Failed to get message: $e'));
    }
  }
}
