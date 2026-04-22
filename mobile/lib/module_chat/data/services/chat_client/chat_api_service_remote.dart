import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shop/module_chat/data/repository/chat_repo/chat_repository_impl.dart';
import 'package:shop/module_chat/domain/chat/chat.dart';
import 'package:shop/module_chat/data/services/chat_client/chat_api_service.dart';
import 'package:shop/services/dio_service/dio_api_client.dart';
import 'package:shop/utils/result.dart';
import 'package:logging/logging.dart';

// This is a remote implementation that communicates with your backend using Dio
class ChatApiServiceRemote implements ChatApiService {
  final DioApiClient _dioClient;
  final _log = Logger('ChatApiServiceRemote');

  ChatApiServiceRemote({
    DioApiClient? dioClient,
  }) : _dioClient = dioClient ?? DioApiClient();

  @override
  Future<Result<List<UserSearchSnippet>>> getUserDataFromUsername(String username) async {
    final request = await _dioClient.dio.get("/auth/users/$username");
    if (request.statusCode == 200) {
      return Result.ok(request.data);
    }
    return const Result.error(HttpException("User not found"));
  }

  @override
  Future<Result<List<Chat>>> fetchChats(
      {int offset = 0, int limit = 20}) async {
    try {
      _log.info('Fetching chats from API (offset: $offset, limit: $limit)');

      final List<dynamic> data = await _dioClient.get<List<dynamic>>(
        '/chats',
        queryParameters: {
          'offset': offset.toString(),
          'limit': limit.toString(),
        },
        fromJson: (data) => data as List<dynamic>,
      );

      final chats = data
          .map((chatData) => Chat.fromJson(chatData as Map<String, dynamic>))
          .toList();

      _log.info('Successfully fetched ${chats.length} chats');
      return Result.ok(chats);
    } on DioException catch (e) {
      _log.severe('Dio error fetching chats: ${e.message}');
      return Result.error(Exception('Failed to fetch chats: ${e.message}'));
    } catch (e) {
      _log.severe('Error fetching chats', e);
      return Result.error(Exception('Failed to fetch chats: $e'));
    }
  }

  @override
  Future<Result<int>> getLatestMessageNumber(String chatId) async {
    try {
      _log.info('Getting latest message number for chat: $chatId');

      final Map<String, dynamic> response =
          await _dioClient.get<Map<String, dynamic>>(
        '/chats/$chatId/latest-message-number',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      final messageNumber = response['message_number'] as int? ?? 0;

      _log.info('Latest message number for chat $chatId: $messageNumber');
      return Result.ok(messageNumber);
    } on DioException catch (e) {
      _log.severe('Dio error getting message number: ${e.message}');
      return Result.error(
          Exception('Failed to get message number: ${e.message}'));
    } catch (e) {
      _log.severe('Error getting latest message number', e);
      return Result.error(Exception('Failed to get message number: $e'));
    }
  }

  @override
  Future<Result<void>> archiveChat(String chatId) async {
    try {
      _log.info('Archiving chat: $chatId');

      await _dioClient.post<void>(
        '/chats/$chatId/archive',
        {},
      );

      _log.info('Successfully archived chat: $chatId');
      return Result.ok(null);
    } on DioException catch (e) {
      _log.severe('Dio error archiving chat: ${e.message}');
      return Result.error(Exception('Failed to archive chat: ${e.message}'));
    } catch (e) {
      _log.severe('Error archiving chat', e);
      return Result.error(Exception('Failed to archive chat: $e'));
    }
  }

  @override
  Future<Result<void>> deleteChat(String chatId) async {
    try {
      _log.info('Deleting chat: $chatId');

      await _dioClient.delete<void>(
        '/chats/$chatId',
      );

      _log.info('Successfully deleted chat: $chatId');
      return Result.ok(null);
    } on DioException catch (e) {
      _log.severe('Dio error deleting chat: ${e.message}');
      return Result.error(Exception('Failed to delete chat: ${e.message}'));
    } catch (e) {
      _log.severe('Error deleting chat', e);
      return Result.error(Exception('Failed to delete chat: $e'));
    }
  }

  @override
  Future<Result<void>> restoreChat(String chatId) async {
    try {
      _log.info('Restoring chat: $chatId');

      await _dioClient.post<void>(
        '/chats/$chatId/restore',
        {},
      );

      _log.info('Successfully restored chat: $chatId');
      return Result.ok(null);
    } on DioException catch (e) {
      _log.severe('Dio error restoring chat: ${e.message}');
      return Result.error(Exception('Failed to restore chat: ${e.message}'));
    } catch (e) {
      _log.severe('Error restoring chat', e);
      return Result.error(Exception('Failed to restore chat: $e'));
    }
  }
}
