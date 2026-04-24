// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Chat {
  String get id;
  String get userId;
  String get username;
  String get avatar;
  String get lastMessage;
  DateTime get lastMessageTime;
  int get unreadCount;
  DateTime get lastOnlineTime;
  int get lastMessageNumber;

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatCopyWith<Chat> get copyWith =>
      _$ChatCopyWithImpl<Chat>(this as Chat, _$identity);

  /// Serializes this Chat to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Chat &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageTime, lastMessageTime) ||
                other.lastMessageTime == lastMessageTime) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.lastOnlineTime, lastOnlineTime) ||
                other.lastOnlineTime == lastOnlineTime) &&
            (identical(other.lastMessageNumber, lastMessageNumber) ||
                other.lastMessageNumber == lastMessageNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      username,
      avatar,
      lastMessage,
      lastMessageTime,
      unreadCount,
      lastOnlineTime,
      lastMessageNumber);

  @override
  String toString() {
    return 'Chat(id: $id, userId: $userId, username: $username, avatar: $avatar, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime, unreadCount: $unreadCount, lastOnlineTime: $lastOnlineTime, lastMessageNumber: $lastMessageNumber)';
  }
}

/// @nodoc
abstract mixin class $ChatCopyWith<$Res> {
  factory $ChatCopyWith(Chat value, $Res Function(Chat) _then) =
      _$ChatCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String username,
      String avatar,
      String lastMessage,
      DateTime lastMessageTime,
      int unreadCount,
      DateTime lastOnlineTime,
      int lastMessageNumber});
}

/// @nodoc
class _$ChatCopyWithImpl<$Res> implements $ChatCopyWith<$Res> {
  _$ChatCopyWithImpl(this._self, this._then);

  final Chat _self;
  final $Res Function(Chat) _then;

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? username = null,
    Object? avatar = null,
    Object? lastMessage = null,
    Object? lastMessageTime = null,
    Object? unreadCount = null,
    Object? lastOnlineTime = null,
    Object? lastMessageNumber = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _self.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessage: null == lastMessage
          ? _self.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessageTime: null == lastMessageTime
          ? _self.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      unreadCount: null == unreadCount
          ? _self.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastOnlineTime: null == lastOnlineTime
          ? _self.lastOnlineTime
          : lastOnlineTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastMessageNumber: null == lastMessageNumber
          ? _self.lastMessageNumber
          : lastMessageNumber // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [Chat].
extension ChatPatterns on Chat {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Chat value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Chat() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Chat value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Chat():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Chat value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Chat() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String userId,
            String username,
            String avatar,
            String lastMessage,
            DateTime lastMessageTime,
            int unreadCount,
            DateTime lastOnlineTime,
            int lastMessageNumber)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Chat() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.username,
            _that.avatar,
            _that.lastMessage,
            _that.lastMessageTime,
            _that.unreadCount,
            _that.lastOnlineTime,
            _that.lastMessageNumber);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String userId,
            String username,
            String avatar,
            String lastMessage,
            DateTime lastMessageTime,
            int unreadCount,
            DateTime lastOnlineTime,
            int lastMessageNumber)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Chat():
        return $default(
            _that.id,
            _that.userId,
            _that.username,
            _that.avatar,
            _that.lastMessage,
            _that.lastMessageTime,
            _that.unreadCount,
            _that.lastOnlineTime,
            _that.lastMessageNumber);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String userId,
            String username,
            String avatar,
            String lastMessage,
            DateTime lastMessageTime,
            int unreadCount,
            DateTime lastOnlineTime,
            int lastMessageNumber)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Chat() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.username,
            _that.avatar,
            _that.lastMessage,
            _that.lastMessageTime,
            _that.unreadCount,
            _that.lastOnlineTime,
            _that.lastMessageNumber);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Chat implements Chat {
  const _Chat(
      {required this.id,
      this.userId = '3',
      required this.username,
      this.avatar = '',
      this.lastMessage = 'Начать чат...',
      required this.lastMessageTime,
      this.unreadCount = 0,
      required this.lastOnlineTime,
      this.lastMessageNumber = 0});
  factory _Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String userId;
  @override
  final String username;
  @override
  @JsonKey()
  final String avatar;
  @override
  @JsonKey()
  final String lastMessage;
  @override
  final DateTime lastMessageTime;
  @override
  @JsonKey()
  final int unreadCount;
  @override
  final DateTime lastOnlineTime;
  @override
  @JsonKey()
  final int lastMessageNumber;

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatCopyWith<_Chat> get copyWith =>
      __$ChatCopyWithImpl<_Chat>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChatToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Chat &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageTime, lastMessageTime) ||
                other.lastMessageTime == lastMessageTime) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.lastOnlineTime, lastOnlineTime) ||
                other.lastOnlineTime == lastOnlineTime) &&
            (identical(other.lastMessageNumber, lastMessageNumber) ||
                other.lastMessageNumber == lastMessageNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      username,
      avatar,
      lastMessage,
      lastMessageTime,
      unreadCount,
      lastOnlineTime,
      lastMessageNumber);

  @override
  String toString() {
    return 'Chat(id: $id, userId: $userId, username: $username, avatar: $avatar, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime, unreadCount: $unreadCount, lastOnlineTime: $lastOnlineTime, lastMessageNumber: $lastMessageNumber)';
  }
}

/// @nodoc
abstract mixin class _$ChatCopyWith<$Res> implements $ChatCopyWith<$Res> {
  factory _$ChatCopyWith(_Chat value, $Res Function(_Chat) _then) =
      __$ChatCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String username,
      String avatar,
      String lastMessage,
      DateTime lastMessageTime,
      int unreadCount,
      DateTime lastOnlineTime,
      int lastMessageNumber});
}

/// @nodoc
class __$ChatCopyWithImpl<$Res> implements _$ChatCopyWith<$Res> {
  __$ChatCopyWithImpl(this._self, this._then);

  final _Chat _self;
  final $Res Function(_Chat) _then;

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? username = null,
    Object? avatar = null,
    Object? lastMessage = null,
    Object? lastMessageTime = null,
    Object? unreadCount = null,
    Object? lastOnlineTime = null,
    Object? lastMessageNumber = null,
  }) {
    return _then(_Chat(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _self.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessage: null == lastMessage
          ? _self.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessageTime: null == lastMessageTime
          ? _self.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      unreadCount: null == unreadCount
          ? _self.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastOnlineTime: null == lastOnlineTime
          ? _self.lastOnlineTime
          : lastOnlineTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastMessageNumber: null == lastMessageNumber
          ? _self.lastMessageNumber
          : lastMessageNumber // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
