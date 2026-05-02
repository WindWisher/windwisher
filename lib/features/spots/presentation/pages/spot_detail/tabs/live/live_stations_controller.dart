// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailLiveStationsController on _SpotDetailPageState {
  Future<void> _loadLiveStations() async {
    if (_isLiveRefreshing) {
      return;
    }
    setState(() {
      _isLiveRefreshing = true;
    });
    try {
      final result = await _resolveLiveStations();
      if (!mounted) {
        return;
      }
      setState(() {
        _liveStationsLoadResult = result;
        final stationKeys = result.stations.map(_stationKey).toSet();
        if (result.stations.isNotEmpty &&
            !stationKeys.contains(_selectedStation)) {
          final resolvedStation = result.stations.first;
          _selectedStation = _stationKey(resolvedStation);
          _applyHistoricalDefaultsForStation(resolvedStation);
        }
        if (result.stations.isNotEmpty &&
            !stationKeys.contains(_alarmStation)) {
          _alarmStation = _stationKey(result.stations.first);
        }
      });
      await _refreshSelectedStationLiveData();
      final savedAlarms = _savedAlarmsForCurrentSpot();
      await _refreshAlarmStationsLiveData(savedAlarms);
      await _processLocalAlarmNotifications(savedAlarms);
      _syncAlarmMonitoring();
    } finally {
      if (mounted) {
        setState(() {
          _isLiveRefreshing = false;
        });
      }
    }
  }

  Future<void> _refreshSelectedStationLiveData() async {
    final station = _findStationByKey(_selectedStation);
    if (station == null) {
      return;
    }
    final ownsRefreshState = !_isLiveRefreshing;
    if (ownsRefreshState && mounted) {
      setState(() {
        _isLiveRefreshing = true;
      });
    }
    try {
      final refreshed = await _fetchLiveDataForStation(station);
      if (!mounted || refreshed == null) {
        if (ownsRefreshState && mounted) {
          _showLiveRefreshFeedback(
            'No se pudo actualizar ${_stationDisplayName(_selectedStation)}.',
          );
        }
        return;
      }
      final liveData = refreshed;
      setState(() {
        final current = _liveStationsLoadResult;
        if (current == null) {
          return;
        }
        final updatedLiveData = Map<String, _StationLiveData>.from(
          current.liveDataByStation,
        );
        updatedLiveData[_selectedStation] = liveData;
        _liveStationsLoadResult = _LiveStationsLoadResult(
          stations: current.stations,
          liveDataByStation: updatedLiveData,
          historicalSeriesByStation: current.historicalSeriesByStation,
          source: current.source,
          message: current.message,
          technicalError: current.technicalError,
        );
      });
    } catch (_) {
      if (ownsRefreshState && mounted) {
        _showLiveRefreshFeedback(
          'No se pudo actualizar ${_stationDisplayName(_selectedStation)}.',
        );
      }
    } finally {
      if (ownsRefreshState && mounted) {
        setState(() {
          _isLiveRefreshing = false;
        });
      }
    }
  }

  void _showLiveRefreshFeedback(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
