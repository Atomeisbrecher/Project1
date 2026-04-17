import 'package:shop/module%20chat/data/services/chat_cache_service.dart';
import 'package:shop/module%20chat/domain/chat/chat.dart';
import 'package:logging/logging.dart';

// Simple in-memory cache implementation
// For production, consider using hive, sqflite, or shared_preferences
class ChatCacheServiceImpl implements ChatCacheService {
  ChatCacheServiceImpl() {
    _messageNumberCache = <String, int>{};
    _chatCache = <Chat>[];
  }

  late Map<String, int> _messageNumberCache;
  late List<Chat> _chatCache;
  final _log = Logger('ChatCacheServiceImpl');

  @override
  Future<List<Chat>> getCachedChats() async {
    _log.info('Retrieved ${_chatCache.length} chats from cache');
    return _chatCache;
  }

  @override
  Future<void> cacheChats(List<dynamic> chats) async {
    _chatCache = chats.cast<Chat>().toList();
    _log.info('Cached ${_chatCache.length} chats');
  }

  @override
  int? getLastMessageNumber(String chatId) {
    final number = _messageNumberCache[chatId];
    _log.info('Retrieved last message number for chat $chatId: $number');
    return number;
  }

  @override
  Future<void> saveLastMessageNumber(String chatId, int messageNumber) async {
    _messageNumberCache[chatId] = messageNumber;
    _log.info(
        'Saved last message number for chat $chatId: $messageNumber');
  }

  @override
  Future<void> clearCache() async {
    _chatCache.clear();
    _messageNumberCache.clear();
    _log.info('Cache cleared');
  }
}
