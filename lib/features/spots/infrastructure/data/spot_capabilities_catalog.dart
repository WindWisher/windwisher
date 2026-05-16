import 'package:windwisher/features/spots/application/services/spot_forecast_model_order.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';

const String olivaCanalGorgsLiveStationProfile = 'oliva_canal_gorgs';
const String olivaCanalGorgsWebcamProfile = 'oliva_canal_gorgs_webcams';
const String olivaCanalGorgsPreferredLiveStationKey = 'avamet:c25m181e07';
const String olivaCanalGorgsSpotName = 'Oliva Canal - Platja dels Gorgs';
const String pilesLiveStationProfile = 'piles';
const String pilesWebcamProfile = 'piles_webcams';
const String pilesPreferredLiveStationKey = 'avamet:c25m181e07';
const String pilesSpotName = 'Piles';
const String gandiaPlayaLiveStationProfile = 'gandia_playa';
const String gandiaPlayaWebcamProfile = 'gandia_playa_webcams';
const String gandiaPlayaPreferredLiveStationKey = 'avamet:c25m131e15';
const String gandiaPlayaSpotName = 'Gandia Playa';
const String deniaLesDevesesLiveStationProfile = 'denia_les_deveses';
const String deniaLesDevesesWebcamProfile = 'denia_les_deveses_webcams';
const String deniaLesDevesesPreferredLiveStationKey = 'avamet:c30m063e10';
const String deniaLesDevesesSpotName = 'Denia - Les Deveses';
const String deniaPuntaMolinsLiveStationProfile = 'denia_punta_molins';
const String deniaPuntaMolinsWebcamProfile = 'denia_punta_molins_webcams';
const String deniaPuntaMolinsPreferredLiveStationKey = 'avamet:c30m063e10';
const String deniaPuntaMolinsSpotName = 'Denia - Punta Els Molins';
const String calpeLiveStationProfile = 'calpe';
const String calpeWebcamProfile = 'calpe_webcams';
const String calpePreferredLiveStationKey = 'avamet:c30m047e03';
const String calpeSpotName = 'Calpe';
const String alteaCapNegretLiveStationProfile = 'altea_cap_negret';
const String alteaCapNegretWebcamProfile = 'altea_cap_negret_webcams';
const String alteaCapNegretPreferredLiveStationKey = 'avamet:c31m018e06';
const String alteaCapNegretSpotName =
    'Altea - Cap Negret (Desembocadura Rio Algar)';
const String villajoyosaEspigonLiveStationProfile = 'villajoyosa_espigon';
const String villajoyosaEspigonWebcamProfile = 'villajoyosa_espigon_webcams';
const String villajoyosaEspigonPreferredLiveStationKey = 'avamet:c31m139e07';
const String villajoyosaEspigonSpotName = 'Villajoyosa - Espigon';
const String villajoyosaPlayaParaisoLiveStationProfile =
    'villajoyosa_playa_paraiso';
const String villajoyosaPlayaParaisoWebcamProfile =
    'villajoyosa_playa_paraiso_webcams';
const String villajoyosaPlayaParaisoPreferredLiveStationKey =
    'avamet:c31m139e05';
const String villajoyosaPlayaParaisoSpotName = 'Villajoyosa - Playa Paraiso';
const String santaPolaPlatjaLissaWebcamProfile =
    'santa_pola_platja_lissa_webcams';
const String santaPolaPlatjaLissaSpotName = 'Santa Pola - Platja Lissa';
const String elCampelloPlayaMuchavistaWebcamProfile =
    'el_campello_playa_muchavista_webcams';
const String elCampelloPlayaMuchavistaSpotName =
    'El Campello - Playa Muchavista';
const String elPerellonetWebcamProfile = 'el_perellonet_webcams';
const String elPerellonetSpotName = 'El Perellonet';
const String tarifaLiveStationProfile = 'tarifa';
const String tarifaPreferredLiveStationKey = '6001';
const String tarifaBalnearioSpotName = 'Tarifa - Balneario';
const String tarifaValdevaquerosSpotName = 'Tarifa - Valdevaqueros';
const String culleraDosselWebcamProfile = 'cullera_dossel_webcams';
const String culleraElPolloSpotName = 'Cullera - El Pollo';

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
  preferredLiveStationKey: pilesPreferredLiveStationKey,
  portusRealtimeStationIds: <int>[4634],
);

const gandiaPlayaSpotCapabilities = SpotCapabilities(
  liveStationProfile: gandiaPlayaLiveStationProfile,
  webcamProfile: gandiaPlayaWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: gandiaPlayaPreferredLiveStationKey,
  portusRealtimeStationIds: <int>[4634],
);

const deniaLesDevesesSpotCapabilities = SpotCapabilities(
  liveStationProfile: deniaLesDevesesLiveStationProfile,
  webcamProfile: deniaLesDevesesWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: deniaLesDevesesPreferredLiveStationKey,
  portusRealtimeStationIds: <int>[4634],
);

const deniaPuntaMolinsSpotCapabilities = SpotCapabilities(
  liveStationProfile: deniaPuntaMolinsLiveStationProfile,
  webcamProfile: deniaPuntaMolinsWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: deniaPuntaMolinsPreferredLiveStationKey,
);

const calpeSpotCapabilities = SpotCapabilities(
  liveStationProfile: calpeLiveStationProfile,
  webcamProfile: calpeWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: calpePreferredLiveStationKey,
);

const alteaCapNegretSpotCapabilities = SpotCapabilities(
  liveStationProfile: alteaCapNegretLiveStationProfile,
  webcamProfile: alteaCapNegretWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: alteaCapNegretPreferredLiveStationKey,
);

const villajoyosaEspigonSpotCapabilities = SpotCapabilities(
  liveStationProfile: villajoyosaEspigonLiveStationProfile,
  webcamProfile: villajoyosaEspigonWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: villajoyosaEspigonPreferredLiveStationKey,
);

const villajoyosaPlayaParaisoSpotCapabilities = SpotCapabilities(
  liveStationProfile: villajoyosaPlayaParaisoLiveStationProfile,
  webcamProfile: villajoyosaPlayaParaisoWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: villajoyosaPlayaParaisoPreferredLiveStationKey,
);

const santaPolaPlatjaLissaSpotCapabilities = SpotCapabilities(
  webcamProfile: santaPolaPlatjaLissaWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  portusRealtimeStationIds: <int>[4651, 4652, 4653],
);

const elCampelloPlayaMuchavistaSpotCapabilities = SpotCapabilities(
  webcamProfile: elCampelloPlayaMuchavistaWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  portusRealtimeStationIds: <int>[4651, 4652, 4653],
);

const elPerellonetSpotCapabilities = SpotCapabilities(
  webcamProfile: elPerellonetWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  portusRealtimeStationIds: <int>[4635],
);

const tarifaBalnearioSpotCapabilities = SpotCapabilities(
  liveStationProfile: tarifaLiveStationProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: tarifaPreferredLiveStationKey,
  preferredAemetLiveStationId: tarifaPreferredLiveStationKey,
);

const tarifaValdevaquerosSpotCapabilities = SpotCapabilities(
  liveStationProfile: tarifaLiveStationProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: tarifaPreferredLiveStationKey,
  preferredAemetLiveStationId: tarifaPreferredLiveStationKey,
);

const culleraElPolloSpotCapabilities = SpotCapabilities(
  webcamProfile: culleraDosselWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
);

SpotCapabilities defaultSpotCapabilitiesForName(String name) {
  final normalized = name.trim().toLowerCase();
  if (normalized == olivaCanalGorgsSpotName.toLowerCase()) {
    return olivaCanalGorgsSpotCapabilities;
  }
  if (normalized == pilesSpotName.toLowerCase()) {
    return pilesSpotCapabilities;
  }
  if (normalized == gandiaPlayaSpotName.toLowerCase()) {
    return gandiaPlayaSpotCapabilities;
  }
  if (normalized == deniaLesDevesesSpotName.toLowerCase()) {
    return deniaLesDevesesSpotCapabilities;
  }
  if (normalized == deniaPuntaMolinsSpotName.toLowerCase()) {
    return deniaPuntaMolinsSpotCapabilities;
  }
  if (normalized == calpeSpotName.toLowerCase()) {
    return calpeSpotCapabilities;
  }
  if (normalized == alteaCapNegretSpotName.toLowerCase()) {
    return alteaCapNegretSpotCapabilities;
  }
  if (normalized == villajoyosaEspigonSpotName.toLowerCase()) {
    return villajoyosaEspigonSpotCapabilities;
  }
  if (normalized == villajoyosaPlayaParaisoSpotName.toLowerCase()) {
    return villajoyosaPlayaParaisoSpotCapabilities;
  }
  if (normalized == santaPolaPlatjaLissaSpotName.toLowerCase()) {
    return santaPolaPlatjaLissaSpotCapabilities;
  }
  if (normalized == elCampelloPlayaMuchavistaSpotName.toLowerCase()) {
    return elCampelloPlayaMuchavistaSpotCapabilities;
  }
  if (normalized == elPerellonetSpotName.toLowerCase()) {
    return elPerellonetSpotCapabilities;
  }
  if (normalized == tarifaBalnearioSpotName.toLowerCase()) {
    return tarifaBalnearioSpotCapabilities;
  }
  if (normalized == tarifaValdevaquerosSpotName.toLowerCase()) {
    return tarifaValdevaquerosSpotCapabilities;
  }
  if (normalized == culleraElPolloSpotName.toLowerCase()) {
    return culleraElPolloSpotCapabilities;
  }
  return SpotCapabilities.empty;
}
