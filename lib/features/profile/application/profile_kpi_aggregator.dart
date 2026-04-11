import 'package:windwisher/features/profile/domain/entities/profile_community_stats_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/profile_kpi_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/profile_session_stats_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';

class ProfileKpiAggregator {
  const ProfileKpiAggregator._();

  static ProfileKpiSnapshot build(
    UserProfileData profile,
    ProfileSessionStatsSnapshot stats,
    ProfileCommunityStatsSnapshot community,
  ) {
    return ProfileKpiSnapshot(
      totalSessions: stats.totalSessions,
      totalSessionsLabel: stats.totalSessionsLabel,
      waterHoursLabel: stats.waterHoursLabel,
      totalJumpsLabel: stats.totalJumpsLabel,
      highestJumpLabel: stats.highestJumpLabel,
      maxHangtimeLabel: stats.maxHangtimeLabel,
      maxAccelerationLabel: stats.maxAccelerationLabel,
      maxRotationLabel: stats.maxRotationLabel,
      maxSpeedLabel: stats.maxSpeedLabel,
      avgSpeedLabel: stats.avgSpeedLabel,
      avgSpeedP95Label: stats.avgSpeedP95Label,
      totalPlaningDistanceLabel: stats.totalPlaningDistanceLabel,
      avgPlaningDistanceLabel: stats.avgPlaningDistanceLabel,
      avgTakeoffSpeedLabel: stats.avgTakeoffSpeedLabel,
      avgLandingSpeedLabel: stats.avgLandingSpeedLabel,
      avgCleanLandingRateLabel: stats.avgCleanLandingRateLabel,
      avgJumpHeightLabel: stats.avgJumpHeightLabel,
      avgHangtimeLabel: stats.avgHangtimeLabel,
      avgJumpHeightConsistencyLabel: stats.avgJumpHeightConsistencyLabel,
      avgSpeedVariabilityLabel: stats.avgSpeedVariabilityLabel,
      avgDirectionalStabilityLabel: stats.avgDirectionalStabilityLabel,
      avgJibeQualityLabel: stats.avgJibeQualityLabel,
      avgTransitionSpeedLossLabel: stats.avgTransitionSpeedLossLabel,
      avgPlaningRecoveryLabel: stats.avgPlaningRecoveryLabel,
      totalTransitionsLabel: stats.totalTransitionsLabel,
      avgTransitionsPerHourLabel: stats.avgTransitionsPerHourLabel,
      avgTackEfficiencyLabel: stats.avgTackEfficiencyLabel,
      avgSweetspotLabel: stats.avgSweetspotLabel,
      avgImpactScoreLabel: stats.avgImpactScoreLabel,
      maxBigAirScoreLabel: stats.maxBigAirScoreLabel,
      avgBigAirScoreLabel: stats.avgBigAirScoreLabel,
      maxFreerideScoreLabel: stats.maxFreerideScoreLabel,
      avgFreerideScoreLabel: stats.avgFreerideScoreLabel,
      avgSafetyScoreLabel: stats.avgSafetyScoreLabel,
      maxSessionScoreLabel: stats.maxSessionScoreLabel,
      totalAreaCoverageLabel: stats.totalAreaCoverageLabel,
      avgNetDriftLabel: stats.avgNetDriftLabel,
      maxDistanceCoastLabel: stats.maxDistanceCoastLabel,
      totalRiskZoneTimeLabel: stats.totalRiskZoneTimeLabel,
      avgGpsQualityLabel: stats.avgGpsQualityLabel,
      totalOverpowerEventsLabel: stats.totalOverpowerEventsLabel,
      avgFallsPerHourLabel: stats.avgFallsPerHourLabel,
      avgLostSamplesLabel: stats.avgLostSamplesLabel,
      avgSessionHoursLabel: stats.avgSessionHoursLabel,
      avgJumpsPerSessionLabel: stats.avgJumpsPerSessionLabel,
      activeDays: stats.activeDays,
      activeDaysLabel: stats.activeDaysLabel,
      sessionsThisMonth: stats.sessionsThisMonth,
      sessionsThisMonthLabel: stats.sessionsThisMonthLabel,
      last30DaysSessionsLabel: stats.last30DaysSessionsLabel,
      previous30DaysSessionsLabel: stats.previous30DaysSessionsLabel,
      daysSinceLatestRecordLabel: stats.daysSinceLatestRecordLabel,
      sessionsWithJumpsPercentLabel: stats.sessionsWithJumpsPercentLabel,
      followersLabel: community.followersLabel,
      followingLabel: community.followingLabel,
      rankingLabel: community.rankingLabel,
      sharedSessionsCountLabel: community.sharedSessionsCountLabel,
      commentsReceivedLabel: community.commentsReceivedLabel,
      likesReceivedLabel: community.likesReceivedLabel,
      followersFollowingRatioLabel: community.followersFollowingRatioLabel,
      commentsPerSharedSessionLabel: community.commentsPerSharedSessionLabel,
      likesPerSharedSessionLabel: community.likesPerSharedSessionLabel,
      mostCommentedSessionLabel: community.mostCommentedSessionLabel,
      mostLikedSessionLabel: community.mostLikedSessionLabel,
      engagementRateLabel: community.engagementRateLabel,
      sharedSessionsLast30DaysLabel: community.sharedSessionsLast30DaysLabel,
      commentsReceivedLast30DaysLabel:
          community.commentsReceivedLast30DaysLabel,
      userRoleLabel: _fallback(profile.userRole),
      baseSpotLabel: _fallback(profile.baseSpot),
      bestSpotLabel: _fallback(profile.bestSpot),
      mostUsedSpotLabel: _fallback(stats.mostUsedSpot ?? profile.baseSpot),
      bestMonthLabel: _fallback(stats.bestMonthLabel),
      latestRecordLabel: _fallback(stats.latestRecordLabel),
      highestJumpTrendLabel: _fallback(stats.highestJumpTrendLabel),
      hangtimeTrendLabel: _fallback(stats.hangtimeTrendLabel),
      latestSessionLabel: _fallback(profile.latestSession),
      latestCommentLabel: _fallback(profile.latestComment),
      featuredThreadLabel: _fallback(profile.featuredThread),
    );
  }

  static String _fallback(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return '--';
    }
    return normalized;
  }
}
