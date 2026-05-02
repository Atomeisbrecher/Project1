import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageStatus { sending, sent, delivered, read, failed }

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'chat_id') required String chatId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String text,
    required DateTime timestamp,
    @JsonKey(name: 'status') required MessageStatus status,
    @JsonKey(name: 'message_number') required int messageNumber,
    @JsonKey(name: 'reply_to_message_id') String? replyToMessageId,
    @JsonKey(name: 'edited_at') String? editedAt,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) => _$MessageFromJson(json);
}
