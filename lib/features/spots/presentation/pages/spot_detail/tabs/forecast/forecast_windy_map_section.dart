part of '../../spot_detail_page.dart';

const String _windyOlivaMapAppId = 'f4d40d8257d0226ea41d05be99b3e11a';
const double _windyMapWidgetHeight = 480;
const double _windyOlivaLatitude = 38.91397175799847;
const double _windyOlivaLongitude = -0.07335473217682421;

bool _isWindyAppWidgetEnabledForSpot(String spotName) {
  return spotName.trim().toLowerCase() == _windguruOlivaSpotName.toLowerCase();
}

extension _SpotDetailForecastWindyMapSection on _SpotDetailPageState {
  bool _showsWindyMapWidget() {
    return _usesWindyAppProvider() &&
        _isWindyAppWidgetEnabledForSpot(widget.name);
  }

  WebViewController? _createWindyMapController() {
    if (WebViewPlatform.instance == null) {
      return null;
    }
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(
        _windyMapWidgetHtml(
          latitude: _windyWidgetLatitude,
          longitude: _windyWidgetLongitude,
        ),
        baseUrl: 'https://windy.app',
      );
  }

  double get _windyWidgetLatitude => widget.latitude ?? _windyOlivaLatitude;

  double get _windyWidgetLongitude => widget.longitude ?? _windyOlivaLongitude;

  Widget _buildWindyMapSection() {
    if (!_showsWindyMapWidget()) {
      return const SizedBox.shrink();
    }

    final controller = kIsWeb || _SpotDetailPageState._isFlutterTest
        ? null
        : (_windyMapController ??= _createWindyMapController());
    final content = kIsWeb
        ? WindyWidgetWebEmbed(
            html: _windyMapWidgetHtml(
              latitude: _windyWidgetLatitude,
              longitude: _windyWidgetLongitude,
            ),
            viewTypePrefix: 'windy-map',
          )
        : controller == null
        ? Center(
            child: Text(
              _SpotDetailPageState._isFlutterTest
                  ? 'Mapa Windy.app no disponible en pruebas.'
                  : 'El mapa Windy.app no esta disponible en este dispositivo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        : WebViewWidget(
            controller: controller,
            gestureRecognizers: {
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          'Mapa de viento Windy.app',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Mapa interactivo para Oliva con seleccion de modelos meteorologicos.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ColoredBox(
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: _windyMapWidgetHeight,
              child: content,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

String _windyMapWidgetHtml({
  required double latitude,
  required double longitude,
}) {
  return '''<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: #ffffff;
    }
    [data-windywidget="map"] {
      width: 100% !important;
      height: 100% !important;
      min-height: 100% !important;
    }
  </style>
</head>
<body>
  <div
    data-windywidget="map"
    data-lat="$latitude"
    data-lng="$longitude"
    data-appid="$_windyOlivaMapAppId"
    data-spots="true"
    data-width="100%"
    data-height="100%">
  </div>
  <script async data-cfasync="false"
    src="https://windy.app/widgets-code/map/windy_map_async.js"></script>
</body>
</html>''';
}
