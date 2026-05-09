class SpotChatNotificationEvent {
  const SpotChatNotificationEvent({
    required this.spotName,
    required this.spotArea,
    required this.messageId,
  });

  final String spotName;
  final String spotArea;
  final String messageId;
}
