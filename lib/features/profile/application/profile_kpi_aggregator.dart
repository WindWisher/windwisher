import 'package:windwisher/core/units/app_units_controller.dart';
import 'package:windwisher/features/profile/domain/entities/profile_community_stats_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/profile_kpi_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/profile_session_stats_snapshot.dart';

class ProfileKpiAggregator {
  const ProfileKpiAggregator._();

  static ProfileKpiSnapshot build(
    ProfileSessionStatsSnapshot stats,
    ProfileCommunityStatsSnapshot community,
  ) {
    final units = AppUnitsController.instance;
    return ProfileKpiSnapshot(
      totalSessions: stats.totalSessions,
      totalSessionsLabel: stats.totalSessionsLabel,
      waterHoursLabel: stats.waterHoursLabel,
      totalJumpsLabel: stats.totalJumpsLabel,
      highestJumpLabel: stats.highestJumpMeters == null
          ? '--'
          : units.formatHeight(stats.highestJumpMeters!),
      maxHangtimeLabel: stats.maxHangtimeLabel,
      maxAccelerationLabel: stats.maxAccelerationLabel,
      maxRotationLabel: stats.maxRotationLabel,
      maxSpeedLabel: stats.maxSpeedKnots == null
          ? '--'
          : units.formatWindSpeed(stats.maxSpeedKnots!),
      avgSpeedLabel: stats.avgSpeedKnots == null
          ? '--'
          : units.formatWindSpeed(stats.avgSpeedKnots!),
      avgSpeedP95Label: stats.avgSpeedP95Knots == null
          ? '--'
          : units.formatWindSpeed(stats.avgSpeedP95Knots!),
      totalPlaningDistanceLabel: units.formatDistance(
        stats.totalPlaningDistanceKm,
      ),
      avgPlaningDistanceLabel: units.formatDistance(stats.avgPlaningDistanceKm),
      avgTakeoffSpeedLabel: stats.avgTakeoffSpeedKnots == null
          ? '--'
          : units.formatWindSpeed(stats.avgTakeoffSpeedKnots!),
      avgLandingSpeedLabel: stats.avgLandingSpeedKnots == null
          ? '--'
          : units.formatWindSpeed(stats.avgLandingSpeedKnots!),
      avgCleanLandingRateLabel: stats.avgCleanLandingRateLabel,
      avgJumpHeightLabel: stats.avgJumpHeightMeters == null
          ? '--'
          : units.formatHeight(stats.avgJumpHeightMeters!),
      avgHangtimeLabel: stats.avgHangtimeLabel,
      avgJumpHeightConsistencyLabel: stats.avgJumpHeightConsistencyLabel,
      avgSpeedVariabilityLabel: stats.avgSpeedVariabilityKnots == null
          ? '--'
          : units.formatWindSpeed(stats.avgSpeedVariabilityKnots!),
      avgDirectionalStabilityLabel: stats.avgDirectionalStabilityLabel,
      avgJibeQualityLabel: stats.avgJibeQualityLabel,
      avgTransitionSpeedLossLabel: stats.avgTransitionSpeedLossKnots == null
          ? '--'
          : units.formatWindSpeed(stats.avgTransitionSpeedLossKnots!),
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
      avgNetDriftLabel: stats.avgNetDriftKm == null
          ? '--'
          : units.formatDistance(stats.avgNetDriftKm!, decimals: 2),
      maxDistanceCoastLabel: stats.maxDistanceCoastKm == null
          ? '--'
          : units.formatDistance(stats.maxDistanceCoastKm!, decimals: 2),
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
      userRoleLabel: '--',
      baseSpotLabel: '--',
      mostUsedSpotLabel: _fallback(stats.mostUsedSpot),
      bestMonthLabel: _fallback(stats.bestMonthLabel),
      latestRecordLabel: _fallback(stats.latestRecordLabel),
      highestJumpTrendLabel: _fallback(stats.highestJumpTrendLabel),
      hangtimeTrendLabel: _fallback(stats.hangtimeTrendLabel),
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
