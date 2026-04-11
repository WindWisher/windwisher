class ProfileCommunityStatsSnapshot {
  const ProfileCommunityStatsSnapshot({
    required this.followersLabel,
    required this.followingLabel,
    required this.rankingLabel,
    required this.sharedSessionsCountLabel,
    required this.commentsReceivedLabel,
    required this.likesReceivedLabel,
    required this.followersFollowingRatioLabel,
    required this.commentsPerSharedSessionLabel,
    required this.likesPerSharedSessionLabel,
    required this.mostCommentedSessionLabel,
    required this.mostLikedSessionLabel,
    required this.engagementRateLabel,
    required this.sharedSessionsLast30DaysLabel,
    required this.commentsReceivedLast30DaysLabel,
    required this.hasSharedSessions,
    required this.hasCommentsReceived,
    required this.hasLikesReceived,
    required this.hasFollowersFollowingRatio,
    required this.hasCommentsPerSharedSession,
    required this.hasLikesPerSharedSession,
    required this.hasMostCommentedSession,
    required this.hasMostLikedSession,
    required this.hasEngagementRate,
    required this.hasSharedSessionsLast30Days,
    required this.hasCommentsReceivedLast30Days,
  });

  final String followersLabel;
  final String followingLabel;
  final String rankingLabel;
  final String sharedSessionsCountLabel;
  final String commentsReceivedLabel;
  final String likesReceivedLabel;
  final String followersFollowingRatioLabel;
  final String commentsPerSharedSessionLabel;
  final String likesPerSharedSessionLabel;
  final String mostCommentedSessionLabel;
  final String mostLikedSessionLabel;
  final String engagementRateLabel;
  final String sharedSessionsLast30DaysLabel;
  final String commentsReceivedLast30DaysLabel;
  final bool hasSharedSessions;
  final bool hasCommentsReceived;
  final bool hasLikesReceived;
  final bool hasFollowersFollowingRatio;
  final bool hasCommentsPerSharedSession;
  final bool hasLikesPerSharedSession;
  final bool hasMostCommentedSession;
  final bool hasMostLikedSession;
  final bool hasEngagementRate;
  final bool hasSharedSessionsLast30Days;
  final bool hasCommentsReceivedLast30Days;

  static const empty = ProfileCommunityStatsSnapshot(
    followersLabel: '--',
    followingLabel: '--',
    rankingLabel: '--',
    sharedSessionsCountLabel: '--',
    commentsReceivedLabel: '--',
    likesReceivedLabel: '--',
    followersFollowingRatioLabel: '--',
    commentsPerSharedSessionLabel: '--',
    likesPerSharedSessionLabel: '--',
    mostCommentedSessionLabel: '--',
    mostLikedSessionLabel: '--',
    engagementRateLabel: '--',
    sharedSessionsLast30DaysLabel: '--',
    commentsReceivedLast30DaysLabel: '--',
    hasSharedSessions: false,
    hasCommentsReceived: false,
    hasLikesReceived: false,
    hasFollowersFollowingRatio: false,
    hasCommentsPerSharedSession: false,
    hasLikesPerSharedSession: false,
    hasMostCommentedSession: false,
    hasMostLikedSession: false,
    hasEngagementRate: false,
    hasSharedSessionsLast30Days: false,
    hasCommentsReceivedLast30Days: false,
  );
}
