// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailLiveMaritimeObservationsController
    on _SpotDetailPageState {
  static const int _maritimeObservationsPageSize = 10;

  double get _maritimeObservationsRadiusKm {
    final normalizedName = widget.name.toLowerCase();
    if (normalizedName.contains('tarifa')) {
      return 50;
    }
    return 10;
  }

  bool _canLoadMaritimeObservations() {
    return widget.latitude != null &&
        widget.longitude != null &&
        _spotMaritimeObservationsClient != null &&
        _hasMaritimeObservationsSupport();
  }

  bool _hasMaritimeObservationsSupport() {
    final normalizedName = widget.name.toLowerCase();
    return normalizedName.contains('tarifa');
  }

  Future<void> _loadMaritimeObservations() {
    return _loadMaritimeObservationsPage(append: false);
  }

  Future<void> _loadMoreMaritimeObservations() {
    return _loadMaritimeObservationsPage(append: true);
  }

  Future<void> _loadMaritimeObservationsPage({required bool append}) async {
    if (_isMaritimeObservationsLoading || !_canLoadMaritimeObservations()) {
      return;
    }
    final client = _spotMaritimeObservationsClient;
    final latitude = widget.latitude;
    final longitude = widget.longitude;
    if (client == null || latitude == null || longitude == null) {
      return;
    }

    setState(() {
      _isMaritimeObservationsLoading = true;
      _maritimeObservationsError = null;
    });

    try {
      final offset = append ? _maritimeObservationsLoadedCount : 0;
      final result = await client.fetchNearby(
        spotName: widget.name,
        latitude: latitude,
        longitude: longitude,
        radiusKm: _maritimeObservationsRadiusKm,
        maxResults: _maritimeObservationsPageSize,
        offset: offset,
      );
      final observations = result.observations;
      final liveWindObservations = observations
          .where(
            (observation) =>
                observation.windKnots != null && observation.windDirDeg != null,
          )
          .toList(growable: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _maritimeObservationsLoaded = true;
        _maritimeObservationsTotal = result.total;
        _maritimeObservationsLoadedCount = append
            ? (_maritimeObservationsLoadedCount + liveWindObservations.length)
                  .clamp(0, result.total)
            : liveWindObservations.length;
        _maritimeObservationsHasMore = result.hasMore;
        final current = _liveStationsLoadResult;
        if (current == null) {
          return;
        }
        final stations = append
            ? current.stations.toList(growable: true)
            : current.stations
                  .where((station) => !_isMaritimeObservationProvider(station))
                  .toList(growable: true);
        final liveData = Map<String, _StationLiveData>.from(
          current.liveDataByStation,
        );
        if (!append) {
          liveData.removeWhere(_isMaritimeObservationStationKey);
        }
        final existingStationKeys = stations.map(_stationKey).toSet();
        String? firstObservationKey;

        for (final observation in liveWindObservations) {
          firstObservationKey ??= observation.stationKey;
          if (!existingStationKeys.add(observation.stationKey)) {
            continue;
          }
          stations.add(
            _NearbyStation(
              name: 'Maritima · ${observation.displayName}',
              distanceKm: observation.distanceKm,
              provider: observation.provider,
              sourceKind: _StationSourceKind.observation,
              stationId: observation.platformId,
              proximityLabel: '${observation.distanceKm.toStringAsFixed(1)} km',
              stationKey: observation.stationKey,
              latitude: observation.latitude,
              longitude: observation.longitude,
            ),
          );
          liveData[observation.stationKey] = _StationLiveData(
            windKnots: observation.windKnots,
            windDeg: observation.windDirDeg,
            gustKnots: observation.gustKnots,
            tempC: observation.airTempC,
            pressureHpa: observation.pressureHpa,
            humidityPct: observation.humidityPct,
            rainMm: null,
            observedAt: observation.observedAt,
            observedAtLabel: observation.platformType,
            seaSurfaceTempC: observation.seaSurfaceTempC,
            waveHeightM: observation.waveHeightM,
            wavePeriodS: observation.wavePeriodS,
          );
        }

        if (!append) {
          final stationKeyToSelect = firstObservationKey;
          if (stationKeyToSelect != null &&
              stations.any(
                (station) => _stationKey(station) == stationKeyToSelect,
              )) {
            _selectedStation = stationKeyToSelect;
            _applyHistoricalDefaultsForStation(
              stations.firstWhere(
                (station) => _stationKey(station) == stationKeyToSelect,
              ),
            );
          }
        }

        _liveStationsLoadResult = _LiveStationsLoadResult(
          stations: stations,
          liveDataByStation: liveData,
          historicalSeriesByStation: current.historicalSeriesByStation,
          source: current.source,
          message: current.message,
          technicalError: current.technicalError,
        );
      });
      if (observations.isEmpty && mounted) {
        _showLiveRefreshFeedback(
          append
              ? 'No hay mas observaciones maritimas dentro del radio de busqueda.'
              : 'No se han encontrado observaciones maritimas dentro del radio de busqueda.',
        );
      } else if (liveWindObservations.isEmpty && mounted) {
        _showLiveRefreshFeedback(
          'Hay ${observations.length} observaciones maritimas, pero ahora no traen viento util.',
        );
      } else if (mounted) {
        _showLiveRefreshFeedback(
          append
              ? 'Se han cargado ${liveWindObservations.length} observaciones maritimas con viento mas.'
              : 'Se han cargado ${liveWindObservations.length} observaciones maritimas con viento.',
        );
      }
    } catch (error) {
      debugPrint('MaritimeObservations load failed: $error');
      if (!mounted) {
        return;
      }
      setState(() {
        _maritimeObservationsError =
            'No se pudieron cargar observaciones maritimas.';
      });
      _showLiveRefreshFeedback(
        'No se pudieron cargar observaciones maritimas.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMaritimeObservationsLoading = false;
        });
      }
    }
  }

  bool _isMaritimeObservationProvider(_NearbyStation station) {
    return station.provider == 'MADIS_MARITIME' ||
        station.provider == 'COPERNICUS_MARINE';
  }

  bool _isMaritimeObservationStationKey(String stationKey, _StationLiveData _) {
    return stationKey.startsWith('madis-maritime:') ||
        stationKey.startsWith('copernicus-marine:');
  }
}
