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
        final portusStationIds = _portusRealtimeStationIdsForSpot();
        for (final stationId in portusStationIds) {
          final snapshot = await _portusRealtimeWindClient.fetchWindStation(
            stationId: stationId,
          );
          if (snapshot == null) {
            continue;
          }
          final stationKey = _portusStationKey(snapshot.stationId);
          if (seenKeys.contains(stationKey)) {
            continue;
          }
          seenKeys.add(stationKey);
          stations.add(
            _NearbyStation(
              name: snapshot.stationName,
              distanceKm: _distanceKm(
                latitudeA: latitude,
                longitudeA: longitude,
                latitudeB: snapshot.latitude,
                longitudeB: snapshot.longitude,
              ),
              provider: 'PUERTOS',
              sourceKind: _StationSourceKind.observation,
              stationId: snapshot.stationId.toString(),
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
            pressureHpa: snapshot.pressureHpa,
            humidityPct: null,
            rainMm: null,
            observedAt: snapshot.observedAt,
          );
          final history = await _portusRealtimeWindClient.fetchWindHistory(
            stationId: snapshot.stationId,
          );
          historyByStation[stationKey] = history
              .map(
                (point) => _HistoricalWindPoint(
                  time: point.time,
                  windKnots: point.windKnots,
                  gustKnots: point.gustKnots,
                  windDirectionDeg: point.windDirectionDeg,
                  directionKind: point.windDirectionDeg == null
                      ? null
                      : _HistoricalDirectionKind.exact,
                ),
              )
              .toList(growable: false);
        }
      } catch (error) {
        technicalError ??= '$error';
      }

      if (usesOlivaCanalLiveProfile) {
        await _addOlivaLiveStations(
          latitude: latitude,
          longitude: longitude,
          stations: stations,
          liveDataByStation: liveDataByStation,
          historyByStation: historyByStation,
          seenKeys: seenKeys,
          setTechnicalError: (error) => technicalError ??= error,
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

  Future<void> _addOlivaLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Map<String, _StationLiveData> liveDataByStation,
    required Map<String, List<_HistoricalWindPoint>> historyByStation,
    required Set<String> seenKeys,
    required void Function(String error) setTechnicalError,
  }) async {
    try {
      final aemetOlivaHistory = await _aemetObservationClient
          .fetchStationObservations(
            stationId: '8058X',
            referenceLatitude: latitude,
            referenceLongitude: longitude,
          );
      historyByStation['8058X'] = aemetOlivaHistory
          .where((snapshot) => snapshot.observedAt != null)
          .map(
            (snapshot) => _HistoricalWindPoint(
              time: snapshot.observedAt!,
              windKnots: snapshot.windKnots ?? 0,
              gustKnots: snapshot.gustKnots,
              windDirectionDeg: snapshot.windDirectionDeg,
              directionKind: snapshot.windDirectionDeg == null
                  ? null
                  : _HistoricalDirectionKind.exact,
            ),
          )
          .toList(growable: false);
    } catch (error) {
      setTechnicalError('$error');
    }

    InforatgeOlivaNovaFeed inforatgePoliesportiuFeed =
        const InforatgeOlivaNovaFeed(
          points: <InforatgeOlivaNovaPoint>[],
          latestSnapshot: null,
        );
    try {
      inforatgePoliesportiuFeed = await _inforatgeOlivaNovaClient.fetchFeed(
        stationCode: '01',
        liveUrl: InforatgeOlivaNovaClient.livePoliesportiuUrl,
      );
    } catch (error) {
      setTechnicalError('$error');
    }

    InforatgeOlivaNovaFeed inforatgeFeed = const InforatgeOlivaNovaFeed(
      points: <InforatgeOlivaNovaPoint>[],
      latestSnapshot: null,
    );
    try {
      inforatgeFeed = await _inforatgeOlivaNovaClient.fetchFeed(
        stationCode: '02',
        liveUrl: InforatgeOlivaNovaClient.liveOlivaNovaUrl,
      );
    } catch (error) {
      setTechnicalError('$error');
    }

    AiguaBlancaMeteoFeed aiguaBlancaFeed = const AiguaBlancaMeteoFeed(
      points: <AiguaBlancaMeteoPoint>[],
      latestSnapshot: null,
    );
    try {
      aiguaBlancaFeed = await _aiguaBlancaMeteoClient.fetchFeed();
    } catch (error) {
      setTechnicalError('$error');
    }

    AvametObservationSnapshot? avametSnapshot;
    try {
      avametSnapshot = await _avametObservationClient.fetchStationObservation(
        stationId: _avametOlivaStationId,
      );
    } catch (error) {
      setTechnicalError('$error');
    }

    AvametObservationSnapshot? avametOlivaPlayaSnapshot;
    try {
      avametOlivaPlayaSnapshot = await _avametObservationClient
          .fetchStationObservation(stationId: _avametOlivaPlayaStationId);
    } catch (error) {
      setTechnicalError('$error');
    }

    final avametHistory = await _loadAvametHistory(_avametOlivaStationId);
    final avametOlivaPlayaHistory = await _loadAvametHistory(
      _avametOlivaPlayaStationId,
    );

    _addInforatgeStation(
      stations: stations,
      liveDataByStation: liveDataByStation,
      historyByStation: historyByStation,
      seenKeys: seenKeys,
      stationKey: _inforatgePoliesportiuStationKey,
      stationName: _inforatgePoliesportiuStationName,
      stationId: _inforatgePoliesportiuStationId,
      latitude: _inforatgePoliesportiuLat,
      longitude: _inforatgePoliesportiuLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
      feed: inforatgePoliesportiuFeed,
    );
    _addInforatgeStation(
      stations: stations,
      liveDataByStation: liveDataByStation,
      historyByStation: historyByStation,
      seenKeys: seenKeys,
      stationKey: _meteoclimaticOlivaNovaStationKey,
      stationName: _meteoclimaticOlivaNovaStationName,
      stationId: _meteoclimaticOlivaNovaStationId,
      latitude: _meteoclimaticOlivaNovaLat,
      longitude: _meteoclimaticOlivaNovaLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
      feed: inforatgeFeed,
    );
    _addAiguaBlancaStation(
      stations: stations,
      liveDataByStation: liveDataByStation,
      historyByStation: historyByStation,
      seenKeys: seenKeys,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
      feed: aiguaBlancaFeed,
    );
    _addAvametStation(
      stations: stations,
      liveDataByStation: liveDataByStation,
      historyByStation: historyByStation,
      seenKeys: seenKeys,
      stationKey: _avametOlivaStationKey,
      stationName: _avametOlivaStationName,
      stationId: _avametOlivaStationId,
      latitude: _avametOlivaStationLat,
      longitude: _avametOlivaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
      snapshot: avametSnapshot,
      history: avametHistory,
      requireWindData: false,
    );
    _addAvametStation(
      stations: stations,
      liveDataByStation: liveDataByStation,
      historyByStation: historyByStation,
      seenKeys: seenKeys,
      stationKey: _avametOlivaPlayaStationKey,
      stationName: _avametOlivaPlayaStationName,
      stationId: _avametOlivaPlayaStationId,
      latitude: _avametOlivaPlayaStationLat,
      longitude: _avametOlivaPlayaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
      snapshot: avametOlivaPlayaSnapshot,
      history: avametOlivaPlayaHistory,
      requireWindData: true,
    );
  }

  Future<List<_HistoricalWindPoint>> _loadAvametHistory(
    String stationId,
  ) async {
    try {
      final intradayHistory = await _avametIntradayHistoryClient
          .fetchIntradayWindHistory(stationId: stationId);
      final mappedIntraday = intradayHistory
          .map(
            (point) => _HistoricalWindPoint(
              time: point.time,
              windKnots: point.windKnots,
              windDirectionDeg: point.windDirectionDeg,
              directionKind: point.windDirectionDeg == null
                  ? null
                  : _HistoricalDirectionKind.exact,
            ),
          )
          .toList(growable: false);
      if (mappedIntraday.isNotEmpty) {
        return mappedIntraday;
      }
    } catch (_) {
      // Fall back to daily history below.
    }
    try {
      final dailyHistory = await _avametDailyHistoryClient
          .fetchDailyWindHistory(stationId: stationId);
      return dailyHistory
          .map(
            (point) => _HistoricalWindPoint(
              time: point.time,
              windKnots: point.windKnots,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const <_HistoricalWindPoint>[];
    }
  }

  void _addInforatgeStation({
    required List<_NearbyStation> stations,
    required Map<String, _StationLiveData> liveDataByStation,
    required Map<String, List<_HistoricalWindPoint>> historyByStation,
    required Set<String> seenKeys,
    required String stationKey,
    required String stationName,
    required String stationId,
    required double latitude,
    required double longitude,
    required double referenceLatitude,
    required double referenceLongitude,
    required InforatgeOlivaNovaFeed feed,
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
        provider: 'INFORATGE',
        sourceKind: _StationSourceKind.observation,
        stationId: stationId,
        proximityLabel: null,
        stationKey: stationKey,
        latitude: latitude,
        longitude: longitude,
      ),
    );
    final snapshot = feed.latestSnapshot;
    liveDataByStation[stationKey] = _StationLiveData(
      windKnots: snapshot?.windKnots?.toDouble(),
      windDeg: snapshot?.windDirectionDeg,
      gustKnots: snapshot?.gustKnots?.toDouble(),
      tempC: snapshot?.tempC,
      pressureHpa: snapshot?.pressureHpa,
      humidityPct: snapshot?.humidityPct,
      rainMm: snapshot?.rainMm,
      observedAt: snapshot?.observedAt,
    );
    historyByStation[stationKey] = feed.points
        .map(
          (point) => _HistoricalWindPoint(
            time: point.time,
            windKnots: point.windKnots,
            windDirectionDeg: point.windDirectionDeg,
            directionKind: point.windDirectionDeg == null
                ? null
                : _HistoricalDirectionKind.exact,
          ),
        )
        .toList(growable: false);
  }

  void _addAiguaBlancaStation({
    required List<_NearbyStation> stations,
    required Map<String, _StationLiveData> liveDataByStation,
    required Map<String, List<_HistoricalWindPoint>> historyByStation,
    required Set<String> seenKeys,
    required double referenceLatitude,
    required double referenceLongitude,
    required AiguaBlancaMeteoFeed feed,
  }) {
    final stationKey = _aiguaBlancaStationKey;
    if (seenKeys.contains(stationKey)) {
      return;
    }
    seenKeys.add(stationKey);
    stations.add(
      _NearbyStation(
        name: _aiguaBlancaStationName,
        distanceKm: _distanceKm(
          latitudeA: referenceLatitude,
          longitudeA: referenceLongitude,
          latitudeB: _aiguaBlancaStationLat,
          longitudeB: _aiguaBlancaStationLon,
        ),
        provider: 'AIGUABLANCA',
        sourceKind: _StationSourceKind.observation,
        stationId: _aiguaBlancaStationId,
        proximityLabel: null,
        stationKey: stationKey,
        latitude: _aiguaBlancaStationLat,
        longitude: _aiguaBlancaStationLon,
      ),
    );
    final snapshot = feed.latestSnapshot;
    liveDataByStation[stationKey] = _StationLiveData(
      windKnots: snapshot?.windKnots?.toDouble(),
      windDeg: snapshot?.windDirectionDeg,
      gustKnots: snapshot?.gustKnots?.toDouble(),
      tempC: snapshot?.tempC,
      pressureHpa: snapshot?.pressureHpa,
      humidityPct: snapshot?.humidityPct,
      rainMm: snapshot?.rainMm,
      observedAt: snapshot?.observedAt,
    );
    historyByStation[stationKey] = feed.points
        .map(
          (point) => _HistoricalWindPoint(
            time: point.time,
            windKnots: point.windKnots,
            gustKnots: point.gustKnots,
            windDirectionDeg: point.windDirectionDeg,
            directionKind: point.windDirectionDeg == null
                ? null
                : _HistoricalDirectionKind.exact,
          ),
        )
        .toList(growable: false);
  }

  void _addAvametStation({
    required List<_NearbyStation> stations,
    required Map<String, _StationLiveData> liveDataByStation,
    required Map<String, List<_HistoricalWindPoint>> historyByStation,
    required Set<String> seenKeys,
    required String stationKey,
    required String stationName,
    required String stationId,
    required double latitude,
    required double longitude,
    required double referenceLatitude,
    required double referenceLongitude,
    required AvametObservationSnapshot? snapshot,
    required List<_HistoricalWindPoint> history,
    required bool requireWindData,
  }) {
    final hasWindData =
        snapshot?.windKnots != null ||
        snapshot?.windDirectionDeg != null ||
        snapshot?.gustKnots != null ||
        history.isNotEmpty;
    if (seenKeys.contains(stationKey) || (requireWindData && !hasWindData)) {
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
        provider: 'AVAMET',
        sourceKind: _StationSourceKind.observation,
        stationId: stationId,
        proximityLabel: null,
        stationKey: stationKey,
        latitude: latitude,
        longitude: longitude,
      ),
    );
    liveDataByStation[stationKey] = _StationLiveData(
      windKnots: snapshot?.windKnots,
      windDeg: snapshot?.windDirectionDeg,
      gustKnots: snapshot?.gustKnots,
      tempC: snapshot?.tempC,
      pressureHpa: snapshot?.pressureHpa?.round(),
      humidityPct: snapshot?.humidityPct,
      rainMm: snapshot?.rainMm,
      observedAt: snapshot?.observedAt,
    );
    historyByStation[stationKey] = history;
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
