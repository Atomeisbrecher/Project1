import 'package:shop/module_chat/data/repository/message_repo/message_repository.dart';
import 'package:shop/utils/result.dart';

class DeleteMessageUseCase {
  DeleteMessageUseCase({required MessageRepository messageRepository})
      : _messageRepository = messageRepository;

  final MessageRepository _messageRepository;

  Future<Result<void>> call(String chatId, String messageId) =>
      _messageRepository.deleteMessage(chatId, messageId);
}
