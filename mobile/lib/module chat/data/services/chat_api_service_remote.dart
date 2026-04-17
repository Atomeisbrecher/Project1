import 'package:shop/module%20chat/domain/chat/chat.dart';
import 'package:shop/module%20chat/data/services/chat_api_service.dart';
import 'package:shop/utils/result.dart';
import 'package:logging/logging.dart';

// This is a remote implementation that should communicate with your backend
class ChatApiServiceRemote implements ChatApiService {
  ChatApiServiceRemote({
    // Inject your HTTP client here
    // required HttpClient httpClient,
    String? value
  }) {
    // Initialize with your HTTP client
  }

  final _log = Logger('ChatApiServiceRemote');

  @override
  Future<Result<List<Chat>>> fetchChats(
      {int offset = 0, int limit = 20}) async {
    try {
      // TODO: Implement HTTP GET request to fetch chats from backend
      // Example: GET /api/chats?offset=0&limit=20
      _log.info('Fetching chats from API (offset: $offset, limit: $limit)');

      // For now,return empty list as placeholder
      return Result.ok([]);
    } catch (e) {
      _log.severe('Error fetching chats', e);
      return Result.error(Exception('Failed to fetch chats: $e'));
    }
  }

  @override
  Future<Result<int>> getLatestMessageNumber(String chatId) async {
    try {
      // TODO: Implement HTTP GET request to check latest message number
      // Example: GET /api/chats/:chatId/latest-message-number
      _log.info('Getting latest message number for chat: $chatId');

      return Result.ok(0);
    } catch (e) {
      _log.severe('Error getting latest message number', e);
      return Result.error(Exception('Failed to get message number: $e'));
    }
  }

  @override
  Future<Result<void>> archiveChat(String chatId) async {
    try {
      // TODO: Implement HTTP POST request to archive chat
      // Example: POST /api/chats/:chatId/archive
      _log.info('Archiving chat: $chatId');

      return Result.ok(null);
    } catch (e) {
      _log.severe('Error archiving chat', e);
      return Result.error(Exception('Failed to archive chat: $e'));
    }
  }

  @override
  Future<Result<void>> deleteChat(String chatId) async {
    try {
      // TODO: Implement HTTP DELETE request to delete chat
      // Example: DELETE /api/chats/:chatId
      _log.info('Deleting chat: $chatId');

      return Result.ok(null);
    } catch (e) {
      _log.severe('Error deleting chat', e);
      return Result.error(Exception('Failed to delete chat: $e'));
    }
  }

  @override
  Future<Result<void>> restoreChat(String chatId) async {
    try {
      // TODO: Implement HTTP POST request to restore chat
      // Example: POST /api/chats/:chatId/restore
      _log.info('Restoring chat: $chatId');

      return Result.ok(null);
    } catch (e) {
      _log.severe('Error restoring chat', e);
      return Result.error(Exception('Failed to restore chat: $e'));
    }
  }
}
