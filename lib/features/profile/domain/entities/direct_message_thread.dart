class DirectMessageThread {
  const DirectMessageThread({
    required this.id,
    required this.participant,
    required this.preview,
    required this.lastActivity,
    required this.unreadCount,
    required this.isMuted,
    required this.isBlocked,
    required this.lastLocation,
  });

  final String id;
  final String participant;
  final String preview;
  final DateTime lastActivity;
  final int unreadCount;
  final bool isMuted;
  final bool isBlocked;
  final String lastLocation;

  DirectMessageThread copyWith({bool? isMuted, bool? isBlocked}) {
    return DirectMessageThread(
      id: id,
      participant: participant,
      preview: preview,
      lastActivity: lastActivity,
      unreadCount: unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isBlocked: isBlocked ?? this.isBlocked,
      lastLocation: lastLocation,
    );
  }
}
