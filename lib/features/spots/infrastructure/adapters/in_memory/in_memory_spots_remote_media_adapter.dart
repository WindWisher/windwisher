import 'package:windwisher/features/spots/domain/entities/spot_webcam.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_remote_media_port.dart';
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

    final lowerName = spotName.toLowerCase();
    if (lowerName.contains('oliva')) {
      return olivaSpotWebcams;
    }

    return const [
      SpotWebcam(
        name: 'Cam principal',
        source: 'WindWisher Cams',
        status: 'Online',
        resolution: '720p',
      ),
    ];
  }

  @override
  List<WebcamReferencePage> getRelatedPagesForWebcam(String webcamName) {
    final normalized = webcamName.toLowerCase();
    if (normalized.contains('nova')) {
      return const [
        WebcamReferencePage(
          title: 'Oliva Nova · Comunitat Valenciana',
          url:
              'https://www.comunitatvalenciana.com/en/valencia/oliva/webcams/oliva-nova-1',
        ),
      ];
    }
    if (normalized.contains('oliva')) {
      return const [
        WebcamReferencePage(
          title: 'Oliva Puerto · Comunitat Valenciana',
          url:
              'https://www.comunitatvalenciana.com/es/valencia/oliva/webcams/oliva-puerto',
        ),
      ];
    }

    return const [
      WebcamReferencePage(
        title: 'Portal webcams de olas',
        url: 'https://www.windguru.cz/',
      ),
    ];
  }
}
