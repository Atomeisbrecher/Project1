import 'package:shop/module_chat/domain/message/message.dart';
import 'package:shop/module_chat/data/repository/message_repo/message_repository.dart';
import 'package:shop/utils/result.dart';

class MessageRepositoryDev implements MessageRepository {
  @override
  Future<Result<List<Message>>> getMessages(String chatId, {int offset = 0, int limit = 50}) async {
    return Result.ok([]);
  }

  @override
  Future<Result<List<Message>>> syncMessages(String chatId, {required int fromMessageNumber}) async {
    return Result.ok([]);
  }

  @override
  Future<Result<Message>> sendMessage(String chatId, String text, {String? replyToMessageId}) async {
    return Result.error(Exception('Not implemented in dev mode'));
  }

  @override
  Future<Result<Message>> editMessage(String chatId, String messageId, String newText) async {
    return Result.error(Exception('Not implemented in dev mode'));
  }

  @override
  Future<Result<void>> deleteMessage(String chatId, String messageId) async {
    return Result.error(Exception('Not implemented in dev mode'));
  }

  @override
  Future<Result<Message>> forwardMessage(String sourceChatId, String messageId, String targetChatId) async {
    return Result.error(Exception('Not implemented in dev mode'));
  }

  @override
  Future<Result<Message>> getMessage(String chatId, String messageId) async {
    return Result.error(Exception('Not implemented in dev mode'));
  }

  @override
  Stream<Message> watchMessages(String chatId) {
    return Stream.empty();
  }

  @override
  Stream<Message> watchMessageUpdates(String chatId) {
    return Stream.empty();
    }
}
