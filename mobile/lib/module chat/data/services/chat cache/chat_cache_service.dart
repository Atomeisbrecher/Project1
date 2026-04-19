abstract class ChatCacheService {
  // Get cached chats
  Future<List<dynamic>> getCachedChats();

  // Save chats to cache
  Future<void> cacheChats(List<dynamic> chats);

  // Get last message number for a chat from cache
  int? getLastMessageNumber(String chatId);

  // Save last message number for a chat
  Future<void> saveLastMessageNumber(String chatId, int messageNumber);

  // Clear cache
  Future<void> clearCache();
}
