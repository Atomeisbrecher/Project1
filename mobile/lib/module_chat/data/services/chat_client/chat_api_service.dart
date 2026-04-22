import 'package:shop/module_chat/data/repository/chat_repo/chat_repository_impl.dart';
import 'package:shop/module_chat/domain/chat/chat.dart';
import 'package:shop/utils/result.dart';

abstract class ChatApiService {
  // Fetch chats from API

  Future<Result<List<UserSearchSnippet>>> getUserDataFromUsername(String username);

  Future<Result<List<Chat>>> fetchChats({int offset = 0, int limit = 20});

  // Check if new messages available
  Future<Result<int>> getLatestMessageNumber(String chatId);

  // Archive a chat
  Future<Result<void>> archiveChat(String chatId);

  // Delete a chat
  Future<Result<void>> deleteChat(String chatId);

  // Restore a chat
  Future<Result<void>> restoreChat(String chatId);
}
