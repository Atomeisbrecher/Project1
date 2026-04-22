import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
abstract class Chat with _$Chat {
  const factory Chat({
    required String id,
    required String userId,
    required String username,
    required String avatar,
    required String lastMessage,
    required DateTime lastMessageTime,
    required int unreadCount,
    required DateTime lastOnlineTime,
    required int lastMessageNumber,
  }) = _Chat;

  factory Chat.fromJson(Map<String, Object?> json) => _$ChatFromJson(json);
}
