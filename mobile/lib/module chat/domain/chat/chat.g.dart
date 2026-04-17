// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Chat _$ChatFromJson(Map<String, dynamic> json) => _Chat(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: (json['unreadCount'] as num).toInt(),
      lastOnlineTime: DateTime.parse(json['lastOnlineTime'] as String),
      lastMessageNumber: (json['lastMessageNumber'] as num).toInt(),
    );

Map<String, dynamic> _$ChatToJson(_Chat instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'username': instance.username,
      'avatar': instance.avatar,
      'lastMessage': instance.lastMessage,
      'lastMessageTime': instance.lastMessageTime.toIso8601String(),
      'unreadCount': instance.unreadCount,
      'lastOnlineTime': instance.lastOnlineTime.toIso8601String(),
      'lastMessageNumber': instance.lastMessageNumber,
    };
