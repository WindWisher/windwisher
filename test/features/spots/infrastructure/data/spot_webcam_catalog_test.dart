import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/application/services/spot_capabilities_catalog.dart';
import 'package:windwisher/features/spots/infrastructure/data/spot_webcam_catalog.dart';

void main() {
  test('Porto Pollo exposes its three direct HLS webcams', () {
    final webcams = webcamsForProfile(portoPolloWebcamProfile);

    expect(webcams, hasLength(3));
    expect(
      webcams.every(
        (webcam) => webcam.streamManifestUrl?.endsWith('.m3u8') ?? false,
      ),
      isTrue,
    );
    expect(
      webcams.map((webcam) => webcam.streamManifestUrl).toSet(),
      hasLength(3),
    );
  });
}
