import 'package:flutter/material.dart';
import 'package:shop/module_chat/data/repository/message_repo/message_repository.dart';
import 'package:shop/module_chat/domain/message/message.dart';
import 'package:shop/module_chat/domain/use_cases/get_messages.dart';
import 'package:shop/module_chat/domain/use_cases/send_message.dart';
import 'package:shop/module_chat/domain/use_cases/edit_message.dart';
import 'package:shop/module_chat/domain/use_cases/delete_message.dart';
import 'package:shop/module_chat/domain/use_cases/forward_message.dart';
import 'package:shop/utils/command.dart';
import 'package:shop/utils/result.dart';
import 'package:logging/logging.dart';

class ChatDetailViewModel extends ChangeNotifier {
  ChatDetailViewModel({
    required GetMessagesUseCase getMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required EditMessageUseCase editMessageUseCase,
    required DeleteMessageUseCase deleteMessageUseCase,
    required ForwardMessageUseCase forwardMessageUseCase,
    required MessageRepository messageRepository,
    required this.chatId,
  })  : _getMessagesUseCase = getMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _editMessageUseCase = editMessageUseCase,
        _deleteMessageUseCase = deleteMessageUseCase,
        _forwardMessageUseCase = forwardMessageUseCase,
        _messageRepository = messageRepository {
          loadMessages = Command1<List<Message>, String>(_loadMessages);
          sendMessage = Command2<Message, String, String>(_sendMessage);
          editMessage = Command3<Message, String, String, String>(_editMessage);
          deleteMessage = Command2<void, String, String>(_deleteMessage);
          forwardMessage = Command3<Message, String, String, String>(_forwardMessage);
  }

  final String chatId;
  final MessageRepository _messageRepository;
  List<Message> _messages = []; // UI state для сообщений в чате, результат выгрузки репозитория и пагинации оттуда же
  List<Message> get messages => _messages;

  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final EditMessageUseCase _editMessageUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final ForwardMessageUseCase _forwardMessageUseCase;
  final _log = Logger('ChatDetailViewModel');

  late Command1<List<Message>, String> loadMessages;
  late Command2<Message, String, String> sendMessage;
  late Command3<Message, String, String, String> editMessage;
  late Command2<void, String, String> deleteMessage;
  late Command3<Message, String, String, String> forwardMessage;

  Future<Result<List<Message>>> _loadMessages(String chatId) async {
    final result = await _getMessagesUseCase(chatId);

    switch (result) {
      case Ok<List<Message>>():
        _messages = result.value;
        break;
      case Error<List<Message>>():
        _log.severe('Failed to load messages for chat: $chatId');
        return Result.ok([]); // TODO: Handle error state properly in UI
    }
    _subscribeToMessages();
    notifyListeners();
    return result;
  }

  Future<Result<Message>> _sendMessage(String chatId, String text) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final tempMessage = Message(
      chatId: chatId,
      text: text,
      id: tempId,
      senderId: 'current_user_id',
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      messageNumber: 0,
    );

    messages.insert(0, tempMessage);
    notifyListeners();

    final result = await _sendMessageUseCase(chatId, text);

    final index = messages.indexWhere((msg) => msg.id == tempId);
    if (index == -1) return result;

    switch (result) {
        case Ok<Message>():
          _log.info('Message sent successfully: ${result.value.id}');
          messages[index] = result.value.copyWith(status: MessageStatus.sent);
          
        case Error<Message>():
          _log.severe('Failed to send message: ${result.error}');
          messages[index] = messages[index].copyWith(status: MessageStatus.failed);
      }
    notifyListeners();
    return result;
  }

  Future<Result<Message>> _editMessage(String chatId, String messageId, String newText) async {
    final result = await _editMessageUseCase(chatId, messageId, newText);

    if (result is Error) _log.severe('Failed to edit message');

    return result;
  }

  Future<Result<void>> _deleteMessage(String chatId, String messageId) async {
    final result = await _deleteMessageUseCase(chatId, messageId);

    if (result is Error) _log.severe('Failed to delete message');

    return result;
  }

  Future<Result<Message>> _forwardMessage(String sourceChatId, String messageId, String targetChatId) async {
    final result = await _forwardMessageUseCase(
        sourceChatId, messageId, targetChatId);

    if (result is Error) _log.severe('Failed to forward message');

    return result;
  }

  void _subscribeToMessages() {
    _messageRepository.messagesStream.listen((newMessage) {
      print(newMessage);
      if (newMessage.chatId != chatId) return;
      _messageRepository.cacheMessage(chatId, newMessage);
      _messages.insert(0, newMessage);
      notifyListeners();
  });
}
}
