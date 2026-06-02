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
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudOlivaXeloStationKey,
      stationName: _weathercloudOlivaXeloStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudOlivaXeloStationId,
      latitude: _weathercloudOlivaXeloStationLat,
      longitude: _weathercloudOlivaXeloStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudOlivaIoliva24StationKey,
      stationName: _weathercloudOlivaIoliva24StationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudOlivaIoliva24StationId,
      latitude: _weathercloudOlivaIoliva24StationLat,
      longitude: _weathercloudOlivaIoliva24StationLon,
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
      stationKey: _weathercloudPilesVjStationKey,
      stationName: _weathercloudPilesVjStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudPilesVjStationId,
      latitude: _weathercloudPilesVjStationLat,
      longitude: _weathercloudPilesVjStationLon,
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
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _meteoclimaticGandiaGrauStationKey,
      stationName: _meteoclimaticGandiaGrauStationName,
      provider: 'METEOCLIMATIC',
      stationId: _meteoclimaticGandiaGrauStationId,
      latitude: _meteoclimaticGandiaGrauStationLat,
      longitude: _meteoclimaticGandiaGrauStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudGandiaSimyoStationKey,
      stationName: _weathercloudGandiaSimyoStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudGandiaSimyoStationId,
      latitude: _weathercloudGandiaSimyoStationLat,
      longitude: _weathercloudGandiaSimyoStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudGandiaGrauStationKey,
      stationName: _weathercloudGandiaGrauStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudGandiaGrauStationId,
      latitude: _weathercloudGandiaGrauStationLat,
      longitude: _weathercloudGandiaGrauStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudGandiaKgcStationKey,
      stationName: _weathercloudGandiaKgcStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudGandiaKgcStationId,
      latitude: _weathercloudGandiaKgcStationLat,
      longitude: _weathercloudGandiaKgcStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudGandiaRicardoStationKey,
      stationName: _weathercloudGandiaRicardoStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudGandiaRicardoStationId,
      latitude: _weathercloudGandiaRicardoStationLat,
      longitude: _weathercloudGandiaRicardoStationLon,
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
      stationKey: _xussDeniaStationKey,
      stationName: _xussDeniaStationName,
      provider: 'XUSS',
      stationId: _xussDeniaStationId,
      latitude: _xussDeniaStationLat,
      longitude: _xussDeniaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudLesDevesesStationKey,
      stationName: _weathercloudLesDevesesStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudLesDevesesStationId,
      latitude: _weathercloudLesDevesesStationLat,
      longitude: _weathercloudLesDevesesStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundDenia129StationKey,
      stationName: _wundergroundDenia129StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundDenia129StationId,
      latitude: _wundergroundDenia129StationLat,
      longitude: _wundergroundDenia129StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundOliva49StationKey,
      stationName: _wundergroundOliva49StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundOliva49StationId,
      latitude: _wundergroundOliva49StationLat,
      longitude: _wundergroundOliva49StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudPaqueboteStationKey,
      stationName: _weathercloudPaqueboteStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudPaqueboteStationId,
      latitude: _weathercloudPaqueboteStationLat,
      longitude: _weathercloudPaqueboteStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametDeniaClubNauticoStationKey,
      stationName: _avametDeniaClubNauticoStationName,
      provider: 'AVAMET',
      stationId: _avametDeniaClubNauticoStationId,
      latitude: _avametDeniaClubNauticoStationLat,
      longitude: _avametDeniaClubNauticoStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametDeniaLesRotesStationKey,
      stationName: _avametDeniaLesRotesStationName,
      provider: 'AVAMET',
      stationId: _avametDeniaLesRotesStationId,
      latitude: _avametDeniaLesRotesStationLat,
      longitude: _avametDeniaLesRotesStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametDeniaMontgoCalafatStationKey,
      stationName: _avametDeniaMontgoCalafatStationName,
      provider: 'AVAMET',
      stationId: _avametDeniaMontgoCalafatStationId,
      latitude: _avametDeniaMontgoCalafatStationLat,
      longitude: _avametDeniaMontgoCalafatStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _meteoclimaticDeniaSantaLlusiaStationKey,
      stationName: _meteoclimaticDeniaSantaLlusiaStationName,
      provider: 'METEOCLIMATIC',
      stationId: _meteoclimaticDeniaSantaLlusiaStationId,
      latitude: _meteoclimaticDeniaSantaLlusiaStationLat,
      longitude: _meteoclimaticDeniaSantaLlusiaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
  }

  void _addDeniaPuntaMolinsWundergroundStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundDenia15StationKey,
      stationName: _wundergroundDenia15StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundDenia15StationId,
      latitude: _wundergroundDenia15StationLat,
      longitude: _wundergroundDenia15StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundElsPoblets7StationKey,
      stationName: _wundergroundElsPoblets7StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundElsPoblets7StationId,
      latitude: _wundergroundElsPoblets7StationLat,
      longitude: _wundergroundElsPoblets7StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundElsPoblets8StationKey,
      stationName: _wundergroundElsPoblets8StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundElsPoblets8StationId,
      latitude: _wundergroundElsPoblets8StationLat,
      longitude: _wundergroundElsPoblets8StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundElVerger21StationKey,
      stationName: _wundergroundElVerger21StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundElVerger21StationId,
      latitude: _wundergroundElVerger21StationLat,
      longitude: _wundergroundElVerger21StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundElsPoblets5StationKey,
      stationName: _wundergroundElsPoblets5StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundElsPoblets5StationId,
      latitude: _wundergroundElsPoblets5StationLat,
      longitude: _wundergroundElsPoblets5StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundElsPoblets14StationKey,
      stationName: _wundergroundElsPoblets14StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundElsPoblets14StationId,
      latitude: _wundergroundElsPoblets14StationLat,
      longitude: _wundergroundElsPoblets14StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundDenia157StationKey,
      stationName: _wundergroundDenia157StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundDenia157StationId,
      latitude: _wundergroundDenia157StationLat,
      longitude: _wundergroundDenia157StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundDenia70StationKey,
      stationName: _wundergroundDenia70StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundDenia70StationId,
      latitude: _wundergroundDenia70StationLat,
      longitude: _wundergroundDenia70StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundDenia123StationKey,
      stationName: _wundergroundDenia123StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundDenia123StationId,
      latitude: _wundergroundDenia123StationLat,
      longitude: _wundergroundDenia123StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundDenia35StationKey,
      stationName: _wundergroundDenia35StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundDenia35StationId,
      latitude: _wundergroundDenia35StationLat,
      longitude: _wundergroundDenia35StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundDenia142StationKey,
      stationName: _wundergroundDenia142StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundDenia142StationId,
      latitude: _wundergroundDenia142StationLat,
      longitude: _wundergroundDenia142StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundDenia140StationKey,
      stationName: _wundergroundDenia140StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundDenia140StationId,
      latitude: _wundergroundDenia140StationLat,
      longitude: _wundergroundDenia140StationLon,
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
      stationKey: _xussDeniaStationKey,
      stationName: _xussDeniaStationName,
      provider: 'XUSS',
      stationId: _xussDeniaStationId,
      latitude: _xussDeniaStationLat,
      longitude: _xussDeniaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudPaqueboteStationKey,
      stationName: _weathercloudPaqueboteStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudPaqueboteStationId,
      latitude: _weathercloudPaqueboteStationLat,
      longitude: _weathercloudPaqueboteStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addDeniaPuntaMolinsWundergroundStations(
      latitude: latitude,
      longitude: longitude,
      stations: stations,
      seenKeys: seenKeys,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametDeniaClubNauticoStationKey,
      stationName: _avametDeniaClubNauticoStationName,
      provider: 'AVAMET',
      stationId: _avametDeniaClubNauticoStationId,
      latitude: _avametDeniaClubNauticoStationLat,
      longitude: _avametDeniaClubNauticoStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametDeniaLesRotesStationKey,
      stationName: _avametDeniaLesRotesStationName,
      provider: 'AVAMET',
      stationId: _avametDeniaLesRotesStationId,
      latitude: _avametDeniaLesRotesStationLat,
      longitude: _avametDeniaLesRotesStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _avametDeniaMontgoCalafatStationKey,
      stationName: _avametDeniaMontgoCalafatStationName,
      provider: 'AVAMET',
      stationId: _avametDeniaMontgoCalafatStationId,
      latitude: _avametDeniaMontgoCalafatStationLat,
      longitude: _avametDeniaMontgoCalafatStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _meteoclimaticDeniaSantaLlusiaStationKey,
      stationName: _meteoclimaticDeniaSantaLlusiaStationName,
      provider: 'METEOCLIMATIC',
      stationId: _meteoclimaticDeniaSantaLlusiaStationId,
      latitude: _meteoclimaticDeniaSantaLlusiaStationLat,
      longitude: _meteoclimaticDeniaSantaLlusiaStationLon,
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
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundCalp39StationKey,
      stationName: _wundergroundCalp39StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundCalp39StationId,
      latitude: _wundergroundCalp39StationLat,
      longitude: _wundergroundCalp39StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundCalp32StationKey,
      stationName: _wundergroundCalp32StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundCalp32StationId,
      latitude: _wundergroundCalp32StationLat,
      longitude: _wundergroundCalp32StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudCalpeStationKey,
      stationName: _weathercloudCalpeStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudCalpeStationId,
      latitude: _weathercloudCalpeStationLat,
      longitude: _weathercloudCalpeStationLon,
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
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudAlteaMeteoAlteaStationKey,
      stationName: _weathercloudAlteaMeteoAlteaStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudAlteaMeteoAlteaStationId,
      latitude: _weathercloudAlteaMeteoAlteaStationLat,
      longitude: _weathercloudAlteaMeteoAlteaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudAlteaLaVellaStationKey,
      stationName: _weathercloudAlteaLaVellaStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudAlteaLaVellaStationId,
      latitude: _weathercloudAlteaLaVellaStationLat,
      longitude: _weathercloudAlteaLaVellaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudAlteaCasaSuerteStationKey,
      stationName: _weathercloudAlteaCasaSuerteStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudAlteaCasaSuerteStationId,
      latitude: _weathercloudAlteaCasaSuerteStationLat,
      longitude: _weathercloudAlteaCasaSuerteStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundAltea13StationKey,
      stationName: _wundergroundAltea13StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundAltea13StationId,
      latitude: _wundergroundAltea13StationLat,
      longitude: _wundergroundAltea13StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundAltea38StationKey,
      stationName: _wundergroundAltea38StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundAltea38StationId,
      latitude: _wundergroundAltea38StationLat,
      longitude: _wundergroundAltea38StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundAltea48StationKey,
      stationName: _wundergroundAltea48StationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundAltea48StationId,
      latitude: _wundergroundAltea48StationLat,
      longitude: _wundergroundAltea48StationLon,
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
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudCulleraPiscinaMbStationKey,
      stationName: _weathercloudCulleraPiscinaMbStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudCulleraPiscinaMbStationId,
      latitude: _weathercloudCulleraPiscinaMbStationLat,
      longitude: _weathercloudCulleraPiscinaMbStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudCulleraEdificioDoselStationKey,
      stationName: _weathercloudCulleraEdificioDoselStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudCulleraEdificioDoselStationId,
      latitude: _weathercloudCulleraEdificioDoselStationLat,
      longitude: _weathercloudCulleraEdificioDoselStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudCulleraFaroStationKey,
      stationName: _weathercloudCulleraFaroStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudCulleraFaroStationId,
      latitude: _weathercloudCulleraFaroStationLat,
      longitude: _weathercloudCulleraFaroStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudCulleraCulMeteoStationKey,
      stationName: _weathercloudCulleraCulMeteoStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudCulleraCulMeteoStationId,
      latitude: _weathercloudCulleraCulMeteoStationLat,
      longitude: _weathercloudCulleraCulMeteoStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudCulleraSaganStationKey,
      stationName: _weathercloudCulleraSaganStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudCulleraSaganStationId,
      latitude: _weathercloudCulleraSaganStationLat,
      longitude: _weathercloudCulleraSaganStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _weathercloudCulleraIbizaStationKey,
      stationName: _weathercloudCulleraIbizaStationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudCulleraIbizaStationId,
      latitude: _weathercloudCulleraIbizaStationLat,
      longitude: _weathercloudCulleraIbizaStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
  }

  void _addXeracoLiveStations({
    required double latitude,
    required double longitude,
    required List<_NearbyStation> stations,
    required Set<String> seenKeys,
  }) {
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _wundergroundXeracoStationKey,
      stationName: _wundergroundXeracoStationName,
      provider: 'WUNDERGROUND',
      stationId: _wundergroundXeracoStationId,
      latitude: _wundergroundXeracoStationLat,
      longitude: _wundergroundXeracoStationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
    _addLiveStationMetadata(
      stations: stations,
      seenKeys: seenKeys,
      stationKey: _meteoclimaticXeracoStationKey,
      stationName: _meteoclimaticXeracoStationName,
      provider: 'METEOCLIMATIC',
      stationId: _meteoclimaticXeracoStationId,
      latitude: _meteoclimaticXeracoStationLat,
      longitude: _meteoclimaticXeracoStationLon,
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
      stationKey: _weathercloudPerelloYt60234StationKey,
      stationName: _weathercloudPerelloYt60234StationName,
      provider: 'WEATHERCLOUD',
      stationId: _weathercloudPerelloYt60234StationId,
      latitude: _weathercloudPerelloYt60234StationLat,
      longitude: _weathercloudPerelloYt60234StationLon,
      referenceLatitude: latitude,
      referenceLongitude: longitude,
    );
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
    if (_resolvedSpotCapabilities().liveStationProfile != null) {
      return const <int>[];
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

  bool _usesXeracoLiveProfile() {
    final capabilities = _resolvedSpotCapabilities();
    return capabilities.liveStationProfile == xeracoLiveStationProfile;
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
    if (capabilities.liveStationProfile == xeracoLiveStationProfile) {
      return xeracoSpotCapabilities;
    }

    final defaultCapabilities = defaultSpotCapabilitiesForName(widget.name);
    if (defaultCapabilities.liveStationProfile != null) {
      return defaultCapabilities;
    }

    return capabilities;
  }

  String _portusStationKey(int stationId) => 'puertos:$stationId';
}
