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
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundOliva107StationKey,
      stationName: _wundergroundOliva107StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundOliva107StationId,
      latitude: _wundergroundOliva107StationLat,
      longitude: _wundergroundOliva107StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
  }

  void _addPilesLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
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
      stationKey: _avametGandiaCamiMarStationKey,
      stationName: _avametGandiaCamiMarStationName,
      provider: 'AVAMET',
      stationId: _avametGandiaCamiMarStationId,
      latitude: _avametGandiaCamiMarStationLat,
      longitude: _avametGandiaCamiMarStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundOliva94StationKey,
      stationName: _wundergroundOliva94StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundOliva94StationId,
      latitude: _wundergroundOliva94StationLat,
      longitude: _wundergroundOliva94StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _windguruDkPilesStationKey,
      stationName: _windguruDkPilesStationName,
      provider: 'WINDGURU_STATION',
      stationId: _windguruDkPilesStationId,
      latitude: _windguruDkPilesStationLat,
      longitude: _windguruDkPilesStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
  }

  void _addGandiaPlayaLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametGandiaCamiMarStationKey,
      stationName: _avametGandiaCamiMarStationName,
      provider: 'AVAMET',
      stationId: _avametGandiaCamiMarStationId,
      latitude: _avametGandiaCamiMarStationLat,
      longitude: _avametGandiaCamiMarStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
  }

  void _addDeniaLesDevesesLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametDeniaPlatjaPegoStationKey,
      stationName: _avametDeniaPlatjaPegoStationName,
      provider: 'AVAMET',
      stationId: _avametDeniaPlatjaPegoStationId,
      latitude: _avametDeniaPlatjaPegoStationLat,
      longitude: _avametDeniaPlatjaPegoStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _windguruDkPilesStationKey,
      stationName: _windguruDkPilesStationName,
      provider: 'WINDGURU_STATION',
      stationId: _windguruDkPilesStationId,
      latitude: _windguruDkPilesStationLat,
      longitude: _windguruDkPilesStationLon,
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
  }

  void _addDeniaPuntaMolinsLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametDeniaPlatjaPegoStationKey,
      stationName: _avametDeniaPlatjaPegoStationName,
      provider: 'AVAMET',
      stationId: _avametDeniaPlatjaPegoStationId,
      latitude: _avametDeniaPlatjaPegoStationLat,
      longitude: _avametDeniaPlatjaPegoStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametDeniaJoanChabasStationKey,
      stationName: _avametDeniaJoanChabasStationName,
      provider: 'AVAMET',
      stationId: _avametDeniaJoanChabasStationId,
      latitude: _avametDeniaJoanChabasStationLat,
      longitude: _avametDeniaJoanChabasStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _windguruDkPilesStationKey,
      stationName: _windguruDkPilesStationName,
      provider: 'WINDGURU_STATION',
      stationId: _windguruDkPilesStationId,
      latitude: _windguruDkPilesStationLat,
      longitude: _windguruDkPilesStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
  }

  void _addCalpeLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametCalpStationKey,
      stationName: _avametCalpStationName,
      provider: 'AVAMET',
      stationId: _avametCalpStationId,
      latitude: _avametCalpStationLat,
      longitude: _avametCalpStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametCalpMorroToixStationKey,
      stationName: _avametCalpMorroToixStationName,
      provider: 'AVAMET',
      stationId: _avametCalpMorroToixStationId,
      latitude: _avametCalpMorroToixStationLat,
      longitude: _avametCalpMorroToixStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametCalpToixMascaratStationKey,
      stationName: _avametCalpToixMascaratStationName,
      provider: 'AVAMET',
      stationId: _avametCalpToixMascaratStationId,
      latitude: _avametCalpToixMascaratStationLat,
      longitude: _avametCalpToixMascaratStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
  }

  void _addAlteaCapNegretLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametAlteaClubNauticoStationKey,
      stationName: _avametAlteaClubNauticoStationName,
      provider: 'AVAMET',
      stationId: _avametAlteaClubNauticoStationId,
      latitude: _avametAlteaClubNauticoStationLat,
      longitude: _avametAlteaClubNauticoStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametAlteaFoiaBaixaStationKey,
      stationName: _avametAlteaFoiaBaixaStationName,
      provider: 'AVAMET',
      stationId: _avametAlteaFoiaBaixaStationId,
      latitude: _avametAlteaFoiaBaixaStationLat,
      longitude: _avametAlteaFoiaBaixaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametAlteaElsArcsStationKey,
      stationName: _avametAlteaElsArcsStationName,
      provider: 'AVAMET',
      stationId: _avametAlteaElsArcsStationId,
      latitude: _avametAlteaElsArcsStationLat,
      longitude: _avametAlteaElsArcsStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
  }

  void _addVillajoyosaEspigonLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametVillajoyosaPuertoStationKey,
      stationName: _avametVillajoyosaPuertoStationName,
      provider: 'AVAMET',
      stationId: _avametVillajoyosaPuertoStationId,
      latitude: _avametVillajoyosaPuertoStationLat,
      longitude: _avametVillajoyosaPuertoStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametVillajoyosaStationKey,
      stationName: _avametVillajoyosaStationName,
      provider: 'AVAMET',
      stationId: _avametVillajoyosaStationId,
      latitude: _avametVillajoyosaStationLat,
      longitude: _avametVillajoyosaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
  }

  void _addVillajoyosaPlayaParaisoLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametVillajoyosaStationKey,
      stationName: _avametVillajoyosaStationName,
      provider: 'AVAMET',
      stationId: _avametVillajoyosaStationId,
      latitude: _avametVillajoyosaStationLat,
      longitude: _avametVillajoyosaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametVillajoyosaCarabassotStationKey,
      stationName: _avametVillajoyosaCarabassotStationName,
      provider: 'AVAMET',
      stationId: _avametVillajoyosaCarabassotStationId,
      latitude: _avametVillajoyosaCarabassotStationLat,
      longitude: _avametVillajoyosaCarabassotStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametVillajoyosaPuertoStationKey,
      stationName: _avametVillajoyosaPuertoStationName,
      provider: 'AVAMET',
      stationId: _avametVillajoyosaPuertoStationId,
      latitude: _avametVillajoyosaPuertoStationLat,
      longitude: _avametVillajoyosaPuertoStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
  }

  void _addTarifaLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _aemetTarifaStationKey,
      stationName: _aemetTarifaStationName,
      provider: 'AEMET',
      stationId: _aemetTarifaStationId,
      latitude: _aemetTarifaStationLat,
      longitude: _aemetTarifaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
  }

  void _addCulleraElPolloLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _inforatgeCulleraDosserStationKey,
      stationName: _inforatgeCulleraDosserStationName,
      provider: 'INFORATGE',
      stationId: _inforatgeCulleraDosserStationId,
      latitude: _inforatgeCulleraDosserStationLat,
      longitude: _inforatgeCulleraDosserStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametCulleraMarenyetStationKey,
      stationName: _avametCulleraMarenyetStationName,
      provider: 'AVAMET',
      stationId: _avametCulleraMarenyetStationId,
      latitude: _avametCulleraMarenyetStationLat,
      longitude: _avametCulleraMarenyetStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundCulleraSantAntoniStationKey,
      stationName: _wundergroundCulleraSantAntoniStationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundCulleraSantAntoniStationId,
      latitude: _wundergroundCulleraSantAntoniStationLat,
      longitude: _wundergroundCulleraSantAntoniStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
  }

  void _addElPerellonetLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _meteoclimaticPerelloStationKey,
      stationName: _meteoclimaticPerelloStationName,
      provider: 'METEOCLIMATIC',
      stationId: _meteoclimaticPerelloStationId,
      latitude: _meteoclimaticPerelloStationLat,
      longitude: _meteoclimaticPerelloStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametPerellonetEstellStationKey,
      stationName: _avametPerellonetEstellStationName,
      provider: 'AVAMET',
      stationId: _avametPerellonetEstellStationId,
      latitude: _avametPerellonetEstellStationLat,
      longitude: _avametPerellonetEstellStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametPerellonetRacoOllaStationKey,
      stationName: _avametPerellonetRacoOllaStationName,
      provider: 'AVAMET',
      stationId: _avametPerellonetRacoOllaStationId,
      latitude: _avametPerellonetRacoOllaStationLat,
      longitude: _avametPerellonetRacoOllaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametPerellonetTancatMiliaStationKey,
      stationName: _avametPerellonetTancatMiliaStationName,
      provider: 'AVAMET',
      stationId: _avametPerellonetTancatMiliaStationId,
      latitude: _avametPerellonetTancatMiliaStationLat,
      longitude: _avametPerellonetTancatMiliaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametPerellonetGarroferaStationKey,
      stationName: _avametPerellonetGarroferaStationName,
      provider: 'AVAMET',
      stationId: _avametPerellonetGarroferaStationId,
      latitude: _avametPerellonetGarroferaStationLat,
      longitude: _avametPerellonetGarroferaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametPerellonetTancatPipaStationKey,
      stationName: _avametPerellonetTancatPipaStationName,
      provider: 'AVAMET',
      stationId: _avametPerellonetTancatPipaStationId,
      latitude: _avametPerellonetTancatPipaStationLat,
      longitude: _avametPerellonetTancatPipaStationLon,
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

  bool _usesPilesLiveProfile() {
    final capabilities = _resolvedSpotCapabilities();
    return capabilities.liveStationProfile == pilesLiveStationProfile;
  }

  bool _usesGandiaPlayaLiveProfile() {
    final capabilities = _resolvedSpotCapabilities();
    return capabilities.liveStationProfile == gandiaPlayaLiveStationProfile;
  }

  bool _usesDeniaLesDevesesLiveProfile() {
    final capabilities = _resolvedSpotCapabilities();
    return capabilities.liveStationProfile == deniaLesDevesesLiveStationProfile;
  }

  bool _usesDeniaPuntaMolinsLiveProfile() {
    final capabilities = _resolvedSpotCapabilities();
    return capabilities.liveStationProfile ==
        deniaPuntaMolinsLiveStationProfile;
  }

  bool _usesCalpeLiveProfile() {
    final capabilities = _resolvedSpotCapabilities();
    return capabilities.liveStationProfile == calpeLiveStationProfile;
  }

  bool _usesAlteaCapNegretLiveProfile() {
    final capabilities = _resolvedSpotCapabilities();
    return capabilities.liveStationProfile == alteaCapNegretLiveStationProfile;
  }

  bool _usesVillajoyosaEspigonLiveProfile() {
    final capabilities = _resolvedSpotCapabilities();
    return capabilities.liveStationProfile ==
        villajoyosaEspigonLiveStationProfile;
  }

  bool _usesVillajoyosaPlayaParaisoLiveProfile() {
    final capabilities = _resolvedSpotCapabilities();
    return capabilities.liveStationProfile ==
        villajoyosaPlayaParaisoLiveStationProfile;
  }

  bool _usesElPerellonetLiveProfile() {
    final capabilities = _resolvedSpotCapabilities();
    return capabilities.liveStationProfile == elPerellonetLiveStationProfile;
  }

  bool _usesTarifaLiveProfile() {
    final capabilities = _resolvedSpotCapabilities();
    return capabilities.liveStationProfile == tarifaLiveStationProfile;
  }

  bool _usesCulleraElPolloLiveProfile() {
    final capabilities = _resolvedSpotCapabilities();
    return capabilities.liveStationProfile == culleraElPolloLiveStationProfile;
  }

  String _inforatgeStationCodeFor(String? stationId) {
    if (stationId == _inforatgePoliesportiuStationId) {
      return '01';
    }
    return '02';
  }

  String _inforatgeLiveUrlFor(String? stationId) {
    if (stationId == _inforatgePoliesportiuStationId) {
      return InforatgeOlivaNovaClient.livePoliesportiuUrl;
    }
    if (stationId == _inforatgeCulleraDosserStationId) {
      return InforatgeOlivaNovaClient.liveCulleraDosserUrl;
    }
    return InforatgeOlivaNovaClient.liveOlivaNovaUrl;
  }

  String _inforatgeHistoryUrlFor(String? stationId) {
    if (stationId == _inforatgeCulleraDosserStationId) {
      return InforatgeOlivaNovaClient.historyCulleraUrl;
    }
    return InforatgeOlivaNovaClient.historyOlivaUrl;
  }

  SpotCapabilities _resolvedSpotCapabilities() {
    final capabilities = widget.capabilities;
    if (capabilities.liveStationProfile == olivaCanalGorgsLiveStationProfile) {
      return olivaCanalGorgsSpotCapabilities;
    }
    if (capabilities.liveStationProfile == pilesLiveStationProfile) {
      return pilesSpotCapabilities;
    }
    if (capabilities.liveStationProfile == gandiaPlayaLiveStationProfile) {
      return gandiaPlayaSpotCapabilities;
    }
    if (capabilities.liveStationProfile == deniaLesDevesesLiveStationProfile) {
      return deniaLesDevesesSpotCapabilities;
    }
    if (capabilities.liveStationProfile == deniaPuntaMolinsLiveStationProfile) {
      return deniaPuntaMolinsSpotCapabilities;
    }
    if (capabilities.liveStationProfile == calpeLiveStationProfile) {
      return calpeSpotCapabilities;
    }
    if (capabilities.liveStationProfile == alteaCapNegretLiveStationProfile) {
      return alteaCapNegretSpotCapabilities;
    }
    if (capabilities.liveStationProfile ==
        villajoyosaEspigonLiveStationProfile) {
      return villajoyosaEspigonSpotCapabilities;
    }
    if (capabilities.liveStationProfile ==
        villajoyosaPlayaParaisoLiveStationProfile) {
      return villajoyosaPlayaParaisoSpotCapabilities;
    }
    if (capabilities.liveStationProfile == elPerellonetLiveStationProfile) {
      return elPerellonetSpotCapabilities;
    }
    if (capabilities.liveStationProfile == tarifaLiveStationProfile) {
      return defaultSpotCapabilitiesForName(widget.name);
    }
    if (capabilities.liveStationProfile == culleraElPolloLiveStationProfile) {
      return culleraElPolloSpotCapabilities;
    }

    final defaultCapabilities = defaultSpotCapabilitiesForName(widget.name);
    if (defaultCapabilities.liveStationProfile != null) {
      return defaultCapabilities;
    }

    return capabilities;
  }

  String _portusStationKey(int stationId) => 'puertos:$stationId';
}
