import 'dart:math' as math;

import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/presentation/logic/start_session_track_metrics_logic.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class StartSessionRecordedSessionBuilder {
  const StartSessionRecordedSessionBuilder._();

  static SessionRecordedMetricsSummaryResult buildMetricsSummary(
    SessionRecordedMetricsSummaryInput input,
  ) {
    final distanceKm = input.recordingDistanceMeters / 1000;
    final avgSpeedKnots = input.samples.isEmpty
        ? 0.0
        : input.samples
                  .map((sample) => sample.speedKnots)
                  .reduce((a, b) => a + b) /
              input.samples.length;
    final movingSpeedSamples = input.samples
        .where(
          (sample) => sample.speedKnots >= input.movingAverageMinSpeedKnots,
        )
        .map((sample) => sample.speedKnots)
        .toList(growable: false);
    final movingAvgSpeedKnots = movingSpeedSamples.isEmpty
        ? 0.0
        : movingSpeedSamples.reduce((a, b) => a + b) /
              movingSpeedSamples.length;
    final planingMinutes = input.movingDuration.inMinutes > 0
        ? input.movingDuration.inMinutes
        : null;
    final activeDuration = input.duration - input.autoPausedDuration;
    final safeActiveDuration = activeDuration.isNegative
        ? Duration.zero
        : activeDuration;
    final safePausedDuration = input.autoPausedDuration.isNegative
        ? Duration.zero
        : input.autoPausedDuration;
    final timelineSamples = List<double>.from(input.timelineKnots)..sort();
    final speedP95Knots = timelineSamples.isEmpty
        ? 0.0
        : timelineSamples[((timelineSamples.length - 1) * 0.95).floor()];
    final trackMetrics = StartSessionTrackMetricsLogic.computeDerivedMetrics(
      SessionTrackDerivedMetricsInput(
        samples: input.samples,
        recordingDistanceMeters: input.recordingDistanceMeters,
        recordingMaxSpeedKnots: input.recordingMaxSpeedKnots,
        rawPositionCount: input.rawPositionCount,
        rejectedAccuracyCount: input.rejectedAccuracyCount,
        rejectedPlausibilityCount: input.rejectedPlausibilityCount,
      ),
    );
    final transitionSummary =
        StartSessionTrackMetricsLogic.analyzeTrackTransitions(
          input.samples,
          movingAverageMinSpeedKnots: input.movingAverageMinSpeedKnots,
        );
    final sessionScore = StartSessionTrackMetricsLogic.computeBoundedScore([
      trackMetrics.datasetHealthPercent,
      (100 - trackMetrics.lostSamplesPercent).toDouble(),
      trackMetrics.sweetspotPercent,
      trackMetrics.routeEfficiencyPercent,
      trackMetrics.directionalStabilityPercent,
    ]);
    final freerideScore = StartSessionTrackMetricsLogic.computeBoundedScore([
      trackMetrics.routeEfficiencyPercent,
      trackMetrics.sweetspotPercent,
      trackMetrics.directionalStabilityPercent,
      timelineSamples.isEmpty
          ? 0.0
          : (10 - (timelineSamples.last - timelineSamples.first).clamp(0, 10)) *
                10.0,
    ]);
    final safetyScore = StartSessionTrackMetricsLogic.computeBoundedScore([
      trackMetrics.datasetHealthPercent,
      input.lastGpsAccuracyMeters == null
          ? 0.0
          : (100 - (input.lastGpsAccuracyMeters!.clamp(0, 25) / 25) * 100)
                .toDouble(),
      math.max(
        0.0,
        100 -
            ((input.duration.inSeconds <= 0
                    ? 0.0
                    : (input.accelerationEventCount /
                          (input.duration.inSeconds / 3600))) *
                18),
      ),
      math.max(0.0, 100 - (input.rotationEventCount * 10)),
    ]);
    final distancePlaningKm =
        movingAvgSpeedKnots > 0 && input.movingDuration > Duration.zero
        ? ((movingAvgSpeedKnots * 0.514444) *
                  input.movingDuration.inMilliseconds /
                  1000) /
              1000
        : 0.0;
    final jumpsCount = input.jumpHistory.length;
    final jumpMetrics = _buildJumpMetrics(
      jumpHistory: input.jumpHistory,
      duration: input.duration,
    );
    final transitionsCount = transitionSummary.count > 0
        ? transitionSummary.count
        : input.accelerationEventCount + input.rotationEventCount;
    final transitionsPerHour = input.duration.inSeconds <= 0
        ? 0.0
        : transitionsCount / (input.duration.inSeconds / 3600);
    final bigAirScore = jumpsCount == 0
        ? null
        : StartSessionTrackMetricsLogic.computeBoundedScore([
            jumpMetrics.maxJumpHeightMeters == null
                ? 0
                : (jumpMetrics.maxJumpHeightMeters! * 12)
                      .clamp(0, 100)
                      .toDouble(),
            jumpMetrics.maxHangtimeSeconds == null
                ? 0
                : (jumpMetrics.maxHangtimeSeconds! * 20)
                      .clamp(0, 100)
                      .toDouble(),
            jumpMetrics.cleanLandingRate ?? 0,
            jumpMetrics.jumpHeightConsistency ?? 0,
          ]);
    final measuredValues = <String, String>{
      'duracion_total': _formatDuration(input.duration),
      'tiempo_activo': _formatDuration(safeActiveDuration),
      'tiempo_parado': _formatDuration(safePausedDuration),
      'ratio_activo_parado': safePausedDuration.inSeconds <= 0
          ? '${safeActiveDuration.inMinutes}:0'
          : '${(safeActiveDuration.inSeconds / safePausedDuration.inSeconds).toStringAsFixed(1)}:1',
      'distancia_total': '${distanceKm.toStringAsFixed(2)} km',
      'distancia_planeo': '${distancePlaningKm.toStringAsFixed(2)} km',
      'velocidad_media': '${avgSpeedKnots.toStringAsFixed(1)} kt',
      'velocidad_max': '${input.recordingMaxSpeedKnots.toStringAsFixed(1)} kt',
      'velocidad_p95': '${speedP95Knots.toStringAsFixed(1)} kt',
      'transiciones': '$transitionsCount',
      'transiciones_hora': transitionsPerHour.toStringAsFixed(1),
      'saltos_totales': '$jumpsCount',
      if (jumpMetrics.top5AverageJumpMeters != null)
        'top5_saltos':
            '${jumpMetrics.top5AverageJumpMeters!.toStringAsFixed(1)} m',
      if (jumpMetrics.avgJumpHeightMeters != null)
        'altura_media_saltos':
            '${jumpMetrics.avgJumpHeightMeters!.toStringAsFixed(1)} m',
      if (jumpMetrics.maxHangtimeSeconds != null)
        'hangtime_max':
            '${jumpMetrics.maxHangtimeSeconds!.toStringAsFixed(1)} s',
      if (jumpMetrics.hangtimeP95Seconds != null)
        'hangtime_p95':
            '${jumpMetrics.hangtimeP95Seconds!.toStringAsFixed(1)} s',
      if (jumpMetrics.jumpWindEfficiency != null)
        'eficiencia_salto_viento': jumpMetrics.jumpWindEfficiency!
            .toStringAsFixed(2),
      if (jumpMetrics.jumpCadencePerHour != null)
        'cadencia_saltos':
            '${jumpMetrics.jumpCadencePerHour!.toStringAsFixed(1)}/h',
      if (jumpMetrics.jumpHeightConsistency != null)
        'consistencia_alturas':
            '${jumpMetrics.jumpHeightConsistency!.toStringAsFixed(0)}%',
      'eficiencia_bordos':
          '${trackMetrics.routeEfficiencyPercent.toStringAsFixed(0)}%',
      'tiempo_sweetspot':
          '${trackMetrics.sweetspotPercent.toStringAsFixed(0)}%',
      'deriva_neta': '${trackMetrics.netDisplacementKm.toStringAsFixed(2)} km',
      'cobertura_area':
          '${trackMetrics.coverageAreaKm2.toStringAsFixed(2)} km2',
      if (jumpMetrics.maxJumpHeightMeters != null)
        'salto_mas_alto':
            '${jumpMetrics.maxJumpHeightMeters!.toStringAsFixed(1)} m',
      if (jumpMetrics.maxJumpHeightMeters != null)
        'distancia_salto_estimada':
            '${(jumpMetrics.maxJumpHeightMeters! * 4.5).toStringAsFixed(0)} m',
      if (jumpMetrics.jumpHeightDistribution != null)
        'distribucion_alturas': jumpMetrics.jumpHeightDistribution!,
      if (jumpMetrics.averageTakeoffSpeedKnots != null)
        'takeoff_speed':
            '${jumpMetrics.averageTakeoffSpeedKnots!.toStringAsFixed(1)} kt',
      if (jumpMetrics.averageLandingSpeedKnots != null)
        'landing_speed':
            '${jumpMetrics.averageLandingSpeedKnots!.toStringAsFixed(1)} kt',
      if (jumpMetrics.cleanLandingRate != null)
        'clean_landing_rate':
            '${jumpMetrics.cleanLandingRate!.toStringAsFixed(0)}%',
      if (jumpMetrics.impactScore != null)
        'impact_score': '${jumpMetrics.impactScore!.toStringAsFixed(1)} G',
      'variabilidad_velocidad': timelineSamples.length >= 2
          ? '${(timelineSamples.last - timelineSamples.first).toStringAsFixed(1)} kt'
          : '0.0 kt',
      'estabilidad_direccional':
          '${trackMetrics.directionalStabilityPercent.toStringAsFixed(0)}%',
      'calidad_jibe': transitionSummary.count > 0
          ? '${transitionSummary.qualityPercent.toStringAsFixed(0)}%'
          : '0%',
      'perdida_vel_transiciones': transitionSummary.avgSpeedLossKnots > 0
          ? '${transitionSummary.avgSpeedLossKnots.toStringAsFixed(1)} kt'
          : '0.0 kt',
      'recuperacion_planeo': transitionSummary.avgRecoverySeconds > 0
          ? '${transitionSummary.avgRecoverySeconds.toStringAsFixed(1)} s'
          : '0.0 s',
      'smoothness_score': timelineSamples.length >= 2
          ? '${(10 - (timelineSamples.last - timelineSamples.first).clamp(0, 10) / 2).toStringAsFixed(1)}/10'
          : '10.0/10',
      'caidas_hora': input.duration.inSeconds <= 0
          ? '0.0'
          : (input.accelerationEventCount / (input.duration.inSeconds / 3600))
                .toStringAsFixed(1),
      'eventos_sobrepotencia': '${input.rotationEventCount}',
      'distancia_max_costa':
          '${trackMetrics.maxDistanceFromStartKm.toStringAsFixed(2)} km',
      'tiempo_zona_riesgo': _formatDuration(trackMetrics.timeInRiskZone),
      'calidad_gps': input.lastGpsAccuracyMeters == null
          ? '--'
          : '${input.lastGpsAccuracyMeters!.toStringAsFixed(1)} m',
      'samples_perdidos':
          '${trackMetrics.lostSamplesPercent.toStringAsFixed(0)}%',
      'latencia_sync': trackMetrics.averageSampleIntervalSeconds > 0
          ? '${trackMetrics.averageSampleIntervalSeconds.toStringAsFixed(1)} s'
          : '--',
      'health_dataset':
          '${trackMetrics.datasetHealthPercent.toStringAsFixed(0)}%',
      'session_score': '${sessionScore.toStringAsFixed(0)}/100',
      if (bigAirScore != null)
        'big_air_score': '${bigAirScore.toStringAsFixed(0)}/100',
      'freeride_score': '${freerideScore.toStringAsFixed(0)}/100',
      'safety_score': '${safetyScore.toStringAsFixed(0)}/100',
    };

    return SessionRecordedMetricsSummaryResult(
      distanceKm: distanceKm,
      avgSpeedKnots: avgSpeedKnots,
      movingAvgSpeedKnots: movingAvgSpeedKnots,
      planingMinutes: planingMinutes,
      jumpsCount: jumpsCount,
      maxJumpHeightMeters: jumpMetrics.maxJumpHeightMeters,
      maxHangtimeSeconds: jumpMetrics.maxHangtimeSeconds,
      measuredValues: measuredValues,
    );
  }

  static RecordedSession build(RecordedSessionBuilderInput input) {
    final insights = SessionInsightData(
      deviceKind: input.deviceKind,
      deviceSensorKeys: input.deviceSensorKeys,
      jumpDetectionMode: input.jumpDetectionMode,
      distanceKm: null,
      maxSpeedKnots: null,
      avgSpeedKnots: null,
      movingAvgSpeedKnots: null,
      planingMinutes: null,
      recordedPointCount: input.recordedPointCount,
      autoPauseCount: input.autoPauseCount,
      accelerationEventCount: input.accelerationEventCount,
      rotationEventCount: input.rotationEventCount,
      maxAccelerationG: null,
      maxRotationDegPerSec: input.maxRotationDegPerSec,
      batteryStart: null,
      batteryEnd: null,
      jumpsCount: null,
      maxJumpHeightMeters: null,
      maxHangtimeSeconds: null,
      jumpHistory: List<SessionJumpRecord>.unmodifiable(input.jumpHistory),
      timelineKnots: List<double>.unmodifiable(input.timelineKnots),
      routePoints: List<SessionTrackPoint>.unmodifiable(input.routePoints),
      events: _buildDetectedEvents(
        pointCount: input.eventPointCount,
        maxSpeedKnots: input.eventMaxSpeedKnots,
        autoPauseCount: input.autoPauseCount,
        accelerationEventCount: input.accelerationEventCount,
        rotationEventCount: input.rotationEventCount,
      ),
      advancedMetrics: SessionAdvancedMetrics(
        groups: SessionInsightData.buildGroupsForRecordedSession(
          values: input.measuredValues,
        ),
      ),
    );

    return RecordedSession(
      id: input.id,
      title: input.title,
      deviceName: input.deviceName,
      endedAt: input.endedAt,
      duration: input.duration,
      summary: input.config.notes.isEmpty
          ? 'Sesion real grabada con el telefono.'
          : input.config.notes,
      gearSetupId: input.config.gearSetupId,
      gearSetupName: input.config.gearSetupName,
      hasSessionPhoto: input.config.sessionPhotoLocalPath != null,
      sessionMediaLabel: input.config.sessionMediaLabel,
      sessionPhotoLocalPath: input.config.sessionPhotoLocalPath,
      spotName: input.config.spot,
      insights: insights,
    );
  }

  static RecordedSession buildImportedSession(
    ImportedRecordedSessionBuilderInput input,
  ) {
    final highestJump = input.imported.jumpHistory
        .map((jump) => jump.heightMeters)
        .where((height) => height > 0)
        .fold<double?>(null, (prev, h) => prev == null ? h : math.max(prev, h));
    final highestHangtime = input.imported.jumpHistory
        .map((jump) => jump.hangtimeSeconds)
        .fold<double?>(null, (prev, t) => prev == null ? t : math.max(prev, t));

    final insights =
        SessionInsightData.empty(
          deviceKind: input.deviceKind,
          deviceSensorKeys: SessionInsightData.physicalSensorsForDeviceKind(
            input.deviceKind,
          ).toList(growable: false),
          events: ['Sesión sincronizada desde dispositivo ${input.deviceName}'],
        ).copyWith(
          jumpHistory: input.imported.jumpHistory,
          advancedMetrics: SessionAdvancedMetrics(
            groups: SessionInsightData.buildGroupsForRecordedSession(
              values: {
                'saltos_totales': '${input.imported.jumpHistory.length}',
                if (highestJump != null)
                  'salto_mas_alto': '${highestJump.toStringAsFixed(1)} m',
                if (highestHangtime != null)
                  'hangtime_max': '${highestHangtime.toStringAsFixed(1)} s',
              },
            ),
          ),
        );

    return RecordedSession(
      id: input.id,
      title: input.imported.title,
      deviceName: input.deviceName,
      endedAt: input.imported.endedAt,
      duration: input.imported.duration,
      summary: input.config.notes.isEmpty
          ? input.imported.summary
          : input.config.notes,
      gearSetupId: input.config.gearSetupId,
      gearSetupName: input.config.gearSetupName,
      hasSessionPhoto: input.config.sessionPhotoLocalPath != null,
      sessionMediaLabel: input.config.sessionMediaLabel,
      sessionPhotoLocalPath: input.config.sessionPhotoLocalPath,
      spotName: input.config.spot,
      insights: insights,
    );
  }

  static RecordedSession buildEditedSession(
    EditedRecordedSessionBuilderInput input,
  ) {
    return RecordedSession(
      id: input.baseSession.id,
      title: input.baseSession.title,
      deviceName: input.baseSession.deviceName,
      endedAt: input.baseSession.endedAt,
      duration: input.baseSession.duration,
      summary: input.notes,
      gearSetupId: input.gearSetupId,
      gearSetupName: input.gearSetupName,
      hasSessionPhoto: input.sessionPhotoLocalPath != null,
      sessionMediaLabel: input.sessionMediaLabel,
      sessionPhotoLocalPath: input.sessionPhotoLocalPath,
      spotName: input.baseSession.spotName,
      insights: input.baseSession.insights,
    );
  }

  static List<String> _buildDetectedEvents({
    required int pointCount,
    required double maxSpeedKnots,
    required int autoPauseCount,
    required int accelerationEventCount,
    required int rotationEventCount,
  }) {
    final events = <String>[
      'Sesión real grabada con el GPS del teléfono',
      'Track validado con $pointCount puntos GPS',
    ];
    if (autoPauseCount > 0) {
      events.add('$autoPauseCount auto-pausas detectadas');
    }
    if (accelerationEventCount > 0) {
      events.add('$accelerationEventCount aceleraciones bruscas detectadas');
    }
    if (rotationEventCount > 0) {
      events.add('$rotationEventCount giros bruscos detectados');
    }
    if (maxSpeedKnots > 0) {
      events.add(
        'Punta máxima registrada: ${maxSpeedKnots.toStringAsFixed(1)} kt',
      );
    }
    return events;
  }

  static _JumpMetrics _buildJumpMetrics({
    required List<SessionJumpRecord> jumpHistory,
    required Duration duration,
  }) {
    if (jumpHistory.isEmpty) {
      return const _JumpMetrics();
    }
    final heightSamples = jumpHistory
        .map((jump) => jump.heightMeters)
        .where((height) => height > 0)
        .toList(growable: false);
    final maxJumpHeightMeters = heightSamples.isEmpty
        ? null
        : heightSamples.reduce(math.max);
    final maxHangtimeSeconds = jumpHistory
        .map((jump) => jump.hangtimeSeconds)
        .reduce(math.max);
    final avgJumpHeightMeters = heightSamples.isEmpty
        ? null
        : heightSamples.reduce((a, b) => a + b) / heightSamples.length;
    final top5AverageJumpMeters = heightSamples.isEmpty
        ? null
        : ((List<double>.from(heightSamples)..sort((a, b) => b.compareTo(a)))
                  .take(5)
                  .reduce((a, b) => a + b) /
              math.min(5, heightSamples.length));
    final hangtimeValues =
        jumpHistory.map((jump) => jump.hangtimeSeconds).toList(growable: false)
          ..sort();
    final hangtimeP95Seconds =
        hangtimeValues[((hangtimeValues.length - 1) * 0.95).floor()];
    final takeoffSpeedKnots = jumpHistory
        .map((jump) => jump.takeoffSpeedKnots)
        .whereType<double>()
        .toList(growable: false);
    final landingSpeedKnots = jumpHistory
        .map((jump) => jump.landingSpeedKnots)
        .whereType<double>()
        .toList(growable: false);
    final landingGs = jumpHistory
        .map((jump) => jump.landingG)
        .toList(growable: false);
    final cleanLandingRate =
        (landingGs.where((value) => value <= 2.4).length / landingGs.length) *
        100;
    final impactScore = landingGs.reduce((a, b) => a + b) / landingGs.length;
    final jumpCadencePerHour = duration.inSeconds <= 0
        ? null
        : jumpHistory.length / (duration.inSeconds / 3600);
    final jumpHeightSpread = heightSamples.length < 2
        ? null
        : heightSamples.reduce(math.max) - heightSamples.reduce(math.min);
    final jumpHeightConsistency =
        jumpHeightSpread == null || avgJumpHeightMeters == null
        ? null
        : math
              .max(
                0.0,
                100 -
                    ((jumpHeightSpread / math.max(avgJumpHeightMeters, 0.1)) *
                            100)
                        .clamp(0, 100),
              )
              .toDouble();
    final averageTakeoffSpeedKnots = takeoffSpeedKnots.isEmpty
        ? null
        : takeoffSpeedKnots.reduce((a, b) => a + b) / takeoffSpeedKnots.length;
    final averageLandingSpeedKnots = landingSpeedKnots.isEmpty
        ? null
        : landingSpeedKnots.reduce((a, b) => a + b) / landingSpeedKnots.length;
    final jumpWindEfficiency =
        maxJumpHeightMeters == null ||
            averageTakeoffSpeedKnots == null ||
            averageTakeoffSpeedKnots <= 0
        ? null
        : (maxJumpHeightMeters / averageTakeoffSpeedKnots) * 10;
    final jumpHeightDistribution = heightSamples.isEmpty
        ? null
        : '${heightSamples.where((value) => value < 3).length}/'
              '${heightSamples.where((value) => value >= 3 && value < 6).length}/'
              '${heightSamples.where((value) => value >= 6).length}';

    return _JumpMetrics(
      maxJumpHeightMeters: maxJumpHeightMeters,
      maxHangtimeSeconds: maxHangtimeSeconds,
      avgJumpHeightMeters: avgJumpHeightMeters,
      top5AverageJumpMeters: top5AverageJumpMeters,
      hangtimeP95Seconds: hangtimeP95Seconds,
      cleanLandingRate: cleanLandingRate,
      impactScore: impactScore,
      jumpCadencePerHour: jumpCadencePerHour,
      jumpHeightConsistency: jumpHeightConsistency,
      averageTakeoffSpeedKnots: averageTakeoffSpeedKnots,
      averageLandingSpeedKnots: averageLandingSpeedKnots,
      jumpWindEfficiency: jumpWindEfficiency,
      jumpHeightDistribution: jumpHeightDistribution,
    );
  }

  static String _formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) {
      return '$h:$m:$s';
    }
    return '$m:$s';
  }
}

class _JumpMetrics {
  const _JumpMetrics({
    this.maxJumpHeightMeters,
    this.maxHangtimeSeconds,
    this.avgJumpHeightMeters,
    this.top5AverageJumpMeters,
    this.hangtimeP95Seconds,
    this.cleanLandingRate,
    this.impactScore,
    this.jumpCadencePerHour,
    this.jumpHeightConsistency,
    this.averageTakeoffSpeedKnots,
    this.averageLandingSpeedKnots,
    this.jumpWindEfficiency,
    this.jumpHeightDistribution,
  });

  final double? maxJumpHeightMeters;
  final double? maxHangtimeSeconds;
  final double? avgJumpHeightMeters;
  final double? top5AverageJumpMeters;
  final double? hangtimeP95Seconds;
  final double? cleanLandingRate;
  final double? impactScore;
  final double? jumpCadencePerHour;
  final double? jumpHeightConsistency;
  final double? averageTakeoffSpeedKnots;
  final double? averageLandingSpeedKnots;
  final double? jumpWindEfficiency;
  final String? jumpHeightDistribution;
}
