import 'package:shop/module_chat/domain/message/message.dart';
import 'package:shop/module_chat/data/repository/message_repo/message_repository.dart';
import 'package:shop/utils/result.dart';

class ForwardMessageUseCase {
  ForwardMessageUseCase({required MessageRepository messageRepository})
      : _messageRepository = messageRepository;

  final MessageRepository _messageRepository;

  Future<Result<Message>> call(
          String sourceChatId, String messageId, String targetChatId) =>
      _messageRepository.forwardMessage(sourceChatId, messageId, targetChatId);
}
