import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageStatus { sending, sent, delivered, read, failed }

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'chat_id', fromJson: _forceString) required String chatId,
    @JsonKey(name: 'sender_id', fromJson: _forceString) required String senderId,
    required String text,
    required DateTime timestamp,
    @JsonKey(name: 'status') required MessageStatus status,
    @JsonKey(name: 'message_number', fromJson: _forceInt) required int messageNumber,
    @JsonKey(name: 'reply_to_message_id', fromJson: _forceStringNullable) String? replyToMessageId,
    @JsonKey(name: 'edited_at', fromJson: _forceStringNullable) String? editedAt,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) => _$MessageFromJson(json);
}

String _forceString(dynamic val) => val.toString();

int _forceInt(dynamic val) {
  if (val is int) return val;
  if (val is String) return int.tryParse(val) ?? 0;
  if (val is double) return val.toInt();
  return 0;
}

String? _forceStringNullable(dynamic val) {
  if (val == null) return null;
  final str = val.toString();
  return str.isEmpty ? null : str;
}