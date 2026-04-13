class DirectMessageNotificationEvent {
  const DirectMessageNotificationEvent({
    required this.threadId,
    required this.messageId,
  });

  final String threadId;
  final String messageId;
}
