import 'package:shop/module%20chat/domain/message/message.dart';
import 'package:shop/module%20chat/domain/message/message_repository.dart';
import 'package:shop/utils/result.dart';

class SendMessageUseCase {
  SendMessageUseCase({required MessageRepository messageRepository})
      : _messageRepository = messageRepository;

  final MessageRepository _messageRepository;

  Future<Result<Message>> call(String chatId, String text,
          {String? replyToMessageId}) =>
      _messageRepository.sendMessage(chatId, text,
          replyToMessageId: replyToMessageId);
}
