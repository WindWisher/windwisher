part of '../../spot_detail_page.dart';

extension _SpotDetailLiveStationPayloadLoader on _SpotDetailPageState {
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
        stationCode: _inforatgeStationCodeFor(station.stationId),
        liveUrl: _inforatgeLiveUrlFor(station.stationId),
        historyUrl: _inforatgeHistoryUrlFor(station.stationId),
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
    if (station.provider == 'METEOPILES') {
      final snapshot = await _meteopilesLiveClient.fetchSnapshot();
      if (snapshot == null) {
        return null;
      }
      return _StationLiveData(
        windKnots: snapshot.windKnots,
        windDeg: snapshot.windDirectionDeg,
        gustKnots: snapshot.gustKnots,
        tempC: snapshot.tempC,
        pressureHpa: snapshot.pressureHpa,
        humidityPct: snapshot.humidityPct,
        rainMm: snapshot.rainMm,
        observedAt: snapshot.observedAt,
        observedAtLabel: snapshot.observedAtLabel,
      );
    }
    if (station.provider == 'METEOCLIMATIC') {
      final stationId = station.stationId;
      if (stationId == null) {
        return null;
      }
      final snapshot = await _meteoclimaticLiveClient.fetchSnapshot(
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
        humidityPct: snapshot.humidityPct,
        rainMm: snapshot.rainMm,
        observedAt: snapshot.observedAt,
        observedAtLabel: snapshot.observedAtLabel,
      );
    }
    if (station.provider == 'WINDGURU_STATION') {
      final stationId = int.tryParse(station.stationId ?? '');
      if (stationId == null) {
        return null;
      }
      final snapshot = await _windguruStationLiveClient.fetchCurrent(
        stationId: stationId,
      );
      if (snapshot == null) {
        return null;
      }
      return _StationLiveData(
        windKnots: snapshot.windKnots,
        windMinKnots: snapshot.windMinKnots,
        windDeg: snapshot.windDirectionDeg,
        gustKnots: snapshot.gustKnots,
        tempC: snapshot.tempC,
        pressureHpa: snapshot.pressureHpa,
        humidityPct: snapshot.humidityPct,
        rainMm: null,
        observedAt: snapshot.observedAt,
        observedAtLabel: snapshot.observedAtLabel,
      );
    }
    if (station.provider == 'WUNDERGROUND') {
      final stationId = station.stationId;
      if (stationId == null) {
        return null;
      }
      final snapshot = await _wundergroundPwsClient.fetchCurrent(
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
        humidityPct: snapshot.humidityPct,
        rainMm: snapshot.rainMm,
        observedAt: snapshot.observedAt,
        observedAtLabel: snapshot.observedAtLabel,
      );
    }
    if (station.provider == 'WEATHERCLOUD') {
      final stationId = station.stationId;
      if (stationId == null) {
        return null;
      }
      final backendSnapshot = await _fetchLatestBackendWeathercloudLiveData(
        station,
      );
      if (backendSnapshot != null) {
        return backendSnapshot;
      }
      final snapshot = await _weathercloudLiveClient.fetchCurrent(
        deviceId: stationId,
      );
      return _StationLiveData(
        windKnots: snapshot?.windKnots,
        windDeg: snapshot?.windDirectionDeg,
        gustKnots: snapshot?.gustKnots,
        tempC: snapshot?.tempC,
        pressureHpa: snapshot?.pressureHpa,
        humidityPct: snapshot?.humidityPct,
        rainMm: snapshot?.rainMm,
        observedAt: snapshot?.observedAt,
        observedAtLabel: snapshot?.observedAtLabel,
      );
    }
    if (station.provider == 'XUSS') {
      final snapshot = await _xussMeteoClient.fetchDeniaSnapshot();
      if (snapshot == null) {
        return null;
      }
      return _StationLiveData(
        windKnots: snapshot.windKnots,
        windDeg: snapshot.windDirectionDeg,
        gustKnots: snapshot.gustKnots,
        tempC: snapshot.tempC,
        pressureHpa: snapshot.pressureHpa,
        humidityPct: snapshot.humidityPct,
        rainMm: snapshot.rainMm,
        observedAt: snapshot.observedAt,
        observedAtLabel: snapshot.observedAtLabel,
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
    if (station.provider == 'MADIS_MARITIME' ||
        station.provider == 'COPERNICUS_MARINE') {
      final cachedLiveData = _resolvedLiveDataByStation()[station.stationKey];
      if (cachedLiveData != null) {
        return cachedLiveData;
      }
      final client = _spotMaritimeObservationsClient;
      if (client == null) {
        return null;
      }
      final observation = await client.fetchLatestStation(
        stationKey: station.stationKey,
      );
      if (observation == null) {
        return null;
      }
      return _StationLiveData(
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

  Future<_StationLiveData?> _fetchLatestBackendWeathercloudLiveData(
    _NearbyStation station,
  ) async {
    final client = _spotLiveObservationHistoryClient;
    if (client == null) {
      return null;
    }
    final points = await client.fetchStationHistory(
      stationKey: station.stationKey,
      range: const Duration(hours: 2),
    );
    if (points.isEmpty) {
      return null;
    }
    final latest = points.last;
    final age = DateTime.now().difference(latest.observedAt);
    if (age.isNegative || age > const Duration(minutes: 30)) {
      return null;
    }
    return _StationLiveData(
      windKnots: latest.windKnots,
      windMinKnots: latest.windMinKnots,
      windDeg: latest.windDirectionDeg,
      gustKnots: latest.gustKnots,
      tempC: latest.tempC,
      pressureHpa: latest.pressureHpa,
      humidityPct: latest.humidityPct,
      rainMm: latest.rainMm,
      observedAt: latest.observedAt,
    );
  }
}
