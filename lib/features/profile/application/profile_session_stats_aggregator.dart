import 'package:windwisher/features/profile/domain/entities/profile_session_stats_snapshot.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';

class ProfileSessionStatsAggregator {
  const ProfileSessionStatsAggregator._();

  static ProfileSessionStatsSnapshot build(Iterable<RecordedSession> sessions) {
    final items = sessions.toList(growable: false)
      ..sort((a, b) => a.endedAt.compareTo(b.endedAt));
    if (items.isEmpty) {
      return ProfileSessionStatsSnapshot.empty;
    }

    var totalWaterHours = 0.0;
    var totalJumps = 0;
    double? maxAccelerationG;
    double? maxRotationDegPerSec;
    var sessionsWithJumps = 0;
    double? highestJumpMeters;
    double? maxHangtimeSeconds;
    double? maxSpeedKnots;
    final speedP95Values = <double>[];
    var totalPlaningDistanceKm = 0.0;
    var totalAreaCoverageKm2 = 0.0;
    final netDriftValues = <double>[];
    double? maxDistanceCoastKm;
    var totalRiskZoneHours = 0.0;
    final gpsAccuracyValues = <double>[];
    var totalOverpowerEvents = 0;
    final fallsPerHourValues = <double>[];
    final lostSamplesValues = <double>[];
    final takeoffSpeedValues = <double>[];
    final landingSpeedValues = <double>[];
    final cleanLandingRateValues = <double>[];
    final jumpHeightConsistencyValues = <double>[];
    final speedVariabilityValues = <double>[];
    final directionalStabilityValues = <double>[];
    final jibeQualityValues = <double>[];
    final transitionSpeedLossValues = <double>[];
    final planingRecoveryValues = <double>[];
    final bigAirScoreValues = <double>[];
    double? maxFreerideScore;
    double? maxSessionScore;
    final activeDays = <DateTime>{};
    final spotCounts = <String, int>{};
    final sessionsByMonth = <String, int>{};
    DateTime? latestRecordAt;
    String? latestRecordLabel;
    final sessionAvgSpeeds = <double>[];
    final jumpHeights = <double>[];
    final jumpHangtimes = <double>[];
    var totalTransitions = 0;
    final transitionsPerHourValues = <double>[];
    final tackEfficiencyValues = <double>[];
    final sweetspotValues = <double>[];
    final impactScoreValues = <double>[];
    double? maxBigAirScore;
    final freerideScoreValues = <double>[];
    final safetyScoreValues = <double>[];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last30Start = today.subtract(const Duration(days: 29));
    final previous30Start = today.subtract(const Duration(days: 59));
    final previous30End = today.subtract(const Duration(days: 30));
    var last30DaysSessions = 0;
    var previous30DaysSessions = 0;
    double? highestJumpLast30;
    double? highestJumpPrevious30;
    double? hangtimeLast30;
    double? hangtimePrevious30;

    for (final session in items) {
      totalWaterHours += session.duration.inSeconds / 3600;
      final sessionDay = DateTime(
        session.endedAt.year,
        session.endedAt.month,
        session.endedAt.day,
      );
      activeDays.add(sessionDay);

      final spotName = session.spotName?.trim();
      if (spotName != null && spotName.isNotEmpty) {
        spotCounts.update(spotName, (value) => value + 1, ifAbsent: () => 1);
      }
      final monthKey = _monthKey(session.endedAt);
      sessionsByMonth.update(monthKey, (value) => value + 1, ifAbsent: () => 1);

      final insights = _decodeInsights(session.insights);
      final avgSpeed = insights.resolvedAvgSpeedKnots;
      if (avgSpeed != null && avgSpeed > 0) {
        sessionAvgSpeeds.add(avgSpeed);
      }
      final acceleration = insights.maxAccelerationG;
      if (acceleration != null &&
          (maxAccelerationG == null || acceleration > maxAccelerationG)) {
        maxAccelerationG = acceleration;
      }
      final rotation = insights.maxRotationDegPerSec;
      if (rotation != null &&
          (maxRotationDegPerSec == null || rotation > maxRotationDegPerSec)) {
        maxRotationDegPerSec = rotation;
      }
      final speedP95 = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.speedP95,
      );
      if (speedP95 != null && speedP95 > 0) {
        speedP95Values.add(speedP95);
      }
      final planingDistance = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.distancePlaning,
      );
      if (planingDistance != null && planingDistance > 0) {
        totalPlaningDistanceKm += planingDistance;
      }
      final areaCoverage = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.areaCoverage,
      );
      if (areaCoverage != null && areaCoverage > 0) {
        totalAreaCoverageKm2 += areaCoverage;
      }
      final netDrift = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.netDrift,
      );
      if (netDrift != null) {
        netDriftValues.add(netDrift.abs());
      }
      final distanceCoast = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.maxDistanceCoast,
      );
      if (distanceCoast != null &&
          (maxDistanceCoastKm == null || distanceCoast > maxDistanceCoastKm)) {
        maxDistanceCoastKm = distanceCoast;
      }
      final gpsAccuracy = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.gpsQuality,
      );
      if (gpsAccuracy != null && gpsAccuracy > 0) {
        gpsAccuracyValues.add(gpsAccuracy);
      }
      final overpowerEvents = insights.advancedMetrics.intValue(
        SessionMetricKeys.overpowerEvents,
      );
      if (overpowerEvents != null && overpowerEvents > 0) {
        totalOverpowerEvents += overpowerEvents;
      }
      final fallsPerHour = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.fallsPerHour,
      );
      if (fallsPerHour != null && fallsPerHour >= 0) {
        fallsPerHourValues.add(fallsPerHour);
      }
      final lostSamples = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.lostSamples,
      );
      if (lostSamples != null && lostSamples >= 0) {
        lostSamplesValues.add(lostSamples);
      }
      final riskZoneTime = insights.advancedMetrics.kpiValue(
        SessionMetricKeys.riskZoneTime,
      );
      final riskZoneHours = _parseDurationHours(riskZoneTime);
      if (riskZoneHours != null && riskZoneHours > 0) {
        totalRiskZoneHours += riskZoneHours;
      }
      final takeoffSpeed = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.takeoffSpeed,
      );
      if (takeoffSpeed != null && takeoffSpeed > 0) {
        takeoffSpeedValues.add(takeoffSpeed);
      }
      final landingSpeed = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.landingSpeed,
      );
      if (landingSpeed != null && landingSpeed > 0) {
        landingSpeedValues.add(landingSpeed);
      }
      final cleanLandingRate = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.cleanLandingRate,
      );
      if (cleanLandingRate != null && cleanLandingRate > 0) {
        cleanLandingRateValues.add(cleanLandingRate);
      }
      final jumpHeightConsistency = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.jumpHeightConsistency,
      );
      if (jumpHeightConsistency != null && jumpHeightConsistency > 0) {
        jumpHeightConsistencyValues.add(jumpHeightConsistency);
      }
      final speedVariability = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.speedVariability,
      );
      if (speedVariability != null && speedVariability > 0) {
        speedVariabilityValues.add(speedVariability);
      }
      final directionalStability = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.directionalStability,
      );
      if (directionalStability != null && directionalStability > 0) {
        directionalStabilityValues.add(directionalStability);
      }
      final jibeQuality = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.jibeQuality,
      );
      if (jibeQuality != null && jibeQuality > 0) {
        jibeQualityValues.add(jibeQuality);
      }
      final transitionSpeedLoss = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.transitionSpeedLoss,
      );
      if (transitionSpeedLoss != null && transitionSpeedLoss > 0) {
        transitionSpeedLossValues.add(transitionSpeedLoss);
      }
      final planingRecovery = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.planingRecovery,
      );
      if (planingRecovery != null && planingRecovery > 0) {
        planingRecoveryValues.add(planingRecovery);
      }
      final transitions = insights.advancedMetrics.intValue(
        SessionMetricKeys.transitions,
      );
      if (transitions != null && transitions > 0) {
        totalTransitions += transitions;
      }
      final transitionsPerHour = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.transitionsPerHour,
      );
      if (transitionsPerHour != null && transitionsPerHour > 0) {
        transitionsPerHourValues.add(transitionsPerHour);
      }
      final tackEfficiency = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.tackEfficiency,
      );
      if (tackEfficiency != null && tackEfficiency > 0) {
        tackEfficiencyValues.add(tackEfficiency);
      }
      final sweetspotPercent = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.sweetspotTime,
      );
      if (sweetspotPercent != null && sweetspotPercent > 0) {
        sweetspotValues.add(sweetspotPercent);
      }
      final impactScore = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.impactScore,
      );
      if (impactScore != null && impactScore > 0) {
        impactScoreValues.add(impactScore);
      }
      final bigAirScore = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.bigAirScore,
      );
      if (bigAirScore != null &&
          (maxBigAirScore == null || bigAirScore > maxBigAirScore)) {
        maxBigAirScore = bigAirScore;
      }
      if (bigAirScore != null) {
        bigAirScoreValues.add(bigAirScore);
      }
      final freerideScore = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.freerideScore,
      );
      if (freerideScore != null && freerideScore > 0) {
        freerideScoreValues.add(freerideScore);
      }
      if (freerideScore != null &&
          (maxFreerideScore == null || freerideScore > maxFreerideScore)) {
        maxFreerideScore = freerideScore;
      }
      final sessionScore = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.sessionScore,
      );
      if (sessionScore != null &&
          (maxSessionScore == null || sessionScore > maxSessionScore)) {
        maxSessionScore = sessionScore;
      }
      final safetyScore = insights.advancedMetrics.doubleValue(
        SessionMetricKeys.safetyScore,
      );
      if (safetyScore != null && safetyScore > 0) {
        safetyScoreValues.add(safetyScore);
      }

      final jumps = insights.resolvedJumpsCount ?? 0;
      totalJumps += jumps;
      if (jumps > 0) {
        sessionsWithJumps += 1;
      }

      for (final jumpRecord in insights.jumpHistory) {
        if (jumpRecord.heightMeters > 0) {
          jumpHeights.add(jumpRecord.heightMeters);
        }
        if (jumpRecord.hangtimeSeconds > 0) {
          jumpHangtimes.add(jumpRecord.hangtimeSeconds);
        }
      }

      final jump = insights.resolvedMaxJumpHeightMeters;
      if (jump != null &&
          (highestJumpMeters == null || jump > highestJumpMeters)) {
        highestJumpMeters = jump;
        latestRecordAt = session.endedAt;
        latestRecordLabel = 'Salto mas alto · ${_formatDate(session.endedAt)}';
      }

      final hangtime = insights.resolvedMaxHangtimeSeconds;
      if (hangtime != null &&
          (maxHangtimeSeconds == null || hangtime > maxHangtimeSeconds)) {
        maxHangtimeSeconds = hangtime;
        if (latestRecordAt == null || session.endedAt.isAfter(latestRecordAt)) {
          latestRecordAt = session.endedAt;
          latestRecordLabel = 'Max hangtime · ${_formatDate(session.endedAt)}';
        }
      }

      final speed = insights.resolvedMaxSpeedKnots;
      if (speed != null && (maxSpeedKnots == null || speed > maxSpeedKnots)) {
        maxSpeedKnots = speed;
      }

      if (!sessionDay.isBefore(last30Start)) {
        last30DaysSessions += 1;
        if (jump != null &&
            (highestJumpLast30 == null || jump > highestJumpLast30)) {
          highestJumpLast30 = jump;
        }
        if (hangtime != null &&
            (hangtimeLast30 == null || hangtime > hangtimeLast30)) {
          hangtimeLast30 = hangtime;
        }
      } else if (!sessionDay.isBefore(previous30Start) &&
          !sessionDay.isAfter(previous30End)) {
        previous30DaysSessions += 1;
        if (jump != null &&
            (highestJumpPrevious30 == null || jump > highestJumpPrevious30)) {
          highestJumpPrevious30 = jump;
        }
        if (hangtime != null &&
            (hangtimePrevious30 == null || hangtime > hangtimePrevious30)) {
          hangtimePrevious30 = hangtime;
        }
      }
    }

    final totalSessions = items.length;
    final sessionsThisMonth = items
        .where(
          (session) =>
              session.endedAt.year == now.year &&
              session.endedAt.month == now.month,
        )
        .length;
    final avgSessionHours = totalSessions == 0
        ? 0.0
        : totalWaterHours / totalSessions;
    final avgJumpsPerSession = totalSessions == 0
        ? 0.0
        : totalJumps / totalSessions.toDouble();
    final avgSpeedKnots = sessionAvgSpeeds.isEmpty
        ? null
        : sessionAvgSpeeds.reduce((a, b) => a + b) / sessionAvgSpeeds.length;
    final avgNetDriftKm = netDriftValues.isEmpty
        ? null
        : netDriftValues.reduce((a, b) => a + b) / netDriftValues.length;
    final avgGpsAccuracyMeters = gpsAccuracyValues.isEmpty
        ? null
        : gpsAccuracyValues.reduce((a, b) => a + b) / gpsAccuracyValues.length;
    final avgFallsPerHour = fallsPerHourValues.isEmpty
        ? null
        : fallsPerHourValues.reduce((a, b) => a + b) /
              fallsPerHourValues.length;
    final avgLostSamplesPercent = lostSamplesValues.isEmpty
        ? null
        : lostSamplesValues.reduce((a, b) => a + b) / lostSamplesValues.length;
    final avgSpeedP95Knots = speedP95Values.isEmpty
        ? null
        : speedP95Values.reduce((a, b) => a + b) / speedP95Values.length;
    final avgPlaningDistanceKm = totalSessions == 0
        ? 0.0
        : totalPlaningDistanceKm / totalSessions;
    final avgTakeoffSpeedKnots = takeoffSpeedValues.isEmpty
        ? null
        : takeoffSpeedValues.reduce((a, b) => a + b) /
              takeoffSpeedValues.length;
    final avgLandingSpeedKnots = landingSpeedValues.isEmpty
        ? null
        : landingSpeedValues.reduce((a, b) => a + b) /
              landingSpeedValues.length;
    final avgCleanLandingRate = cleanLandingRateValues.isEmpty
        ? null
        : cleanLandingRateValues.reduce((a, b) => a + b) /
              cleanLandingRateValues.length;
    final avgJumpHeightMeters = jumpHeights.isEmpty
        ? null
        : jumpHeights.reduce((a, b) => a + b) / jumpHeights.length;
    final avgHangtimeSeconds = jumpHangtimes.isEmpty
        ? null
        : jumpHangtimes.reduce((a, b) => a + b) / jumpHangtimes.length;
    final avgJumpHeightConsistencyPercent = jumpHeightConsistencyValues.isEmpty
        ? null
        : jumpHeightConsistencyValues.reduce((a, b) => a + b) /
              jumpHeightConsistencyValues.length;
    final avgSpeedVariabilityKnots = speedVariabilityValues.isEmpty
        ? null
        : speedVariabilityValues.reduce((a, b) => a + b) /
              speedVariabilityValues.length;
    final avgDirectionalStabilityPercent = directionalStabilityValues.isEmpty
        ? null
        : directionalStabilityValues.reduce((a, b) => a + b) /
              directionalStabilityValues.length;
    final avgJibeQualityPercent = jibeQualityValues.isEmpty
        ? null
        : jibeQualityValues.reduce((a, b) => a + b) / jibeQualityValues.length;
    final avgTransitionSpeedLossKnots = transitionSpeedLossValues.isEmpty
        ? null
        : transitionSpeedLossValues.reduce((a, b) => a + b) /
              transitionSpeedLossValues.length;
    final avgPlaningRecoverySeconds = planingRecoveryValues.isEmpty
        ? null
        : planingRecoveryValues.reduce((a, b) => a + b) /
              planingRecoveryValues.length;
    final avgBigAirScore = bigAirScoreValues.isEmpty
        ? null
        : bigAirScoreValues.reduce((a, b) => a + b) / bigAirScoreValues.length;
    final avgTransitionsPerHour = transitionsPerHourValues.isEmpty
        ? null
        : transitionsPerHourValues.reduce((a, b) => a + b) /
              transitionsPerHourValues.length;
    final avgTackEfficiencyPercent = tackEfficiencyValues.isEmpty
        ? null
        : tackEfficiencyValues.reduce((a, b) => a + b) /
              tackEfficiencyValues.length;
    final avgSweetspotPercent = sweetspotValues.isEmpty
        ? null
        : sweetspotValues.reduce((a, b) => a + b) / sweetspotValues.length;
    final avgImpactScore = impactScoreValues.isEmpty
        ? null
        : impactScoreValues.reduce((a, b) => a + b) / impactScoreValues.length;
    final avgFreerideScore = freerideScoreValues.isEmpty
        ? null
        : freerideScoreValues.reduce((a, b) => a + b) /
              freerideScoreValues.length;
    final avgSafetyScore = safetyScoreValues.isEmpty
        ? null
        : safetyScoreValues.reduce((a, b) => a + b) / safetyScoreValues.length;
    final daysSinceLatestRecord = latestRecordAt == null
        ? null
        : today
              .difference(
                DateTime(
                  latestRecordAt.year,
                  latestRecordAt.month,
                  latestRecordAt.day,
                ),
              )
              .inDays;

    return ProfileSessionStatsSnapshot(
      totalSessions: totalSessions,
      totalWaterHours: totalWaterHours,
      totalJumps: totalJumps,
      activeDays: activeDays.length,
      sessionsWithJumps: sessionsWithJumps,
      highestJumpMeters: highestJumpMeters,
      maxHangtimeSeconds: maxHangtimeSeconds,
      maxAccelerationG: maxAccelerationG,
      maxRotationDegPerSec: maxRotationDegPerSec,
      maxSpeedKnots: maxSpeedKnots,
      avgSpeedKnots: avgSpeedKnots,
      avgSpeedP95Knots: avgSpeedP95Knots,
      totalPlaningDistanceKm: totalPlaningDistanceKm,
      avgPlaningDistanceKm: avgPlaningDistanceKm,
      avgTakeoffSpeedKnots: avgTakeoffSpeedKnots,
      avgLandingSpeedKnots: avgLandingSpeedKnots,
      avgCleanLandingRate: avgCleanLandingRate,
      avgJumpHeightMeters: avgJumpHeightMeters,
      avgHangtimeSeconds: avgHangtimeSeconds,
      avgJumpHeightConsistencyPercent: avgJumpHeightConsistencyPercent,
      avgSpeedVariabilityKnots: avgSpeedVariabilityKnots,
      avgDirectionalStabilityPercent: avgDirectionalStabilityPercent,
      avgJibeQualityPercent: avgJibeQualityPercent,
      avgTransitionSpeedLossKnots: avgTransitionSpeedLossKnots,
      avgPlaningRecoverySeconds: avgPlaningRecoverySeconds,
      totalTransitions: totalTransitions,
      avgTransitionsPerHour: avgTransitionsPerHour,
      avgTackEfficiencyPercent: avgTackEfficiencyPercent,
      avgSweetspotPercent: avgSweetspotPercent,
      avgImpactScore: avgImpactScore,
      maxBigAirScore: maxBigAirScore,
      avgBigAirScore: avgBigAirScore,
      maxFreerideScore: maxFreerideScore,
      avgFreerideScore: avgFreerideScore,
      avgSafetyScore: avgSafetyScore,
      maxSessionScore: maxSessionScore,
      totalAreaCoverageKm2: totalAreaCoverageKm2,
      avgNetDriftKm: avgNetDriftKm,
      maxDistanceCoastKm: maxDistanceCoastKm,
      totalRiskZoneHours: totalRiskZoneHours,
      avgGpsAccuracyMeters: avgGpsAccuracyMeters,
      totalOverpowerEvents: totalOverpowerEvents,
      avgFallsPerHour: avgFallsPerHour,
      avgLostSamplesPercent: avgLostSamplesPercent,
      avgSessionHours: avgSessionHours,
      avgJumpsPerSession: avgJumpsPerSession,
      sessionsThisMonth: sessionsThisMonth,
      last30DaysSessions: last30DaysSessions,
      previous30DaysSessions: previous30DaysSessions,
      daysSinceLatestRecord: daysSinceLatestRecord,
      mostUsedSpot: _topKeyByCount(spotCounts),
      bestMonthLabel: _topKeyByCount(sessionsByMonth),
      latestRecordLabel: latestRecordLabel,
      highestJumpTrendLabel: _buildTrendLabel(
        current: highestJumpLast30,
        previous: highestJumpPrevious30,
        unit: 'm',
      ),
      hangtimeTrendLabel: _buildTrendLabel(
        current: hangtimeLast30,
        previous: hangtimePrevious30,
        unit: 's',
      ),
    );
  }

  static SessionInsightData _decodeInsights(Object raw) {
    if (raw is SessionInsightData) {
      return raw;
    }
    if (raw is Map<String, dynamic>) {
      return SessionInsightData.fromJson(raw);
    }
    return SessionInsightData.empty(deviceKind: 'Dispositivo Android');
  }

  static double? _parseDurationHours(String? raw) {
    if (raw == null || raw.isEmpty || raw == '--') {
      return null;
    }
    final hourMatch = RegExp(r'(\d+)h').firstMatch(raw);
    final minuteMatch = RegExp(r'(\d+)m').firstMatch(raw);
    final secondMatch = RegExp(r'(\d+)s').firstMatch(raw);
    final hours = int.tryParse(hourMatch?.group(1) ?? '') ?? 0;
    final minutes = int.tryParse(minuteMatch?.group(1) ?? '') ?? 0;
    final seconds = int.tryParse(secondMatch?.group(1) ?? '') ?? 0;
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;
    if (totalSeconds > 0) {
      return totalSeconds / 3600;
    }
    return null;
  }

  static String _monthKey(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}';

  static String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  static String? _topKeyByCount(Map<String, int> source) {
    if (source.isEmpty) {
      return null;
    }
    final entries = source.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }

  static String? _buildTrendLabel({
    required double? current,
    required double? previous,
    required String unit,
  }) {
    if (current == null || previous == null) {
      return null;
    }
    final delta = current - previous;
    final prefix = delta > 0 ? '+' : '';
    return '$prefix${delta.toStringAsFixed(1)} $unit';
  }
}
