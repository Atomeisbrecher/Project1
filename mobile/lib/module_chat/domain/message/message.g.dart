// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
      id: json['id'] as String,
      chatId: _forceString(json['chat_id']),
      senderId: _forceString(json['sender_id']),
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: $enumDecode(_$MessageStatusEnumMap, json['status']),
      messageNumber: _forceInt(json['message_number']),
      replyToMessageId: _forceStringNullable(json['reply_to_message_id']),
      editedAt: _forceStringNullable(json['edited_at']),
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
