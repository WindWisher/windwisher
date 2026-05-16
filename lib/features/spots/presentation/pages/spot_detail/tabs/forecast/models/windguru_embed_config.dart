part of '../../../spot_detail_page.dart';

const double _windguruWidgetHeight = 680;
const String _windguruOlivaSpotName = 'Oliva Canal - Platja dels Gorgs';
const String _windguruPilesSpotName = 'Piles';
const String _windguruGandiaPlayaSpotName = 'Gandia Playa';
const String _windguruDeniaLesDevesesSpotName = 'Denia - Les Deveses';
const String _windguruDeniaPuntaMolinsSpotName = 'Denia - Punta Els Molins';
const String _windguruCalpeSpotName = 'Calpe';
const String _windguruAlteaCapNegretSpotName =
    'Altea - Cap Negret (Desembocadura Rio Algar)';
const String _windguruVillajoyosaEspigonSpotName = 'Villajoyosa - Espigon';
const String _windguruVillajoyosaPlayaParaisoSpotName =
    'Villajoyosa - Playa Paraiso';
const String _windguruSantaPolaPlatjaLissaSpotName =
    'Santa Pola - Platja Lissa';
const String _windguruElCampelloPlayaMuchavistaSpotName =
    'El Campello - Playa Muchavista';
const String _windguruElPerellonetSpotName = 'El Perellonet';
const String _windguruXeracoSpotName = 'Xeraco';
const String _windguruTarifaBalnearioSpotName = 'Tarifa - Balneario';
const String _windguruTarifaValdevaquerosSpotName = 'Tarifa - Valdevaqueros';
const String _windguruCulleraElPolloSpotName = 'Cullera - El Pollo';

bool _isWindguruWidgetEnabledForSpot(String spotName) {
  final normalizedSpot = spotName.trim().toLowerCase();
  return normalizedSpot == _windguruOlivaSpotName.toLowerCase() ||
      normalizedSpot == _windguruPilesSpotName.toLowerCase() ||
      normalizedSpot == _windguruElPerellonetSpotName.toLowerCase() ||
      normalizedSpot == _windguruCulleraElPolloSpotName.toLowerCase() ||
      normalizedSpot == _windguruGandiaPlayaSpotName.toLowerCase() ||
      normalizedSpot == _windguruDeniaPuntaMolinsSpotName.toLowerCase() ||
      normalizedSpot == _windguruCalpeSpotName.toLowerCase() ||
      normalizedSpot == _windguruSantaPolaPlatjaLissaSpotName.toLowerCase() ||
      normalizedSpot ==
          _windguruElCampelloPlayaMuchavistaSpotName.toLowerCase() ||
      normalizedSpot == _windguruTarifaValdevaquerosSpotName.toLowerCase();
}

double _windguruWidgetHeightForSpot(String spotName) {
  return _windguruWidgetHeight;
}

String _windguruWidgetHtmlForSpot(String spotName) {
  final normalizedSpot = spotName.trim().toLowerCase();
  if (!_isWindguruWidgetEnabledForSpot(spotName)) {
    return _buildWindguruUnavailableHtml(spotName);
  }
  if (normalizedSpot == _windguruPilesSpotName.toLowerCase()) {
    return _buildWindguruWidgetHtml(
      spotId: '504236',
      widgetId: 'wg_fwdg_504236_52_1778698331142',
    );
  }
  if (normalizedSpot == _windguruGandiaPlayaSpotName.toLowerCase()) {
    return _buildWindguruWidgetHtml(
      spotId: '48859',
      widgetId: 'wg_fwdg_48859_52_1778870000005',
    );
  }
  if (normalizedSpot == _windguruDeniaLesDevesesSpotName.toLowerCase()) {
    return _buildWindguruWidgetHtml(
      spotId: '207168',
      widgetId: 'wg_fwdg_207168_52_1778788880000',
    );
  }
  if (normalizedSpot == _windguruDeniaPuntaMolinsSpotName.toLowerCase()) {
    return _buildWindguruWidgetHtml(
      spotId: '48855',
      widgetId: 'wg_fwdg_48855_52_1778788880001',
    );
  }
  if (normalizedSpot == _windguruCalpeSpotName.toLowerCase()) {
    return _buildWindguruWidgetHtml(
      spotId: '48851',
      widgetId: 'wg_fwdg_48851_52_1778788880002',
    );
  }
  if (normalizedSpot == _windguruAlteaCapNegretSpotName.toLowerCase()) {
    return _buildWindguruWidgetHtml(
      spotId: '48851',
      widgetId: 'wg_fwdg_48851_52_1778788880003',
    );
  }
  if (normalizedSpot == _windguruVillajoyosaEspigonSpotName.toLowerCase()) {
    return _buildWindguruWidgetHtml(
      spotId: '342848',
      widgetId: 'wg_fwdg_342848_52_1778840000000',
    );
  }
  if (normalizedSpot ==
      _windguruVillajoyosaPlayaParaisoSpotName.toLowerCase()) {
    return _buildWindguruWidgetHtml(
      spotId: '342848',
      widgetId: 'wg_fwdg_342848_52_1778840000001',
    );
  }
  if (normalizedSpot == _windguruSantaPolaPlatjaLissaSpotName.toLowerCase()) {
    return _buildWindguruWidgetHtml(
      spotId: '48840',
      widgetId: 'wg_fwdg_48840_52_1778870000000',
    );
  }
  if (normalizedSpot ==
      _windguruElCampelloPlayaMuchavistaSpotName.toLowerCase()) {
    return _buildWindguruWidgetHtml(
      spotId: '48846',
      widgetId: 'wg_fwdg_48846_52_1778870000001',
    );
  }
  if (normalizedSpot == _windguruElPerellonetSpotName.toLowerCase()) {
    return _buildWindguruWidgetHtml(
      spotId: '48862',
      widgetId: 'wg_fwdg_48862_52_1778870000002',
    );
  }
  if (normalizedSpot == _windguruTarifaValdevaquerosSpotName.toLowerCase()) {
    return _buildWindguruWidgetHtml(
      spotId: '541946',
      widgetId: 'wg_fwdg_541946_52_1778870000006',
    );
  }
  if (normalizedSpot == _windguruCulleraElPolloSpotName.toLowerCase()) {
    return _buildWindguruWidgetHtml(
      spotId: '48861',
      widgetId: 'wg_fwdg_48861_52_1778870000004',
    );
  }
  return _buildWindguruWidgetHtml(
    spotId: '48858',
    widgetId: 'wg_fwdg_48858_52_1773264003952',
  );
}

String _windguruWidgetSubtitleForSpot(String spotName) {
  final normalizedSpot = spotName.trim().toLowerCase();
  if (normalizedSpot == _windguruPilesSpotName.toLowerCase()) {
    return 'Widget Windguru · Piles';
  }
  if (normalizedSpot == _windguruGandiaPlayaSpotName.toLowerCase()) {
    return 'Widget Windguru · Gandia';
  }
  if (normalizedSpot == _windguruDeniaLesDevesesSpotName.toLowerCase()) {
    return 'Widget Windguru · Les Deveses';
  }
  if (normalizedSpot == _windguruDeniaPuntaMolinsSpotName.toLowerCase()) {
    return 'Widget Windguru · Punta Molins';
  }
  if (normalizedSpot == _windguruCalpeSpotName.toLowerCase()) {
    return 'Widget Windguru · Calpe';
  }
  if (normalizedSpot == _windguruAlteaCapNegretSpotName.toLowerCase()) {
    return 'Widget Windguru · Calpe como referencia cercana a Altea';
  }
  if (normalizedSpot == _windguruVillajoyosaEspigonSpotName.toLowerCase()) {
    return 'Widget Windguru · Villajoyosa';
  }
  if (normalizedSpot ==
      _windguruVillajoyosaPlayaParaisoSpotName.toLowerCase()) {
    return 'Widget Windguru · Villajoyosa';
  }
  if (normalizedSpot == _windguruSantaPolaPlatjaLissaSpotName.toLowerCase()) {
    return 'Widget Windguru · Santa Pola';
  }
  if (normalizedSpot ==
      _windguruElCampelloPlayaMuchavistaSpotName.toLowerCase()) {
    return 'Widget Windguru · San Juan / Muchavista';
  }
  if (normalizedSpot == _windguruElPerellonetSpotName.toLowerCase()) {
    return 'Widget Windguru · El Mareny Blau / Perello';
  }
  if (normalizedSpot == _windguruXeracoSpotName.toLowerCase()) {
    return 'Widget Windguru · Xeraco';
  }
  if (normalizedSpot == _windguruTarifaBalnearioSpotName.toLowerCase()) {
    return 'Widget Windguru · Tarifa';
  }
  if (normalizedSpot == _windguruTarifaValdevaquerosSpotName.toLowerCase()) {
    return 'Widget Windguru · Valdevaqueros';
  }
  if (normalizedSpot == _windguruCulleraElPolloSpotName.toLowerCase()) {
    return 'Widget Windguru · Cullera';
  }
  if (normalizedSpot == _windguruOlivaSpotName.toLowerCase()) {
    return 'Widget Windguru · Oliva Canal';
  }
  if (!_isWindguruWidgetEnabledForSpot(spotName)) {
    return 'Windguru reservado para 10 spots prioritarios';
  }
  return 'Widget Windguru · $spotName';
}

String _buildWindguruUnavailableHtml(String spotName) {
  final safeSpotName = spotName
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
  return '''<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      min-height: 100%;
      background: #ffffff;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      color: #263238;
    }
    .message {
      box-sizing: border-box;
      min-height: 220px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      gap: 8px;
      padding: 24px;
      text-align: center;
    }
    .title {
      font-size: 18px;
      font-weight: 700;
    }
    .body {
      font-size: 14px;
      line-height: 1.4;
      color: #607d8b;
    }
  </style>
</head>
<body>
  <div class="message">
    <div class="title">Windguru no configurado para $safeSpotName</div>
    <div class="body">El limite de widgets se reserva para los 10 spots prioritarios.</div>
  </div>
</body>
</html>
''';
}

String _buildWindguruWidgetHtml({
  required String spotId,
  required String widgetId,
  bool constrainedLayout = false,
}) {
  final layoutCss = constrainedLayout
      ? '''
      min-width: 980px;
      overflow-x: auto;
      overflow-y: hidden;
      -webkit-text-size-adjust: 100%;
    }
    body {
      width: max-content;
      min-height: 720px;'''
      : '''
      overflow: hidden;''';
  return '''<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      background: #ffffff;
      $layoutCss
    }
  </style>
</head>
<body>
  <script id="$widgetId">
    (function (window, document) {
      var loader = function () {
        var arg = ["s=$spotId", "m=52", "mw=84", "uid=$widgetId", "ai=0", "wj=knots", "tj=c", "waj=m", "tij=cm", "odh=0", "doh=24", "fhours=240", "hrsm=1", "vt=forecasts", "lng=es", "p=WINDSPD,GUST,MWINDSPD,SMER,HTSGW,PERPW,DIRPW,PWEN,SWELL1,SWPER1,SWEN1,SWDIR1,SWELL2,SWEN2,SWPER2,SWDIR2,WVHGT,WVPER,WVEN,WVDIR,TMPE,TMP,WCHILL,CDC,TCDC,APCP1s,RH,RATING"];
        var script = document.createElement("script");
        var tag = document.getElementsByTagName("script")[0];
        script.src = "https://www.windguru.cz/js/widget.php?" + (arg.join("&"));
        tag.parentNode.insertBefore(script, tag);
      };
      window.addEventListener ? window.addEventListener("load", loader, false) : window.attachEvent("onload", loader);
    })(window, document);
  </script>
</body>
</html>
''';
}
