import 'package:windwisher/features/spots/infrastructure/services/aemet_coastal_forecast_client.dart';
import 'package:windwisher/features/spots/infrastructure/services/aemet_beach_forecast_client.dart';

const kAemetMunicipalForecastModel = 'Prediccion municipal';
const kAemetPortusAtmosphereForecastModel = 'Puertos del Estado';
const kLegacyAemetPortusAtmosphereForecastModel = 'Portus Atmosfera';

const Map<String, List<String>> baseForecastModelsByProvider = {
  'Open-Meteo': [
    'Best match',
    'AROME Seamless',
    'ARPEGE Europe',
    'ECMWF',
    'AROME France',
    'ICON',
    'ARPEGE Seamless',
    'ARPEGE World',
    'GFS',
  ],
  'AEMET': [kAemetMunicipalForecastModel, kAemetPortusAtmosphereForecastModel],
  'Windguru': ['Widget'],
  'Windy.app': ['Widget'],
  'Meteoblue': ['Basic', 'Current', 'Day', 'Sea'],
  'Meteostat': ['Hourly', 'Day'],
  'Meteosource': ['Hourly', 'Current', 'Day'],
};

List<String> getSpotForecastModels({
  required String spotName,
  String? spotArea,
  String? spotBeachCode,
  List<String> spotBeachCodes = const <String>[],
  required String provider,
  bool supportsPortusForecast = true,
}) {
  final base = baseForecastModelsByProvider[provider];
  if (base == null) {
    return const [];
  }

  final normalizedSpot = spotName.trim().toLowerCase();
  if (provider == 'Open-Meteo' && normalizedSpot == 'oliva puerto') {
    return const [
      'Best match',
      'AROME Seamless',
      'ARPEGE Europe',
      'ECMWF',
      'AROME France',
      'ICON',
      'ARPEGE Seamless',
      'ARPEGE World',
      'GFS',
    ];
  }

  final models = List<String>.from(base);
  if (provider == 'AEMET' && !supportsPortusForecast) {
    models.remove(kAemetPortusAtmosphereForecastModel);
  }
  if (provider == 'AEMET' && spotArea != null) {
    final beachModels = <String>{
      if (spotBeachCode != null && spotBeachCode.isNotEmpty)
        buildAemetBeachForecastModelLabel(
          beachCode: spotBeachCode,
          beachName: getAemetBeachDisplayName(beachCode: spotBeachCode),
        ),
      ...spotBeachCodes.map(
        (code) => buildAemetBeachForecastModelLabel(
          beachCode: code,
          beachName: getAemetBeachDisplayName(beachCode: code),
        ),
      ),
    };
    for (final beachModel in beachModels) {
      if (!models.contains(beachModel)) {
        models.add(beachModel);
      }
    }
    final coastalCode = getAemetCoastalAreaCode(area: spotArea);
    if (coastalCode != null && !models.contains(kAemetCoastalForecastModel)) {
      models.add(kAemetCoastalForecastModel);
    }
  }

  return models;
}

String? getSpotDefaultForecastModel({
  required String spotName,
  String? spotArea,
  String? spotBeachCode,
  List<String> spotBeachCodes = const <String>[],
  required String provider,
  bool supportsPortusForecast = true,
}) {
  final models = getSpotForecastModels(
    spotName: spotName,
    spotArea: spotArea,
    spotBeachCode: spotBeachCode,
    spotBeachCodes: spotBeachCodes,
    provider: provider,
    supportsPortusForecast: supportsPortusForecast,
  );
  if (models.isEmpty) {
    return null;
  }

  final normalizedSpot = spotName.trim().toLowerCase();
  if (provider == 'Open-Meteo' && normalizedSpot == 'oliva puerto') {
    return 'Best match';
  }

  if (provider == 'Open-Meteo') {
    return 'Best match';
  }

  if (provider == 'AEMET') {
    return models.contains(kAemetPortusAtmosphereForecastModel)
        ? kAemetPortusAtmosphereForecastModel
        : models.first;
  }

  if (provider == 'Meteoblue') {
    return 'Basic';
  }

  if (provider == 'Meteosource') {
    return 'Hourly';
  }

  if (provider == 'Windguru' || provider == 'Windy.app') {
    return 'Widget';
  }

  if (provider == 'Meteostat') {
    return 'Hourly';
  }

  return models.first;
}

bool isAemetPortusAtmosphereForecastModel(String model) {
  return model == kAemetPortusAtmosphereForecastModel ||
      model == kLegacyAemetPortusAtmosphereForecastModel;
}
