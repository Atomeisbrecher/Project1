import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageStatus { sending, sent, delivered, read, failed }

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String chatId,
    required String senderId,
    required String text,
    required DateTime timestamp,
    required MessageStatus status,
    required int messageNumber,
    String? replyToMessageId,
    String? editedAt,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) => _$MessageFromJson(json);
}
