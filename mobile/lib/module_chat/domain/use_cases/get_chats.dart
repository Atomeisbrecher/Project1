import 'package:shop/module_chat/domain/chat/chat.dart';
import 'package:shop/module_chat/data/repository/chat_repo/chat_repository.dart';
import 'package:shop/utils/result.dart';

class GetChatsUseCase {
  GetChatsUseCase({required ChatRepository chatRepository})
      : _chatRepository = chatRepository;

  final ChatRepository _chatRepository;

  Future<Result<List<Chat>>> call({int offset = 0, int limit = 20}) =>
      _chatRepository.getChats(offset: offset, limit: limit);
}
