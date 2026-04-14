class CommunityUserSummary {
  const CommunityUserSummary({
    required this.username,
    required this.bigAirScore,
    required this.activityScore,
    required this.highestJumpMeters,
    required this.mainSpot,
    required this.avatarColorValue,
    this.displayName,
    this.handle,
    this.avatarPath,
    this.bannerPath,
  });

  final String username;
  final int bigAirScore;
  final int activityScore;
  final double highestJumpMeters;
  final String mainSpot;
  final int avatarColorValue;
  final String? displayName;
  final String? handle;
  final String? avatarPath;
  final String? bannerPath;
}
