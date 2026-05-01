import 'package:shop/module_chat/domain/message/message.dart';
import 'package:shop/module_chat/data/repository/message_repo/message_repository.dart';
import 'package:shop/utils/result.dart';

class MessageRepositoryDev extends MessageRepository {

  @override
  Future<void> cacheMessage(String chatId, Message message) async {
    throw UnimplementedError();
  }

  Future<List<Message>> getCachedMessages(String chatId) {
    throw UnimplementedError();
  }

  int? getLastMessageNumber(String chatId) {
    throw UnimplementedError();
  }

  Future<void> saveLastMessageNumber(String chatId, int messageNumber) {
    throw UnimplementedError();
  }

  Future<void> clearCache(String chatId) {
    throw UnimplementedError();
  }

  @override
  Stream<Message> get messagesStream => throw UnimplementedError();

  @override
  Future<Result<List<Message>>> getMessages(String chatId, {int offset = 0, int limit = 50}) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Message>>> syncMessages(String chatId, {required int fromMessageNumber}) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Message>> sendMessage(String chatId, String text, {String? replyToMessageId}) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Message>> editMessage(String chatId, String messageId, String newText) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteMessage(String chatId, String messageId) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Message>> forwardMessage(String sourceChatId, String messageId, String targetChatId) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Message>> getMessage(String chatId, String messageId) async {
    throw UnimplementedError();
  }

  @override
  Stream<Message> watchMessages(String chatId) {
    throw UnimplementedError();
  }

  @override
  Stream<Message> watchMessageUpdates(String chatId) {
    throw UnimplementedError();
    }
}
