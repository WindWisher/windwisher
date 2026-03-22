import 'package:windwisher/features/spots/domain/entities/spot_webcam.dart';

const List<SpotWebcam> olivaSpotWebcams = [
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
  ),
];
