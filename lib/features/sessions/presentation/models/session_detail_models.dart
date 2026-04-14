import 'session_advanced_metrics_models.dart';

export 'session_advanced_metrics_models.dart';

class SessionInsightData {
  const SessionInsightData({
    required this.deviceKind,
    required this.deviceSensorKeys,
    required this.jumpDetectionMode,
    required this.distanceKm,
    required this.maxSpeedKnots,
    required this.avgSpeedKnots,
    required this.movingAvgSpeedKnots,
    required this.planingMinutes,
    required this.recordedPointCount,
    required this.autoPauseCount,
    required this.accelerationEventCount,
    required this.rotationEventCount,
    required this.maxAccelerationG,
    required this.maxRotationDegPerSec,
    required this.batteryStart,
    required this.batteryEnd,
    required this.jumpsCount,
    required this.maxJumpHeightMeters,
    required this.maxHangtimeSeconds,
    required this.jumpHistory,
    required this.timelineKnots,
    required this.routePoints,
    required this.events,
    required this.advancedMetrics,
  });

  final String? deviceKind;
  final List<String> deviceSensorKeys;
  final String jumpDetectionMode;

  // Legacy compatibility fields.
  // Prefer reading derived metrics from `advancedMetrics` via `kpiValue(...)`.
  // These remain temporarily to keep old sessions and transition flows working
  // while the app finishes migrating to Advanced Metrics as the single source.
  final double? distanceKm;
  final double? maxSpeedKnots;
  final double? avgSpeedKnots;
  final double? movingAvgSpeedKnots;
  final int? planingMinutes;
  final int? recordedPointCount;
  final int? autoPauseCount;
  final int? accelerationEventCount;
  final int? rotationEventCount;
  final double? maxAccelerationG;
  final double? maxRotationDegPerSec;
  final int? batteryStart;
  final int? batteryEnd;
  final int? jumpsCount;
  final double? maxJumpHeightMeters;
  final double? maxHangtimeSeconds;

  // Session source data. These are not Advanced Metrics; they are inputs or
  // event collections used by the metrics engine.
  final List<SessionJumpRecord> jumpHistory;
  final List<double> timelineKnots;
  final List<SessionTrackPoint> routePoints;
  final List<String> events;
  final SessionAdvancedMetrics advancedMetrics;

  List<SessionKpiGroup> get groups => advancedMetrics.groups;

  bool get hasLegacyMetricSnapshot =>
      distanceKm != null ||
      maxSpeedKnots != null ||
      avgSpeedKnots != null ||
      movingAvgSpeedKnots != null ||
      planingMinutes != null ||
      jumpsCount != null ||
      maxJumpHeightMeters != null ||
      maxHangtimeSeconds != null;

  bool get hasAdvancedMetrics => advancedMetrics.groups.isNotEmpty;

  double? get resolvedDistanceKm =>
      advancedMetrics.doubleValue(SessionMetricKeys.distanceTotal) ??
      distanceKm;

  double? get resolvedMaxSpeedKnots =>
      advancedMetrics.doubleValue(SessionMetricKeys.maxSpeed) ?? maxSpeedKnots;

  double? get resolvedAvgSpeedKnots =>
      advancedMetrics.doubleValue(SessionMetricKeys.avgSpeed) ?? avgSpeedKnots;

  double? get resolvedMovingAvgSpeedKnots => movingAvgSpeedKnots;

  int? get resolvedPlaningMinutes => planingMinutes;

  int? get resolvedJumpsCount =>
      advancedMetrics.intValue(SessionMetricKeys.totalJumps) ?? jumpsCount;

  double? get resolvedMaxJumpHeightMeters =>
      advancedMetrics.doubleValue(SessionMetricKeys.highestJump) ??
      maxJumpHeightMeters;

  double? get resolvedMaxHangtimeSeconds =>
      advancedMetrics.doubleValue(SessionMetricKeys.maxHangtime) ??
      maxHangtimeSeconds;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'deviceKind': deviceKind,
      'deviceSensorKeys': deviceSensorKeys,
      'jumpDetectionMode': jumpDetectionMode,
      'distanceKm': distanceKm,
      'maxSpeedKnots': maxSpeedKnots,
      'avgSpeedKnots': avgSpeedKnots,
      'movingAvgSpeedKnots': movingAvgSpeedKnots,
      'planingMinutes': planingMinutes,
      'recordedPointCount': recordedPointCount,
      'autoPauseCount': autoPauseCount,
      'accelerationEventCount': accelerationEventCount,
      'rotationEventCount': rotationEventCount,
      'maxAccelerationG': maxAccelerationG,
      'maxRotationDegPerSec': maxRotationDegPerSec,
      'batteryStart': batteryStart,
      'batteryEnd': batteryEnd,
      'jumpsCount': jumpsCount,
      'maxJumpHeightMeters': maxJumpHeightMeters,
      'maxHangtimeSeconds': maxHangtimeSeconds,
      'jumpHistory': jumpHistory
          .map((entry) => entry.toJson())
          .toList(growable: false),
      'timelineKnots': timelineKnots,
      'routePoints': routePoints
          .map((entry) => entry.toJson())
          .toList(growable: false),
      'events': events,
      'advancedMetrics': advancedMetrics.toJson(),
      'groups': advancedMetrics.groups
          .map((entry) => entry.toJson())
          .toList(growable: false),
    };
  }

  static SessionInsightData fromJson(Map<String, dynamic> json) {
    return SessionInsightData(
      deviceKind: json['deviceKind'] as String?,
      deviceSensorKeys: (json['deviceSensorKeys'] as List<dynamic>? ?? const [])
          .map((entry) => entry.toString())
          .toList(growable: false),
      jumpDetectionMode:
          json['jumpDetectionMode'] as String? ?? 'inertial_fallback',
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      maxSpeedKnots: (json['maxSpeedKnots'] as num?)?.toDouble(),
      avgSpeedKnots: (json['avgSpeedKnots'] as num?)?.toDouble(),
      movingAvgSpeedKnots: (json['movingAvgSpeedKnots'] as num?)?.toDouble(),
      planingMinutes: (json['planingMinutes'] as num?)?.toInt(),
      recordedPointCount: (json['recordedPointCount'] as num?)?.toInt(),
      autoPauseCount: (json['autoPauseCount'] as num?)?.toInt(),
      accelerationEventCount: (json['accelerationEventCount'] as num?)?.toInt(),
      rotationEventCount: (json['rotationEventCount'] as num?)?.toInt(),
      maxAccelerationG: (json['maxAccelerationG'] as num?)?.toDouble(),
      maxRotationDegPerSec: (json['maxRotationDegPerSec'] as num?)?.toDouble(),
      batteryStart: (json['batteryStart'] as num?)?.toInt(),
      batteryEnd: (json['batteryEnd'] as num?)?.toInt(),
      jumpsCount: (json['jumpsCount'] as num?)?.toInt(),
      maxJumpHeightMeters: (json['maxJumpHeightMeters'] as num?)?.toDouble(),
      maxHangtimeSeconds: (json['maxHangtimeSeconds'] as num?)?.toDouble(),
      jumpHistory: (json['jumpHistory'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SessionJumpRecord.fromJson)
          .toList(growable: false),
      timelineKnots: (json['timelineKnots'] as List<dynamic>? ?? const [])
          .whereType<num>()
          .map((entry) => entry.toDouble())
          .toList(growable: false),
      routePoints: (json['routePoints'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SessionTrackPoint.fromJson)
          .toList(growable: false),
      events: (json['events'] as List<dynamic>? ?? const [])
          .map((entry) => entry.toString())
          .toList(growable: false),
      advancedMetrics: SessionAdvancedMetrics.fromJson(
        json['advancedMetrics'] as Map<String, dynamic>? ??
            <String, dynamic>{'groups': json['groups']},
      ),
    );
  }

  SessionInsightData copyWith({
    String? deviceKind,
    List<String>? deviceSensorKeys,
    String? jumpDetectionMode,
    double? distanceKm,
    double? maxSpeedKnots,
    double? avgSpeedKnots,
    double? movingAvgSpeedKnots,
    int? planingMinutes,
    int? recordedPointCount,
    int? autoPauseCount,
    int? accelerationEventCount,
    int? rotationEventCount,
    double? maxAccelerationG,
    double? maxRotationDegPerSec,
    int? batteryStart,
    int? batteryEnd,
    int? jumpsCount,
    double? maxJumpHeightMeters,
    double? maxHangtimeSeconds,
    List<SessionJumpRecord>? jumpHistory,
    List<double>? timelineKnots,
    List<SessionTrackPoint>? routePoints,
    List<String>? events,
    SessionAdvancedMetrics? advancedMetrics,
  }) {
    return SessionInsightData(
      deviceKind: deviceKind ?? this.deviceKind,
      deviceSensorKeys: deviceSensorKeys ?? this.deviceSensorKeys,
      jumpDetectionMode: jumpDetectionMode ?? this.jumpDetectionMode,
      distanceKm: distanceKm ?? this.distanceKm,
      maxSpeedKnots: maxSpeedKnots ?? this.maxSpeedKnots,
      avgSpeedKnots: avgSpeedKnots ?? this.avgSpeedKnots,
      movingAvgSpeedKnots: movingAvgSpeedKnots ?? this.movingAvgSpeedKnots,
      planingMinutes: planingMinutes ?? this.planingMinutes,
      recordedPointCount: recordedPointCount ?? this.recordedPointCount,
      autoPauseCount: autoPauseCount ?? this.autoPauseCount,
      accelerationEventCount:
          accelerationEventCount ?? this.accelerationEventCount,
      rotationEventCount: rotationEventCount ?? this.rotationEventCount,
      maxAccelerationG: maxAccelerationG ?? this.maxAccelerationG,
      maxRotationDegPerSec: maxRotationDegPerSec ?? this.maxRotationDegPerSec,
      batteryStart: batteryStart ?? this.batteryStart,
      batteryEnd: batteryEnd ?? this.batteryEnd,
      jumpsCount: jumpsCount ?? this.jumpsCount,
      maxJumpHeightMeters: maxJumpHeightMeters ?? this.maxJumpHeightMeters,
      maxHangtimeSeconds: maxHangtimeSeconds ?? this.maxHangtimeSeconds,
      jumpHistory: jumpHistory ?? this.jumpHistory,
      timelineKnots: timelineKnots ?? this.timelineKnots,
      routePoints: routePoints ?? this.routePoints,
      events: events ?? this.events,
      advancedMetrics: advancedMetrics ?? this.advancedMetrics,
    );
  }

  static const List<String> capabilityOrder = [
    'gps',
    'speed',
    'motion',
    'altitude',
    'heart_rate',
    'barometer',
    'battery',
    'network',
    'weather',
  ];

  static const Map<String, String> capabilityLabels = {
    'gps': 'GPS',
    'speed': 'Velocidad',
    'motion': 'Movimiento',
    'altitude': 'Altitud',
    'heart_rate': 'Ritmo cardíaco',
    'barometer': 'Barómetro',
    'battery': 'Batería',
    'network': 'Conectividad',
    'weather': 'Meteo',
  };

  static const List<String> physicalSensorOrder = [
    'gps',
    'accelerometer',
    'gyroscope',
    'magnetometer',
    'heart_rate',
    'barometer',
  ];

  static const Map<String, String> physicalSensorLabels = {
    'gps': 'GPS',
    'accelerometer': 'Acelerómetro',
    'gyroscope': 'Giroscopio',
    'magnetometer': 'Magnetómetro',
    'heart_rate': 'Ritmo cardíaco',
    'barometer': 'Barómetro',
  };

  static const List<String> derivedCapabilityOrder = [
    'speed',
    'altitude',
    'orientation',
    'motion_analysis',
    'jump_detection_inertial',
    'jump_detection_barometric',
  ];

  static const Map<String, String> derivedCapabilityLabels = {
    'speed': 'Velocidad derivada',
    'altitude': 'Altitud derivada',
    'orientation': 'Orientación calculada',
    'motion_analysis': 'Análisis de movimiento',
    'jump_detection_inertial': 'Detección de saltos inercial',
    'jump_detection_barometric': 'Apoyo barométrico para saltos',
  };

  static Set<String> derivedCapabilitiesForPhysicalSensors(
    Iterable<String> sensorKeys,
  ) {
    final sensors = sensorKeys.toSet();
    final capabilities = <String>{};

    if (sensors.contains('gps')) {
      capabilities.add('speed');
      capabilities.add('altitude');
    }
    if (sensors.contains('barometer')) {
      capabilities.add('altitude');
      capabilities.add('jump_detection_barometric');
    }
    if (sensors.contains('accelerometer') && sensors.contains('gyroscope')) {
      capabilities.add('motion_analysis');
      capabilities.add('jump_detection_inertial');
    }
    if (sensors.contains('accelerometer') &&
        sensors.contains('gyroscope') &&
        sensors.contains('magnetometer')) {
      capabilities.add('orientation');
    }

    return capabilities;
  }

  static List<String> practicalUseCasesForPhysicalSensors(
    Iterable<String> sensorKeys,
  ) {
    final sensors = sensorKeys.toSet();
    final items = <String>[];

    if (sensors.contains('gps')) {
      items.add('Puede registrar track y velocidad por GPS.');
    }
    if (sensors.contains('heart_rate')) {
      items.add(
        'Puede registrar pulso si el dispositivo lo expone durante la sesion.',
      );
    }
    if (sensors.contains('barometer')) {
      items.add(
        'Tiene fuente vertical valida para apoyar la medicion barometrica del salto.',
      );
    }
    if (sensors.contains('accelerometer') && sensors.contains('gyroscope')) {
      items.add(
        'Puede analizar movimiento y maniobras con sensores inerciales.',
      );
    }
    if (items.isEmpty) {
      items.add('Todavia no sabemos que puede aportar a la sesion.');
    }

    return items;
  }

  static String jumpDetectionModeForDevice({
    required String deviceKind,
    Iterable<String>? sensorKeys,
    String? placement,
  }) {
    final normalizedKind = deviceKind.toLowerCase();
    final resolvedPlacement = (placement ?? '').toLowerCase();
    final sensors = (sensorKeys ?? physicalSensorsForDeviceKind(deviceKind)).toSet();
    final boardLike =
        resolvedPlacement == 'board' ||
        normalizedKind.contains('woo') ||
        normalizedKind.contains('surfr') ||
        normalizedKind.contains('tabla');
    if (boardLike) {
      return 'board_imu';
    }
    if (sensors.contains('accelerometer') && sensors.contains('gyroscope')) {
      return 'body_imu';
    }
    return 'body_imu';
  }

  static SessionInsightData empty({
    required String deviceKind,
    List<String>? deviceSensorKeys,
    List<String>? events,
  }) {
    return SessionInsightData(
      deviceKind: deviceKind,
      deviceSensorKeys:
          deviceSensorKeys ??
          physicalSensorsForDeviceKind(deviceKind).toList(growable: false),
      jumpDetectionMode: jumpDetectionModeForDevice(
        deviceKind: deviceKind,
        sensorKeys: deviceSensorKeys ?? physicalSensorsForDeviceKind(deviceKind),
      ),
      distanceKm: null,
      maxSpeedKnots: null,
      avgSpeedKnots: null,
      movingAvgSpeedKnots: null,
      planingMinutes: null,
      recordedPointCount: null,
      autoPauseCount: null,
      accelerationEventCount: null,
      rotationEventCount: null,
      maxAccelerationG: null,
      maxRotationDegPerSec: null,
      batteryStart: null,
      batteryEnd: null,
      jumpsCount: null,
      maxJumpHeightMeters: null,
      maxHangtimeSeconds: null,
      jumpHistory: const <SessionJumpRecord>[],
      timelineKnots: const <double>[],
      routePoints: const <SessionTrackPoint>[],
      events: events ?? const <String>[],
      advancedMetrics: SessionAdvancedMetrics(
        groups: buildGroupsForRecordedSession(values: const <String, String>{}),
      ),
    );
  }

  static List<SessionKpiGroup> buildGroupsForRecordedSession({
    required Map<String, String> values,
  }) {
    return buildRecordedSessionKpiGroups(values: values);
  }

  SessionKpiItem? kpiByKey(String key) => advancedMetrics.kpiByKey(key);

  String? kpiValue(String key) => advancedMetrics.kpiValue(key);

  static Set<String> physicalSensorsForDeviceKind(String kind) {
    switch (kind) {
      case 'Android':
      case 'Dispositivo Android':
        return {'gps', 'accelerometer', 'gyroscope', 'magnetometer'};
      case 'iPhone':
        return {'gps', 'accelerometer', 'gyroscope', 'magnetometer'};
      case 'Apple Watch':
      case 'Smartwatch':
        return {'gps', 'accelerometer', 'gyroscope', 'heart_rate', 'barometer'};
      case 'Woo Sports':
      case 'SurfR':
      case 'Sensor de tabla':
        return {'gps', 'accelerometer', 'gyroscope'};
      default:
        return {'gps', 'accelerometer', 'gyroscope'};
    }
  }
}

class SessionTrackPoint {
  const SessionTrackPoint({
    required this.latitude,
    required this.longitude,
    required this.speedKnots,
    required this.recordedAt,
  });

  final double latitude;
  final double longitude;
  final double speedKnots;
  final DateTime recordedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'speedKnots': speedKnots,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  static SessionTrackPoint fromJson(Map<String, dynamic> json) {
    return SessionTrackPoint(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      speedKnots: (json['speedKnots'] as num?)?.toDouble() ?? 0,
      recordedAt:
          DateTime.tryParse(json['recordedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class SessionJumpRecord {
  const SessionJumpRecord({
    required this.index,
    required this.heightMeters,
    required this.hangtimeSeconds,
    required this.landingG,
    required this.recordedAt,
    this.mountType = 'body',
    this.measurementMode = 'body_imu',
    this.measurementConfidence,
    this.peakHeightMeters,
    this.takeoffHeightMeters,
    this.barometricHeightMeters,
    this.barometricPeakHeightMeters,
    this.barometricTakeoffHeightMeters,
    this.heightDeltaMeters,
    this.heightDeltaPercent,
    this.approachHeadingDeg,
    this.approachCourseDeg,
    this.approachWindOffsetDeg,
    this.edgeAngleDeg,
    this.maneuverG,
    this.maneuverRotationDegPerSec,
    this.fallSpeedMetersPerSecond,
    this.takeoffSpeedKnots,
    this.landingSpeedKnots,
  });

  final int index;
  final double heightMeters;
  final double hangtimeSeconds;
  final double landingG;
  final Duration recordedAt;
  final String mountType;
  final String measurementMode;
  final double? measurementConfidence;
  final double? peakHeightMeters;
  final double? takeoffHeightMeters;
  final double? barometricHeightMeters;
  final double? barometricPeakHeightMeters;
  final double? barometricTakeoffHeightMeters;
  final double? heightDeltaMeters;
  final double? heightDeltaPercent;
  final double? approachHeadingDeg;
  final double? approachCourseDeg;
  final double? approachWindOffsetDeg;
  final double? edgeAngleDeg;
  final double? maneuverG;
  final double? maneuverRotationDegPerSec;
  final double? fallSpeedMetersPerSecond;
  final double? takeoffSpeedKnots;
  final double? landingSpeedKnots;

  int get jumpNumber => index;

  String get timeLabel {
    final totalSeconds = recordedAt.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'index': index,
      'jumpNumber': jumpNumber,
      'heightMeters': heightMeters,
      'hangtimeSeconds': hangtimeSeconds,
      'landingG': landingG,
      'recordedAtSeconds': recordedAt.inSeconds,
      'mountType': mountType,
      'measurementMode': measurementMode,
      'measurementConfidence': measurementConfidence,
      'peakHeightMeters': peakHeightMeters,
      'takeoffHeightMeters': takeoffHeightMeters,
      'barometricHeightMeters': barometricHeightMeters,
      'barometricPeakHeightMeters': barometricPeakHeightMeters,
      'barometricTakeoffHeightMeters': barometricTakeoffHeightMeters,
      'heightDeltaMeters': heightDeltaMeters,
      'heightDeltaPercent': heightDeltaPercent,
      'approachHeadingDeg': approachHeadingDeg,
      'approachCourseDeg': approachCourseDeg,
      'approachWindOffsetDeg': approachWindOffsetDeg,
      'edgeAngleDeg': edgeAngleDeg,
      'maneuverG': maneuverG,
      'maneuverRotationDegPerSec': maneuverRotationDegPerSec,
      'fallSpeedMetersPerSecond': fallSpeedMetersPerSecond,
      'takeoffSpeedKnots': takeoffSpeedKnots,
      'landingSpeedKnots': landingSpeedKnots,
      'timeLabel': timeLabel,
    };
  }

  static SessionJumpRecord fromJson(Map<String, dynamic> json) {
    return SessionJumpRecord(
      index:
          (json['index'] as num?)?.toInt() ??
          (json['jumpNumber'] as num?)?.toInt() ??
          0,
      heightMeters: (json['heightMeters'] as num?)?.toDouble() ?? 0,
      hangtimeSeconds: (json['hangtimeSeconds'] as num?)?.toDouble() ?? 0,
      landingG: (json['landingG'] as num?)?.toDouble() ?? 0,
      recordedAt: Duration(
        seconds: (json['recordedAtSeconds'] as num?)?.toInt() ?? 0,
      ),
      mountType: (json['mountType'] as String?)?.trim().isNotEmpty == true
          ? (json['mountType'] as String).trim()
          : 'body',
      measurementMode:
          (json['measurementMode'] as String?)?.trim().isNotEmpty == true
          ? (json['measurementMode'] as String).trim()
          : 'body_imu',
      measurementConfidence: (json['measurementConfidence'] as num?)
          ?.toDouble(),
      peakHeightMeters: (json['peakHeightMeters'] as num?)?.toDouble(),
      takeoffHeightMeters: (json['takeoffHeightMeters'] as num?)?.toDouble(),
      barometricHeightMeters:
          (json['barometricHeightMeters'] as num?)?.toDouble(),
      barometricPeakHeightMeters:
          (json['barometricPeakHeightMeters'] as num?)?.toDouble(),
      barometricTakeoffHeightMeters:
          (json['barometricTakeoffHeightMeters'] as num?)?.toDouble(),
      heightDeltaMeters: (json['heightDeltaMeters'] as num?)?.toDouble(),
      heightDeltaPercent: (json['heightDeltaPercent'] as num?)?.toDouble(),
      approachHeadingDeg: (json['approachHeadingDeg'] as num?)?.toDouble(),
      approachCourseDeg: (json['approachCourseDeg'] as num?)?.toDouble(),
      approachWindOffsetDeg:
          (json['approachWindOffsetDeg'] as num?)?.toDouble(),
      edgeAngleDeg: (json['edgeAngleDeg'] as num?)?.toDouble(),
      maneuverG: (json['maneuverG'] as num?)?.toDouble(),
      maneuverRotationDegPerSec: (json['maneuverRotationDegPerSec'] as num?)
          ?.toDouble(),
      fallSpeedMetersPerSecond: (json['fallSpeedMetersPerSecond'] as num?)
          ?.toDouble(),
      takeoffSpeedKnots: (json['takeoffSpeedKnots'] as num?)?.toDouble(),
      landingSpeedKnots: (json['landingSpeedKnots'] as num?)?.toDouble(),
    );
  }
}
