class ProfileKpiSnapshot {
  const ProfileKpiSnapshot({
    required this.totalSessions,
    required this.totalSessionsLabel,
    required this.waterHoursLabel,
    required this.totalJumpsLabel,
    required this.highestJumpLabel,
    required this.maxHangtimeLabel,
    required this.maxAccelerationLabel,
    required this.maxRotationLabel,
    required this.maxSpeedLabel,
    required this.avgSpeedLabel,
    required this.avgSpeedP95Label,
    required this.totalPlaningDistanceLabel,
    required this.avgPlaningDistanceLabel,
    required this.avgTakeoffSpeedLabel,
    required this.avgLandingSpeedLabel,
    required this.avgCleanLandingRateLabel,
    required this.avgJumpHeightLabel,
    required this.avgHangtimeLabel,
    required this.avgJumpHeightConsistencyLabel,
    required this.avgSpeedVariabilityLabel,
    required this.avgDirectionalStabilityLabel,
    required this.avgJibeQualityLabel,
    required this.avgTransitionSpeedLossLabel,
    required this.avgPlaningRecoveryLabel,
    required this.totalTransitionsLabel,
    required this.avgTransitionsPerHourLabel,
    required this.avgTackEfficiencyLabel,
    required this.avgSweetspotLabel,
    required this.avgImpactScoreLabel,
    required this.maxBigAirScoreLabel,
    required this.avgBigAirScoreLabel,
    required this.maxFreerideScoreLabel,
    required this.avgFreerideScoreLabel,
    required this.avgSafetyScoreLabel,
    required this.maxSessionScoreLabel,
    required this.totalAreaCoverageLabel,
    required this.avgNetDriftLabel,
    required this.maxDistanceCoastLabel,
    required this.totalRiskZoneTimeLabel,
    required this.avgGpsQualityLabel,
    required this.totalOverpowerEventsLabel,
    required this.avgFallsPerHourLabel,
    required this.avgLostSamplesLabel,
    required this.avgSessionHoursLabel,
    required this.avgJumpsPerSessionLabel,
    required this.activeDays,
    required this.activeDaysLabel,
    required this.sessionsThisMonth,
    required this.sessionsThisMonthLabel,
    required this.last30DaysSessionsLabel,
    required this.previous30DaysSessionsLabel,
    required this.daysSinceLatestRecordLabel,
    required this.sessionsWithJumpsPercentLabel,
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
    required this.userRoleLabel,
    required this.baseSpotLabel,
    required this.mostUsedSpotLabel,
    required this.bestMonthLabel,
    required this.latestRecordLabel,
    required this.highestJumpTrendLabel,
    required this.hangtimeTrendLabel,
  });

  final int totalSessions;
  final String totalSessionsLabel;
  final String waterHoursLabel;
  final String totalJumpsLabel;
  final String highestJumpLabel;
  final String maxHangtimeLabel;
  final String maxAccelerationLabel;
  final String maxRotationLabel;
  final String maxSpeedLabel;
  final String avgSpeedLabel;
  final String avgSpeedP95Label;
  final String totalPlaningDistanceLabel;
  final String avgPlaningDistanceLabel;
  final String avgTakeoffSpeedLabel;
  final String avgLandingSpeedLabel;
  final String avgCleanLandingRateLabel;
  final String avgJumpHeightLabel;
  final String avgHangtimeLabel;
  final String avgJumpHeightConsistencyLabel;
  final String avgSpeedVariabilityLabel;
  final String avgDirectionalStabilityLabel;
  final String avgJibeQualityLabel;
  final String avgTransitionSpeedLossLabel;
  final String avgPlaningRecoveryLabel;
  final String totalTransitionsLabel;
  final String avgTransitionsPerHourLabel;
  final String avgTackEfficiencyLabel;
  final String avgSweetspotLabel;
  final String avgImpactScoreLabel;
  final String maxBigAirScoreLabel;
  final String avgBigAirScoreLabel;
  final String maxFreerideScoreLabel;
  final String avgFreerideScoreLabel;
  final String avgSafetyScoreLabel;
  final String maxSessionScoreLabel;
  final String totalAreaCoverageLabel;
  final String avgNetDriftLabel;
  final String maxDistanceCoastLabel;
  final String totalRiskZoneTimeLabel;
  final String avgGpsQualityLabel;
  final String totalOverpowerEventsLabel;
  final String avgFallsPerHourLabel;
  final String avgLostSamplesLabel;
  final String avgSessionHoursLabel;
  final String avgJumpsPerSessionLabel;
  final int activeDays;
  final String activeDaysLabel;
  final int sessionsThisMonth;
  final String sessionsThisMonthLabel;
  final String last30DaysSessionsLabel;
  final String previous30DaysSessionsLabel;
  final String daysSinceLatestRecordLabel;
  final String sessionsWithJumpsPercentLabel;
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
  final String userRoleLabel;
  final String baseSpotLabel;
  final String mostUsedSpotLabel;
  final String bestMonthLabel;
  final String latestRecordLabel;
  final String highestJumpTrendLabel;
  final String hangtimeTrendLabel;

  bool get hasSessionActivity => totalSessions > 0;
  bool get hasActiveDays => activeDays > 0;
  bool get hasSessionsThisMonth => sessionsThisMonth > 0;
  bool get hasBestMonth => bestMonthLabel != '--';
  bool get hasMostUsedSpot => mostUsedSpotLabel != '--';
  bool get hasLatestRecord => latestRecordLabel != '--';
  bool get hasSharedSessions => sharedSessionsCountLabel != '--';
  bool get hasCommentsReceived => commentsReceivedLabel != '--';
  bool get hasLikesReceived => likesReceivedLabel != '--';
  bool get hasFollowersFollowingRatio => followersFollowingRatioLabel != '--';
  bool get hasCommentsPerSharedSession => commentsPerSharedSessionLabel != '--';
  bool get hasLikesPerSharedSession => likesPerSharedSessionLabel != '--';
  bool get hasMostCommentedSession => mostCommentedSessionLabel != '--';
  bool get hasMostLikedSession => mostLikedSessionLabel != '--';
  bool get hasEngagementRate => engagementRateLabel != '--';
  bool get hasSharedSessionsLast30Days => sharedSessionsLast30DaysLabel != '--';
  bool get hasCommentsReceivedLast30Days =>
      commentsReceivedLast30DaysLabel != '--';
  bool get hasAvgSpeed => avgSpeedLabel != '--';
  bool get hasAvgSpeedP95 => avgSpeedP95Label != '--';
  bool get hasTotalPlaningDistance => totalPlaningDistanceLabel != '0.0 km';
  bool get hasAvgPlaningDistance => avgPlaningDistanceLabel != '0.0 km';
  bool get hasAvgTakeoffSpeed => avgTakeoffSpeedLabel != '--';
  bool get hasAvgLandingSpeed => avgLandingSpeedLabel != '--';
  bool get hasAvgCleanLandingRate => avgCleanLandingRateLabel != '--';
  bool get hasTransitions => totalTransitionsLabel != '0';
  bool get hasAvgTransitionsPerHour => avgTransitionsPerHourLabel != '--';
  bool get hasAvgTackEfficiency => avgTackEfficiencyLabel != '--';
  bool get hasAvgSweetspot => avgSweetspotLabel != '--';
  bool get hasAvgImpactScore => avgImpactScoreLabel != '--';
  bool get hasAvgJumpHeightConsistency => avgJumpHeightConsistencyLabel != '--';
  bool get hasAvgSpeedVariability => avgSpeedVariabilityLabel != '--';
  bool get hasAvgDirectionalStability => avgDirectionalStabilityLabel != '--';
  bool get hasAvgJibeQuality => avgJibeQualityLabel != '--';
  bool get hasAvgTransitionSpeedLoss => avgTransitionSpeedLossLabel != '--';
  bool get hasAvgPlaningRecovery => avgPlaningRecoveryLabel != '--';
  bool get hasMaxBigAirScore => maxBigAirScoreLabel != '--';
  bool get hasAvgBigAirScore => avgBigAirScoreLabel != '--';
  bool get hasMaxFreerideScore => maxFreerideScoreLabel != '--';
  bool get hasAvgFreerideScore => avgFreerideScoreLabel != '--';
  bool get hasAvgSafetyScore => avgSafetyScoreLabel != '--';
  bool get hasMaxAcceleration => maxAccelerationLabel != '--';
  bool get hasMaxRotation => maxRotationLabel != '--';
  bool get hasTotalAreaCoverage => totalAreaCoverageLabel != '0.0 km2';
  bool get hasAvgNetDrift => avgNetDriftLabel != '--';
  bool get hasMaxDistanceCoast => maxDistanceCoastLabel != '--';
  bool get hasRiskZoneTime => totalRiskZoneTimeLabel != '0 min';
  bool get hasAvgGpsQuality => avgGpsQualityLabel != '--';
  bool get hasOverpowerEvents => totalOverpowerEventsLabel != '0';
  bool get hasAvgFallsPerHour => avgFallsPerHourLabel != '--';
  bool get hasAvgLostSamples => avgLostSamplesLabel != '--';
  bool get hasMaxSessionScore => maxSessionScoreLabel != '--';
  bool get hasAvgJumpHeight => avgJumpHeightLabel != '--';
  bool get hasAvgHangtime => avgHangtimeLabel != '--';
  bool get hasHighestJumpTrend => highestJumpTrendLabel != '--';
  bool get hasHangtimeTrend => hangtimeTrendLabel != '--';
}
