class SessionMetricKeys {
  const SessionMetricKeys._();

  static const String distanceTotal = 'distancia_total';
  static const String distancePlaning = 'distancia_planeo';
  static const String speedP95 = 'velocidad_p95';
  static const String maxSpeed = 'velocidad_max';
  static const String avgSpeed = 'velocidad_media';
  static const String totalJumps = 'saltos_totales';
  static const String highestJump = 'salto_mas_alto';
  static const String maxHangtime = 'hangtime_max';
  static const String transitions = 'transiciones';
  static const String transitionsPerHour = 'transiciones_hora';
  static const String tackEfficiency = 'eficiencia_bordos';
  static const String sweetspotTime = 'tiempo_sweetspot';
  static const String impactScore = 'impact_score';
  static const String takeoffSpeed = 'takeoff_speed';
  static const String landingSpeed = 'landing_speed';
  static const String cleanLandingRate = 'clean_landing_rate';
  static const String speedVariability = 'variabilidad_velocidad';
  static const String directionalStability = 'estabilidad_direccional';
  static const String jibeQuality = 'calidad_jibe';
  static const String transitionSpeedLoss = 'perdida_vel_transiciones';
  static const String planingRecovery = 'recuperacion_planeo';
  static const String jumpHeightConsistency = 'consistencia_alturas';
  static const String sessionScore = 'session_score';
  static const String netDrift = 'deriva_neta';
  static const String areaCoverage = 'cobertura_area';
  static const String fallsPerHour = 'caidas_hora';
  static const String overpowerEvents = 'eventos_sobrepotencia';
  static const String maxDistanceCoast = 'distancia_max_costa';
  static const String riskZoneTime = 'tiempo_zona_riesgo';
  static const String gpsQuality = 'calidad_gps';
  static const String lostSamples = 'samples_perdidos';
  static const String bigAirScore = 'big_air_score';
  static const String freerideScore = 'freeride_score';
  static const String safetyScore = 'safety_score';
}

class SessionAdvancedMetrics {
  const SessionAdvancedMetrics({required this.groups});

  final List<SessionKpiGroup> groups;

  SessionKpiItem? kpiByKey(String key) {
    for (final group in groups) {
      for (final item in group.items) {
        if (item.key == key && item.available) {
          return item;
        }
      }
    }
    return null;
  }

  String? kpiValue(String key) => kpiByKey(key)?.value;

  double? doubleValue(String key) => _parseLeadingDouble(kpiValue(key));

  int? intValue(String key) => doubleValue(key)?.round();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'groups': groups.map((entry) => entry.toJson()).toList(growable: false),
    };
  }

  static SessionAdvancedMetrics fromJson(Map<String, dynamic> json) {
    return SessionAdvancedMetrics(
      groups: (json['groups'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SessionKpiGroup.fromJson)
          .toList(growable: false),
    );
  }
}

double? _parseLeadingDouble(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final normalized = value.replaceAll(',', '.');
  final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(normalized);
  if (match == null) {
    return null;
  }
  return double.tryParse(match.group(0)!);
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
    required this.key,
    required this.label,
    required this.value,
    required this.available,
  });

  final String key;
  final String label;
  final String value;
  final bool available;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'label': label,
      'value': value,
      'available': available,
    };
  }

  static SessionKpiItem fromJson(Map<String, dynamic> json) {
    final label = json['label'] as String? ?? '';
    final key = json['key'] as String? ?? _normalizedKpiKeyForLabel(label);
    return SessionKpiItem(
      key: key,
      label: label,
      value: json['value'] as String? ?? '',
      available: json['available'] as bool? ?? false,
    );
  }
}

List<SessionKpiGroup> buildRecordedSessionKpiGroups({
  required Map<String, String> values,
}) {
  return _buildKpiGroups(
    values: values,
    availabilityForKey: (key, required) => values.containsKey(key),
  );
}

class _KpiDefinition {
  const _KpiDefinition(this.key, this.requiredCapabilities);

  final String key;
  final Set<String> requiredCapabilities;
}

String _normalizedKpiKeyForLabel(String label) {
  for (final entry in _kpiLabels.entries) {
    if (entry.value == label) {
      return entry.key;
    }
  }
  return label
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}

SessionKpiItem _item(Map<String, String> values, String key, bool available) {
  return SessionKpiItem(
    key: key,
    label: _kpiLabels[key] ?? key,
    value: values[key] ?? '--',
    available: available,
  );
}

List<SessionKpiGroup> _buildKpiGroups({
  required Map<String, String> values,
  required bool Function(String key, Set<String> required) availabilityForKey,
}) {
  return _kpiGroupDefinitions.entries
      .map((entry) {
        return SessionKpiGroup(
          title: entry.key,
          items: entry.value
              .map((definition) {
                return _item(
                  values,
                  definition.key,
                  availabilityForKey(
                    definition.key,
                    definition.requiredCapabilities,
                  ),
                );
              })
              .toList(growable: false),
        );
      })
      .toList(growable: false);
}

const Map<String, String> _kpiLabels = {
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
  'saltos_totales': 'Saltos totales',
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

const Map<String, List<_KpiDefinition>> _kpiGroupDefinitions = {
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
    _KpiDefinition('saltos_totales', {'motion'}),
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
