class SpotForecastEntry {
  const SpotForecastEntry({
    required this.time,
    required this.windKnots,
    this.gustKnots,
    required this.windDeg,
    this.airTempC,
    this.waterTempC,
    this.pressureHpa,
    this.cloudCoverPct,
    this.waveM,
    this.wavePeriodSeconds,
    this.waveDirDeg,
    this.currentMps,
    this.currentDirDeg,
    this.salinityPsu,
    this.rainMm,
  });

  final DateTime time;
  final int windKnots;
  final int? gustKnots;
  final int windDeg;
  final int? airTempC;
  final int? waterTempC;
  final int? pressureHpa;
  final int? cloudCoverPct;
  final double? waveM;
  final double? wavePeriodSeconds;
  final int? waveDirDeg;
  final double? currentMps;
  final int? currentDirDeg;
  final double? salinityPsu;
  final double? rainMm;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'time': time.toIso8601String(),
      'windKnots': windKnots,
      'gustKnots': gustKnots,
      'windDeg': windDeg,
      'airTempC': airTempC,
      'waterTempC': waterTempC,
      'pressureHpa': pressureHpa,
      'cloudCoverPct': cloudCoverPct,
      'waveM': waveM,
      'wavePeriodSeconds': wavePeriodSeconds,
      'waveDirDeg': waveDirDeg,
      'currentMps': currentMps,
      'currentDirDeg': currentDirDeg,
      'salinityPsu': salinityPsu,
      'rainMm': rainMm,
    };
  }

  factory SpotForecastEntry.fromJson(Map<String, dynamic> json) {
    return SpotForecastEntry(
      time: DateTime.parse(json['time'] as String),
      windKnots: (json['windKnots'] as num).round(),
      gustKnots: (json['gustKnots'] as num?)?.round(),
      windDeg: (json['windDeg'] as num).round(),
      airTempC: (json['airTempC'] as num?)?.round(),
      waterTempC: (json['waterTempC'] as num?)?.round(),
      pressureHpa: (json['pressureHpa'] as num?)?.round(),
      cloudCoverPct: (json['cloudCoverPct'] as num?)?.round(),
      waveM: (json['waveM'] as num?)?.toDouble(),
      wavePeriodSeconds: (json['wavePeriodSeconds'] as num?)?.toDouble(),
      waveDirDeg: (json['waveDirDeg'] as num?)?.round(),
      currentMps: (json['currentMps'] as num?)?.toDouble(),
      currentDirDeg: (json['currentDirDeg'] as num?)?.round(),
      salinityPsu: (json['salinityPsu'] as num?)?.toDouble(),
      rainMm: (json['rainMm'] as num?)?.toDouble(),
    );
  }
}
