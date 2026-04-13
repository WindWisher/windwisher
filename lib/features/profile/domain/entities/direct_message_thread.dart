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
    this.participantAvatarPath,
  });

  final String id;
  final String participant;
  final String preview;
  final DateTime lastActivity;
  final int unreadCount;
  final bool isMuted;
  final bool isBlocked;
  final String lastLocation;
  final String? participantAvatarPath;

  DirectMessageThread copyWith({
    bool? isMuted,
    bool? isBlocked,
    int? unreadCount,
    String? preview,
    DateTime? lastActivity,
    String? participantAvatarPath,
  }) {
    return DirectMessageThread(
      id: id,
      participant: participant,
      preview: preview ?? this.preview,
      lastActivity: lastActivity ?? this.lastActivity,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isBlocked: isBlocked ?? this.isBlocked,
      lastLocation: lastLocation,
      participantAvatarPath:
          participantAvatarPath ?? this.participantAvatarPath,
    );
  }
}
