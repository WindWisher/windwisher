import 'package:windwisher/features/spots/domain/entities/spot_webcam.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_remote_media_port.dart';
import 'package:windwisher/features/spots/infrastructure/data/spot_capabilities_catalog.dart';
import 'package:windwisher/features/spots/infrastructure/data/spot_webcam_catalog.dart';

class InMemorySpotsRemoteMediaAdapter implements SpotsRemoteMediaPort {
  @override
  List<SpotWebcam> getWebcamsForSpot({
    required String spotName,
    required bool isCustom,
  }) {
    if (isCustom) {
      return const [];
    }

    final capabilities = defaultSpotCapabilitiesForName(spotName);
    final profileWebcams = webcamsForProfile(capabilities.webcamProfile);
    if (profileWebcams.isNotEmpty) {
      return profileWebcams;
    }

    return const <SpotWebcam>[];
  }

  @override
  List<WebcamReferencePage> getRelatedPagesForWebcam(String webcamName) {
    return referencePagesForWebcam(webcamName);
  }
}
