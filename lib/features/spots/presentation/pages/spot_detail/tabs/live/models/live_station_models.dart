part of '../../../spot_detail_page.dart';

class _NearbyStation {
  const _NearbyStation({
    required this.name,
    required this.distanceKm,
    required this.provider,
    required this.sourceKind,
    required this.stationKey,
    required this.latitude,
    required this.longitude,
    this.stationId,
    this.proximityLabel,
  });

  final String name;
  final double distanceKm;
  final String provider;
  final _StationSourceKind sourceKind;
  final String stationKey;
  final double latitude;
  final double longitude;
  final String? stationId;
  final String? proximityLabel;
}

enum _StationSourceKind {
  observation('Observacion'),
  forecast('Forecast');

  const _StationSourceKind(this.label);

  final String label;
}

class _StationLiveData {
  const _StationLiveData({
    required this.windKnots,
    required this.windDeg,
    required this.gustKnots,
    required this.tempC,
    required this.pressureHpa,
    required this.humidityPct,
    required this.rainMm,
    required this.observedAt,
    this.observedAtLabel,
  });

  final double? windKnots;
  final int? windDeg;
  final double? gustKnots;
  final double? tempC;
  final int? pressureHpa;
  final int? humidityPct;
  final double? rainMm;
  final DateTime? observedAt;
  final String? observedAtLabel;
}

class _LiveStationsLoadResult {
  const _LiveStationsLoadResult({
    required this.stations,
    required this.liveDataByStation,
    required this.historicalSeriesByStation,
    required this.source,
    this.message,
    this.technicalError,
  });

  final List<_NearbyStation> stations;
  final Map<String, _StationLiveData> liveDataByStation;
  final Map<String, List<_HistoricalWindPoint>> historicalSeriesByStation;
  final _LiveStationsDataSource source;
  final String? message;
  final String? technicalError;
}

enum _LiveStationsDataSource { real, unavailable }
