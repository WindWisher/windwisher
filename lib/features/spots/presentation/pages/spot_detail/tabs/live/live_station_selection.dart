// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailLiveStationSelection on _SpotDetailPageState {
  void _handleLiveStationChanged(String value) {
    final station = _findStationByKey(value);
    setState(() {
      _selectedStation = value;
      _applyHistoricalDefaultsForStation(station);
    });
    _refreshSelectedStationLiveData();
    _refreshSelectedStationHistoricalData();
  }

  String _stationKey(_NearbyStation station) {
    return station.stationKey;
  }

  _NearbyStation? _findStationByKey(String key) {
    for (final station in _resolvedNearbyStations()) {
      if (_stationKey(station) == key) {
        return station;
      }
    }
    return null;
  }

  String _stationDisplayName(String key) {
    final station = _findStationByKey(key);
    return station?.name ?? key;
  }

  String _stationLabel(_NearbyStation station) {
    final stationLocationLabel =
        station.proximityLabel ?? '${station.distanceKm.toStringAsFixed(1)} km';
    final directionLabel = _stationDirectionLabel(station);
    if (directionLabel == null) {
      return '${station.name} · $stationLocationLabel';
    }
    return '${station.name} · $stationLocationLabel · $directionLabel';
  }

  String? _stationDirectionLabel(_NearbyStation station) {
    final latitude = widget.latitude;
    final longitude = widget.longitude;
    if (latitude == null || longitude == null) {
      return null;
    }
    final bearing = _bearingDegrees(
      latitudeA: latitude,
      longitudeA: longitude,
      latitudeB: station.latitude,
      longitudeB: station.longitude,
    );
    return _degreesToCardinal(bearing);
  }

  String _stationLabelForKey(String key) {
    final station = _findStationByKey(key);
    if (station == null) {
      return key;
    }
    return _stationLabel(station);
  }

  String _selectedStationName() {
    return _stationDisplayName(_selectedStation);
  }

  bool _isOlivaAemetOfficialStation(_NearbyStation? station) {
    return station?.provider == 'AEMET' && station?.stationId == '8058X';
  }

  bool _isOlivaNovaInforatgeStation(_NearbyStation? station) {
    return station?.provider == 'INFORATGE' &&
        station?.stationId == _meteoclimaticOlivaNovaStationId;
  }

  bool _isAiguaBlancaStation(_NearbyStation? station) {
    return station?.provider == 'AIGUABLANCA' &&
        station?.stationId == _aiguaBlancaStationId;
  }

  void _applyHistoricalDefaultsForStation(_NearbyStation? station) {
    if (_isOlivaNovaInforatgeStation(station) ||
        _isAiguaBlancaStation(station)) {
      _historyBucket1d = _HistoricalBucketOption.min20;
      return;
    }
    if (_historyBucket1d == _HistoricalBucketOption.min20) {
      _historyBucket1d = _HistoricalBucketOption.h1;
    }
  }

  List<_NearbyStation> _resolvedNearbyStations() {
    return _liveStationsLoadResult?.stations ?? const <_NearbyStation>[];
  }

  Map<String, _StationLiveData> _resolvedLiveDataByStation() {
    return _liveStationsLoadResult?.liveDataByStation ??
        const <String, _StationLiveData>{};
  }

  _StationLiveData _selectedLiveData() {
    return _resolvedLiveDataByStation()[_selectedStation] ??
        const _StationLiveData(
          windKnots: null,
          windDeg: null,
          gustKnots: null,
          tempC: null,
          pressureHpa: null,
          humidityPct: null,
          rainMm: null,
          observedAt: null,
        );
  }
}
