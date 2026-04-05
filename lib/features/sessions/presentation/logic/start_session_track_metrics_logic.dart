import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class StartSessionTrackMetricsLogic {
  const StartSessionTrackMetricsLogic._();

  static SessionTrackDerivedMetricsResult computeDerivedMetrics(
    SessionTrackDerivedMetricsInput input,
  ) {
    final samples = input.samples;
    final netDisplacementKm = _computeNetDisplacementKm(samples);
    final coverageAreaKm2 = _computeCoverageAreaKm2(samples);
    final maxDistanceFromStartKm = _computeMaxDistanceFromStartKm(samples);
    final timeInRiskZone = _computeTimeInRiskZone(samples);
    final sweetspotPercent = _computeSweetspotPercent(
      samples,
      input.recordingMaxSpeedKnots,
    );
    final directionalStabilityPercent =
        _computeDirectionalStabilityPercent(samples);
    final routeEfficiencyPercent = _computeRouteEfficiencyPercent(
      recordingDistanceMeters: input.recordingDistanceMeters,
      netDisplacementKm: netDisplacementKm,
    );
    final averageSampleIntervalSeconds =
        _computeAverageSampleIntervalSeconds(samples);
    final rejectedCount =
        input.rejectedAccuracyCount + input.rejectedPlausibilityCount;
    final lostSamplesPercent = input.rawPositionCount <= 0
        ? 0.0
        : (rejectedCount / input.rawPositionCount) * 100;
    final datasetHealthPercent = input.rawPositionCount <= 0
        ? 0.0
        : ((samples.length / input.rawPositionCount) * 100)
              .clamp(0, 100)
              .toDouble();

    return SessionTrackDerivedMetricsResult(
      netDisplacementKm: netDisplacementKm,
      coverageAreaKm2: coverageAreaKm2,
      maxDistanceFromStartKm: maxDistanceFromStartKm,
      timeInRiskZone: timeInRiskZone,
      sweetspotPercent: sweetspotPercent,
      directionalStabilityPercent: directionalStabilityPercent,
      routeEfficiencyPercent: routeEfficiencyPercent,
      averageSampleIntervalSeconds: averageSampleIntervalSeconds,
      lostSamplesPercent: lostSamplesPercent,
      datasetHealthPercent: datasetHealthPercent,
    );
  }

  static SessionTrackTransitionSummary analyzeTrackTransitions(
    List<SessionCaptureSample> samples, {
    required double movingAverageMinSpeedKnots,
  }) {
    if (samples.length < 3) {
      return const SessionTrackTransitionSummary.empty();
    }

    var transitionCount = 0;
    var cleanCount = 0;
    var totalSpeedLossKnots = 0.0;
    var totalRecoverySeconds = 0.0;
    var recoveryCount = 0;

    for (var i = 1; i < samples.length - 1; i++) {
      final previous = samples[i - 1];
      final current = samples[i];
      final next = samples[i + 1];

      final previousDistance = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        current.latitude,
        current.longitude,
      );
      final nextDistance = Geolocator.distanceBetween(
        current.latitude,
        current.longitude,
        next.latitude,
        next.longitude,
      );
      if (!previousDistance.isFinite ||
          !nextDistance.isFinite ||
          previousDistance < 3 ||
          nextDistance < 3) {
        continue;
      }

      final previousBearing = Geolocator.bearingBetween(
        previous.latitude,
        previous.longitude,
        current.latitude,
        current.longitude,
      );
      final nextBearing = Geolocator.bearingBetween(
        current.latitude,
        current.longitude,
        next.latitude,
        next.longitude,
      );
      final rawDelta = (nextBearing - previousBearing).abs();
      final bearingDelta = math.min(rawDelta, 360 - rawDelta);
      if (bearingDelta < 35 || bearingDelta > 170) {
        continue;
      }

      final beforeSpeed = (previous.speedKnots + current.speedKnots) / 2;
      final afterSpeed = (current.speedKnots + next.speedKnots) / 2;
      if (beforeSpeed < movingAverageMinSpeedKnots &&
          afterSpeed < movingAverageMinSpeedKnots) {
        continue;
      }

      transitionCount += 1;
      final speedLoss = math.max(0.0, beforeSpeed - afterSpeed);
      totalSpeedLossKnots += speedLoss;

      if (afterSpeed >= beforeSpeed * 0.7) {
        cleanCount += 1;
      }

      final recoveryThreshold = math.max(
        movingAverageMinSpeedKnots,
        beforeSpeed * 0.8,
      );
      for (var j = i + 1; j < samples.length; j++) {
        final recoverySample = samples[j];
        if (recoverySample.speedKnots < recoveryThreshold) {
          continue;
        }
        final recoverySeconds =
            recoverySample.timestamp.difference(current.timestamp).inMilliseconds /
            1000;
        if (recoverySeconds.isFinite && recoverySeconds >= 0) {
          totalRecoverySeconds += recoverySeconds;
          recoveryCount += 1;
        }
        break;
      }
    }

    if (transitionCount == 0) {
      return const SessionTrackTransitionSummary.empty();
    }

    return SessionTrackTransitionSummary(
      count: transitionCount,
      qualityPercent: (cleanCount / transitionCount) * 100,
      avgSpeedLossKnots: totalSpeedLossKnots / transitionCount,
      avgRecoverySeconds: recoveryCount == 0
          ? 0
          : totalRecoverySeconds / recoveryCount,
    );
  }

  static double computeBoundedScore(List<double> components) {
    final normalized = components
        .where((value) => value.isFinite)
        .map((value) => value.clamp(0, 100).toDouble())
        .toList(growable: false);
    if (normalized.isEmpty) {
      return 0;
    }
    final total = normalized.reduce((a, b) => a + b);
    return total / normalized.length;
  }

  static double _computeNetDisplacementKm(List<SessionCaptureSample> samples) {
    if (samples.length < 2) {
      return 0;
    }
    final first = samples.first;
    final last = samples.last;
    return Geolocator.distanceBetween(
          first.latitude,
          first.longitude,
          last.latitude,
          last.longitude,
        ) /
        1000;
  }

  static double _computeCoverageAreaKm2(List<SessionCaptureSample> samples) {
    if (samples.length < 2) {
      return 0;
    }
    var minLat = samples.first.latitude;
    var maxLat = samples.first.latitude;
    var minLon = samples.first.longitude;
    var maxLon = samples.first.longitude;

    for (final sample in samples.skip(1)) {
      minLat = math.min(minLat, sample.latitude);
      maxLat = math.max(maxLat, sample.latitude);
      minLon = math.min(minLon, sample.longitude);
      maxLon = math.max(maxLon, sample.longitude);
    }

    final midLatRadians = ((minLat + maxLat) / 2) * math.pi / 180;
    final latKm = (maxLat - minLat) * 111.32;
    final lonKm = (maxLon - minLon) * 111.32 * math.cos(midLatRadians);
    final area = latKm * lonKm;
    return area.isFinite ? area.abs() : 0;
  }

  static double _computeMaxDistanceFromStartKm(
    List<SessionCaptureSample> samples,
  ) {
    if (samples.length < 2) {
      return 0;
    }
    final first = samples.first;
    var maxDistanceMeters = 0.0;
    for (final sample in samples.skip(1)) {
      final distanceMeters = Geolocator.distanceBetween(
        first.latitude,
        first.longitude,
        sample.latitude,
        sample.longitude,
      );
      if (!distanceMeters.isFinite || distanceMeters < 0) {
        continue;
      }
      if (distanceMeters > maxDistanceMeters) {
        maxDistanceMeters = distanceMeters;
      }
    }
    return maxDistanceMeters / 1000;
  }

  static Duration _computeTimeInRiskZone(List<SessionCaptureSample> samples) {
    if (samples.length < 2) {
      return Duration.zero;
    }
    const riskDistanceMeters = 500.0;
    final first = samples.first;
    var total = Duration.zero;

    for (var i = 1; i < samples.length; i++) {
      final previous = samples[i - 1];
      final current = samples[i];
      final distanceFromStartMeters = Geolocator.distanceBetween(
        first.latitude,
        first.longitude,
        current.latitude,
        current.longitude,
      );
      if (!distanceFromStartMeters.isFinite ||
          distanceFromStartMeters < riskDistanceMeters) {
        continue;
      }
      final delta = current.timestamp.difference(previous.timestamp);
      if (delta.isNegative || delta.inMilliseconds <= 0) {
        continue;
      }
      total += delta;
    }

    return total;
  }

  static double _computeSweetspotPercent(
    List<SessionCaptureSample> samples,
    double recordingMaxSpeedKnots,
  ) {
    if (samples.isEmpty || recordingMaxSpeedKnots <= 0) {
      return 0;
    }
    final minSweetspot = recordingMaxSpeedKnots * 0.7;
    final maxSweetspot = recordingMaxSpeedKnots * 0.9;
    final matchingCount = samples
        .where(
          (sample) =>
              sample.speedKnots >= minSweetspot &&
              sample.speedKnots <= maxSweetspot,
        )
        .length;
    return (matchingCount / samples.length) * 100;
  }

  static double _computeDirectionalStabilityPercent(
    List<SessionCaptureSample> samples,
  ) {
    final bearings = <double>[];
    for (var i = 1; i < samples.length; i++) {
      final previous = samples[i - 1];
      final current = samples[i];
      final distance = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        current.latitude,
        current.longitude,
      );
      if (!distance.isFinite || distance < 3) {
        continue;
      }
      bearings.add(
        Geolocator.bearingBetween(
          previous.latitude,
          previous.longitude,
          current.latitude,
          current.longitude,
        ),
      );
    }
    if (bearings.length < 2) {
      return 0;
    }
    var totalDelta = 0.0;
    for (var i = 1; i < bearings.length; i++) {
      final delta = (bearings[i] - bearings[i - 1]).abs();
      totalDelta += math.min(delta, 360 - delta);
    }
    final averageDelta = totalDelta / (bearings.length - 1);
    return (100 - (averageDelta / 180) * 100).clamp(0, 100);
  }

  static double _computeRouteEfficiencyPercent({
    required double recordingDistanceMeters,
    required double netDisplacementKm,
  }) {
    if (recordingDistanceMeters <= 0) {
      return 0;
    }
    final netDistanceMeters = netDisplacementKm * 1000;
    return ((netDistanceMeters / recordingDistanceMeters) * 100).clamp(0, 100);
  }

  static double _computeAverageSampleIntervalSeconds(
    List<SessionCaptureSample> samples,
  ) {
    if (samples.length < 2) {
      return 0;
    }
    var totalSeconds = 0.0;
    var segmentCount = 0;
    for (var i = 1; i < samples.length; i++) {
      final delta =
          samples[i].timestamp.difference(samples[i - 1].timestamp).inMilliseconds /
          1000;
      if (!delta.isFinite || delta <= 0) {
        continue;
      }
      totalSeconds += delta;
      segmentCount += 1;
    }
    if (segmentCount == 0) {
      return 0;
    }
    return totalSeconds / segmentCount;
  }
}
