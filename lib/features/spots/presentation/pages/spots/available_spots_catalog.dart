part of 'spots_page.dart';

class _AvailableSpot {
  const _AvailableSpot({
    required this.name,
    required this.area,
    this.latitude,
    this.longitude,
    this.aemetMunicipalityCode,
    this.aemetBeachCode,
    this.aemetBeachCodes = const <String>[],
    this.capabilities = SpotCapabilities.empty,
  });

  final String name;
  final String area;
  final double? latitude;
  final double? longitude;
  final String? aemetMunicipalityCode;
  final String? aemetBeachCode;
  final List<String> aemetBeachCodes;
  final SpotCapabilities capabilities;
}

const _availableSpots = <_AvailableSpot>[
  _AvailableSpot(
    name: olivaCanalGorgsSpotName,
    area: 'Valencia',
    latitude: 38.91397175799847,
    longitude: -0.07335473217682421,
    aemetMunicipalityCode: '46181',
    aemetBeachCode: '4618102',
    aemetBeachCodes: ['4618103'],
    capabilities: olivaCanalGorgsSpotCapabilities,
  ),
  _AvailableSpot(
    name: 'Piles',
    area: 'Valencia',
    latitude: 38.9402,
    longitude: -0.1324,
    aemetMunicipalityCode: '46197',
  ),
  _AvailableSpot(
    name: 'Punta de los Molinos',
    area: 'Denia, Alicante',
    latitude: 38.8462,
    longitude: 0.0916,
    aemetMunicipalityCode: '03063',
  ),
  _AvailableSpot(
    name: 'Calpe',
    area: 'Alicante',
    latitude: 38.6446,
    longitude: 0.0456,
    aemetMunicipalityCode: '03047',
  ),
  _AvailableSpot(
    name: 'Altea',
    area: 'Alicante',
    latitude: 38.6027,
    longitude: -0.0462,
    aemetMunicipalityCode: '03018',
  ),
  _AvailableSpot(
    name: 'Villajoyosa',
    area: 'Alicante',
    latitude: 38.5079,
    longitude: -0.2291,
    aemetMunicipalityCode: '03139',
  ),
  _AvailableSpot(
    name: 'Santa Pola',
    area: 'Alicante',
    latitude: 38.1923,
    longitude: -0.5556,
    aemetMunicipalityCode: '03121',
  ),
  _AvailableSpot(
    name: 'Cullera',
    area: 'Valencia',
    latitude: 39.1653,
    longitude: -0.2516,
    aemetMunicipalityCode: '46105',
  ),
  _AvailableSpot(
    name: 'Xeraco',
    area: 'Valencia',
    latitude: 39.0318,
    longitude: -0.2161,
    aemetMunicipalityCode: '46143',
  ),
  _AvailableSpot(
    name: 'El Perellonet',
    area: 'Valencia',
    latitude: 39.2763,
    longitude: -0.2758,
    aemetMunicipalityCode: '46250',
  ),
  _AvailableSpot(
    name: 'Tarifa',
    area: 'Cadiz',
    latitude: 36.0143,
    longitude: -5.6044,
    aemetMunicipalityCode: '11035',
  ),
];
