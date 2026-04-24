import 'dart:ffi';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
abstract class Chat with _$Chat {
  const factory Chat({
    required String id,
    @Default('3') String userId,
    required String username,
    @Default('') String avatar,
    @Default('Начать чат...') String lastMessage,
    required DateTime lastMessageTime,
    @Default(0) int unreadCount,

    required DateTime lastOnlineTime,
    @Default(0) int lastMessageNumber,
  }) = _Chat;

  factory Chat.fromJson(Map<String, Object?> json) => _$ChatFromJson(json);
}
