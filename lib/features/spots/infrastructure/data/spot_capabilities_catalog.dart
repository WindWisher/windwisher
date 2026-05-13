import 'package:windwisher/features/spots/application/services/spot_forecast_model_order.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';

const String olivaCanalGorgsLiveStationProfile = 'oliva_canal_gorgs';
const String olivaCanalGorgsWebcamProfile = 'oliva_canal_gorgs_webcams';
const String olivaCanalGorgsPreferredLiveStationKey = 'avamet:c25m181e07';
const String olivaCanalGorgsSpotName = 'Oliva Canal - Platja dels Gorgs';
const String pilesLiveStationProfile = 'piles';
const String pilesWebcamProfile = 'piles_webcams';
const String pilesSpotName = 'Piles';

const olivaCanalGorgsSpotCapabilities = SpotCapabilities(
  liveStationProfile: olivaCanalGorgsLiveStationProfile,
  webcamProfile: olivaCanalGorgsWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: olivaCanalGorgsPreferredLiveStationKey,
  preferredAemetLiveStationId: null,
  portusRealtimeStationIds: <int>[4634],
  includeOlivaReferenceLiveStations: true,
);

const pilesSpotCapabilities = SpotCapabilities(
  liveStationProfile: pilesLiveStationProfile,
  webcamProfile: pilesWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  portusRealtimeStationIds: <int>[4634],
  includeOlivaReferenceLiveStations: true,
);

SpotCapabilities defaultSpotCapabilitiesForName(String name) {
  final normalized = name.trim().toLowerCase();
  if (normalized == olivaCanalGorgsSpotName.toLowerCase()) {
    return olivaCanalGorgsSpotCapabilities;
  }
  if (normalized == pilesSpotName.toLowerCase()) {
    return pilesSpotCapabilities;
  }
  return SpotCapabilities.empty;
}
