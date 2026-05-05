part of 'spots_page.dart';

class _CustomSpotPoint {
  const _CustomSpotPoint({
    required this.latitude,
    required this.longitude,
    required this.xFraction,
    required this.yFraction,
  });

  final double latitude;
  final double longitude;
  final double xFraction;
  final double yFraction;

  LatLng toLatLng() => LatLng(latitude, longitude);
}
