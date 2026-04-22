import 'package:shop/module_chat/data/repository/chat_repo/chat_repository.dart';
import 'package:shop/utils/result.dart';

class SearchChatsUseCase {
  SearchChatsUseCase({required ChatRepository chatRepository})
      : _chatRepository = chatRepository;

  final ChatRepository _chatRepository;

  Future<Result<List<dynamic>>> call(String query) =>
      _chatRepository.searchChats(query);
}
