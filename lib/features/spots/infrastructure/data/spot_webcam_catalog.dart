import 'package:windwisher/features/spots/domain/entities/spot_webcam.dart';
import 'package:windwisher/features/spots/infrastructure/data/spot_capabilities_catalog.dart';

const List<SpotWebcam> _olivaCanalGorgsWebcams = [
  SpotWebcam(
    name: 'Oliva Puerto',
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/es/valencia/oliva/webcams/oliva-puerto',
    summary: 'Webcam principal de Oliva desde el Club Nautico.',
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/OlivaPuerto/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/OlivaPuerto/webcam_mini.png',
    locationLabel: 'Club Nautico de Oliva',
    latitude: 38.93111,
    longitude: -0.095787,
    referencePages: [
      WebcamReferencePage(
        title: 'Oliva Puerto · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/es/valencia/oliva/webcams/oliva-puerto',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Oliva Nova',
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/en/valencia/oliva/webcams/oliva-nova-1',
    summary: 'Webcam de Oliva Nova Beach & Golf.',
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/Olivagolf/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/Olivagolf/webcam_mini.png',
    locationLabel: 'Oliva Nova Beach & Golf',
    latitude: 38.8934,
    longitude: -0.056047,
    referencePages: [
      WebcamReferencePage(
        title: 'Oliva Nova · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/en/valencia/oliva/webcams/oliva-nova-1',
      ),
    ],
  ),
];

const List<SpotWebcam> _pilesWebcams = [
  SpotWebcam(
    name: 'Piles',
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/es/valencia/piles/webcams/piles-2',
    summary: 'Webcam oficial de la playa de Piles.',
    locationLabel: 'Playa de Piles',
    latitude: 38.9519444444,
    longitude: -0.1144444444,
    referencePages: [
      WebcamReferencePage(
        title: 'Piles · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/es/valencia/piles/webcams/piles-2',
      ),
      WebcamReferencePage(
        title: 'Playa Piles · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/valencia/piles/playas/playa-piles-1',
      ),
    ],
  ),
];

List<SpotWebcam> webcamsForProfile(String? profile) {
  return switch (profile) {
    olivaCanalGorgsWebcamProfile => _olivaCanalGorgsWebcams,
    pilesWebcamProfile => _pilesWebcams,
    _ => const <SpotWebcam>[],
  };
}

List<WebcamReferencePage> referencePagesForWebcam(String webcamName) {
  for (final webcam in _allProfileWebcams) {
    if (webcam.name == webcamName) {
      return webcam.referencePages;
    }
  }

  return const <WebcamReferencePage>[];
}

const List<SpotWebcam> _allProfileWebcams = [
  ..._olivaCanalGorgsWebcams,
  ..._pilesWebcams,
];
