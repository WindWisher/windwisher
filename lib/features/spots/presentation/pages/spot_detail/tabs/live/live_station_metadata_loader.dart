part of '../../spot_detail_page.dart';

extension _SpotDetailLiveStationMetadataLoader on _SpotDetailPageState {
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
