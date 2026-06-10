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
    name: 'Calp Playa Arenal-Bol',
    source: 'Ibericam / Ayuntamiento de Calp',
    status: 'Directo',
    resolution: 'Player web',
    primaryPageUrl:
        'https://ibericam.com/player/modern/player.html?s=4&a=live&v=calpe-playa-del-arenal-bol&i=image-4&l=ibericam&primaryColor=%230044aaff',
    summary:
        'Webcam en directo desde Playa Arenal-Bol con vista al Penon de Ifach.',
    previewImageUrl:
        'https://image-4.ibericam.com/poster/webcam-calpe-playa-del-arenal-bol.webp',
    locationLabel: 'Playa Arenal-Bol',
    latitude: 38.6422,
    longitude: 0.0469,
    referencePages: [
      WebcamReferencePage(
        title: 'Calp Arenal-Bol · Ayuntamiento de Calp',
        url: 'https://www.calp.es/es/webcams',
      ),
      WebcamReferencePage(
        title: 'Calpe Playa del Arenal-Bol · Ibericam',
        url: 'https://ibericam.com/alicante/webcam-calpe-playa-del-arenal-bol/',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Calp Solymar Gran Hotel',
    source: 'IPCamLive / Estimar Hotels',
    status: 'Directo',
    resolution: 'Player web',
    primaryPageUrl:
        'https://g0.ipcamlive.com/player/player.php?alias=5c35e0c28ae9d&autoplay=1',
    summary:
        'Webcam del Hotel Solymar con vista directa a la Playa Arenal-Bol.',
    previewImageUrl:
        'https://www.turismolive.es/wp-content/uploads/2025/03/25-03-02-A-Calpe-Playa-del-Arenal.jpg',
    locationLabel: 'SOLYMAR Gran Hotel',
    latitude: 38.6424,
    longitude: 0.0494,
    referencePages: [
      WebcamReferencePage(
        title: 'Live Cam SOLYMAR Gran Hotel · Estimar Hotels',
        url: 'https://estimarhotels.com/calpe/solymar-gran-hotel/live-cam/',
      ),
      WebcamReferencePage(
        title: 'Calpe Playa Arenal-Bol · Turismo Live',
        url:
            'https://www.turismolive.es/webcam-calpe-alicante-playa-del-arenal-bol/',
      ),
    ],
  ),
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
      WebcamReferencePage(
        title: 'Calpe · Vision-Environnement',
        url:
            'https://www.vision-environnement.com/es/webcam/espana/alicante/836-calpe/',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Calp Club Nautico',
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/es/alacant-alicante/calp/webcams/calp-club-nautico',
    summary:
        'Webcam oficial del Club Nautico de Calp con vista a la bahia y al Penon de Ifach.',
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/CalpeNautico/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/CalpeNautico/webcam_mini.png',
    locationLabel: 'Club Nautico de Calp',
    latitude: 38.6427,
    longitude: 0.0694,
    referencePages: [
      WebcamReferencePage(
        title: 'Calp Club Nautico · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/es/alacant-alicante/calp/webcams/calp-club-nautico',
      ),
      WebcamReferencePage(
        title: 'Calp Yacht Club · Comunitat Valenciana',
        url:
            'https://www.comunitatvalenciana.com/en/alacant-alicante/calp/webcams/calp-yacht-club',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Calp Penon de Ifach y puerto',
    source: 'SkylineWebcams / Hotel Porto Calpe',
    status: 'Directo',
    resolution: 'Player web',
    primaryPageUrl:
        'https://www.skylinewebcams.com/es/webcam/espana/comunidad-valenciana/alicante/calpe-penon-de-ifach.html',
    summary:
        'Vista panoramica del Penon de Ifach y el puerto deportivo de Calp.',
    previewImageUrl: 'https://cdn.skylinewebcams.com/social3032.jpg',
    locationLabel: 'Puerto de Calp',
    latitude: 38.6399,
    longitude: 0.0692,
    referencePages: [
      WebcamReferencePage(
        title: 'Calp Penon de Ifach · SkylineWebcams',
        url:
            'https://www.skylinewebcams.com/es/webcam/espana/comunidad-valenciana/alicante/calpe-penon-de-ifach.html',
      ),
      WebcamReferencePage(
        title: 'Webcams · Ayuntamiento de Calp',
        url: 'https://www.calp.es/es/webcams',
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
  SpotWebcam(
    name: 'Altea Cap-Blanch Playa',
    source: 'Camping Cap-Blanch / YouTube',
    status: 'Directo',
    resolution: 'YouTube live',
    primaryPageUrl: 'https://www.youtube.com/watch?v=hvsK8Fvz4rE',
    summary:
        'Webcam de playa del Camping Cap-Blanch, muy cercana a Altea y Cap Negret.',
    previewImageUrl: 'https://img.youtube.com/vi/hvsK8Fvz4rE/hqdefault.jpg',
    locationLabel: 'Camping Cap-Blanch',
    latitude: 38.57451,
    longitude: -0.064749,
    referencePages: [
      WebcamReferencePage(
        title: 'Camping Cap-Blanch · Webcam Playa de Altea',
        url: 'https://www.camping-capblanch.com/webcam1.html',
      ),
      WebcamReferencePage(
        title: 'Playa de Altea · YouTube',
        url: 'https://www.youtube.com/watch?v=hvsK8Fvz4rE',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Altea Cap-Blanch Entrada',
    source: 'Camping Cap-Blanch / YouTube',
    status: 'Directo',
    resolution: 'YouTube live',
    primaryPageUrl: 'https://www.youtube.com/watch?v=SE1Oh8qn9Sk',
    summary:
        'Webcam de entrada del Camping Cap-Blanch, util como referencia secundaria.',
    previewImageUrl: 'https://img.youtube.com/vi/SE1Oh8qn9Sk/hqdefault.jpg',
    locationLabel: 'Camping Cap-Blanch',
    latitude: 38.57451,
    longitude: -0.064749,
    referencePages: [
      WebcamReferencePage(
        title: 'Camping Cap-Blanch · Webcam entrada',
        url: 'https://www.camping-capblanch.com/webcam2.html',
      ),
      WebcamReferencePage(
        title: 'Entrada Camping Cap-Blanch · YouTube',
        url: 'https://www.youtube.com/watch?v=SE1Oh8qn9Sk',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Altea Cap-Blanch Interior',
    source: 'Camping Cap-Blanch / YouTube',
    status: 'Directo',
    resolution: 'YouTube live',
    primaryPageUrl: 'https://www.youtube.com/watch?v=9ebySyOCIqg',
    summary:
        'Webcam interior del Camping Cap-Blanch, anadida temporalmente para pruebas.',
    previewImageUrl: 'https://img.youtube.com/vi/9ebySyOCIqg/hqdefault.jpg',
    locationLabel: 'Camping Cap-Blanch',
    latitude: 38.57451,
    longitude: -0.064749,
    referencePages: [
      WebcamReferencePage(
        title: 'Camping Cap-Blanch · Webcam interior',
        url: 'https://www.camping-capblanch.com/webcam3.html',
      ),
      WebcamReferencePage(
        title: 'Interior Camping Cap-Blanch · YouTube',
        url: 'https://www.youtube.com/watch?v=9ebySyOCIqg',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Altea Cap-Blanch Albir',
    source: 'Camping Cap-Blanch / YouTube',
    status: 'Directo',
    resolution: 'YouTube live',
    primaryPageUrl: 'https://www.youtube.com/watch?v=mdOqWWUxIJw',
    summary:
        'Webcam hacia Playa del Albir y Sierra Helada desde Camping Cap-Blanch.',
    previewImageUrl: 'https://img.youtube.com/vi/mdOqWWUxIJw/hqdefault.jpg',
    locationLabel: 'Camping Cap-Blanch',
    latitude: 38.57451,
    longitude: -0.064749,
    referencePages: [
      WebcamReferencePage(
        title: 'Camping Cap-Blanch · Webcam Playa del Albir',
        url: 'https://www.camping-capblanch.com/webcam4.html',
      ),
      WebcamReferencePage(
        title: 'Playa del Albir · YouTube',
        url: 'https://www.youtube.com/watch?v=mdOqWWUxIJw',
      ),
    ],
  ),
  SpotWebcam(
    name: "L'Alfas del Pi",
    source: 'Comunitat Valenciana',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.comunitatvalenciana.com/es/alacant-alicante/lalfas-del-pi/webcams/l-alfas-del-pi',
    summary:
        'Webcam oficial de L\'Alfas del Pi, cercana a Altea por la zona de Albir.',
    streamManifestUrl:
        'https://streaming.comunitatvalenciana.com/webcam/Alfaselpi/manifest.mpd',
    previewImageUrl:
        'https://streaming.comunitatvalenciana.com/static/Alfaselpi/webcam_mini.png',
    locationLabel: "L'Alfas del Pi",
    latitude: 38.57451,
    longitude: -0.064749,
    referencePages: [
      WebcamReferencePage(
        title: "L'Alfas del Pi · Comunitat Valenciana",
        url:
            'https://www.comunitatvalenciana.com/es/alacant-alicante/lalfas-del-pi/webcams/l-alfas-del-pi',
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
  SpotWebcam(
    name: 'Villajoyosa Sea View',
    source: 'SkylineWebcams / Hotel Montiboli',
    status: 'Directo',
    resolution: 'Player web',
    primaryPageUrl:
        'https://www.skylinewebcams.com/es/webcam/espana/comunidad-valenciana/alicante/villajoyosa.html',
    summary:
        'Vista panoramica de la costa de Villajoyosa desde la zona de Montiboli.',
    previewImageUrl: 'https://cdn.skylinewebcams.com/social2675.jpg',
    locationLabel: 'Hotel Montiboli',
    latitude: 38.5096,
    longitude: -0.1947,
    referencePages: [
      WebcamReferencePage(
        title: 'Villajoyosa · SkylineWebcams',
        url:
            'https://www.skylinewebcams.com/es/webcam/espana/comunidad-valenciana/alicante/villajoyosa.html',
      ),
      WebcamReferencePage(
        title: 'Webcam · Hotel Montiboli',
        url: 'https://www.montiboli.com/es/entorno/webcam/',
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
  SpotWebcam(
    name: 'Santa Pola Gran Playa panoramica',
    source: 'SkylineWebcams',
    status: 'Directo',
    resolution: 'Player web',
    primaryPageUrl:
        'https://www.skylinewebcams.com/es/webcam/espana/comunidad-valenciana/santa-pola/gran-playa.html',
    summary:
        'Vista panoramica elevada de Gran Playa y Playa Lisa, diferente a la webcam oficial situada a nivel de playa.',
    previewImageUrl: 'https://cdn.skylinewebcams.com/social4821.jpg',
    locationLabel: 'Gran Playa',
    latitude: 38.1922,
    longitude: -0.5656,
    referencePages: [
      WebcamReferencePage(
        title: 'Santa Pola Gran Playa · SkylineWebcams',
        url:
            'https://www.skylinewebcams.com/es/webcam/espana/comunidad-valenciana/santa-pola/gran-playa.html',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Santa Pola paseo maritimo y puerto',
    source: 'SkylineWebcams',
    status: 'Directo',
    resolution: 'Player web',
    primaryPageUrl:
        'https://www.skylinewebcams.com/es/webcam/espana/comunidad-valenciana/santa-pola/paseo-maritimo.html',
    summary:
        'Vista panoramica del paseo maritimo y del puerto deportivo de Santa Pola.',
    previewImageUrl: 'https://cdn.skylinewebcams.com/social4828.jpg',
    locationLabel: 'Puerto deportivo de Santa Pola',
    latitude: 38.18968,
    longitude: -0.55438,
    referencePages: [
      WebcamReferencePage(
        title: 'Santa Pola paseo maritimo · SkylineWebcams',
        url:
            'https://www.skylinewebcams.com/es/webcam/espana/comunidad-valenciana/santa-pola/paseo-maritimo.html',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Santa Pola Nautica Antonio',
    source: 'Nautica Antonio',
    status: 'Directo',
    resolution: 'MJPEG',
    primaryPageUrl:
        'http://nauticaantonio.telecablesantapola.es:8085/axis-cgi/mjpg/video.cgi?resolution=640x480',
    summary:
        'Flujo directo desde el contradique del puerto pesquero de Santa Pola con vista hacia el sur.',
    previewImageUrl:
        'https://images.webcamgalore.com/13710-current-webcam-Santa-Pola.jpg',
    locationLabel: 'Contradique del puerto pesquero',
    latitude: 38.1869,
    longitude: -0.562878,
    referencePages: [
      WebcamReferencePage(
        title: 'Nautica Antonio vista sur · IpLiveCams',
        url:
            'https://www.iplivecams.com/live-cams/nautica-antonio-south-view-alicante-spain/',
      ),
      WebcamReferencePage(
        title: 'Nautica Antonio · Webcam Galore',
        url: 'https://www.webcamgalore.com/webcam/Spain/Santa-Pola/13710.html',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Isla de Tabarca puerto',
    source: 'AVAMET',
    status: 'Directo',
    resolution: 'Imagen live',
    primaryPageUrl: 'https://www.avamet.es/estacions/illaplana/tabarca.jpg',
    summary:
        'Vista norte del puerto de Tabarca, actualizada aproximadamente cada 3 minutos.',
    previewImageUrl: 'https://www.avamet.es/estacions/illaplana/tabarca.jpg',
    locationLabel: 'Puerto de Tabarca',
    latitude: 38.1658,
    longitude: -0.4815,
    referencePages: [
      WebcamReferencePage(
        title: 'Tabarca · AVAMET',
        url: 'https://www.avamet.org/mxo_i.php?id=c32m014e27',
      ),
    ],
  ),
];

const List<SpotWebcam> _elCampelloPlayaMuchavistaWebcams = [
  SpotWebcam(
    name: 'Playa Muchavista',
    source: 'Ayuntamiento de El Campello',
    status: 'Directo',
    resolution: 'Imagen live',
    primaryPageUrl: 'http://cams.elcampello.es:85/image/muchavista',
    summary:
        'Webcam municipal situada en Playa Muchavista, la referencia visual mas cercana al spot.',
    previewImageUrl: 'http://cams.elcampello.es:85/image/muchavista',
    locationLabel: 'Playa Muchavista',
    latitude: 38.384911564997914,
    longitude: -0.4089188575744629,
    referencePages: [
      WebcamReferencePage(
        title: 'Webcams Ayuntamiento de El Campello',
        url: 'https://www.elcampello.es/index.php?s=webcams',
      ),
    ],
  ),
  SpotWebcam(
    name: 'Playa El Campello · Camaramar',
    source: 'Camaramar',
    status: 'Directo',
    resolution: 'HLS',
    primaryPageUrl:
        'https://www.camaramar.com/webcam/comunidad-valenciana_alicante_campello',
    summary:
        'Webcam de Camaramar/Campello Surf Club con vista de playa y previsiones de surf.',
    streamManifestUrl:
        'https://wow.camaramar.com/camaramar/42_campello.stream/playlist.m3u8',
    previewImageUrl:
        'https://www.camaramar.com/uploads/webcam/98d64c89-1847-44b1-a4d3-5ff88a05f697.webp',
    locationLabel: 'Playa El Campello',
    latitude: 38.39511242726364,
    longitude: -0.40633815737892465,
    referencePages: [
      WebcamReferencePage(
        title: 'Webcam Playa El Campello · Camaramar',
        url:
            'https://www.camaramar.com/webcam/comunidad-valenciana_alicante_campello',
      ),
    ],
  ),
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

const List<SpotWebcam> _tarifaBalnearioWebcams = [
  SpotWebcam(
    name: 'Tarifa Balneario',
    source: 'Camaramar',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl: 'https://www.camaramar.com/webcam/tarifa-balneario',
    summary: 'Webcam en directo de la playa del Balneario y Los Lances Sur.',
    locationLabel: 'Playa del Balneario',
    latitude: 36.00911890458527,
    longitude: -5.60893187013924,
    referencePages: [
      WebcamReferencePage(
        title: 'Tarifa Balneario · Camaramar',
        url: 'https://www.camaramar.com/webcam/tarifa-balneario',
      ),
      WebcamReferencePage(
        title: 'Los Lances Sur · Spotfav',
        url: 'https://www.spotfav.com/dashboard/spots/los-lances-sur',
      ),
    ],
  ),
];

const List<SpotWebcam> _tarifaCampoFutbolWebcams = [
  SpotWebcam(
    name: 'Tarifa Rio Jara',
    source: 'Ozu Tarifa',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.kiteschool-ozutarifa.com/webcam-kitesurf-tarifa/',
    summary: 'Webcam en directo de Rio Jara y el spot Campo de futbol.',
    previewImageUrl:
        'https://www.kiteschool-ozutarifa.com/wp-content/uploads/2024/02/webcam.jpg',
    locationLabel: 'Rio Jara',
    latitude: 36.02129962247533,
    longitude: -5.616776453751289,
    referencePages: [
      WebcamReferencePage(
        title: 'Webcam kitesurf Tarifa · Ozu Tarifa',
        url: 'https://www.kiteschool-ozutarifa.com/webcam-kitesurf-tarifa/',
      ),
      WebcamReferencePage(
        title: 'Campo de futbol - Rio Jara · Spotfav',
        url: 'https://www.spotfav.com/dashboard/spots/campo-de-futbol-rio-jara',
      ),
      WebcamReferencePage(
        title: 'Tarifa Rio Jara · WorldCam',
        url:
            'https://worldcam.eu/webcams/europe/spain/35943-tarifa-rio-jara-kitesurf-spot',
      ),
    ],
  ),
];

const List<SpotWebcam> _tarifaLosLancesWebcams = [
  SpotWebcam(
    name: 'Tarifa Los Lances',
    source: 'Meteo365',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl: 'https://meteo365.es/livecams/tarifa.php',
    summary: 'Webcam en directo de la playa de Los Lances.',
    locationLabel: 'Playa de Los Lances',
    latitude: 36.046076176197694,
    longitude: -5.640893942328883,
    referencePages: [
      WebcamReferencePage(
        title: 'Tarifa Los Lances · Meteo365',
        url: 'https://meteo365.es/livecams/tarifa.php',
      ),
      WebcamReferencePage(
        title: 'Tarifa Playa · Meteo365',
        url: 'https://meteo365.es/livecams/tarifa-playa.php',
      ),
    ],
  ),
];

const List<SpotWebcam> _tarifaValdevaquerosWebcams = [
  SpotWebcam(
    name: 'Tarifa Valdevaqueros Spin Out',
    source: 'Spin Out',
    status: 'Directo',
    resolution: 'Web oficial',
    primaryPageUrl:
        'https://www.tarifaspinout.com/weather-webcam-tarifa-spin-out',
    summary: 'Webcam en directo de la playa de Valdevaqueros.',
    locationLabel: 'Valdevaqueros',
    latitude: 36.06686048995999,
    longitude: -5.6851553052299035,
    referencePages: [
      WebcamReferencePage(
        title: 'Weather & webcam Tarifa · Spin Out',
        url: 'https://www.tarifaspinout.com/weather-webcam-tarifa-spin-out',
      ),
      WebcamReferencePage(
        title: 'Tarifa Valdevaqueros · WorldCam',
        url:
            'https://es.worldcam.eu/webcams/europe/spain/23926-tarifa-valdevaqueros',
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
    tarifaBalnearioWebcamProfile => _tarifaBalnearioWebcams,
    tarifaCampoFutbolWebcamProfile => _tarifaCampoFutbolWebcams,
    tarifaLosLancesWebcamProfile => _tarifaLosLancesWebcams,
    tarifaValdevaquerosWebcamProfile => _tarifaValdevaquerosWebcams,
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
  ..._tarifaBalnearioWebcams,
  ..._tarifaCampoFutbolWebcams,
  ..._tarifaLosLancesWebcams,
  ..._tarifaValdevaquerosWebcams,
  ..._culleraDosselWebcams,
  ..._xeracoWebcams,
];
