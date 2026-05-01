import 'package:shop/module_chat/data/services/chat_cache/chat_cache_service.dart';
import 'package:shop/module_chat/domain/chat/chat.dart';
import 'package:logging/logging.dart';
import 'package:shop/module_chat/domain/message/message.dart';

// later hive boxes or smth, key component of the whole system perfomance
// TODO: implement Hive or other local storage Service
// TODO: implement cache for chats and messages inside of the repositories, to avoid unnecessary API calls and improve performance
// TODO: implement cache invalidation strategy, to keep the cache up-to-date and avoid stale data
// TODO: implement cache synchronization with the server, to ensure data consistency and avoid conflicts
// TODO: implement cache eviction strategy, to manage the cache size and avoid memory issues
// TODO: implement cache expiration strategy, to ensure data freshness and avoid stale data
// TODO: implement cache versioning strategy, to handle changes in the data structure and avoid compatibility issues
// TODO: implement cache backup and restore strategy, to prevent data loss and ensure data recovery in case of failures
// TODO: implement cache monitoring and logging, to track cache performance and identify issues
// TODO: implement cache testing and validation, to ensure cache correctness and reliability
// TODO: implement cache documentation and usage guidelines, to ensure proper usage and maintenance of the cache
// TODO: implement cache security and privacy measures, to protect sensitive data and ensure compliance with regulations
// TODO: implement cache performance optimization techniques, to improve cache efficiency and reduce latency
// TODO: implement cache scalability techniques, to handle increasing data volume and user load

class ChatCacheServiceImpl implements ChatCacheService {
  ChatCacheServiceImpl() {
    _messageNumberCache = <String, int>{};
    _chatCache = <Chat>[];
    _messageCache = <String, Message>{};
  }


  late Map<String, Message> _messageCache;
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
  Future<void> cacheMessage(String chatId, Message message) async {
    _messageCache[chatId] = message;
  }

  @override
  Future<List<Message>> getCachedMessages(String chatId) async {
    final message = _messageCache[chatId];
    if (message == null) {
      _log.info('No cached messages found for chat $chatId');
      return [];
    }
    _log.info('Retrieved cached message for chat $chatId: ${message.id}');
    return [message];
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

  @override
  Future<void> clearChatCache(String chatId) async {
    _messageCache.remove(chatId);
    _messageNumberCache.remove(chatId);
    _log.info('Cache cleared for chat $chatId');
  }
  
}
