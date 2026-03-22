class SessionLikeState {
  const SessionLikeState({
    required this.sessionId,
    required this.likesCount,
    required this.isLikedByUser,
  });

  final String sessionId;
  final int likesCount;
  final bool isLikedByUser;
}
