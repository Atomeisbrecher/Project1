// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Message {
  String get id;
  @JsonKey(name: 'chat_id', fromJson: _forceString)
  String get chatId;
  @JsonKey(name: 'sender_id', fromJson: _forceString)
  String get senderId;
  String get text;
  DateTime get timestamp;
  @JsonKey(name: 'status')
  MessageStatus get status;
  @JsonKey(name: 'message_number', fromJson: _forceInt)
  int get messageNumber;
  @JsonKey(name: 'reply_to_message_id', fromJson: _forceStringNullable)
  String? get replyToMessageId;
  @JsonKey(name: 'edited_at', fromJson: _forceStringNullable)
  String? get editedAt;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MessageCopyWith<Message> get copyWith =>
      _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Message &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.messageNumber, messageNumber) ||
                other.messageNumber == messageNumber) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, chatId, senderId, text,
      timestamp, status, messageNumber, replyToMessageId, editedAt);

  @override
  String toString() {
    return 'Message(id: $id, chatId: $chatId, senderId: $senderId, text: $text, timestamp: $timestamp, status: $status, messageNumber: $messageNumber, replyToMessageId: $replyToMessageId, editedAt: $editedAt)';
  }
}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) =
      _$MessageCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'chat_id', fromJson: _forceString) String chatId,
      @JsonKey(name: 'sender_id', fromJson: _forceString) String senderId,
      String text,
      DateTime timestamp,
      @JsonKey(name: 'status') MessageStatus status,
      @JsonKey(name: 'message_number', fromJson: _forceInt) int messageNumber,
      @JsonKey(name: 'reply_to_message_id', fromJson: _forceStringNullable)
      String? replyToMessageId,
      @JsonKey(name: 'edited_at', fromJson: _forceStringNullable)
      String? editedAt});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res> implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? senderId = null,
    Object? text = null,
    Object? timestamp = null,
    Object? status = null,
    Object? messageNumber = null,
    Object? replyToMessageId = freezed,
    Object? editedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chatId: null == chatId
          ? _self.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _self.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatus,
      messageNumber: null == messageNumber
          ? _self.messageNumber
          : messageNumber // ignore: cast_nullable_to_non_nullable
              as int,
      replyToMessageId: freezed == replyToMessageId
          ? _self.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      editedAt: freezed == editedAt
          ? _self.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
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
    TResult Function(_Message value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Message() when $default != null:
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
    TResult Function(_Message value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Message():
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
    TResult? Function(_Message value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Message() when $default != null:
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
            @JsonKey(name: 'chat_id', fromJson: _forceString) String chatId,
            @JsonKey(name: 'sender_id', fromJson: _forceString) String senderId,
            String text,
            DateTime timestamp,
            @JsonKey(name: 'status') MessageStatus status,
            @JsonKey(name: 'message_number', fromJson: _forceInt)
            int messageNumber,
            @JsonKey(
                name: 'reply_to_message_id', fromJson: _forceStringNullable)
            String? replyToMessageId,
            @JsonKey(name: 'edited_at', fromJson: _forceStringNullable)
            String? editedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Message() when $default != null:
        return $default(
            _that.id,
            _that.chatId,
            _that.senderId,
            _that.text,
            _that.timestamp,
            _that.status,
            _that.messageNumber,
            _that.replyToMessageId,
            _that.editedAt);
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
            @JsonKey(name: 'chat_id', fromJson: _forceString) String chatId,
            @JsonKey(name: 'sender_id', fromJson: _forceString) String senderId,
            String text,
            DateTime timestamp,
            @JsonKey(name: 'status') MessageStatus status,
            @JsonKey(name: 'message_number', fromJson: _forceInt)
            int messageNumber,
            @JsonKey(
                name: 'reply_to_message_id', fromJson: _forceStringNullable)
            String? replyToMessageId,
            @JsonKey(name: 'edited_at', fromJson: _forceStringNullable)
            String? editedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Message():
        return $default(
            _that.id,
            _that.chatId,
            _that.senderId,
            _that.text,
            _that.timestamp,
            _that.status,
            _that.messageNumber,
            _that.replyToMessageId,
            _that.editedAt);
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
            @JsonKey(name: 'chat_id', fromJson: _forceString) String chatId,
            @JsonKey(name: 'sender_id', fromJson: _forceString) String senderId,
            String text,
            DateTime timestamp,
            @JsonKey(name: 'status') MessageStatus status,
            @JsonKey(name: 'message_number', fromJson: _forceInt)
            int messageNumber,
            @JsonKey(
                name: 'reply_to_message_id', fromJson: _forceStringNullable)
            String? replyToMessageId,
            @JsonKey(name: 'edited_at', fromJson: _forceStringNullable)
            String? editedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Message() when $default != null:
        return $default(
            _that.id,
            _that.chatId,
            _that.senderId,
            _that.text,
            _that.timestamp,
            _that.status,
            _that.messageNumber,
            _that.replyToMessageId,
            _that.editedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Message implements Message {
  const _Message(
      {required this.id,
      @JsonKey(name: 'chat_id', fromJson: _forceString) required this.chatId,
      @JsonKey(name: 'sender_id', fromJson: _forceString)
      required this.senderId,
      required this.text,
      required this.timestamp,
      @JsonKey(name: 'status') required this.status,
      @JsonKey(name: 'message_number', fromJson: _forceInt)
      required this.messageNumber,
      @JsonKey(name: 'reply_to_message_id', fromJson: _forceStringNullable)
      this.replyToMessageId,
      @JsonKey(name: 'edited_at', fromJson: _forceStringNullable)
      this.editedAt});
  factory _Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'chat_id', fromJson: _forceString)
  final String chatId;
  @override
  @JsonKey(name: 'sender_id', fromJson: _forceString)
  final String senderId;
  @override
  final String text;
  @override
  final DateTime timestamp;
  @override
  @JsonKey(name: 'status')
  final MessageStatus status;
  @override
  @JsonKey(name: 'message_number', fromJson: _forceInt)
  final int messageNumber;
  @override
  @JsonKey(name: 'reply_to_message_id', fromJson: _forceStringNullable)
  final String? replyToMessageId;
  @override
  @JsonKey(name: 'edited_at', fromJson: _forceStringNullable)
  final String? editedAt;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MessageCopyWith<_Message> get copyWith =>
      __$MessageCopyWithImpl<_Message>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MessageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Message &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.messageNumber, messageNumber) ||
                other.messageNumber == messageNumber) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, chatId, senderId, text,
      timestamp, status, messageNumber, replyToMessageId, editedAt);

  @override
  String toString() {
    return 'Message(id: $id, chatId: $chatId, senderId: $senderId, text: $text, timestamp: $timestamp, status: $status, messageNumber: $messageNumber, replyToMessageId: $replyToMessageId, editedAt: $editedAt)';
  }
}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) =
      __$MessageCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'chat_id', fromJson: _forceString) String chatId,
      @JsonKey(name: 'sender_id', fromJson: _forceString) String senderId,
      String text,
      DateTime timestamp,
      @JsonKey(name: 'status') MessageStatus status,
      @JsonKey(name: 'message_number', fromJson: _forceInt) int messageNumber,
      @JsonKey(name: 'reply_to_message_id', fromJson: _forceStringNullable)
      String? replyToMessageId,
      @JsonKey(name: 'edited_at', fromJson: _forceStringNullable)
      String? editedAt});
}

/// @nodoc
class __$MessageCopyWithImpl<$Res> implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? senderId = null,
    Object? text = null,
    Object? timestamp = null,
    Object? status = null,
    Object? messageNumber = null,
    Object? replyToMessageId = freezed,
    Object? editedAt = freezed,
  }) {
    return _then(_Message(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chatId: null == chatId
          ? _self.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _self.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatus,
      messageNumber: null == messageNumber
          ? _self.messageNumber
          : messageNumber // ignore: cast_nullable_to_non_nullable
              as int,
      replyToMessageId: freezed == replyToMessageId
          ? _self.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      editedAt: freezed == editedAt
          ? _self.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
