import 'package:shop/module%20chat/domain/chat/chat.dart';
import 'package:shop/utils/result.dart';

abstract class ChatRepository {
  // Get all chats for the current user
  Future<Result<List<Chat>>> getChats({int offset = 0, int limit = 20});

  // Sync chats from server
  Future<Result<List<Chat>>> syncChats();

  // Search chats
  Future<Result<List<Chat>>> searchChats(String query);

  // Archive chat
  Future<Result<void>> archiveChat(String chatId);

  // Delete chat
  Future<Result<void>> deleteChat(String chatId);

  // Restore chat
  Future<Result<void>> restoreChat(String chatId);

  // Get last message number from cache
  int? getLastMessageNumberFromCache(String chatId);

  // Save last message number to cache
  Future<void> saveLastMessageNumberToCache(String chatId, int messageNumber);

  // Check if new messages available
  Future<Result<bool>> hasNewMessages(String chatId, int cachedMessageNumber);

  // Listen to chat changes
  Stream<Chat> watchChat(String chatId);
}
