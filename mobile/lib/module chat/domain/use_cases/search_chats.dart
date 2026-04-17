import 'package:shop/module%20chat/domain/chat/chat_repository.dart';
import 'package:shop/utils/result.dart';

class SearchChatsUseCase {
  SearchChatsUseCase({required ChatRepository chatRepository})
      : _chatRepository = chatRepository;

  final ChatRepository _chatRepository;

  Future<Result<List<dynamic>>> call(String query) =>
      _chatRepository.searchChats(query);
}
