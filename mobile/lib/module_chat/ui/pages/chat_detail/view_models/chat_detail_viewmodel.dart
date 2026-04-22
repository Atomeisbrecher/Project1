import 'package:shop/module_chat/domain/message/message.dart';
import 'package:shop/module_chat/domain/use_cases/get_messages.dart';
import 'package:shop/module_chat/domain/use_cases/send_message.dart';
import 'package:shop/module_chat/domain/use_cases/edit_message.dart';
import 'package:shop/module_chat/domain/use_cases/delete_message.dart';
import 'package:shop/module_chat/domain/use_cases/forward_message.dart';
import 'package:shop/utils/command.dart';
import 'package:shop/utils/result.dart';
import 'package:logging/logging.dart';

class ChatDetailViewModel {
  ChatDetailViewModel({
    required GetMessagesUseCase getMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required EditMessageUseCase editMessageUseCase,
    required DeleteMessageUseCase deleteMessageUseCase,
    required ForwardMessageUseCase forwardMessageUseCase,
  })  : _getMessagesUseCase = getMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _editMessageUseCase = editMessageUseCase,
        _deleteMessageUseCase = deleteMessageUseCase,
        _forwardMessageUseCase = forwardMessageUseCase {
    loadMessages = Command1<List<Message>, String>(_loadMessages);
    sendMessage = Command2<Message, String, String>(_sendMessage);
    editMessage = Command3<Message, String, String, String>(_editMessage);
    deleteMessage = Command2<void, String, String>(_deleteMessage);
    forwardMessage =
        Command3<Message, String, String, String>(_forwardMessage);
  }

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

    if (result is Error) {
      _log.severe('Failed to load messages for chat: $chatId');
    }

    return result;
  }

  Future<Result<Message>> _sendMessage(String chatId, String text) async {
    final result = await _sendMessageUseCase(chatId, text);

    if (result is Error) {
      _log.severe('Failed to send message');
    }

    return result;
  }

  Future<Result<Message>> _editMessage(
      String chatId, String messageId, String newText) async {
    final result0 = await _editMessageUseCase(chatId, messageId, newText);

    if (result0 is Error) {
      _log.severe('Failed to edit message');
    }

    return result0;
  }

  Future<Result<void>> _deleteMessage(
      String chatId, String messageId) async {
    final result = await _deleteMessageUseCase(chatId, messageId);

    if (result is Error) {
      _log.severe('Failed to delete message');
    }

    return result;
  }

  Future<Result<Message>> _forwardMessage(
      String sourceChatId, String messageId, String targetChatId) async {
    final result = await _forwardMessageUseCase(
        sourceChatId, messageId, targetChatId);

    if (result is Error) {
      _log.severe('Failed to forward message');
    }

    return result;
  }
}
