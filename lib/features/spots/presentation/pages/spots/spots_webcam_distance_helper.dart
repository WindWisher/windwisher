part of 'spots_page.dart';

const double _nearbyWebcamThresholdKm = 8;

int _nearbySpotWebcamCount({
  required _SpotItem spot,
  required SpotsModule spotsModule,
}) {
  final spotLat = spot.latitude;
  final spotLon = spot.longitude;
  if (spotLat == null || spotLon == null) {
    return 0;
  }

  final webcams = spotsModule.getSpotWebcams(
    spotName: spot.name,
    isCustom: spot.isCustom,
  );
  var count = 0;
  for (final webcam in webcams) {
    final webcamLat = webcam.latitude;
    final webcamLon = webcam.longitude;
    if (webcamLat == null || webcamLon == null) {
      continue;
    }
    final distanceKm = _distanceKm(
      latitudeA: spotLat,
      longitudeA: spotLon,
      latitudeB: webcamLat,
      longitudeB: webcamLon,
    );
    if (distanceKm <= _nearbyWebcamThresholdKm) {
      count += 1;
    }
  }
  return count;
}

double _distanceKm({
  required double latitudeA,
  required double longitudeA,
  required double latitudeB,
  required double longitudeB,
}) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRadians(latitudeB - latitudeA);
  final dLon = _toRadians(longitudeB - longitudeA);
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(latitudeA)) *
          math.cos(_toRadians(latitudeB)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _toRadians(double value) => value * (math.pi / 180);
