import 'package:shop/module%20chat/domain/chat/chat.dart';
import 'package:shop/module%20chat/domain/chat/chat_repository.dart';
import 'package:shop/module%20chat/data/services/chat_api_service.dart';
import 'package:shop/module%20chat/data/services/chat_cache_service.dart';
import 'package:shop/module%20chat/data/services/websocket_service.dart';
import 'package:shop/utils/result.dart';
import 'package:logging/logging.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required ChatApiService chatApiService,
    required ChatCacheService chatCacheService,
    required WebSocketService webSocketService,
  })  : _chatApiService = chatApiService,
        _chatCacheService = chatCacheService,
        _webSocketService = webSocketService {
    _initWebSocketListeners();
  }

  final ChatApiService _chatApiService;
  final ChatCacheService _chatCacheService;
  final WebSocketService _webSocketService;
  final _log = Logger('ChatRepository');

  void _initWebSocketListeners() {
    // Initialize WebSocket listeners for real-time updates
  }

  @override
  Future<Result<List<Chat>>> getChats({int offset = 0, int limit = 20}) async {
    try {
      // Try to get from cache first
      final cachedChats = await _chatCacheService.getCachedChats();
      if (cachedChats.isNotEmpty) {
        _log.info('Loaded chats from cache');
        return Result.ok(cachedChats.cast<Chat>());
      }

      // If not in cache, fetch from API
      final result = await _chatApiService.fetchChats(offset: offset, limit: limit);
      switch (result) {
        case Ok<List<Chat>>():
          await _chatCacheService.cacheChats(result.value);
          _log.info('Loaded ${result.value.length} chats from API');
          return result;
        case Error():
          _log.warning('Failed to load chats from API, returning empty list');
          return Result.ok([]);
      }
    } catch (e) {
      _log.severe('Error loading chats', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override
  Future<Result<List<Chat>>> syncChats() async {
    try {
      final result = await _chatApiService.fetchChats();
      switch (result) {
        case Ok<List<Chat>>():
          await _chatCacheService.cacheChats(result.value);
          _log.info('Synced ${result.value.length} chats');
          return result;
        case Error():
          _log.warning('Failed to sync chats from API, returning cached chats');
          final cachedChats = await _chatCacheService.getCachedChats();
          return Result.ok(cachedChats.cast<Chat>());
      }
    } catch (e) {
      _log.severe('Error syncing chats', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override
  Future<Result<List<Chat>>> searchChats(String query) async {
    try {
      // TODO: Implement search on the server side
      // For now, we'll filter cached chats
      final cachedChats = await _chatCacheService.getCachedChats();
      final filtered = cachedChats.cast<Chat>().where((chat) {
        return chat.username.toLowerCase().contains(query.toLowerCase()) ||
            chat.lastMessage.toLowerCase().contains(query.toLowerCase());
      }).toList();

      _log.info('Found ${filtered.length} chats matching query: $query');
      return Result.ok(filtered);
    } catch (e) {
      _log.severe('Error searching chats', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override
  Future<Result<void>> archiveChat(String chatId) async {
    try {
      final result = await _chatApiService.archiveChat(chatId);

      if (result is Ok) {
        // Remove from cache
        final cachedChats = await _chatCacheService.getCachedChats();
        cachedChats.removeWhere((chat) => (chat as Chat).id == chatId);
        await _chatCacheService.cacheChats(cachedChats);
        _log.info('Archived chat: $chatId');
      }

      return result;
    } catch (e) {
      _log.severe('Error archiving chat', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override
  Future<Result<void>> deleteChat(String chatId) async {
    try {
      final result = await _chatApiService.deleteChat(chatId);

      if (result is Ok) {
        // Remove from cache
        final cachedChats = await _chatCacheService.getCachedChats();
        cachedChats.removeWhere((chat) => (chat as Chat).id == chatId);
        await _chatCacheService.cacheChats(cachedChats);
        _log.info('Deleted chat: $chatId');
      }

      return result;
    } catch (e) {
      _log.severe('Error deleting chat', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override
  Future<Result<void>> restoreChat(String chatId) async {
    try {
      final result = await _chatApiService.restoreChat(chatId);

      if (result is Ok) {
        _log.info('Restored chat: $chatId');
      }

      return result;
    } catch (e) {
      _log.severe('Error restoring chat', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override
  int? getLastMessageNumberFromCache(String chatId) {
    return _chatCacheService.getLastMessageNumber(chatId);
  }

  @override
  Future<void> saveLastMessageNumberToCache(
      String chatId, int messageNumber) async {
    await _chatCacheService.saveLastMessageNumber(chatId, messageNumber);
  }

  @override
  Future<Result<bool>> hasNewMessages(
      String chatId, int cachedMessageNumber) async {
    try {
      final result = await _chatApiService.getLatestMessageNumber(chatId);
      switch (result) {
        case Ok<int>():
          final hasNew = result.value > cachedMessageNumber;
          if (hasNew) {
            _log.info(
                'Chat $chatId has new messages. Cached: $cachedMessageNumber, Latest: ${result.value}');
          }
          return Result.ok(hasNew);
        case Error():
          _log.warning('Failed to get latest message number for chat: $chatId');
          return Result.ok(false);
      }
    } catch (e) {
      _log.severe('Error checking for new messages', e);
      return Result.error(Exception('Error: $e'));
    }
  }

  @override
  Stream<Chat> watchChat(String chatId) {
    return _webSocketService.onChatUpdate().map((event) {
      // Parse and map the event to Chat object
      // Implementation depends on your WebSocket event format
      return event as Chat;
    });
  }
}
