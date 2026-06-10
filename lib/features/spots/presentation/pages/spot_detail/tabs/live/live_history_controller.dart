// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailLiveHistoryController on _SpotDetailPageState {
  Future<bool> _refreshSelectedStationHistoricalData() async {
    final station = _findStationByKey(_selectedStation);
    final current = _liveStationsLoadResult;
    if (station == null || current == null) {
      return false;
    }

    final stopwatch = Stopwatch()..start();
    try {
      final refreshedHistory = await _fetchHistoricalDataForStation(
        station,
      ).timeout(const Duration(seconds: 15));
      debugPrint(
        'LiveStationTiming phase=history elapsedMs=${stopwatch.elapsedMilliseconds} '
        'provider=${station.provider} stationKey=${station.stationKey} '
        'station="${station.name}" success=${refreshedHistory != null} '
        'points=${refreshedHistory?.length ?? 0}',
      );
      if (!mounted || refreshedHistory == null) {
        return false;
      }

      setState(() {
        final latest = _liveStationsLoadResult;
        if (latest == null) {
          return;
        }
        final updatedHistory = Map<String, List<_HistoricalWindPoint>>.from(
          latest.historicalSeriesByStation,
        );
        updatedHistory[station.stationKey] = refreshedHistory;
        _historyChartFocusKey = null;
        _historyChartFullscreenFocusKey = null;
        _liveStationsLoadResult = _LiveStationsLoadResult(
          stations: latest.stations,
          liveDataByStation: latest.liveDataByStation,
          historicalSeriesByStation: updatedHistory,
          source: latest.source,
          message: latest.message,
          technicalError: latest.technicalError,
        );
      });
      return true;
    } catch (error) {
      debugPrint(
        'LiveStationTiming phase=history elapsedMs=${stopwatch.elapsedMilliseconds} '
        'provider=${station.provider} stationKey=${station.stationKey} '
        'station="${station.name}" error=$error',
      );
      return false;
    }
  }

  Future<void> _loadSelectedStationHistoricalData() async {
    if (_isHistoricalLoading) {
      return;
    }
    if (!_supportsHistoricalDataForSelectedStation()) {
      _showLiveRefreshFeedback(
        'Esta estacion todavia no tiene historico disponible.',
      );
      return;
    }
    setState(() {
      _isHistoricalLoading = true;
    });
    try {
      final historyUpdated = await _refreshSelectedStationHistoricalData();
      if (!historyUpdated && mounted) {
        _showLiveRefreshFeedback(
          'No se pudo cargar el historico de ${_stationDisplayName(_selectedStation)}.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isHistoricalLoading = false;
        });
      }
    }
  }

  Future<void> _refreshHistoricalChartData() async {
    if (_isHistoricalRefreshing) {
      return;
    }
    setState(() {
      _isHistoricalRefreshing = true;
    });
    try {
      await _refreshSelectedStationLiveData();
      final historyUpdated = await _refreshSelectedStationHistoricalData();
      _refreshHistoryForecastRows();
      if (!historyUpdated && mounted) {
        _showLiveRefreshFeedback(
          'No se pudo actualizar el historico de ${_stationDisplayName(_selectedStation)}.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isHistoricalRefreshing = false;
        });
      }
    }
  }

  List<_HistoricalWindPoint> _selectedHistoricalWindPoints() {
    final station = _findStationByKey(_selectedStation);
    if (station == null) {
      return const <_HistoricalWindPoint>[];
    }
    return _historicalWindPointsForStation(station);
  }

  List<_HistoricalWindPoint> _historicalWindPointsForStation(
    _NearbyStation station,
  ) {
    return _liveStationsLoadResult?.historicalSeriesByStation[station
            .stationKey] ??
        const <_HistoricalWindPoint>[];
  }

  bool _hasRealHistoricalSeries() => _selectedHistoricalWindPoints().isNotEmpty;

  bool _supportsHistoricalDataForSelectedStation() {
    final station = _findStationByKey(_selectedStation);
    if (station == null) {
      return false;
    }
    return station.provider != 'METEOCLIMATIC';
  }

  String? _selectedHistoricalUnavailableDescription() {
    final station = _findStationByKey(_selectedStation);
    if (station?.provider == 'METEOCLIMATIC') {
      return 'Meteoclimatic no muestra historico, solo datos en directo.';
    }
    return null;
  }

  bool _supportsThreeDayHistoryForSelectedStation() {
    final station = _findStationByKey(_selectedStation);
    if (station == null) {
      return false;
    }
    if (station.provider == 'INFORATGE') {
      return false;
    }
    if (station.provider == 'AIGUABLANCA') {
      return false;
    }
    if (station.provider == 'WUNDERGROUND' &&
        !_usesBackendHistoryForWundergroundStation(station)) {
      return false;
    }
    if (station.provider == 'AEMET' && station.stationId == '8058X') {
      return false;
    }
    return true;
  }

  bool _usesFixedAemetOlivaHistoryWindow() {
    final station = _findStationByKey(_selectedStation);
    return _isOlivaAemetOfficialStation(station);
  }

  bool _usesRawCollectedHistoryForSelectedStation() {
    final station = _findStationByKey(_selectedStation);
    return station?.provider == 'WINDGURU_STATION' ||
        station?.provider == 'METEOPILES' ||
        station?.provider == 'METEOCLIMATIC' ||
        station?.provider == 'WEATHERCLOUD' ||
        station?.provider == 'XUSS' ||
        (station != null &&
            _usesBackendHistoryForWundergroundStation(station)) ||
        station?.provider == 'MADIS_MARITIME' ||
        station?.provider == 'COPERNICUS_MARINE';
  }

  bool _usesBackendHistoryForWundergroundStation(_NearbyStation station) {
    if (station.provider != 'WUNDERGROUND') {
      return false;
    }
    return switch (station.stationKey) {
      _wundergroundOliva107StationKey ||
      _wundergroundDenia129StationKey ||
      _wundergroundOliva49StationKey ||
      _wundergroundDenia15StationKey ||
      _wundergroundElsPoblets7StationKey ||
      _wundergroundElsPoblets8StationKey ||
      _wundergroundElVerger21StationKey ||
      _wundergroundElsPoblets5StationKey ||
      _wundergroundElsPoblets14StationKey ||
      _wundergroundDenia157StationKey ||
      _wundergroundDenia70StationKey ||
      _wundergroundDenia123StationKey ||
      _wundergroundDenia35StationKey ||
      _wundergroundDenia142StationKey ||
      _wundergroundDenia140StationKey ||
      _wundergroundCalp39StationKey ||
      _wundergroundCalp32StationKey ||
      _wundergroundSantJoan177StationKey ||
      _wundergroundElCampello26StationKey ||
      _wundergroundElCampello18StationKey ||
      _wundergroundAlicante69StationKey ||
      _wundergroundElCampello27StationKey ||
      _wundergroundElCampello35StationKey ||
      _wundergroundAlicante17StationKey ||
      _wundergroundSantaPola2108StationKey ||
      _wundergroundSantaPola1834StationKey ||
      _wundergroundSantaPola1907StationKey ||
      _wundergroundSantaPola2348StationKey ||
      _wundergroundSantaPola2257StationKey ||
      _wundergroundElche122StationKey ||
      _wundergroundElche99StationKey ||
      _wundergroundElche115StationKey ||
      _wundergroundElche66StationKey ||
      _wundergroundAltea13StationKey ||
      _wundergroundAltea38StationKey ||
      _wundergroundAltea48StationKey ||
      _wundergroundVillajoyosaLavil16StationKey ||
      _wundergroundVillajoyosaLavil24StationKey ||
      _wundergroundVillajoyosaLavil41StationKey ||
      _wundergroundVillajoyosaVilla310StationKey => true,
      _ => false,
    };
  }

  String _historicalSeriesDisplayLabel() {
    final station = _findStationByKey(_selectedStation);
    switch (station?.provider) {
      case 'AEMET':
        return 'AEMET';
      case 'AVAMET':
        return 'AVAMET';
      case 'WUNDERGROUND':
        return 'Weather Underground';
      case 'METEOCLIMATIC':
        return 'Meteoclimatic';
      case 'INFORATGE':
        return 'Inforatge';
      case 'MADIS_MARITIME':
        return 'MADIS Maritime';
      case 'COPERNICUS_MARINE':
        return 'Copernicus Marine';
      default:
        return 'Historico';
    }
  }

  List<_HistoricalBucketOption> _availableBucketOptions(_HistoryRange range) {
    switch (range) {
      case _HistoryRange.h1:
        if (_usesFixedAemetOlivaHistoryWindow()) {
          return const <_HistoricalBucketOption>[
            _HistoricalBucketOption.h1,
            _HistoricalBucketOption.h3,
          ];
        }
        return const <_HistoricalBucketOption>[
          _HistoricalBucketOption.min20,
          _HistoricalBucketOption.h1,
          _HistoricalBucketOption.h3,
        ];
      case _HistoryRange.h3:
        return const <_HistoricalBucketOption>[
          _HistoricalBucketOption.h3,
          _HistoricalBucketOption.h6,
          _HistoricalBucketOption.h12,
        ];
    }
  }

  _HistoricalBucketOption _selectedBucketOption(_HistoryRange range) {
    if (_usesFixedAemetOlivaHistoryWindow()) {
      return _HistoricalBucketOption.h1;
    }
    switch (range) {
      case _HistoryRange.h1:
        return _historyBucket1d;
      case _HistoryRange.h3:
        return _historyBucket3d;
    }
  }

  void _setSelectedBucketOption(_HistoricalBucketOption option) {
    if (_usesFixedAemetOlivaHistoryWindow()) {
      _historyBucket1d = _HistoricalBucketOption.h1;
      return;
    }
    switch (_historyRange) {
      case _HistoryRange.h1:
        _historyBucket1d = option;
      case _HistoryRange.h3:
        _historyBucket3d = option;
    }
  }
}
