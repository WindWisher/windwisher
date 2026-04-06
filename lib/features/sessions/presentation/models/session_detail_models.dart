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
    required this.groups,
  });

  final String? deviceKind;
  final List<String> deviceSensorKeys;
  final String jumpDetectionMode;
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
  final List<SessionJumpRecord> jumpHistory;
  final List<double> timelineKnots;
  final List<SessionTrackPoint> routePoints;
  final List<String> events;
  final List<SessionKpiGroup> groups;

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
      'groups': groups.map((entry) => entry.toJson()).toList(growable: false),
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
      groups: (json['groups'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SessionKpiGroup.fromJson)
          .toList(growable: false),
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
    List<SessionKpiGroup>? groups,
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
      groups: groups ?? this.groups,
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
    'jump_detection_barometric': 'Detección de saltos barométrica',
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

  static String jumpDetectionModeForSensors(Iterable<String> sensorKeys) {
    final sensors = sensorKeys.toSet();
    if (sensors.contains('barometer')) {
      return 'barometric';
    }
    return 'inertial_fallback';
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
      jumpDetectionMode: jumpDetectionModeForSensors(
        deviceSensorKeys ?? physicalSensorsForDeviceKind(deviceKind),
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
      groups: buildGroupsForRecordedSession(values: const <String, String>{}),
    );
  }

  static List<SessionKpiGroup> buildGroupsForRecordedSession({
    required Map<String, String> values,
  }) {
    return _buildKpiGroups(
      values: values,
      availabilityForKey: (key, required) => values.containsKey(key),
    );
  }

  static SessionKpiItem _item(
    Map<String, String> values,
    String key,
    bool available,
  ) {
    return SessionKpiItem(
      label: _kpiLabels[key] ?? key,
      value: values[key] ?? '--',
      available: available,
    );
  }

  static List<SessionKpiGroup> _buildKpiGroups({
    required Map<String, String> values,
    required bool Function(String key, Set<String> required)
    availabilityForKey,
  }) {
    return _kpiGroupDefinitions.entries.map((entry) {
      return SessionKpiGroup(
        title: entry.key,
        items: entry.value.map((definition) {
          return _item(
            values,
            definition.key,
            availabilityForKey(definition.key, definition.requiredCapabilities),
          );
        }).toList(growable: false),
      );
    }).toList(growable: false);
  }

  static Set<String> physicalSensorsForDeviceKind(String kind) {
    switch (kind) {
      case 'Android':
      case 'Dispositivo Android':
        return {
          'gps',
          'accelerometer',
          'gyroscope',
          'magnetometer',
        };
      case 'iPhone':
        return {
          'gps',
          'accelerometer',
          'gyroscope',
          'magnetometer',
        };
      case 'Apple Watch':
      case 'Smartwatch':
        return {
          'gps',
          'accelerometer',
          'gyroscope',
          'heart_rate',
          'barometer',
        };
      case 'Woo Sports':
      case 'SurfR':
        return {'gps', 'accelerometer', 'gyroscope'};
      default:
        return {'gps', 'accelerometer', 'gyroscope'};
    }
  }

  static const Map<String, String> _kpiLabels = {
    'duracion_total': 'Duración total',
    'tiempo_activo': 'Tiempo activo',
    'tiempo_parado': 'Tiempo parado',
    'ratio_activo_parado': 'Ratio activo/parado',
    'distancia_total': 'Distancia total',
    'distancia_planeo': 'Distancia de planeo',
    'distancia_upwind': 'Distancia upwind',
    'distancia_downwind': 'Distancia downwind',
    'velocidad_media': 'Velocidad media',
    'velocidad_max': 'Velocidad maxima',
    'velocidad_p95': 'Velocidad alta sostenida',
    'transiciones': 'Transiciones',
    'transiciones_hora': 'Transiciones/hora',
    'top5_saltos': 'Top 5 saltos',
    'altura_media_saltos': 'Altura media saltos',
    'hangtime_max': 'Hangtime max',
    'hangtime_p95': 'Hangtime P95',
    'eficiencia_salto_viento': 'Eficiencia salto/viento',
    'cadencia_saltos': 'Cadencia de saltos',
    'consistencia_alturas': 'Consistencia de alturas',
    'intentos_truco': 'Intentos de maniobra',
    'exito_truco': 'Exito de maniobra',
    'combo_rate': 'Secuencia de maniobras',
    'dificultad_media': 'Intensidad de maniobra',
    'caidas_intento': 'Caidas por maniobra',
    'progresion_truco': 'Progresion de maniobra',
    'vmg_upwind': 'VMG upwind',
    'vmg_downwind': 'VMG downwind',
    'angulo_cenida': 'Angulo de cenida',
    'eficiencia_bordos': 'Eficiencia de bordos',
    'tiempo_sweetspot': 'Tiempo en sweetspot',
    'deriva_neta': 'Deriva neta',
    'cobertura_area': 'Cobertura de area',
    'salto_mas_alto': 'Salto mas alto',
    'distancia_salto_estimada': 'Distancia de salto estimada',
    'distribucion_alturas': 'Distribucion de alturas',
    'takeoff_speed': 'Velocidad de despegue',
    'landing_speed': 'Velocidad de aterrizaje',
    'clean_landing_rate': 'Clean landing rate',
    'impact_score': 'Impact score',
    'variabilidad_velocidad': 'Variabilidad de velocidad',
    'estabilidad_direccional': 'Estabilidad direccional',
    'calidad_jibe': 'Calidad de jibe',
    'perdida_vel_transiciones': 'Perdida vel. transiciones',
    'recuperacion_planeo': 'Recuperacion de planeo',
    'smoothness_score': 'Suavidad de navegacion',
    'viento_medio': 'Viento medio',
    'viento_rango': 'Rango de viento',
    'direccion_dominante': 'Dirección dominante',
    'gust_factor': 'Gust factor',
    'temperatura': 'Temperatura',
    'presion': 'Presión',
    'lluvia': 'Lluvia',
    'caidas_hora': 'Caídas/hora',
    'eventos_sobrepotencia': 'Eventos de sobrepotencia',
    'distancia_max_costa': 'Distancia max. costa',
    'tiempo_zona_riesgo': 'Tiempo en zona de riesgo',
    'alertas_atendidas': 'Alertas atendidas',
    'fatiga_estimada': 'Fatiga estimada',
    'bateria_hora': 'Bateria/hora',
    'calidad_gps': 'Calidad GPS',
    'samples_perdidos': 'Samples perdidos',
    'latencia_sync': 'Latencia sync',
    'health_dataset': 'Health dataset',
    'session_score': 'Session score',
    'big_air_score': 'Big Air score',
    'freestyle_score': 'Score de maniobras',
    'freeride_score': 'Freeride score',
    'safety_score': 'Safety score',
    'progress_score': 'Progress score',
  };

  static const Map<String, List<_KpiDefinition>> _kpiGroupDefinitions = {
    'Core Session': [
      _KpiDefinition('duracion_total', {}),
      _KpiDefinition('tiempo_activo', {'motion'}),
      _KpiDefinition('tiempo_parado', {'motion'}),
      _KpiDefinition('ratio_activo_parado', {'motion'}),
      _KpiDefinition('distancia_total', {'gps'}),
      _KpiDefinition('distancia_planeo', {'gps', 'speed'}),
      _KpiDefinition('distancia_upwind', {'gps'}),
      _KpiDefinition('distancia_downwind', {'gps'}),
      _KpiDefinition('velocidad_media', {'speed'}),
      _KpiDefinition('velocidad_max', {'speed'}),
      _KpiDefinition('velocidad_p95', {'speed'}),
      _KpiDefinition('transiciones', {'motion'}),
      _KpiDefinition('transiciones_hora', {'motion'}),
    ],
    'Big Air': [
      _KpiDefinition('top5_saltos', {'altitude', 'motion'}),
      _KpiDefinition('altura_media_saltos', {'altitude', 'motion'}),
      _KpiDefinition('hangtime_max', {'altitude', 'motion'}),
      _KpiDefinition('hangtime_p95', {'altitude', 'motion'}),
      _KpiDefinition('eficiencia_salto_viento', {'altitude', 'speed'}),
      _KpiDefinition('cadencia_saltos', {'altitude', 'motion'}),
      _KpiDefinition('consistencia_alturas', {'altitude'}),
    ],
    'Maniobras': [
      _KpiDefinition('intentos_truco', {'motion'}),
      _KpiDefinition('exito_truco', {'motion'}),
      _KpiDefinition('combo_rate', {'motion'}),
      _KpiDefinition('dificultad_media', {'motion'}),
      _KpiDefinition('caidas_intento', {'motion'}),
      _KpiDefinition('progresion_truco', {'motion'}),
    ],
    'Freeride / Navegacion': [
      _KpiDefinition('vmg_upwind', {'gps', 'speed'}),
      _KpiDefinition('vmg_downwind', {'gps', 'speed'}),
      _KpiDefinition('angulo_cenida', {'gps'}),
      _KpiDefinition('eficiencia_bordos', {'gps', 'motion'}),
      _KpiDefinition('tiempo_sweetspot', {'speed'}),
      _KpiDefinition('deriva_neta', {'gps'}),
      _KpiDefinition('cobertura_area', {'gps'}),
    ],
    'Saltos': [
      _KpiDefinition('salto_mas_alto', {'altitude', 'motion'}),
      _KpiDefinition('distancia_salto_estimada', {'speed', 'altitude', 'motion'}),
      _KpiDefinition('distribucion_alturas', {'altitude'}),
      _KpiDefinition('takeoff_speed', {'speed', 'altitude'}),
      _KpiDefinition('landing_speed', {'speed', 'altitude'}),
      _KpiDefinition('clean_landing_rate', {'motion'}),
      _KpiDefinition('impact_score', {'motion'}),
    ],
    'Control tecnico': [
      _KpiDefinition('variabilidad_velocidad', {'speed'}),
      _KpiDefinition('estabilidad_direccional', {'gps', 'motion'}),
      _KpiDefinition('calidad_jibe', {'motion', 'speed'}),
      _KpiDefinition('perdida_vel_transiciones', {'motion', 'speed'}),
      _KpiDefinition('recuperacion_planeo', {'motion', 'speed'}),
      _KpiDefinition('smoothness_score', {'motion'}),
    ],
    'Condiciones meteo-contexto': [
      _KpiDefinition('viento_medio', {'weather'}),
      _KpiDefinition('viento_rango', {'weather'}),
      _KpiDefinition('direccion_dominante', {'weather'}),
      _KpiDefinition('gust_factor', {'weather'}),
      _KpiDefinition('temperatura', {'weather'}),
      _KpiDefinition('presion', {'weather', 'barometer'}),
      _KpiDefinition('lluvia', {'weather'}),
    ],
    'Seguridad y riesgo': [
      _KpiDefinition('caidas_hora', {'motion'}),
      _KpiDefinition('eventos_sobrepotencia', {'motion', 'speed'}),
      _KpiDefinition('distancia_max_costa', {'gps'}),
      _KpiDefinition('tiempo_zona_riesgo', {'gps'}),
      _KpiDefinition('alertas_atendidas', {'network'}),
      _KpiDefinition('fatiga_estimada', {'heart_rate'}),
    ],
    'Dispositivo y calidad de datos': [
      _KpiDefinition('bateria_hora', {'battery'}),
      _KpiDefinition('calidad_gps', {'gps'}),
      _KpiDefinition('samples_perdidos', {'network'}),
      _KpiDefinition('latencia_sync', {'network'}),
      _KpiDefinition('health_dataset', {'network'}),
    ],
    'KPIs compuestos': [
      _KpiDefinition('session_score', {'gps', 'speed'}),
      _KpiDefinition('big_air_score', {'altitude', 'speed'}),
      _KpiDefinition('freestyle_score', {'motion'}),
      _KpiDefinition('freeride_score', {'gps', 'speed'}),
      _KpiDefinition('safety_score', {'motion', 'gps'}),
      _KpiDefinition('progress_score', {'network'}),
    ],
  };

}

class _KpiDefinition {
  const _KpiDefinition(this.key, this.requiredCapabilities);

  final String key;
  final Set<String> requiredCapabilities;
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
      'maneuverG': maneuverG,
      'maneuverRotationDegPerSec': maneuverRotationDegPerSec,
      'fallSpeedMetersPerSecond': fallSpeedMetersPerSecond,
      'takeoffSpeedKnots': takeoffSpeedKnots,
      'landingSpeedKnots': landingSpeedKnots,
      'recordedAtSeconds': recordedAt.inSeconds,
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
      maneuverG: (json['maneuverG'] as num?)?.toDouble(),
      maneuverRotationDegPerSec:
          (json['maneuverRotationDegPerSec'] as num?)?.toDouble(),
      fallSpeedMetersPerSecond:
          (json['fallSpeedMetersPerSecond'] as num?)?.toDouble(),
      takeoffSpeedKnots: (json['takeoffSpeedKnots'] as num?)?.toDouble(),
      landingSpeedKnots: (json['landingSpeedKnots'] as num?)?.toDouble(),
      recordedAt: Duration(
        seconds: (json['recordedAtSeconds'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}

class SessionKpiGroup {
  const SessionKpiGroup({required this.title, required this.items});

  final String title;
  final List<SessionKpiItem> items;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'items': items.map((entry) => entry.toJson()).toList(growable: false),
    };
  }

  static SessionKpiGroup fromJson(Map<String, dynamic> json) {
    return SessionKpiGroup(
      title: json['title'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SessionKpiItem.fromJson)
          .toList(growable: false),
    );
  }
}

class SessionKpiItem {
  const SessionKpiItem({
    required this.label,
    required this.value,
    required this.available,
  });

  final String label;
  final String value;
  final bool available;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'value': value,
      'available': available,
    };
  }

  static SessionKpiItem fromJson(Map<String, dynamic> json) {
    return SessionKpiItem(
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
      available: json['available'] as bool? ?? false,
    );
  }
}
