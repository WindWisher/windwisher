part of '../../../spot_detail_page.dart';

class _ForecastRow {
  const _ForecastRow({
    required this.slotTime,
    required this.hour,
    required this.windKnots,
    this.gustKnots,
    required this.windDeg,
    this.tempC,
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

  final DateTime slotTime;
  final String hour;
  final int windKnots;
  final int? gustKnots;
  final int windDeg;
  final int? tempC;
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
}

enum _ForecastRange {
  d1(1, '1 dia'),
  d3(3, '3 dias'),
  d7(7, '7 dias'),
  d15(15, '15 dias');

  const _ForecastRange(this.days, this.label);

  final int days;
  final String label;
}

enum _ForecastResolution {
  h6(360, '6h'),
  h3(180, '3h'),
  h1(60, '1h'),
  m15(15, '15m'),
  m20(20, '20m');

  const _ForecastResolution(this.minutes, this.label);

  final int minutes;
  final String label;
}

enum _ForecastDataSource { live, mock, fallback }

enum _ForecastFullscreenMode { none, forecastTable, meteoblueSea, windguru }

class _ForecastLoadResult {
  const _ForecastLoadResult({
    required this.rows,
    required this.source,
    this.message,
    this.technicalError,
  });

  final List<_ForecastRow> rows;
  final _ForecastDataSource source;
  final String? message;
  final String? technicalError;
}

class _AemetBeachForecastLoadResult {
  const _AemetBeachForecastLoadResult({
    required this.data,
    required this.source,
    this.message,
    this.technicalError,
  });

  final List<AemetBeachForecastData> data;
  final _ForecastDataSource source;
  final String? message;
  final String? technicalError;
}

class _AemetCoastalForecastLoadResult {
  const _AemetCoastalForecastLoadResult({
    required this.data,
    required this.source,
    this.message,
    this.technicalError,
  });

  final AemetCoastalForecastData? data;
  final _ForecastDataSource source;
  final String? message;
  final String? technicalError;
}

class _MeteoblueCurrentDayLoadResult {
  const _MeteoblueCurrentDayLoadResult({
    required this.snapshot,
    required this.source,
    this.message,
    this.technicalError,
  });

  final MeteoblueCurrentDaySnapshot snapshot;
  final _ForecastDataSource source;
  final String? message;
  final String? technicalError;
}

class _MeteosourceCurrentDayLoadResult {
  const _MeteosourceCurrentDayLoadResult({
    required this.snapshot,
    required this.source,
    this.message,
    this.technicalError,
  });

  final MeteosourceCurrentDaySnapshot snapshot;
  final _ForecastDataSource source;
  final String? message;
  final String? technicalError;
}

class _MeteostatDayLoadResult {
  const _MeteostatDayLoadResult({
    required this.snapshot,
    required this.source,
    this.message,
    this.technicalError,
  });

  final MeteostatDaySnapshot snapshot;
  final _ForecastDataSource source;
  final String? message;
  final String? technicalError;
}
