class RecordedSession {
  const RecordedSession({
    required this.id,
    required this.title,
    required this.deviceName,
    required this.endedAt,
    required this.duration,
    required this.summary,
    required this.gearSetupId,
    required this.gearSetupName,
    required this.hasSessionPhoto,
    required this.sessionMediaLabel,
    required this.sessionPhotoLocalPath,
    required this.spotName,
    required this.insights,
  });

  final String id;
  final String title;
  final String deviceName;
  final DateTime endedAt;
  final Duration duration;
  final String summary;
  final String? gearSetupId;
  final String? gearSetupName;
  final bool hasSessionPhoto;
  final String sessionMediaLabel;
  final String? sessionPhotoLocalPath;
  final String? spotName;
  final Object insights;

  Map<String, dynamic> toJson({
    required Object? Function(Object value) encodeInsights,
  }) {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'deviceName': deviceName,
      'endedAt': endedAt.toIso8601String(),
      'durationSeconds': duration.inSeconds,
      'summary': summary,
      'gearSetupId': gearSetupId,
      'gearSetupName': gearSetupName,
      'hasSessionPhoto': hasSessionPhoto,
      'sessionMediaLabel': sessionMediaLabel,
      'sessionPhotoLocalPath': sessionPhotoLocalPath,
      'spotName': spotName,
      'insights': encodeInsights(insights),
    };
  }

  static RecordedSession fromJson(
    Map<String, dynamic> json, {
    required Object Function(Object? value) decodeInsights,
  }) {
    return RecordedSession(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Sesion',
      deviceName: json['deviceName'] as String? ?? 'Dispositivo',
      endedAt: _parseDateTime(json['endedAt']) ?? DateTime.now(),
      duration: Duration(
        seconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      ),
      summary: json['summary'] as String? ?? '',
      gearSetupId: json['gearSetupId'] as String?,
      gearSetupName: json['gearSetupName'] as String?,
      hasSessionPhoto: json['hasSessionPhoto'] as bool? ?? false,
      sessionMediaLabel:
          json['sessionMediaLabel'] as String? ??
          'Pantallazo del mapa del spot',
      sessionPhotoLocalPath: json['sessionPhotoLocalPath'] as String?,
      spotName: json['spotName'] as String?,
      insights: decodeInsights(json['insights']),
    );
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is! String) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}
