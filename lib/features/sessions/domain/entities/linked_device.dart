class LinkedDevice {
  const LinkedDevice({
    required this.id,
    required this.name,
    required this.kind,
    required this.status,
    required this.lastSync,
    required this.family,
    required this.placement,
    required this.physicalSensorKeys,
    required this.isSessionEligible,
  });

  final String id;
  final String name;
  final String kind;
  final String status;
  final String lastSync;
  final String family;
  final String placement;
  final List<String> physicalSensorKeys;
  final bool isSessionEligible;

  bool get hasBarometer => physicalSensorKeys.contains('barometer');
  bool get hasAltimeter => physicalSensorKeys.contains('altimeter');
  bool get canMeasureJumpHeight =>
      family == 'board_sensor' || hasBarometer || hasAltimeter;

  static bool isSessionEligibleForDetectedDevice({
    required String family,
    required List<String> physicalSensorKeys,
  }) {
    if (family == 'phone' || family == 'watch' || family == 'board_sensor') {
      return true;
    }
    return false;
  }

  LinkedDevice copyWith({
    String? name,
    String? kind,
    String? status,
    String? lastSync,
    String? family,
    String? placement,
    List<String>? physicalSensorKeys,
    bool? isSessionEligible,
  }) {
    return LinkedDevice(
      id: id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      lastSync: lastSync ?? this.lastSync,
      family: family ?? this.family,
      placement: placement ?? this.placement,
      physicalSensorKeys: physicalSensorKeys ?? this.physicalSensorKeys,
      isSessionEligible: isSessionEligible ?? this.isSessionEligible,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'kind': kind,
      'status': status,
      'lastSync': lastSync,
      'family': family,
      'placement': placement,
      'physicalSensorKeys': physicalSensorKeys,
      'isSessionEligible': isSessionEligible,
    };
  }

  static LinkedDevice fromJson(Map<String, dynamic> json) {
    final kind = json['kind'] as String? ?? 'Dispositivo Android';
    final family = json['family'] as String? ?? _inferFamily(kind);
    final physicalSensorKeys =
        (json['physicalSensorKeys'] as List<dynamic>? ?? const <dynamic>[])
            .map((entry) => entry.toString())
            .toList(growable: false);
    return LinkedDevice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Dispositivo',
      kind: kind,
      status: json['status'] as String? ?? 'Pendiente',
      lastSync: json['lastSync'] as String? ?? 'sin sincronizacion',
      family: family,
      placement: json['placement'] as String? ?? _inferPlacement(family),
      physicalSensorKeys: physicalSensorKeys,
      isSessionEligible: json['isSessionEligible'] as bool? ??
          isSessionEligibleForDetectedDevice(
            family: family,
            physicalSensorKeys: physicalSensorKeys,
          ),
    );
  }

  static String _inferFamily(String kind) {
    final normalized = kind.toLowerCase();
    if (normalized.contains('watch')) {
      return 'watch';
    }
    if (normalized.contains('woo') || normalized.contains('tabla')) {
      return 'board_sensor';
    }
    if (normalized.contains('iphone') ||
        normalized.contains('android') ||
        normalized.contains('phone') ||
        normalized.contains('web') ||
        normalized.contains('mac') ||
        normalized.contains('windows') ||
        normalized.contains('linux')) {
      return 'phone';
    }
    return 'unknown';
  }

  static String _inferPlacement(String family) {
    switch (family) {
      case 'watch':
        return 'wrist';
      case 'board_sensor':
        return 'board';
      case 'phone':
        return 'local';
      default:
        return 'unknown';
    }
  }

}
