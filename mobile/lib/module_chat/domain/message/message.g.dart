// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: $enumDecode(_$MessageStatusEnumMap, json['status']),
      messageNumber: (json['message_number'] as num).toInt(),
      replyToMessageId: json['reply_to_message_id'] as String?,
      editedAt: json['edited_at'] as String?,
    );

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
      'id': instance.id,
      'chat_id': instance.chatId,
      'sender_id': instance.senderId,
      'text': instance.text,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': _$MessageStatusEnumMap[instance.status]!,
      'message_number': instance.messageNumber,
      'reply_to_message_id': instance.replyToMessageId,
      'edited_at': instance.editedAt,
    };

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.read: 'read',
  MessageStatus.failed: 'failed',
};
