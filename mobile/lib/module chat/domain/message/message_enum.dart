enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed;

  String get displayName => switch (this) {
    MessageStatus.sending => 'Sending...',
    MessageStatus.sent => 'Sent',
    MessageStatus.delivered => 'Delivered',
    MessageStatus.read => 'Read',
    MessageStatus.failed => 'Failed',
  };

  bool get isStatusIcon => this == MessageStatus.read || 
                            this == MessageStatus.delivered ||
                            this == MessageStatus.sent;
}
