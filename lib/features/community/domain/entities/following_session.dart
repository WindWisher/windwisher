class FollowingSession {
  const FollowingSession({
    required this.id,
    required this.username,
    required this.title,
    required this.spot,
    required this.dateLabel,
    required this.endedAt,
    required this.bigAirScore,
    required this.highestJumpMeters,
    required this.distanceKm,
    required this.durationLabel,
    required this.equipmentLabel,
    required this.likesCount,
    required this.hasSessionPhoto,
  });

  final String id;
  final String username;
  final String title;
  final String spot;
  final String dateLabel;
  final DateTime endedAt;
  final int bigAirScore;
  final double highestJumpMeters;
  final double distanceKm;
  final String durationLabel;
  final String equipmentLabel;
  final int likesCount;
  final bool hasSessionPhoto;
}
