import 'package:shop/module_chat/domain/message/message.dart';

abstract class ChatCacheService {

  static const MAX_CACHE_MESSAGES = 100; // Максимальное количество сообщений для кэширования в каждом чате
  // Get cached chats
  Future<List<dynamic>> getCachedChats();

  // Save chats to cache
  Future<void> cacheChats(List<dynamic> chats);

  Future<void> cacheMessage(String chatId, Message message);

  Future<List<Message>> getCachedMessages(String chatId);
  // Get last message number for a chat from cache
  int? getLastMessageNumber(String chatId);

  // Save last message number for a chat
  Future<void> saveLastMessageNumber(String chatId, int messageNumber);

  // Clear cache
  Future<void> clearChatCache(String chatId);
}
