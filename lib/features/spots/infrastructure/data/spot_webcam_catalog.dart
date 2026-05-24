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
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/Piles/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/Piles/webcam_mini.png',
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

const List<SpotWebcam> _gandiaPlayaWebcams = [
  SpotWebcam(
    name: 'Gandia',
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/es/valencia/gandia/webcams/gandia-1',
    summary: 'Webcam oficial de la playa de Gandia.',
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/Gandia/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/Gandia/webcam_mini.png',
    locationLabel: 'Playa de Gandia',
    latitude: 39.0213360000282,
    longitude: -0.17404363698316397,
    referencePages: [
      WebcamReferencePage(
        title: 'Gandia · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/es/valencia/gandia/webcams/gandia-1',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Gandia Playa Restaurante Ripoll',
    source: 'Ibericam',
    status: 'Directo',
    resolution: 'Player web',
    primaryPageUrl:
        'https://ibericam.com/player/modern/player.html?s=4&a=live&v=gandia-playa-de-gandia&i=image-4&l=ibericam&primaryColor=%230044aaff',
    summary:
        'Webcam de la Playa de Gandia desde el Restaurante Ripoll, junto al Club Nautico.',
    previewImageUrl:
        'https://image-4.ibericam.com/poster/webcam-gandia-playa-de-gandia.webp',
    locationLabel: 'Restaurante Ripoll',
    referencePages: [
      WebcamReferencePage(
        title: 'Gandia Playa · Ibericam',
        url: 'https://ibericam.com/valencia/webcam-gandia-playa-de-gandia/',
      ),
    ],
  ),
];

const List<SpotWebcam> _deniaLesDevesesWebcams = [
  SpotWebcam(
    name: 'Denia Platja de les Deveses',
    source: 'Traffic Cams / Weathercloud',
    status: 'Imagen actualizable',
    resolution: 'Imagen web',
    primaryPageUrl:
        'https://www.traffic-cams.com/traffic-camshotsworld/WRLD19423.jpg',
    summary:
        'Imagen directa de la webcam ubicada junto a la estacion Weathercloud Platja de les Deveses.',
    previewImageUrl:
        'https://www.traffic-cams.com/traffic-camshotsworld/WRLD19423.jpg',
    locationLabel: 'Playa de Les Deveses',
    latitude: 38.8808,
    longitude: -0.0306,
    referencePages: [
      WebcamReferencePage(
        title: 'Denia Playa de Les Deveses · Traffic Cams',
        url:
            'https://www.traffic-cams.com/world/webcam/feed25373122804025didkey38846',
      ),
      WebcamReferencePage(
        title: 'Webcam Denia Deveses · Comunitat Valenciana',
        url:
            'http://comunitatvalenciana.com/actualidad/denia/webcams/webcam-denia-deveses',
      ),
      WebcamReferencePage(
        title: 'Platja de les Deveses · Weathercloud',
        url: 'https://app.weathercloud.net/d5629095484',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Denia Puerto',
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/es/alacant-alicante/denia/webcams/denia-puerto',
    summary:
        'Webcam oficial del puerto de Denia, usada como referencia visual cercana a Les Deveses.',
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/Denia/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/Denia/webcam_mini.png',
    locationLabel: 'Puerto de Denia',
    latitude: 38.8447,
    longitude: 0.1163,
    referencePages: [
      WebcamReferencePage(
        title: 'Denia Puerto · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/es/alacant-alicante/denia/webcams/denia-puerto',
      ),
    ],
  ),
];

const List<SpotWebcam> _calpeWebcams = [
  SpotWebcam(
    name: 'Calp Playa de la Fossa',
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/es/alacant-alicante/calp/webcams/calp-playa-de-la-fossa',
    summary:
        'Webcam oficial de Calp en la playa de la Fossa con vista al Penon de Ifach.',
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/CalpPlayaFoss/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/CalpPlayaFoss/webcam_mini.png',
    locationLabel: 'Platja de la Fossa',
    latitude: 38.6459,
    longitude: 0.0716,
    referencePages: [
      WebcamReferencePage(
        title: 'Calp Playa de la Fossa · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/es/alacant-alicante/calp/webcams/calp-playa-de-la-fossa',
      ),
    ],
  ),
];

const List<SpotWebcam> _alteaCapNegretWebcams = [
  SpotWebcam(
    name: 'Altea Maritimo',
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/es/alacant-alicante/altea/webcams/altea-maritimo',
    summary:
        'Webcam oficial de Altea Maritimo, usada como referencia visual cercana a Cap Negret.',
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/Altea/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/Altea/webcam_mini.png',
    locationLabel: 'Altea Maritimo',
    latitude: 38.5987,
    longitude: -0.0489,
    referencePages: [
      WebcamReferencePage(
        title: 'Altea Maritimo · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/es/alacant-alicante/altea/webcams/altea-maritimo',
      ),
    ],
  ),
];

const List<SpotWebcam> _villajoyosaEspigonWebcams = [
  SpotWebcam(
    name: 'La Vila Joiosa',
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/es/alacant-alicante/la-vila-joiosa-villajoyosa/webcams/la-vila-joiosa',
    summary:
        'Webcam oficial de La Vila Joiosa, usada como referencia visual del espigon.',
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/LaVilaJoiosa/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/LaVilaJoiosa/webcam_mini.png',
    locationLabel: 'La Vila Joiosa',
    latitude: 38.50250939174642,
    longitude: -0.23176962068917067,
    referencePages: [
      WebcamReferencePage(
        title: 'La Vila Joiosa · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/es/alacant-alicante/la-vila-joiosa-villajoyosa/webcams/la-vila-joiosa',
      ),
    ],
  ),
];

const List<SpotWebcam> _santaPolaPlatjaLissaWebcams = [
  SpotWebcam(
    name: 'Santa Pola Gran Playa',
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/es/alacant-alicante/santa-pola/webcams/santa-pola-gran-playa',
    summary:
        'Webcam oficial de Gran Playa, usada como referencia visual cercana a Playa Lisa.',
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/SantaPolaGranPlaya/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/SantaPolaGranPlaya/webcam_mini.png',
    locationLabel: 'Club Windsurf Santa Pola',
    latitude: 38.18894536347976,
    longitude: -0.5899657589196392,
    referencePages: [
      WebcamReferencePage(
        title: 'Santa Pola Gran Playa · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/es/alacant-alicante/santa-pola/webcams/santa-pola-gran-playa',
      ),
    ],
  ),
];

const List<SpotWebcam> _elCampelloPlayaMuchavistaWebcams = [
  SpotWebcam(
    name: 'El Campello',
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/es/alacant-alicante/el-campello/webcams/el-campello-1',
    summary:
        'Webcam oficial de El Campello, usada como referencia visual cercana a Playa Muchavista.',
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/ElCampello/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/ElCampello/webcam_mini.png',
    locationLabel: 'El Campello',
    latitude: 38.39511242726364,
    longitude: -0.40633815737892465,
    referencePages: [
      WebcamReferencePage(
        title: 'El Campello · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/es/alacant-alicante/el-campello/webcams/el-campello-1',
      ),
      WebcamReferencePage(
        title: 'Playa de Muchavista · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/es/alacant-alicante/el-campello/beaches/playa-de-muchavista',
      ),
    ],
  ),
];

const List<SpotWebcam> _elPerellonetWebcams = [
  SpotWebcam(
    name: 'Valencia El Saler',
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/de/valencia/valencia/webcams/valencia-el-saler',
    summary:
        'Webcam oficial de El Saler, usada como referencia visual cercana a El Perellonet.',
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/ElSaler/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/ElSaler/webcam_mini.png',
    locationLabel: 'El Saler',
    latitude: 39.28220282720261,
    longitude: -0.2768460668785311,
    referencePages: [
      WebcamReferencePage(
        title: 'Valencia El Saler · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/de/valencia/valencia/webcams/valencia-el-saler',
      ),
    ],
  ),
];

const List<SpotWebcam> _culleraDosselWebcams = [
  SpotWebcam(
    name: 'Cullera Dosser',
    source: 'Inforatge',
    status: 'Directo',
    resolution: 'Imagen actualizable',
    primaryPageUrl: 'https://inforatgedb.com/cullera/webcam2/webcamcullera.jpg',
    summary:
        'Webcam del deposito Safi en la zona del Dosser, la referencia visual mas cercana a El Pollo.',
    previewImageUrl:
        'https://inforatgedb.com/cullera/webcam2/webcamcullera.jpg',
    locationLabel: 'Cullera Dosser',
    latitude: 39.1889,
    longitude: -0.2263,
    referencePages: [
      WebcamReferencePage(
        title: 'Webcam Cullera Dosser · Inforatge',
        url: 'https://inforatge.com/meteo-cullera/webcam',
      ),
      WebcamReferencePage(
        title: 'Cullera instala en el Dosel una estacion y webcam',
        url:
            'https://visit-cullera.es/2021/10/28/cullera-instala-en-el-dosel-una-segunda-estacion-meteorologica/',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Cullera Sant Antoni',
    source: 'ClimaMeteoInfo',
    status: 'Directo',
    resolution: 'Imagen actualizable',
    primaryPageUrl:
        'https://www.climameteoinfo.com/webcam/id.VAL_210401867121.jpg',
    summary:
        'Webcam directa de la estacion Cullera-Sant Antoni, buena referencia visual al sur de El Pollo.',
    previewImageUrl:
        'https://www.climameteoinfo.com/webcam/id.VAL_210401867121.jpg',
    locationLabel: 'Cullera Sant Antoni',
    latitude: 39.162655,
    longitude: -0.244687,
    referencePages: [
      WebcamReferencePage(
        title: 'Cullera-Sant Antoni · ClimaMeteoInfo',
        url: 'https://climameteoinfo.com/webest/id.VAL_210401867121.html',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Cullera Marenyet',
    source: 'Naicams',
    status: 'Directo',
    resolution: 'YouTube',
    primaryPageUrl: 'https://www.youtube.com/watch?v=NNkpUXhP_L8',
    summary:
        'Camara en directo de Cullera - Marenyet. YouTube no permite incrustarla como iframe, por eso se abre con el reproductor oficial.',
    previewImageUrl: 'https://img.youtube.com/vi/NNkpUXhP_L8/hqdefault.jpg',
    locationLabel: 'Cullera Marenyet',
    latitude: 39.17258,
    longitude: -0.2392,
    referencePages: [
      WebcamReferencePage(
        title: 'Cullera - Marenyet · YouTube',
        url: 'https://www.youtube.com/watch?v=NNkpUXhP_L8',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Cullera Castillo',
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/va/valencia/cullera/webcams/castell-de-cullera-1-1',
    summary:
        'Webcam oficial de Cullera desde el castillo, usada como referencia visual cercana a El Dossel.',
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/CulleraCastillo/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/CulleraCastillo/webcam_mini.png',
    locationLabel: 'Castillo de Cullera',
    latitude: 39.194313988284584,
    longitude: -0.2252612016398693,
    referencePages: [
      WebcamReferencePage(
        title: 'Castell de Cullera · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/va/valencia/cullera/webcams/castell-de-cullera-1-1',
      ),
    ],
  ),
];

const List<SpotWebcam> _xeracoWebcams = [
  SpotWebcam(
    name: 'Xeraco Playa',
    source: 'CostaSol Xeraco',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://g0.ipcamlive.com/player/player.php?alias=645b5e0857e41',
    summary:
        'Webcam en directo de la playa de Xeraco con vista hacia la bahia de Cullera.',
    locationLabel: 'Playa de Xeraco',
    latitude: 39.04147,
    longitude: -0.18954,
    referencePages: [
      WebcamReferencePage(
        title: 'CostaSol Xeraco · Webcam playa',
        url: 'https://www.costasolxeraco.com/camara.php?Lang=es',
      ),
      WebcamReferencePage(
        title: 'Playa de Xeraco · Nuvoler',
        url: 'https://www.nuvoler.com/spot/72/',
      ),
    ],
  ),
];

List<SpotWebcam> webcamsForProfile(String? profile) {
  return switch (profile) {
    olivaCanalGorgsWebcamProfile => _olivaCanalGorgsWebcams,
    pilesWebcamProfile => _pilesWebcams,
    gandiaPlayaWebcamProfile => _gandiaPlayaWebcams,
    deniaLesDevesesWebcamProfile => _deniaLesDevesesWebcams,
    deniaPuntaMolinsWebcamProfile => _deniaLesDevesesWebcams,
    calpeWebcamProfile => _calpeWebcams,
    alteaCapNegretWebcamProfile => _alteaCapNegretWebcams,
    villajoyosaEspigonWebcamProfile => _villajoyosaEspigonWebcams,
    villajoyosaPlayaParaisoWebcamProfile => _villajoyosaEspigonWebcams,
    santaPolaPlatjaLissaWebcamProfile => _santaPolaPlatjaLissaWebcams,
    elCampelloPlayaMuchavistaWebcamProfile => _elCampelloPlayaMuchavistaWebcams,
    elPerellonetWebcamProfile => _elPerellonetWebcams,
    culleraDosselWebcamProfile => _culleraDosselWebcams,
    xeracoWebcamProfile => _xeracoWebcams,
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
  ..._gandiaPlayaWebcams,
  ..._deniaLesDevesesWebcams,
  ..._calpeWebcams,
  ..._alteaCapNegretWebcams,
  ..._villajoyosaEspigonWebcams,
  ..._santaPolaPlatjaLissaWebcams,
  ..._elCampelloPlayaMuchavistaWebcams,
  ..._elPerellonetWebcams,
  ..._culleraDosselWebcams,
  ..._xeracoWebcams,
];
