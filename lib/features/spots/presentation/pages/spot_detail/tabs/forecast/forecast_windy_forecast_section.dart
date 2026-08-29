part of '../../spot_detail_page.dart';

const String _windyOlivaForecastAppId = 'dbf4f161c6247e37676bba0c32551af2';
const double _windyForecastWidgetHeight = 560;

extension _SpotDetailForecastWindyForecastSection on _SpotDetailPageState {
  WebViewController? _createWindyForecastController() {
    if (WebViewPlatform.instance == null) {
      return null;
    }
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(
        _windyForecastWidgetHtml(
          latitude: _windyWidgetLatitude,
          longitude: _windyWidgetLongitude,
        ),
        baseUrl: 'https://windy.app',
      );
  }

  Widget _buildWindyForecastSection() {
    if (!_showsWindyMapWidget()) {
      return const SizedBox.shrink();
    }

    final controller = kIsWeb || _SpotDetailPageState._isFlutterTest
        ? null
        : (_windyForecastController ??= _createWindyForecastController());
    final content = kIsWeb
        ? WindyWidgetWebEmbed(
            html: _windyForecastWidgetHtml(
              latitude: _windyWidgetLatitude,
              longitude: _windyWidgetLongitude,
            ),
            viewTypePrefix: 'windy-forecast',
          )
        : controller == null
        ? Center(
            child: Text(
              _SpotDetailPageState._isFlutterTest
                  ? 'Forecast Windy.app no disponible en pruebas.'
                  : 'El forecast Windy.app no esta disponible en este dispositivo.',
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
        Text(
          'Prevision Windy.app',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Prevision calculada para las coordenadas exactas del spot de Oliva.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ColoredBox(
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: _windyForecastWidgetHeight,
              child: content,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

String _windyForecastWidgetHtml({
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
      min-height: 100%;
      overflow-x: hidden;
      background: #ffffff;
    }
    [data-windywidget="forecast"] {
      box-sizing: border-box;
      width: 100% !important;
      min-height: 540px !important;
    }
  </style>
</head>
<body>
  <div
    data-windywidget="forecast"
    data-thememode="white"
    data-lat="$latitude"
    data-lng="$longitude"
    data-appid="$_windyOlivaForecastAppId">
  </div>
  <script async data-cfasync="false"
    src="https://windy.app/widgets-code/forecast/windy_forecast_async.js"></script>
</body>
</html>''';
}
