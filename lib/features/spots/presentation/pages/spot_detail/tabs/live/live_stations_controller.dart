// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailLiveStationsController on _SpotDetailPageState {
  Future<void> _loadLiveStations() async {
    if (_isLiveRefreshing) {
      return;
    }
    final stopwatch = Stopwatch()..start();
    var handedOffRefreshState = false;
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
          final resolvedStation =
              _preferredLiveStation(result.stations) ?? result.stations.first;
          _selectedStation = _stationKey(resolvedStation);
          _applyHistoricalDefaultsForStation(resolvedStation);
        }
        if (result.stations.isNotEmpty &&
            !stationKeys.contains(_alarmStation)) {
          final supportedAlarmStations = _supportedCustomAlarmStations(
            result.stations,
          );
          if (supportedAlarmStations.isNotEmpty) {
            final resolvedAlarmStation =
                _preferredLiveStation(supportedAlarmStations) ??
                supportedAlarmStations.first;
            _alarmStation = _stationKey(resolvedAlarmStation);
          }
        }
        _isLiveRefreshing = false;
      });
      handedOffRefreshState = true;
      debugPrint(
        'LiveStationTiming phase=resolve-stations elapsedMs=${stopwatch.elapsedMilliseconds} '
        'spot="${widget.name}" stations=${result.stations.length} source=${result.source.name}',
      );
      unawaited(_hydrateSelectedLiveStationPayload());
    } catch (error) {
      debugPrint(
        'LiveStationTiming phase=resolve-stations elapsedMs=${stopwatch.elapsedMilliseconds} '
        'spot="${widget.name}" error=$error',
      );
      rethrow;
    } finally {
      if (mounted && !handedOffRefreshState) {
        setState(() {
          _isLiveRefreshing = false;
        });
      }
    }
  }

  Future<void> _hydrateSelectedLiveStationPayload() async {
    await _refreshSelectedStationLiveData();
    if (!mounted) {
      return;
    }
  }

  Future<void> _refreshSelectedStationLiveData() async {
    final station = _findStationByKey(_selectedStation);
    if (station == null) {
      return;
    }
    final stopwatch = Stopwatch()..start();
    final ownsRefreshState = !_isLiveRefreshing;
    if (ownsRefreshState && mounted) {
      setState(() {
        _isLiveRefreshing = true;
      });
    }
    try {
      final refreshed = await _fetchLiveDataForStation(station);
      debugPrint(
        'LiveStationTiming phase=live-data elapsedMs=${stopwatch.elapsedMilliseconds} '
        'provider=${station.provider} stationKey=${station.stationKey} '
        'station="${station.name}" success=${refreshed != null}',
      );
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
    } catch (error) {
      debugPrint(
        'LiveStationTiming phase=live-data elapsedMs=${stopwatch.elapsedMilliseconds} '
        'provider=${station.provider} stationKey=${station.stationKey} '
        'station="${station.name}" error=$error',
      );
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

  _NearbyStation? _preferredLiveStation(List<_NearbyStation> stations) {
    final preferredKey = widget.capabilities.preferredLiveStationKey;
    if (preferredKey == null) {
      return null;
    }
    for (final station in stations) {
      if (_stationKey(station) == preferredKey) {
        return station;
      }
    }
    return null;
  }
}
