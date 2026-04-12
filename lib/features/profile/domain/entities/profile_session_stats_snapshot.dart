class ProfileSessionStatsSnapshot {
  const ProfileSessionStatsSnapshot({
    required this.totalSessions,
    required this.totalWaterHours,
    required this.totalJumps,
    required this.activeDays,
    required this.sessionsWithJumps,
    required this.highestJumpMeters,
    required this.maxHangtimeSeconds,
    required this.maxAccelerationG,
    required this.maxRotationDegPerSec,
    required this.maxSpeedKnots,
    required this.avgSpeedKnots,
    required this.avgSpeedP95Knots,
    required this.totalPlaningDistanceKm,
    required this.avgPlaningDistanceKm,
    required this.avgTakeoffSpeedKnots,
    required this.avgLandingSpeedKnots,
    required this.avgCleanLandingRate,
    required this.avgJumpHeightMeters,
    required this.avgHangtimeSeconds,
    required this.avgJumpHeightConsistencyPercent,
    required this.avgSpeedVariabilityKnots,
    required this.avgDirectionalStabilityPercent,
    required this.avgJibeQualityPercent,
    required this.avgTransitionSpeedLossKnots,
    required this.avgPlaningRecoverySeconds,
    required this.totalTransitions,
    required this.avgTransitionsPerHour,
    required this.avgTackEfficiencyPercent,
    required this.avgSweetspotPercent,
    required this.avgImpactScore,
    required this.maxBigAirScore,
    required this.avgBigAirScore,
    required this.maxFreerideScore,
    required this.avgFreerideScore,
    required this.avgSafetyScore,
    required this.maxSessionScore,
    required this.totalAreaCoverageKm2,
    required this.avgNetDriftKm,
    required this.maxDistanceCoastKm,
    required this.totalRiskZoneHours,
    required this.avgGpsAccuracyMeters,
    required this.totalOverpowerEvents,
    required this.avgFallsPerHour,
    required this.avgLostSamplesPercent,
    required this.avgSessionHours,
    required this.avgJumpsPerSession,
    required this.sessionsThisMonth,
    required this.last30DaysSessions,
    required this.previous30DaysSessions,
    required this.daysSinceLatestRecord,
    required this.mostUsedSpot,
    required this.bestMonthLabel,
    required this.latestRecordLabel,
    required this.highestJumpTrendLabel,
    required this.hangtimeTrendLabel,
  });

  final int totalSessions;
  final double totalWaterHours;
  final int totalJumps;
  final int activeDays;
  final int sessionsWithJumps;
  final double? highestJumpMeters;
  final double? maxHangtimeSeconds;
  final double? maxAccelerationG;
  final double? maxRotationDegPerSec;
  final double? maxSpeedKnots;
  final double? avgSpeedKnots;
  final double? avgSpeedP95Knots;
  final double totalPlaningDistanceKm;
  final double avgPlaningDistanceKm;
  final double? avgTakeoffSpeedKnots;
  final double? avgLandingSpeedKnots;
  final double? avgCleanLandingRate;
  final double? avgJumpHeightMeters;
  final double? avgHangtimeSeconds;
  final double? avgJumpHeightConsistencyPercent;
  final double? avgSpeedVariabilityKnots;
  final double? avgDirectionalStabilityPercent;
  final double? avgJibeQualityPercent;
  final double? avgTransitionSpeedLossKnots;
  final double? avgPlaningRecoverySeconds;
  final int totalTransitions;
  final double? avgTransitionsPerHour;
  final double? avgTackEfficiencyPercent;
  final double? avgSweetspotPercent;
  final double? avgImpactScore;
  final double? maxBigAirScore;
  final double? avgBigAirScore;
  final double? maxFreerideScore;
  final double? avgFreerideScore;
  final double? avgSafetyScore;
  final double? maxSessionScore;
  final double totalAreaCoverageKm2;
  final double? avgNetDriftKm;
  final double? maxDistanceCoastKm;
  final double totalRiskZoneHours;
  final double? avgGpsAccuracyMeters;
  final int totalOverpowerEvents;
  final double? avgFallsPerHour;
  final double? avgLostSamplesPercent;
  final double avgSessionHours;
  final double avgJumpsPerSession;
  final int sessionsThisMonth;
  final int last30DaysSessions;
  final int previous30DaysSessions;
  final int? daysSinceLatestRecord;
  final String? mostUsedSpot;
  final String? bestMonthLabel;
  final String? latestRecordLabel;
  final String? highestJumpTrendLabel;
  final String? hangtimeTrendLabel;

  static const empty = ProfileSessionStatsSnapshot(
    totalSessions: 0,
    totalWaterHours: 0,
    totalJumps: 0,
    activeDays: 0,
    sessionsWithJumps: 0,
    highestJumpMeters: null,
    maxHangtimeSeconds: null,
    maxAccelerationG: null,
    maxRotationDegPerSec: null,
    maxSpeedKnots: null,
    avgSpeedKnots: null,
    avgSpeedP95Knots: null,
    totalPlaningDistanceKm: 0,
    avgPlaningDistanceKm: 0,
    avgTakeoffSpeedKnots: null,
    avgLandingSpeedKnots: null,
    avgCleanLandingRate: null,
    avgJumpHeightMeters: null,
    avgHangtimeSeconds: null,
    avgJumpHeightConsistencyPercent: null,
    avgSpeedVariabilityKnots: null,
    avgDirectionalStabilityPercent: null,
    avgJibeQualityPercent: null,
    avgTransitionSpeedLossKnots: null,
    avgPlaningRecoverySeconds: null,
    totalTransitions: 0,
    avgTransitionsPerHour: null,
    avgTackEfficiencyPercent: null,
    avgSweetspotPercent: null,
    avgImpactScore: null,
    maxBigAirScore: null,
    avgBigAirScore: null,
    maxFreerideScore: null,
    avgFreerideScore: null,
    avgSafetyScore: null,
    maxSessionScore: null,
    totalAreaCoverageKm2: 0,
    avgNetDriftKm: null,
    maxDistanceCoastKm: null,
    totalRiskZoneHours: 0,
    avgGpsAccuracyMeters: null,
    totalOverpowerEvents: 0,
    avgFallsPerHour: null,
    avgLostSamplesPercent: null,
    avgSessionHours: 0,
    avgJumpsPerSession: 0,
    sessionsThisMonth: 0,
    last30DaysSessions: 0,
    previous30DaysSessions: 0,
    daysSinceLatestRecord: null,
    mostUsedSpot: null,
    bestMonthLabel: null,
    latestRecordLabel: null,
    highestJumpTrendLabel: null,
    hangtimeTrendLabel: null,
  );


  String get totalSessionsLabel => '$totalSessions';

  String get waterHoursLabel {
    final numeric = totalWaterHours;
    return '${numeric.toStringAsFixed(numeric.truncateToDouble() == numeric ? 0 : 1)}h';
  }

  String get totalJumpsLabel => '$totalJumps';

  String get highestJumpLabel => highestJumpMeters == null
      ? '--'
      : '${highestJumpMeters!.toStringAsFixed(1)}m';

  String get maxHangtimeLabel => maxHangtimeSeconds == null
      ? '--'
      : '${maxHangtimeSeconds!.toStringAsFixed(1)}s';

  String get maxAccelerationLabel => maxAccelerationG == null
      ? '--'
      : '${maxAccelerationG!.toStringAsFixed(1)} G';

  String get maxRotationLabel => maxRotationDegPerSec == null
      ? '--'
      : '${maxRotationDegPerSec!.toStringAsFixed(0)} deg/s';

  String get maxSpeedLabel =>
      maxSpeedKnots == null ? '--' : '${maxSpeedKnots!.toStringAsFixed(1)} kt';

  String get avgSpeedLabel =>
      avgSpeedKnots == null ? '--' : '${avgSpeedKnots!.toStringAsFixed(1)} kt';

  String get avgSpeedP95Label => avgSpeedP95Knots == null
      ? '--'
      : '${avgSpeedP95Knots!.toStringAsFixed(1)} kt';

  String get totalPlaningDistanceLabel =>
      '${totalPlaningDistanceKm.toStringAsFixed(1)} km';

  String get avgPlaningDistanceLabel =>
      '${avgPlaningDistanceKm.toStringAsFixed(1)} km';

  String get avgTakeoffSpeedLabel => avgTakeoffSpeedKnots == null
      ? '--'
      : '${avgTakeoffSpeedKnots!.toStringAsFixed(1)} kt';

  String get avgLandingSpeedLabel => avgLandingSpeedKnots == null
      ? '--'
      : '${avgLandingSpeedKnots!.toStringAsFixed(1)} kt';

  String get avgCleanLandingRateLabel => avgCleanLandingRate == null
      ? '--'
      : '${avgCleanLandingRate!.toStringAsFixed(0)}%';

  String get avgJumpHeightLabel => avgJumpHeightMeters == null
      ? '--'
      : '${avgJumpHeightMeters!.toStringAsFixed(1)}m';

  String get avgHangtimeLabel => avgHangtimeSeconds == null
      ? '--'
      : '${avgHangtimeSeconds!.toStringAsFixed(1)}s';

  String get avgJumpHeightConsistencyLabel =>
      avgJumpHeightConsistencyPercent == null
      ? '--'
      : '${avgJumpHeightConsistencyPercent!.toStringAsFixed(0)}%';

  String get avgSpeedVariabilityLabel => avgSpeedVariabilityKnots == null
      ? '--'
      : '${avgSpeedVariabilityKnots!.toStringAsFixed(1)} kt';

  String get avgDirectionalStabilityLabel =>
      avgDirectionalStabilityPercent == null
      ? '--'
      : '${avgDirectionalStabilityPercent!.toStringAsFixed(0)}%';

  String get avgJibeQualityLabel => avgJibeQualityPercent == null
      ? '--'
      : '${avgJibeQualityPercent!.toStringAsFixed(0)}%';

  String get avgTransitionSpeedLossLabel => avgTransitionSpeedLossKnots == null
      ? '--'
      : '${avgTransitionSpeedLossKnots!.toStringAsFixed(1)} kt';

  String get avgPlaningRecoveryLabel => avgPlaningRecoverySeconds == null
      ? '--'
      : '${avgPlaningRecoverySeconds!.toStringAsFixed(1)} s';

  String get totalTransitionsLabel => '$totalTransitions';

  String get avgTransitionsPerHourLabel => avgTransitionsPerHour == null
      ? '--'
      : avgTransitionsPerHour!.toStringAsFixed(1);

  String get avgTackEfficiencyLabel => avgTackEfficiencyPercent == null
      ? '--'
      : '${avgTackEfficiencyPercent!.toStringAsFixed(0)}%';

  String get avgSweetspotLabel => avgSweetspotPercent == null
      ? '--'
      : '${avgSweetspotPercent!.toStringAsFixed(0)}%';

  String get avgImpactScoreLabel =>
      avgImpactScore == null ? '--' : '${avgImpactScore!.toStringAsFixed(1)} G';

  String get maxBigAirScoreLabel => maxBigAirScore == null
      ? '--'
      : '${maxBigAirScore!.toStringAsFixed(0)}/100';

  String get avgBigAirScoreLabel => avgBigAirScore == null
      ? '--'
      : '${avgBigAirScore!.toStringAsFixed(0)}/100';

  String get maxFreerideScoreLabel => maxFreerideScore == null
      ? '--'
      : '${maxFreerideScore!.toStringAsFixed(0)}/100';

  String get avgFreerideScoreLabel => avgFreerideScore == null
      ? '--'
      : '${avgFreerideScore!.toStringAsFixed(0)}/100';

  String get avgSafetyScoreLabel => avgSafetyScore == null
      ? '--'
      : '${avgSafetyScore!.toStringAsFixed(0)}/100';

  String get maxSessionScoreLabel => maxSessionScore == null
      ? '--'
      : '${maxSessionScore!.toStringAsFixed(0)}/100';

  String get totalAreaCoverageLabel =>
      '${totalAreaCoverageKm2.toStringAsFixed(1)} km2';

  String get avgNetDriftLabel =>
      avgNetDriftKm == null ? '--' : '${avgNetDriftKm!.toStringAsFixed(2)} km';

  String get maxDistanceCoastLabel => maxDistanceCoastKm == null
      ? '--'
      : '${maxDistanceCoastKm!.toStringAsFixed(2)} km';

  String get totalRiskZoneTimeLabel {
    final totalMinutes = (totalRiskZoneHours * 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours <= 0) {
      return '$minutes min';
    }
    return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}min';
  }

  String get avgGpsQualityLabel => avgGpsAccuracyMeters == null
      ? '--'
      : '${avgGpsAccuracyMeters!.toStringAsFixed(1)} m';

  String get totalOverpowerEventsLabel => '$totalOverpowerEvents';

  String get avgFallsPerHourLabel =>
      avgFallsPerHour == null ? '--' : avgFallsPerHour!.toStringAsFixed(1);

  String get avgLostSamplesLabel => avgLostSamplesPercent == null
      ? '--'
      : '${avgLostSamplesPercent!.toStringAsFixed(0)}%';

  String get avgSessionHoursLabel => '${avgSessionHours.toStringAsFixed(1)}h';

  String get avgJumpsPerSessionLabel => avgJumpsPerSession.toStringAsFixed(1);

  String get activeDaysLabel => '$activeDays';

  String get sessionsThisMonthLabel => '$sessionsThisMonth';

  String get last30DaysSessionsLabel => '$last30DaysSessions';

  String get previous30DaysSessionsLabel => '$previous30DaysSessions';

  String get daysSinceLatestRecordLabel =>
      daysSinceLatestRecord == null ? '--' : '${daysSinceLatestRecord!} dias';

  String get sessionsWithJumpsPercentLabel {
    if (totalSessions == 0) {
      return '--%';
    }
    final percent = (sessionsWithJumps / totalSessions) * 100;
    return '${percent.toStringAsFixed(0)}%';
  }

}
