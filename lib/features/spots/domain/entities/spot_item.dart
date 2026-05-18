class SpotCapabilities {
  const SpotCapabilities({
    this.liveStationProfile,
    this.webcamProfile,
    this.defaultForecastProvider,
    this.defaultForecastModel,
    this.preferredLiveStationKey,
    this.preferredAemetLiveStationId,
    this.portusRealtimeStationIds = const <int>[],
    this.includeOlivaReferenceLiveStations = false,
    this.navigationLatitude,
    this.navigationLongitude,
    this.navigationLabel,
  });

  static const empty = SpotCapabilities();

  final String? liveStationProfile;
  final String? webcamProfile;
  final String? defaultForecastProvider;
  final String? defaultForecastModel;
  final String? preferredLiveStationKey;
  final String? preferredAemetLiveStationId;
  final List<int> portusRealtimeStationIds;
  final bool includeOlivaReferenceLiveStations;
  final double? navigationLatitude;
  final double? navigationLongitude;
  final String? navigationLabel;
}

class SpotItem {
  const SpotItem({
    required this.name,
    required this.area,
    required this.isCustom,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.aemetMunicipalityCode,
    this.aemetBeachCode,
    this.aemetBeachCodes = const <String>[],
    this.backgroundImagePath,
    this.capabilities = SpotCapabilities.empty,
  });

  final String name;
  final String area;
  final bool isCustom;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? aemetMunicipalityCode;
  final String? aemetBeachCode;
  final List<String> aemetBeachCodes;
  final String? backgroundImagePath;
  final SpotCapabilities capabilities;

  String? get liveStationProfile => capabilities.liveStationProfile;

  List<String> get resolvedAemetBeachCodes {
    final values = <String>[];
    if (aemetBeachCode != null && aemetBeachCode!.isNotEmpty) {
      values.add(aemetBeachCode!);
    }
    for (final code in aemetBeachCodes) {
      if (code.isNotEmpty && !values.contains(code)) {
        values.add(code);
      }
    }
    return List<String>.unmodifiable(values);
  }
}
