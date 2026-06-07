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
const String deniaLesDevesesPreferredLiveStationKey = 'weathercloud:5629095484';
const String deniaLesDevesesSpotName = 'Denia - Les Deveses';
const String deniaPuntaMolinsLiveStationProfile = 'denia_punta_molins';
const String deniaPuntaMolinsWebcamProfile = 'denia_punta_molins_webcams';
const String deniaPuntaMolinsPreferredLiveStationKey =
    'weathercloud:3711662418';
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
    'weathercloud:5741540482';
const String villajoyosaPlayaParaisoSpotName = 'Villajoyosa - Playa Paraiso';
const String santaPolaPlatjaLissaWebcamProfile =
    'santa_pola_platja_lissa_webcams';
const String santaPolaPlatjaLissaSpotName = 'Santa Pola - Platja Lissa';
const String elCampelloPlayaMuchavistaWebcamProfile =
    'el_campello_playa_muchavista_webcams';
const String elCampelloPlayaMuchavistaLiveStationProfile =
    'el_campello_playa_muchavista';
const String elCampelloPlayaMuchavistaPreferredLiveStationKey =
    'wunderground:IELCAM26';
const String elCampelloPlayaMuchavistaSpotName =
    'El Campello - Playa Muchavista';
const String elPerellonetLiveStationProfile = 'el_perellonet';
const String elPerellonetWebcamProfile = 'el_perellonet_webcams';
const String elPerellonetPreferredLiveStationKey =
    'meteoclimatic:ESPVA4600000046420A';
const String elPerellonetSpotName = 'El Perellonet';
const String tarifaLiveStationProfile = 'tarifa';
const String tarifaPreferredLiveStationKey = '6001';
const String tarifaBalnearioSpotName = 'Tarifa - Balneario';
const String tarifaCampoFutbolSpotName = 'Tarifa - Campo de futbol';
const String tarifaLosLancesSpotName = 'Tarifa - Los Lances';
const String tarifaValdevaquerosSpotName = 'Tarifa - Valdevaqueros';
const String culleraElPolloLiveStationProfile = 'cullera_el_pollo';
const String culleraDosselWebcamProfile = 'cullera_dossel_webcams';
const String culleraElPolloPreferredLiveStationKey = 'weathercloud:4227028590';
const String culleraElPolloSpotName = 'Cullera - El Pollo';
const String xeracoLiveStationProfile = 'xeraco';
const String xeracoWebcamProfile = 'xeraco_webcams';
const String xeracoPreferredLiveStationKey = 'wunderground:IXERACO2';
const String xeracoSpotName = 'Xeraco';
const String dakhlaSpotName = 'Dakhla';
const String essaouiraSpotName = 'Essaouira';

const olivaCanalGorgsSpotCapabilities = SpotCapabilities(
  liveStationProfile: olivaCanalGorgsLiveStationProfile,
  webcamProfile: olivaCanalGorgsWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: olivaCanalGorgsPreferredLiveStationKey,
  preferredAemetLiveStationId: null,
  portusRealtimeStationIds: <int>[4634],
  includeOlivaReferenceLiveStations: true,
  navigationLatitude: 38.91580884367901,
  navigationLongitude: -0.07779792085000076,
  navigationLabel: 'Llegada Oliva Canal',
);

const pilesSpotCapabilities = SpotCapabilities(
  liveStationProfile: pilesLiveStationProfile,
  webcamProfile: pilesWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: pilesPreferredLiveStationKey,
  portusRealtimeStationIds: <int>[4634],
  navigationLatitude: 38.943633843553286,
  navigationLongitude: -0.10985116793513353,
  navigationLabel: 'Llegada Piles',
);

const gandiaPlayaSpotCapabilities = SpotCapabilities(
  liveStationProfile: gandiaPlayaLiveStationProfile,
  webcamProfile: gandiaPlayaWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: gandiaPlayaPreferredLiveStationKey,
  portusRealtimeStationIds: <int>[4634],
  navigationLatitude: 39.02083052614467,
  navigationLongitude: -0.17543646293914303,
  navigationLabel: 'Llegada Gandia Playa',
);

const deniaLesDevesesSpotCapabilities = SpotCapabilities(
  liveStationProfile: deniaLesDevesesLiveStationProfile,
  webcamProfile: deniaLesDevesesWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: deniaLesDevesesPreferredLiveStationKey,
  navigationLatitude: 38.883244386654184,
  navigationLongitude: -0.03539319215620903,
  navigationLabel: 'Llegada Denia - Les Deveses',
);

const deniaPuntaMolinsSpotCapabilities = SpotCapabilities(
  liveStationProfile: deniaPuntaMolinsLiveStationProfile,
  webcamProfile: deniaPuntaMolinsWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: deniaPuntaMolinsPreferredLiveStationKey,
  navigationLatitude: 38.86044033592307,
  navigationLongitude: 0.04655905881270543,
  navigationLabel: 'Llegada Denia - Punta Els Molins',
);

const calpeSpotCapabilities = SpotCapabilities(
  liveStationProfile: calpeLiveStationProfile,
  webcamProfile: calpeWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: calpePreferredLiveStationKey,
  navigationLatitude: 38.64159285682161,
  navigationLongitude: 0.04694828199875873,
  navigationLabel: 'Llegada Calpe',
);

const alteaCapNegretSpotCapabilities = SpotCapabilities(
  liveStationProfile: alteaCapNegretLiveStationProfile,
  webcamProfile: alteaCapNegretWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: alteaCapNegretPreferredLiveStationKey,
  navigationLatitude: 38.606497460633456,
  navigationLongitude: -0.041219503393286,
  navigationLabel: 'Llegada Altea - Cap Negret',
);

const villajoyosaEspigonSpotCapabilities = SpotCapabilities(
  liveStationProfile: villajoyosaEspigonLiveStationProfile,
  webcamProfile: villajoyosaEspigonWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: villajoyosaEspigonPreferredLiveStationKey,
  navigationLatitude: 38.50239214628279,
  navigationLongitude: -0.23440666068378316,
  navigationLabel: 'Llegada Villajoyosa - Espigon',
);

const villajoyosaPlayaParaisoSpotCapabilities = SpotCapabilities(
  liveStationProfile: villajoyosaPlayaParaisoLiveStationProfile,
  webcamProfile: villajoyosaPlayaParaisoWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: villajoyosaPlayaParaisoPreferredLiveStationKey,
  navigationLatitude: 38.49715021833233,
  navigationLongitude: -0.2584490074105973,
  navigationLabel: 'Llegada Villajoyosa - Playa Paraiso',
);

const santaPolaPlatjaLissaSpotCapabilities = SpotCapabilities(
  webcamProfile: santaPolaPlatjaLissaWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  portusRealtimeStationIds: <int>[4651, 4652, 4653],
  navigationLatitude: 38.190017240184275,
  navigationLongitude: -0.5902498009788203,
  navigationLabel: 'Llegada Santa Pola - Platja Lissa',
);

const elCampelloPlayaMuchavistaSpotCapabilities = SpotCapabilities(
  liveStationProfile: elCampelloPlayaMuchavistaLiveStationProfile,
  webcamProfile: elCampelloPlayaMuchavistaWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: elCampelloPlayaMuchavistaPreferredLiveStationKey,
  portusRealtimeStationIds: <int>[4651, 4652, 4653],
  navigationLatitude: 38.39502060831646,
  navigationLongitude: -0.4071727602994512,
  navigationLabel: 'Llegada El Campello - Playa Muchavista',
);

const elPerellonetSpotCapabilities = SpotCapabilities(
  liveStationProfile: elPerellonetLiveStationProfile,
  webcamProfile: elPerellonetWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: elPerellonetPreferredLiveStationKey,
  portusRealtimeStationIds: <int>[4635],
  navigationLatitude: 39.28095954536101,
  navigationLongitude: -0.27708708529321363,
  navigationLabel: 'Llegada El Perellonet',
);

const tarifaBalnearioSpotCapabilities = SpotCapabilities(
  liveStationProfile: tarifaLiveStationProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: tarifaPreferredLiveStationKey,
  preferredAemetLiveStationId: tarifaPreferredLiveStationKey,
  navigationLatitude: 36.009606703879996,
  navigationLongitude: -5.607629973493867,
  navigationLabel: 'Llegada Tarifa - Balneario',
);

const tarifaCampoFutbolSpotCapabilities = SpotCapabilities(
  liveStationProfile: tarifaLiveStationProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: tarifaPreferredLiveStationKey,
  preferredAemetLiveStationId: tarifaPreferredLiveStationKey,
  navigationLatitude: 36.02176430173696,
  navigationLongitude: -5.615059313052187,
  navigationLabel: 'Llegada Tarifa - Campo de futbol',
);

const tarifaLosLancesSpotCapabilities = SpotCapabilities(
  liveStationProfile: tarifaLiveStationProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: tarifaPreferredLiveStationKey,
  preferredAemetLiveStationId: tarifaPreferredLiveStationKey,
  navigationLatitude: 36.047401,
  navigationLongitude: -5.640325,
  navigationLabel: 'Llegada Tarifa - Los Lances',
);

const tarifaValdevaquerosSpotCapabilities = SpotCapabilities(
  liveStationProfile: tarifaLiveStationProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: tarifaPreferredLiveStationKey,
  preferredAemetLiveStationId: tarifaPreferredLiveStationKey,
  navigationLatitude: 36.06735671371158,
  navigationLongitude: -5.683717901374338,
  navigationLabel: 'Llegada Tarifa - Valdevaqueros',
);

const culleraElPolloSpotCapabilities = SpotCapabilities(
  liveStationProfile: culleraElPolloLiveStationProfile,
  webcamProfile: culleraDosselWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: culleraElPolloPreferredLiveStationKey,
  navigationLatitude: 39.21294234832044,
  navigationLongitude: -0.23836018562887695,
  navigationLabel: 'Llegada Cullera - El Pollo',
);

const xeracoSpotCapabilities = SpotCapabilities(
  liveStationProfile: xeracoLiveStationProfile,
  webcamProfile: xeracoWebcamProfile,
  defaultForecastProvider: 'AEMET',
  defaultForecastModel: kAemetPortusAtmosphereForecastModel,
  preferredLiveStationKey: xeracoPreferredLiveStationKey,
  navigationLatitude: 39.03800937721705,
  navigationLongitude: -0.18951786389646919,
  navigationLabel: 'Llegada Xeraco',
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
  if (normalized == tarifaCampoFutbolSpotName.toLowerCase()) {
    return tarifaCampoFutbolSpotCapabilities;
  }
  if (normalized == tarifaLosLancesSpotName.toLowerCase()) {
    return tarifaLosLancesSpotCapabilities;
  }
  if (normalized == tarifaValdevaquerosSpotName.toLowerCase()) {
    return tarifaValdevaquerosSpotCapabilities;
  }
  if (normalized == culleraElPolloSpotName.toLowerCase()) {
    return culleraElPolloSpotCapabilities;
  }
  if (normalized == xeracoSpotName.toLowerCase()) {
    return xeracoSpotCapabilities;
  }
  return SpotCapabilities.empty;
}
