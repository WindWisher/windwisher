part of '../../spot_detail_page.dart';

extension _SpotDetailLiveStationDataLoader on _SpotDetailPageState {
  Future<_LiveStationsLoadResult> _resolveLiveStations() async {
    final latitude = widget.latitude;
    final longitude = widget.longitude;
    if (latitude == null || longitude == null) {
      return const _LiveStationsLoadResult(
        stations: <_NearbyStation>[],
        liveDataByStation: <String, _StationLiveData>{},
        historicalSeriesByStation: <String, List<_HistoricalWindPoint>>{},
        source: _LiveStationsDataSource.unavailable,
        message:
            'Este spot no tiene coordenadas para buscar estaciones reales cercanas.',
      );
    }

    try {
      final usesOlivaCanalLiveProfile = _usesOlivaCanalLiveProfile();
      final usesPilesLiveProfile = _usesPilesLiveProfile();
      final usesGandiaPlayaLiveProfile = _usesGandiaPlayaLiveProfile();
      final usesDeniaLesDevesesLiveProfile = _usesDeniaLesDevesesLiveProfile();
      final usesDeniaPuntaMolinsLiveProfile =
          _usesDeniaPuntaMolinsLiveProfile();
      final usesCalpeLiveProfile = _usesCalpeLiveProfile();
      final usesAlteaCapNegretLiveProfile = _usesAlteaCapNegretLiveProfile();
      final usesElCampelloPlayaMuchavistaLiveProfile =
          _usesElCampelloPlayaMuchavistaLiveProfile();
      final usesSantaPolaPlatjaLissaLiveProfile =
          _usesSantaPolaPlatjaLissaLiveProfile();
      final usesVillajoyosaEspigonLiveProfile =
          _usesVillajoyosaEspigonLiveProfile();
      final usesVillajoyosaPlayaParaisoLiveProfile =
          _usesVillajoyosaPlayaParaisoLiveProfile();
      final usesElPerellonetLiveProfile = _usesElPerellonetLiveProfile();
      final usesTarifaLiveProfile = _usesTarifaLiveProfile();
      final usesCulleraElPolloLiveProfile = _usesCulleraElPolloLiveProfile();
      final usesXeracoLiveProfile = _usesXeracoLiveProfile();
      final usesDakhlaLiveProfile = _usesDakhlaLiveProfile();
      final usesEssaouiraLiveProfile = _usesEssaouiraLiveProfile();
      final stations = <_NearbyStation>[];
      final liveDataByStation = <String, _StationLiveData>{};
      final historyByStation = <String, List<_HistoricalWindPoint>>{};
      final seenKeys = <String>{};
      String? errorMessage;
      String? technicalError;

      List<AemetObservationStationSnapshot> snapshots =
          const <AemetObservationStationSnapshot>[];
      if (!usesOlivaCanalLiveProfile &&
          !usesPilesLiveProfile &&
          !usesGandiaPlayaLiveProfile &&
          !usesDeniaLesDevesesLiveProfile &&
          !usesDeniaPuntaMolinsLiveProfile &&
          !usesCalpeLiveProfile &&
          !usesAlteaCapNegretLiveProfile &&
          !usesElCampelloPlayaMuchavistaLiveProfile &&
          !usesSantaPolaPlatjaLissaLiveProfile &&
          !usesVillajoyosaEspigonLiveProfile &&
          !usesVillajoyosaPlayaParaisoLiveProfile &&
          !usesElPerellonetLiveProfile &&
          !usesTarifaLiveProfile &&
          !usesCulleraElPolloLiveProfile &&
          !usesXeracoLiveProfile &&
          !usesDakhlaLiveProfile &&
          !usesEssaouiraLiveProfile) {
        try {
          snapshots = await _aemetObservationClient.fetchNearestStations(
            latitude: latitude,
            longitude: longitude,
            limit: 20,
            maxDistanceKm: 5,
            preferredStationId: _preferredLiveStationId(),
          );
        } catch (error) {
          errorMessage = !EnvConfig.aemetAccessConfigured
              ? 'AEMET sin API key cargada para observaciones reales.'
              : 'No se han podido cargar observaciones reales de AEMET.';
          technicalError = '$error';
        }
      }

      for (final snapshot in snapshots) {
        final normalizedName = snapshot.stationName.toLowerCase();
        final isOlivaClubNautico =
            normalizedName.contains('club nautico') &&
            normalizedName.contains('oliva');
        final stationName = snapshot.stationId == '8058X'
            ? 'AEMET Oliva'
            : (isOlivaClubNautico
                  ? 'Club Nautico de Oliva'
                  : snapshot.stationName);
        final stationKey = snapshot.stationId;
        if (seenKeys.contains(stationKey)) {
          continue;
        }
        seenKeys.add(stationKey);
        stations.add(
          _NearbyStation(
            name: stationName,
            distanceKm: snapshot.distanceKm,
            provider: 'AEMET',
            sourceKind: _StationSourceKind.observation,
            stationId: snapshot.stationId,
            proximityLabel: null,
            stationKey: stationKey,
            latitude: snapshot.latitude,
            longitude: snapshot.longitude,
          ),
        );
        liveDataByStation[stationKey] = _StationLiveData(
          windKnots: snapshot.windKnots,
          windDeg: snapshot.windDirectionDeg,
          gustKnots: snapshot.gustKnots,
          tempC: snapshot.tempC,
          pressureHpa: snapshot.pressureHpa?.round(),
          humidityPct: snapshot.humidityPct,
          rainMm: snapshot.rainMm,
          observedAt: snapshot.observedAt,
        );
      }

      try {
        await _addConfiguredPortusStationMetadata(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      } catch (error) {
        technicalError ??= '$error';
      }

      if (usesOlivaCanalLiveProfile) {
        _addOlivaLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesPilesLiveProfile) {
        _addPilesLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesGandiaPlayaLiveProfile) {
        _addGandiaPlayaLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesDeniaLesDevesesLiveProfile) {
        _addDeniaLesDevesesLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesDeniaPuntaMolinsLiveProfile) {
        _addDeniaPuntaMolinsLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesCalpeLiveProfile) {
        _addCalpeLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesAlteaCapNegretLiveProfile) {
        _addAlteaCapNegretLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesElCampelloPlayaMuchavistaLiveProfile) {
        _addElCampelloPlayaMuchavistaLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesSantaPolaPlatjaLissaLiveProfile) {
        _addSantaPolaPlatjaLissaLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesVillajoyosaEspigonLiveProfile) {
        _addVillajoyosaEspigonLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesVillajoyosaPlayaParaisoLiveProfile) {
        _addVillajoyosaPlayaParaisoLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesElPerellonetLiveProfile) {
        _addElPerellonetLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesTarifaLiveProfile) {
        _addTarifaLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesCulleraElPolloLiveProfile) {
        _addCulleraElPolloLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesXeracoLiveProfile) {
        _addXeracoLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesDakhlaLiveProfile) {
        _addDakhlaLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }
      if (usesEssaouiraLiveProfile) {
        _addEssaouiraLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          seenKeys: seenKeys,
        );
      }

      stations.sort((a, b) {
        final distanceCompare = a.distanceKm.compareTo(b.distanceKm);
        if (distanceCompare != 0) {
          return distanceCompare;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      if (stations.isEmpty) {
        return _LiveStationsLoadResult(
          stations: const <_NearbyStation>[],
          liveDataByStation: const <String, _StationLiveData>{},
          historicalSeriesByStation:
              const <String, List<_HistoricalWindPoint>>{},
          source: _LiveStationsDataSource.unavailable,
          message:
              errorMessage ??
              'No se han podido cargar estaciones de observacion reales.',
          technicalError: technicalError,
        );
      }
      return _LiveStationsLoadResult(
        stations: stations,
        liveDataByStation: liveDataByStation,
        historicalSeriesByStation: historyByStation,
        source: _LiveStationsDataSource.real,
      );
    } catch (error) {
      return _LiveStationsLoadResult(
        stations: const <_NearbyStation>[],
        liveDataByStation: const <String, _StationLiveData>{},
        historicalSeriesByStation: const <String, List<_HistoricalWindPoint>>{},
        source: _LiveStationsDataSource.unavailable,
        message: !EnvConfig.aemetAccessConfigured
            ? 'AEMET sin API key cargada para observaciones reales.'
            : 'No se han podido cargar observaciones reales de AEMET.',
        technicalError: '$error',
      );
    }
  }

  String? _preferredLiveStationId() {
    return _resolvedSpotCapabilities().preferredAemetLiveStationId;
  }
}
