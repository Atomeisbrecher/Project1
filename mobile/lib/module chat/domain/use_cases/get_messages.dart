import 'package:shop/module%20chat/domain/message/message.dart';
import 'package:shop/module%20chat/domain/message/message_repository.dart';
import 'package:shop/utils/result.dart';

class GetMessagesUseCase {
  GetMessagesUseCase({required MessageRepository messageRepository})
      : _messageRepository = messageRepository;

  final MessageRepository _messageRepository;

  Future<Result<List<Message>>> call(String chatId,
          {int offset = 0, int limit = 50}) =>
      _messageRepository.getMessages(chatId, offset: offset, limit: limit);
}
