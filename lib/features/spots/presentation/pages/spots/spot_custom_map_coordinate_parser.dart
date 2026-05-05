part of 'spots_page.dart';

LatLng? _parseCustomMapCoordinates({
  required String latitudeText,
  required String longitudeText,
}) {
  final latitude = double.tryParse(latitudeText.trim());
  final longitude = double.tryParse(longitudeText.trim());

  if (latitude == null || longitude == null) {
    return null;
  }
  if (!_isValidLatitude(latitude) || !_isValidLongitude(longitude)) {
    return null;
  }

  return LatLng(latitude, longitude);
}

bool _isValidLatitude(double value) => value >= -90 && value <= 90;

bool _isValidLongitude(double value) => value >= -180 && value <= 180;
