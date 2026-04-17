import 'package:shop/module%20chat/domain/message/message.dart';
import 'package:shop/module%20chat/domain/message/message_repository.dart';
import 'package:shop/utils/result.dart';

class EditMessageUseCase {
  EditMessageUseCase({required MessageRepository messageRepository})
      : _messageRepository = messageRepository;

  final MessageRepository _messageRepository;

  Future<Result<Message>> call(
          String chatId, String messageId, String newText) =>
      _messageRepository.editMessage(chatId, messageId, newText);
}
