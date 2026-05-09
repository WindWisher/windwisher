part of '../../spot_detail_page.dart';

extension _SpotDetailLiveStationDataLoader on _SpotDetailPageState {
  Future<_StationLiveData?> _fetchLiveDataForStation(
    _NearbyStation station,
  ) async {
    if (station.provider == 'AVAMET') {
      final snapshot = await _avametObservationClient.fetchStationObservation(
        stationId: station.stationId!,
      );
      if (snapshot == null) {
        return null;
      }
      return _StationLiveData(
        windKnots: snapshot.windKnots?.toDouble(),
        windDeg: snapshot.windDirectionDeg,
        gustKnots: snapshot.gustKnots?.toDouble(),
        tempC: snapshot.tempC,
        pressureHpa: snapshot.pressureHpa?.round(),
        humidityPct: snapshot.humidityPct,
        rainMm: snapshot.rainMm,
        observedAt: snapshot.observedAt,
      );
    }
    if (station.provider == 'INFORATGE') {
      final feed = await _inforatgeOlivaNovaClient.fetchFeed(
        stationCode: station.stationId == _inforatgePoliesportiuStationId
            ? '01'
            : '02',
        liveUrl: station.stationId == _inforatgePoliesportiuStationId
            ? InforatgeOlivaNovaClient.livePoliesportiuUrl
            : InforatgeOlivaNovaClient.liveOlivaNovaUrl,
      );
      final snapshot = feed.latestSnapshot;
      if (snapshot == null) {
        return null;
      }
      return _StationLiveData(
        windKnots: snapshot.windKnots?.toDouble(),
        windDeg: snapshot.windDirectionDeg,
        gustKnots: snapshot.gustKnots?.toDouble(),
        tempC: snapshot.tempC,
        pressureHpa: snapshot.pressureHpa,
        humidityPct: snapshot.humidityPct,
        rainMm: snapshot.rainMm,
        observedAt: snapshot.observedAt,
      );
    }
    if (station.provider == 'AIGUABLANCA') {
      final feed = await _aiguaBlancaMeteoClient.fetchFeed();
      final snapshot = feed.latestSnapshot;
      if (snapshot == null) {
        return null;
      }
      return _StationLiveData(
        windKnots: snapshot.windKnots?.toDouble(),
        windDeg: snapshot.windDirectionDeg,
        gustKnots: snapshot.gustKnots?.toDouble(),
        tempC: snapshot.tempC,
        pressureHpa: snapshot.pressureHpa,
        humidityPct: snapshot.humidityPct,
        rainMm: snapshot.rainMm,
        observedAt: snapshot.observedAt,
      );
    }
    if (station.provider == 'PUERTOS') {
      final stationId = int.tryParse(station.stationId ?? '');
      if (stationId == null) {
        return null;
      }
      final snapshot = await _portusRealtimeWindClient.fetchWindStation(
        stationId: stationId,
      );
      if (snapshot == null) {
        return null;
      }
      return _StationLiveData(
        windKnots: snapshot.windKnots,
        windDeg: snapshot.windDirectionDeg,
        gustKnots: snapshot.gustKnots,
        tempC: snapshot.tempC,
        pressureHpa: snapshot.pressureHpa,
        humidityPct: null,
        rainMm: null,
        observedAt: snapshot.observedAt,
        observedAtLabel: snapshot.observedAtLabel,
      );
    }
    if (station.stationId == null) {
      return null;
    }
    final snapshot = await _aemetObservationClient.fetchStationObservation(
      stationId: station.stationId!,
      referenceLatitude: station.latitude,
      referenceLongitude: station.longitude,
    );
    if (snapshot == null) {
      return null;
    }
    return _StationLiveData(
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
      final stations = <_NearbyStation>[];
      final liveDataByStation = <String, _StationLiveData>{};
      final historyByStation = <String, List<_HistoricalWindPoint>>{};
      final seenKeys = <String>{};
      String? errorMessage;
      String? technicalError;

      List<AemetObservationStationSnapshot> snapshots =
          const <AemetObservationStationSnapshot>[];
      if (!usesOlivaCanalLiveProfile) {
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

  void _addOlivaLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _aemetOlivaStationKey,
      stationName: _aemetOlivaStationName,
      provider: 'AEMET',
      stationId: _aemetOlivaStationId,
      latitude: _aemetOlivaStationLat,
      longitude: _aemetOlivaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _inforatgePoliesportiuStationKey,
      stationName: _inforatgePoliesportiuStationName,
      provider: 'INFORATGE',
      stationId: _inforatgePoliesportiuStationId,
      latitude: _inforatgePoliesportiuLat,
      longitude: _inforatgePoliesportiuLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _meteoclimaticOlivaNovaStationKey,
      stationName: _meteoclimaticOlivaNovaStationName,
      provider: 'INFORATGE',
      stationId: _meteoclimaticOlivaNovaStationId,
      latitude: _meteoclimaticOlivaNovaLat,
      longitude: _meteoclimaticOlivaNovaLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _aiguaBlancaStationKey,
      stationName: _aiguaBlancaStationName,
      provider: 'AIGUABLANCA',
      stationId: _aiguaBlancaStationId,
      latitude: _aiguaBlancaStationLat,
      longitude: _aiguaBlancaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametOlivaStationKey,
      stationName: _avametOlivaStationName,
      provider: 'AVAMET',
      stationId: _avametOlivaStationId,
      latitude: _avametOlivaStationLat,
      longitude: _avametOlivaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametOlivaPlayaStationKey,
      stationName: _avametOlivaPlayaStationName,
      provider: 'AVAMET',
      stationId: _avametOlivaPlayaStationId,
      latitude: _avametOlivaPlayaStationLat,
      longitude: _avametOlivaPlayaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
  }

  Future<void> _addConfiguredPortusStationMetadata({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) async {
    final portusStationIds = _portusRealtimeStationIdsForSpot();
    for (final stationId in portusStationIds) {
      final station = await _portusRealtimeWindClient.fetchWindStationMetadata(
        stationId: stationId,
      );
      if (station == null) {
        continue;
      }
      _addLiveStationMetadata(
        stations: stations,
        seenKeys: seenKeys,
        stationKey: _portusStationKey(station.id),
        stationName: station.name,
        provider: 'PUERTOS',
        stationId: station.id.toString(),
        latitude: station.latitude,
        longitude: station.longitude,
        referenceLatitude: latitude,
        referenceLongitude: longitude,
      );
    }
  }

  void _addLiveStationMetadata({
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
    required String stationKey,
    required String stationName,
    required String provider,
    required String stationId,
    required double latitude,
    required double longitude,
    required double referenceLatitude,
    required double referenceLongitude,
  }) {
    if (seenKeys.contains(stationKey)) {
      return;
    }
    seenKeys.add(stationKey);
    stations.add(
      _NearbyStation(
        name: stationName,
        distanceKm: _distanceKm(
          latitudeA: referenceLatitude,
          longitudeA: referenceLongitude,
          latitudeB: latitude,
          longitudeB: longitude,
        ),
        provider: provider,
        sourceKind: _StationSourceKind.observation,
        stationId: stationId,
        proximityLabel: null,
        stationKey: stationKey,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  String? _preferredLiveStationId() {
    return _resolvedSpotCapabilities().preferredAemetLiveStationId;
  }

  List<int> _portusRealtimeStationIdsForSpot() {
    final configuredStationIds =
        _resolvedSpotCapabilities().portusRealtimeStationIds;
    if (configuredStationIds.isNotEmpty) {
      return configuredStationIds;
    }
    final normalized = '${widget.name} ${widget.area}'.toLowerCase();
    if (normalized.contains('gandia') || normalized.contains('gandía')) {
      return const <int>[4634];
    }
    if (normalized.contains('valencia') || normalized.contains('malvarrosa')) {
      return const <int>[4635];
    }
    if (normalized.contains('sagunto')) {
      return const <int>[4632, 4633];
    }
    if (normalized.contains('alicante')) {
      return const <int>[4651, 4652, 4653];
    }
    if (normalized.contains('castellon') ||
        normalized.contains('castelló') ||
        normalized.contains('castello')) {
      return const <int>[4660, 4661, 4662, 4663, 4664, 4665];
    }
    return const <int>[];
  }

  bool _usesOlivaCanalLiveProfile() {
    final capabilities = _resolvedSpotCapabilities();
    return capabilities.includeOlivaReferenceLiveStations;
  }

  SpotCapabilities _resolvedSpotCapabilities() {
    final capabilities = widget.capabilities;
    if (capabilities.liveStationProfile == olivaCanalGorgsLiveStationProfile) {
      return olivaCanalGorgsSpotCapabilities;
    }

    final defaultCapabilities = defaultSpotCapabilitiesForName(widget.name);
    if (defaultCapabilities.liveStationProfile != null) {
      return defaultCapabilities;
    }

    return capabilities;
  }

  String _portusStationKey(int stationId) => 'puertos:$stationId';
}
