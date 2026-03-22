class SessionComment {
  const SessionComment({
    required this.id,
    required this.sessionId,
    required this.authorUsername,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String authorUsername;
  final String text;
  final DateTime createdAt;
}
