import 'package:shop/module%20chat/domain/chat/chat.dart';
import 'package:shop/module%20chat/domain/chat/chat_repository.dart';
import 'package:shop/utils/result.dart';

class SyncChatsUseCase {
  SyncChatsUseCase({required ChatRepository chatRepository})
      : _chatRepository = chatRepository;

  final ChatRepository _chatRepository;

  Future<Result<List<Chat>>> call() => _chatRepository.syncChats();
}
