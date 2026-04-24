import 'package:shop/module_chat/data/repository/chat_repo/chat_repository.dart';
import 'package:shop/utils/result.dart';
import 'package:shop/module_chat/domain/chat/chat.dart';

class SearchUsersChatsUseCase {
  SearchUsersChatsUseCase({required ChatRepository chatRepository})
      : _chatRepository = chatRepository;

  final ChatRepository _chatRepository;

  Future<Result<List<Chat>>> call(String query) =>
      _chatRepository.searchUsersChats(query);
}