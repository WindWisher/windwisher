class CommunityUserSummary {
  const CommunityUserSummary({
    required this.username,
    required this.bigAirScore,
    required this.highestJumpMeters,
    required this.mainSpot,
    required this.avatarColorValue,
  });

  final String username;
  final int bigAirScore;
  final double highestJumpMeters;
  final String mainSpot;
  final int avatarColorValue;
}
