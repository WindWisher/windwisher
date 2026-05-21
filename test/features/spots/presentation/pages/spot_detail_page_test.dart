import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/application/use_cases/spots_catalog_use_cases.dart';
import 'package:windwisher/features/spots/application/use_cases/spots_forecast_use_cases.dart';
import 'package:windwisher/features/spots/application/use_cases/spots_remote_media_use_cases.dart';
import 'package:windwisher/features/spots/di/spots_module.dart';
import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/domain/entities/spot_webcam.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_catalog_port.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_forecast_port.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_remote_media_port.dart';
import 'package:windwisher/features/spots/infrastructure/services/aemet_beach_forecast_client.dart';
import 'package:windwisher/features/spots/infrastructure/services/aemet_coastal_forecast_client.dart';
import 'package:windwisher/features/spots/infrastructure/services/aigua_blanca_meteo_client.dart';
import 'package:windwisher/features/spots/infrastructure/services/avamet_daily_history_client.dart';
import 'package:windwisher/features/spots/infrastructure/services/avamet_intraday_history_client.dart';
import 'package:windwisher/features/spots/infrastructure/services/aemet_observation_client.dart';
import 'package:windwisher/features/spots/infrastructure/services/inforatge_oliva_nova_client.dart';
import 'package:windwisher/features/spots/infrastructure/services/meteoblue_current_day_client.dart';
import 'package:windwisher/features/spots/infrastructure/services/meteostat_day_client.dart';
import 'package:windwisher/features/spots/infrastructure/services/meteosource_current_day_client.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/spot_detail_page.dart';

void main() {
  testWidgets(
    'updates forecast banner and model options when provider changes',
    (tester) async {
      await _pumpSpotDetailPage(
        tester,
        SpotDetailPage(
          name: 'Oliva Puerto',
          area: 'Valencia',
          isCustom: false,
          aemetBeachCode: '4618102',
          aemetBeachCodes: ['4618103'],
          spotsModule: _buildTestModule(
            forecastPort: _FakeSpotsForecastPort(
              handler:
                  ({
                    required spotName,
                    required area,
                    required provider,
                    required model,
                  }) async {
                    return [
                      _entry(
                        hour: 0,
                        windKnots: provider == 'AEMET' ? 15 : 12,
                        gustKnots: provider == 'AEMET' ? 19 : 16,
                        windDeg: provider == 'AEMET' ? 135 : 90,
                      ),
                    ];
                  },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Datos reales cargados desde Open-Meteo.'),
        findsOneWidget,
      );
      expect(find.text('Tabla Forecast (Best match)'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(DropdownButtonFormField<String>, 'Proveedor meteo'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Meteosource'), findsWidgets);
      expect(find.text('Meteostat'), findsWidgets);
      expect(find.text('Windguru'), findsWidgets);
      await tester.tap(find.text('AEMET').last);
      await tester.pumpAndSettle();

      expect(find.text('Datos reales cargados desde AEMET.'), findsOneWidget);
      expect(
        find.text('Tabla Forecast (Prediccion municipal)'),
        findsOneWidget,
      );

      await tester.tap(
        find.widgetWithText(
          DropdownButtonFormField<String>,
          'Modelo de prevision',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Prediccion municipal'), findsWidgets);
      expect(find.text('Prediccion de playa (Pau-Pi)'), findsOneWidget);
      expect(find.text("Prediccion de playa (l'Aigua Blanca)"), findsOneWidget);
      expect(find.text('Maritima costera'), findsOneWidget);
      expect(find.text('Hourly'), findsNothing);
      expect(find.text('GFS'), findsNothing);
    },
  );

  testWidgets('live section distinguishes observation source from forecast', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        latitude: 38.904444,
        longitude: -0.065,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  return [_entry(hour: 0)];
                },
          ),
        ),
        aemetObservationClient: AemetObservationClient(
          apiKey: 'test-key',
          fetchJson: (url) async => {'datos': 'test://aemet-live'},
          fetchJsonList: (url) async => [
            {
              'idema': '8058X',
              'ubi': 'OLIVA',
              'lat': 38.914444,
              'lon': -0.065,
              'fint': '2026-03-08T20:00:00+0000',
              'vv': 1.2,
              'dv': 255,
              'vmax': 2.4,
              'ta': 11.5,
              'pres': 1021.9,
              'hr': 94,
              'prec': 0.0,
            },
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();

    expect(find.text('Observacion · AEMET · 8058X'), findsOneWidget);
    expect(find.text('AEMET Oliva · 1.1 km · N'), findsWidgets);
  });

  testWidgets('live refresh keeps selected station', (tester) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        latitude: 38.904444,
        longitude: -0.065,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  return [_entry(hour: 0)];
                },
          ),
        ),
        aemetObservationClient: AemetObservationClient(
          apiKey: 'test-key',
          fetchJson: (url) async => {'datos': 'test://aemet-live'},
          fetchJsonList: (url) async => [
            {
              'idema': '8058X',
              'ubi': 'OLIVA',
              'lat': 38.914444,
              'lon': -0.065,
              'fint': '2026-03-08T20:00:00+0000',
              'vv': 1.2,
              'dv': 255,
              'vmax': 2.4,
              'ta': 11.5,
              'pres': 1021.9,
              'hr': 94,
              'prec': 0.0,
            },
            {
              'idema': 'CNO1',
              'ubi': 'CLUB NAUTICO OLIVA',
              'lat': 38.902,
              'lon': -0.09,
              'fint': '2026-03-08T20:00:00+0000',
              'vv': 2.0,
              'dv': 180,
              'vmax': 3.2,
              'ta': 12.4,
              'pres': 1020.1,
              'hr': 80,
              'prec': 0.2,
            },
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Estacion meteorologica cercana',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Club Nautico de Oliva').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Refrescar estacion'));
    await tester.pumpAndSettle();

    final stationDropdown = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButtonFormField<String> &&
          widget.decoration.labelText == 'Estacion meteorologica cercana',
    );

    final state = tester.state<FormFieldState<String>>(stationDropdown).value;
    expect(state, 'avamet:c25m181e07');
  });

  testWidgets('live wind semaforo chip opens legend dialog', (tester) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        latitude: 38.904444,
        longitude: -0.065,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  return [_entry(hour: 0)];
                },
          ),
        ),
        aemetObservationClient: AemetObservationClient(
          apiKey: 'test-key',
          fetchJson: (url) async => {'datos': 'test://aemet-live'},
          fetchJsonList: (url) async => [
            {
              'idema': '8058X',
              'ubi': 'OLIVA',
              'lat': 38.914444,
              'lon': -0.065,
              'fint': '2026-03-08T20:00:00+0000',
              'vv': 15.0,
              'dv': 255,
              'vmax': 19.0,
              'ta': 11.5,
              'pres': 1021.9,
              'hr': 94,
              'prec': 0.0,
            },
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Leyenda del semaforo'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Leyenda del semaforo de viento'), findsOneWidget);
    expect(find.textContaining('18-26 kt'), findsOneWidget);
    expect(find.textContaining('Viento optimo'), findsOneWidget);
    expect(find.textContaining('Viento super fuerte'), findsOneWidget);
    expect(find.textContaining('14-18 kt'), findsWidgets);
    expect(find.textContaining('Viento flojo'), findsOneWidget);
    expect(find.text('Tamano orientativo de cometa'), findsOneWidget);
    expect(find.text('14-18 kt'), findsWidgets);
    expect(find.text('12-14 m'), findsOneWidget);
  });

  testWidgets('live history falls back to AEMET official before AVAMET', (
    tester,
  ) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        latitude: 38.904444,
        longitude: -0.065,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  return [_entry(hour: 0)];
                },
          ),
        ),
        aemetObservationClient: AemetObservationClient(
          apiKey: 'test-key',
          fetchJson: (url) async => {'datos': 'test://aemet-live'},
          fetchJsonList: (url) async => [
            {
              'idema': '8058X',
              'ubi': 'OLIVA',
              'lat': 38.914444,
              'lon': -0.065,
              'fint': '2026-03-08T20:00:00+0000',
              'vv': 1.2,
              'dv': 255,
              'vmax': 2.4,
              'ta': 11.5,
              'pres': 1021.9,
              'hr': 94,
              'prec': 0.0,
            },
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();

    final stationDropdown = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButtonFormField<String> &&
          widget.decoration.labelText == 'Estacion meteorologica cercana',
    );
    final state = tester.state<FormFieldState<String>>(stationDropdown).value;
    expect(state, '8058X');
    expect(
      find.widgetWithText(OutlinedButton, 'Comparar con forecast'),
      findsNothing,
    );
    expect(
      find.widgetWithText(DropdownButtonFormField<String>, 'Fuente prevision'),
      findsNothing,
    );
  });
  testWidgets('live history falls back to AVAMET when AEMET official fails', (
    tester,
  ) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        latitude: 38.904444,
        longitude: -0.065,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  return [_entry(hour: 0)];
                },
          ),
        ),
        aemetObservationClient: AemetObservationClient(
          apiKey: 'test-key',
          fetchJson: (url) async => {'datos': 'test://aemet-live'},
          fetchJsonList: (url) async => <Map<String, dynamic>>[],
        ),
        avametDailyHistoryClient: AvametDailyHistoryClient(
          fetchText: (url) async => '''
<script>
\$('#grafic3').highcharts({
  series:[
    {yAxis: 0,data:[[1773356400000,8.2],[1773270000000,5.6]],name:'Vel Mit'}
  ],
  plotOptions:{}
});
</script>
''',
        ),
        avametIntradayHistoryClient: AvametIntradayHistoryClient(
          fetchText: (url) async => '''
<script>
\$('#grafic3').highcharts({
  series:[
    {yAxis: 0,data:[[1773356400000,90],[1773360000000,135],[1773363600000,180]],name:'Direcció'},
    {yAxis: 1,data:[[1773356400000,8.2],[1773360000000,9.0],[1773363600000,10.1]],name:'Velocitat'}
  ],
  tooltip:{}
});
</script>
<script>
\$('#grafic4').highcharts({});
</script>
''',
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(OutlinedButton, 'Comparar con forecast'),
      findsNothing,
    );
    expect(
      find.widgetWithText(DropdownButtonFormField<String>, 'Fuente prevision'),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<String> &&
            widget.decoration.labelText == 'Proveedor forecast',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<String> &&
            widget.decoration.labelText == 'Modelo forecast',
      ),
      findsOneWidget,
    );
    expect(find.text('1d'), findsOneWidget);
    expect(find.text('3d'), findsOneWidget);
    expect(find.text('3 h'), findsOneWidget);
    expect(find.text('6 h'), findsOneWidget);
    expect(find.text('12 h'), findsOneWidget);
    expect(find.text('7d'), findsNothing);
    expect(find.text('30d'), findsNothing);

    final stationDropdown = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButtonFormField<String> &&
          widget.decoration.labelText == 'Estacion meteorologica cercana',
    );
    final state = tester.state<FormFieldState<String>>(stationDropdown).value;
    expect(state, 'avamet:c25m181e07');

    await tester.tap(find.text('1d'));
    await tester.pumpAndSettle();

    expect(find.text('20 min'), findsOneWidget);
    expect(find.text('1 h'), findsWidgets);
    expect(find.text('3 h'), findsWidgets);
  });

  testWidgets('live section adds Oliva realtime stations', (tester) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        latitude: 38.904444,
        longitude: -0.065,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  return [_entry(hour: 0)];
                },
          ),
        ),
        aemetObservationClient: AemetObservationClient(
          apiKey: 'test-key',
          fetchJson: (url) async => {'datos': 'test://aemet-live'},
          fetchJsonList: (url) async => [
            {
              'idema': '8058X',
              'ubi': 'OLIVA',
              'lat': 38.914444,
              'lon': -0.065,
              'fint': '2026-03-08T20:00:00+0000',
              'vv': 1.2,
              'dv': 255,
              'vmax': 2.4,
              'ta': 11.5,
              'pres': 1021.9,
              'hr': 94,
              'prec': 0.0,
            },
          ],
        ),
        aiguaBlancaMeteoClient: _FakeAiguaBlancaMeteoClient(),
        inforatgeOlivaNovaClient: _FakeInforatgeOlivaNovaClient(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Estacion meteorologica cercana',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Oliva Poliesportiu'), findsWidgets);
    expect(find.textContaining('Oliva Nova Beach & Golf Resort'), findsWidgets);
    expect(find.textContaining('Playa Aigua Blanca'), findsWidgets);
  });

  testWidgets('live section defaults Oliva Nova history bucket to 20 min', (
    tester,
  ) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        latitude: 38.904444,
        longitude: -0.065,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  return [_entry(hour: 0)];
                },
          ),
        ),
        aemetObservationClient: AemetObservationClient(
          apiKey: 'test-key',
          fetchJson: (url) async => {'datos': 'test://aemet-live'},
          fetchJsonList: (url) async => [
            {
              'idema': '8058X',
              'ubi': 'OLIVA',
              'lat': 38.914444,
              'lon': -0.065,
              'fint': '2026-03-08T20:00:00+0000',
              'vv': 1.2,
              'dv': 255,
              'vmax': 2.4,
              'ta': 11.5,
              'pres': 1021.9,
              'hr': 94,
              'prec': 0.0,
            },
          ],
        ),
        aiguaBlancaMeteoClient: _FakeAiguaBlancaMeteoClient(),
        inforatgeOlivaNovaClient: _FakeInforatgeOlivaNovaClient(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Estacion meteorologica cercana',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.textContaining('Oliva Nova Beach & Golf Resort').last,
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SegmentedButton &&
            widget.selected.any((value) => value.toString().contains('min20')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Meteosource exposes hourly model and live banner', (
    tester,
  ) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  if (provider == 'Meteosource') {
                    return [
                      _entry(
                        hour: 0,
                        windKnots: 11,
                        gustKnots: 15,
                        windDeg: 105,
                      ),
                    ];
                  }
                  return [_entry(hour: 0)];
                },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Proveedor meteo'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meteosource').last);
    await tester.pumpAndSettle();

    expect(
      find.text('Datos reales cargados desde Meteosource.'),
      findsOneWidget,
    );
    expect(find.text('Tabla Forecast (Hourly)'), findsOneWidget);
    expect(find.text('7 dias'), findsNothing);

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hourly'), findsWidgets);
    expect(find.text('Basic'), findsNothing);
  });

  testWidgets('Meteosource exposes current and day models', (tester) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        meteosourceCurrentDayClient: _FakeMeteosourceCurrentDayClient(),
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  if (provider == 'Meteosource') {
                    return [
                      _entry(
                        hour: 0,
                        windKnots: 11,
                        gustKnots: 15,
                        windDeg: 105,
                      ),
                    ];
                  }
                  return [_entry(hour: 0)];
                },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Proveedor meteo'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meteosource').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Current'), findsWidgets);
    expect(find.text('Day'), findsWidgets);

    await tester.tap(find.text('Current').last);
    await tester.pumpAndSettle();

    expect(find.text('Meteosource Current'), findsOneWidget);
    expect(find.text('Mostly cloudy'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Day').last);
    await tester.pumpAndSettle();

    expect(find.text('Meteosource Day'), findsOneWidget);
    expect(find.textContaining('Mostly cloudy, more clouds'), findsOneWidget);
  });

  testWidgets('Meteostat exposes hourly model and live banner', (tester) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  if (provider == 'Meteostat') {
                    return List.generate(24 * 7, (index) {
                      final time = DateTime(
                        2026,
                        3,
                        7,
                      ).add(Duration(hours: index));
                      return SpotForecastEntry(
                        time: time,
                        windKnots: 10 + (index % 4),
                        gustKnots: 14 + (index % 5),
                        windDeg: 112,
                        airTempC: 18 + (index % 3),
                        waterTempC: null,
                        pressureHpa: 1015 - (index ~/ 24),
                        cloudCoverPct: null,
                        waveM: null,
                        rainMm: index % 9 == 0 ? 0.4 : 0,
                      );
                    });
                  }
                  return [_entry(hour: 0)];
                },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Proveedor meteo'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meteostat').last);
    await tester.pumpAndSettle();

    expect(find.text('Datos reales cargados desde Meteostat.'), findsOneWidget);
    expect(find.text('Tabla Forecast (Hourly)'), findsOneWidget);
  });

  testWidgets(
    'Meteostat hourly keeps 7 day range available and renders full week',
    (tester) async {
      await _pumpSpotDetailPage(
        tester,
        SpotDetailPage(
          name: 'Oliva Puerto',
          area: 'Valencia',
          isCustom: false,
          spotsModule: _buildTestModule(
            forecastPort: _FakeSpotsForecastPort(
              handler:
                  ({
                    required spotName,
                    required area,
                    required provider,
                    required model,
                  }) async {
                    if (provider == 'Meteostat' && model == 'Hourly') {
                      final start = DateTime(2026, 3, 2);
                      return List.generate(24 * 8, (index) {
                        final time = start.add(Duration(hours: index));
                        return SpotForecastEntry(
                          time: time,
                          windKnots: 10 + (index % 4),
                          gustKnots: 14 + (index % 5),
                          windDeg: 112,
                          airTempC: 18 + (index % 3),
                          pressureHpa: 1015 - (index ~/ 24),
                          rainMm: index % 9 == 0 ? 0.4 : 0,
                        );
                      });
                    }
                    return [_entry(hour: 0)];
                  },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(DropdownButtonFormField<String>, 'Proveedor meteo'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Meteostat').last);
      await tester.pumpAndSettle();

      expect(find.text('7 dias'), findsOneWidget);

      await tester.ensureVisible(find.text('7 dias'));
      await tester.tap(find.text('7 dias'), warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('1h').last);
      await tester.tap(find.text('1h').last, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Dom\n23 h'), findsOneWidget);
    },
  );

  testWidgets('Meteostat exposes day model and renders daily summary', (
    tester,
  ) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        meteostatDayClient: _FakeMeteostatDayClient(),
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  if (provider == 'Meteostat' && model == 'Hourly') {
                    return [
                      _entry(
                        hour: 0,
                        windKnots: 10,
                        gustKnots: 14,
                        windDeg: 112,
                      ),
                    ];
                  }
                  return const <SpotForecastEntry>[];
                },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Proveedor meteo'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meteostat').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Day'), findsWidgets);

    await tester.tap(find.text('Day').last);
    await tester.pumpAndSettle();

    expect(find.text('Meteostat Day'), findsOneWidget);
    expect(find.textContaining('Presion: 1019.8 hPa'), findsOneWidget);
    expect(find.textContaining('Sol: 240 min'), findsOneWidget);
  });

  testWidgets('Meteoblue exposes separate models and renders each view', (
    tester,
  ) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        meteoblueCurrentDayClient: _FakeMeteoblueCurrentDayClient(),
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  if (provider == 'Meteoblue') {
                    return List.generate(13, (index) {
                      final minutes = index * 15;
                      return SpotForecastEntry(
                        time: DateTime(
                          2026,
                          3,
                          7,
                        ).add(Duration(minutes: minutes)),
                        windKnots: 17 + (index ~/ 4),
                        gustKnots: index % 4 == 0 ? 22 + (index ~/ 4) : null,
                        windDeg: 120,
                        airTempC: 19,
                        pressureHpa: 1014,
                        cloudCoverPct: 20,
                        rainMm: 0,
                      );
                    });
                  }
                  return [
                    _entry(hour: 0, windKnots: 12, gustKnots: 16, windDeg: 90),
                  ];
                },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Proveedor meteo'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Meteoblue'), findsWidgets);

    await tester.tap(find.text('Meteoblue').last);
    await tester.pumpAndSettle();

    expect(find.text('Datos reales cargados desde Meteoblue.'), findsOneWidget);
    expect(find.text('Tabla Forecast (Basic)'), findsOneWidget);
    expect(find.text('15m'), findsOneWidget);
    expect(find.text('1h'), findsOneWidget);
    expect(find.text('3h'), findsNothing);
    expect(find.textContaining('00:15'), findsOneWidget);

    expect(find.text('Meteoblue Current'), findsNothing);
    expect(find.text('Meteoblue Sea (1h)'), findsNothing);
    expect(find.text('Meteoblue Day'), findsNothing);

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Current'), findsWidgets);
    expect(find.text('Day'), findsWidgets);
    expect(find.text('Sea'), findsWidgets);

    await tester.tap(find.text('Current').last);
    await tester.pumpAndSettle();

    expect(find.text('Tabla Forecast (Basic)'), findsNothing);
    expect(find.text('Meteoblue Current'), findsOneWidget);
    expect(find.text('Meteoblue Sea (1h)'), findsNothing);
    expect(find.text('Meteoblue Day'), findsNothing);
    expect(find.text('Observado'), findsOneWidget);
    expect(find.text('Direccion'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sea').last);
    await tester.pumpAndSettle();

    expect(find.text('Meteoblue Current'), findsNothing);
    expect(find.text('Meteoblue Sea (1h)'), findsOneWidget);
    expect(find.text('Meteoblue Day'), findsNothing);
    expect(find.text('6h'), findsOneWidget);
    expect(find.text('12h'), findsOneWidget);
    expect(find.text('24h'), findsOneWidget);
    expect(find.text('21'), findsNothing);
    expect(find.text('Periodo(oleaje)'), findsOneWidget);
    expect(find.text('Surf(wave)'), findsOneWidget);
    expect(find.text('Mar de fondo'), findsWidgets);
    expect(find.text('Sea status'), findsWidgets);
    expect(find.text('Marejada'), findsWidgets);
    expect(find.text('E'), findsWidgets);

    await tester.tap(find.text('12h'));
    await tester.pumpAndSettle();

    expect(find.text('21'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Day').last);
    await tester.pumpAndSettle();

    expect(find.text('Meteoblue Current'), findsNothing);
    expect(find.text('Meteoblue Sea (1h)'), findsNothing);
    expect(find.text('Meteoblue Day'), findsOneWidget);
    expect(find.textContaining('Predict.:'), findsWidgets);
  });

  testWidgets('AEMET beach model shows dedicated beach forecast table', (
    tester,
  ) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        aemetBeachCode: '4618102',
        aemetBeachCodes: ['4618103'],
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  return [_entry(hour: 0)];
                },
          ),
        ),
        aemetBeachForecastClient: AemetBeachForecastClient(
          apiKey: 'test-key',
          fetchJson: (url) async {
            final beachCode = url.contains('4618103') ? '4618103' : '4618102';
            return {'datos': 'https://mock.aemet.local/playa-$beachCode.json'};
          },
          fetchJsonList: (url) async {
            if (url.contains('4618103')) {
              return [
                {
                  'id': 4618103,
                  'nombre': "l'Aigua Blanca",
                  'elaborado': '2026-03-08T01:00:00',
                  'prediccion': {
                    'dia': [
                      {
                        'fecha': 20260308,
                        'estadoCielo': {
                          'descripcion1': 'nuboso',
                          'descripcion2': 'despejado',
                        },
                        'viento': {
                          'descripcion1': 'flojo',
                          'descripcion2': 'moderado',
                        },
                        'oleaje': {
                          'descripcion1': 'debil',
                          'descripcion2': 'moderado',
                        },
                        'tMaxima': {'valor1': 16},
                        'tAgua': {'valor1': 15},
                        'sTermica': {'descripcion1': 'agradable'},
                        'uvMax': {'valor1': 4},
                      },
                    ],
                  },
                },
              ];
            }
            return [
              {
                'id': 4618102,
                'nombre': 'Pau-Pi',
                'elaborado': '2026-03-08T01:00:00',
                'prediccion': {
                  'dia': [
                    {
                      'fecha': 20260308,
                      'estadoCielo': {
                        'descripcion1': 'despejado',
                        'descripcion2': 'nuboso',
                      },
                      'viento': {
                        'descripcion1': 'moderado',
                        'descripcion2': 'flojo',
                      },
                      'oleaje': {
                        'descripcion1': 'moderado',
                        'descripcion2': 'debil',
                      },
                      'tMaxima': {'valor1': 15},
                      'tAgua': {'valor1': 14},
                      'sTermica': {'descripcion1': 'fresco'},
                      'uvMax': {'valor1': 3},
                    },
                  ],
                },
              },
            ];
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Proveedor meteo'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('AEMET').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prediccion de playa (Pau-Pi)').last);
    await tester.pumpAndSettle();

    expect(
      find.text('Tabla Forecast (Prediccion de playa (Pau-Pi))'),
      findsOneWidget,
    );
    expect(find.text('Tabla Playa AEMET'), findsOneWidget);
    expect(find.text('Pau-Pi'), findsOneWidget);
    expect(find.textContaining('Manana: despejado'), findsOneWidget);
    expect(find.textContaining('Manana: moderado'), findsAtLeastNWidgets(1));
    expect(find.text('14 C'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("Prediccion de playa (l'Aigua Blanca)").last);
    await tester.pumpAndSettle();

    expect(
      find.text("Tabla Forecast (Prediccion de playa (l'Aigua Blanca))"),
      findsOneWidget,
    );
    expect(find.text("l'Aigua Blanca"), findsOneWidget);
    expect(find.textContaining('Manana: nuboso'), findsOneWidget);
  });

  testWidgets('AEMET coastal model shows dedicated coastal forecast table', (
    tester,
  ) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  return [_entry(hour: 0)];
                },
          ),
        ),
        aemetCoastalForecastClient: AemetCoastalForecastClient(
          apiKey: 'test-key',
          fetchJson: (url) async {
            return {'datos': 'https://mock.aemet.local/costera.json'};
          },
          fetchJsonList: (url) async {
            return [
              {
                'nombre': 'Boletin meteorologico y marino para Valencia',
                'origen': {'elaborado': '2026-03-08T00:00:00'},
                'aviso': {'texto': 'No hay avisos'},
                'situacion': {'texto': 'Altas presiones sin cambios.'},
                'prediccion': {
                  'inicio': '2026-03-08T00:00:00',
                  'fin': '2026-03-09T00:00:00',
                  'zona': [
                    {
                      'subzona': [
                        {
                          'id': 8174610,
                          'nombre': 'Aguas costeras de Valencia',
                          'texto':
                              'Componente N 2 a 4 rolando por la tarde a E. Marejadilla.',
                        },
                      ],
                    },
                  ],
                },
                'tendencia': {
                  'texto': 'No se esperan condiciones de aviso en ninguna zona',
                },
              },
            ];
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Proveedor meteo'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('AEMET').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maritima costera').last);
    await tester.pumpAndSettle();

    expect(find.text('Tabla Forecast (Maritima costera)'), findsOneWidget);
    expect(find.text('Tabla Costera AEMET'), findsOneWidget);
    expect(find.text('Aguas costeras de Valencia'), findsOneWidget);
    expect(find.textContaining('Marejadilla'), findsAtLeastNWidgets(1));
    expect(find.textContaining('No hay avisos'), findsOneWidget);
  });

  testWidgets('forecast model selector does not overflow on narrow width', (
    tester,
  ) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        aemetBeachCode: '4618102',
        aemetBeachCodes: ['4618103'],
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  return [_entry(hour: 0)];
                },
          ),
        ),
      ),
      size: const Size(320, 900),
    );

    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Proveedor meteo'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('AEMET').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("Prediccion de playa (l'Aigua Blanca)").last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.text("Tabla Forecast (Prediccion de playa (l'Aigua Blanca))"),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Info del modelo'));
    await tester.pumpAndSettle();

    expect(find.text('Prediccion de playa (l\'Aigua Blanca)'), findsWidgets);
    expect(find.textContaining('Tipo:'), findsOneWidget);
  });

  testWidgets('Open-Meteo exposes Meteo-France model variants', (tester) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  return [_entry(hour: 0)];
                },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Best match'), findsNWidgets(2));
    expect(find.text('AROME Seamless'), findsOneWidget);
    expect(find.text('AROME France'), findsOneWidget);
    expect(find.text('ARPEGE Europe'), findsOneWidget);
    expect(find.text('ARPEGE Seamless'), findsOneWidget);
    expect(find.text('ARPEGE World'), findsOneWidget);
    expect(find.text('Top'), findsNWidgets(2));
    expect(find.text('Recomendado'), findsNWidgets(2));
  });

  testWidgets('shows model info dialog from forecast filter', (tester) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  return [_entry(hour: 0)];
                },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('AROME Seamless').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Info del modelo'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('GFS')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('AROME Seamless'),
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Salida Meteo-France combinada para mantener continuidad espacial y temporal',
      ),
      findsOneWidget,
    );
    expect(find.text('Tipo: Alta resolucion continua'), findsOneWidget);
    expect(find.text('Resolucion: Aprox. 1.5-2.5 km'), findsOneWidget);
    expect(find.text('Horizonte: Corto plazo, hasta 2-4 dias'), findsOneWidget);
    expect(find.textContaining('Para Oliva Puerto: Top.'), findsOneWidget);
    expect(find.text('Cerrar'), findsOneWidget);
  });

  testWidgets('shows empty state when selected provider returns no data', (
    tester,
  ) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  if (provider == 'AEMET') {
                    return const <SpotForecastEntry>[];
                  }
                  return [_entry(hour: 0)];
                },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(
      find.text('Datos reales cargados desde Open-Meteo.'),
      findsOneWidget,
    );

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Proveedor meteo'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('AEMET').last);
    await tester.pumpAndSettle();

    expect(find.text('Sin datos disponibles'), findsOneWidget);
    expect(find.text('AEMET no devolvio datos reales.'), findsOneWidget);
    expect(find.textContaining('Tabla Forecast'), findsNothing);
  });

  testWidgets('does not refetch AEMET data when only the model changes', (
    tester,
  ) async {
    final calls = <({String provider, String model})>[];

    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  calls.add((provider: provider, model: model));
                  return [_entry(hour: 0)];
                },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(calls, hasLength(1));
    expect(calls.last.provider, 'Open-Meteo');

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Proveedor meteo'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('AEMET').last);
    await tester.pumpAndSettle();

    expect(calls, hasLength(2));
    expect(calls.last.provider, 'AEMET');
    expect(calls.last.model, 'Prediccion municipal');

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maritima costera').last);
    await tester.pumpAndSettle();

    expect(find.text('Tabla Forecast (Maritima costera)'), findsOneWidget);
    expect(calls, hasLength(2));
  });

  testWidgets(
    'preview uses local range and resolution filters without refetch',
    (tester) async {
      final calls = <({String provider, String model})>[];

      await _pumpSpotDetailPage(
        tester,
        SpotDetailPage(
          name: 'Oliva Puerto',
          area: 'Valencia',
          isCustom: false,
          spotsModule: _buildTestModule(
            forecastPort: _FakeSpotsForecastPort(
              handler:
                  ({
                    required spotName,
                    required area,
                    required provider,
                    required model,
                  }) async {
                    calls.add((provider: provider, model: model));
                    return List<SpotForecastEntry>.generate(
                      56,
                      (index) => _entry(hour: (index * 3) % 24),
                    );
                  },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(calls, hasLength(1));

      await tester.ensureVisible(find.text('1h').last);
      await tester.tap(find.text('1h').last, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(calls, hasLength(1));

      await tester.ensureVisible(find.text('7 dias').first);
      await tester.tap(find.text('7 dias').first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(calls, hasLength(1));
    },
  );

  testWidgets('fullscreen button shows only fullscreen table overlay', (
    tester,
  ) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  return List<SpotForecastEntry>.generate(
                    16,
                    (index) => _entry(hour: (index * 3) % 24),
                  );
                },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.fullscreen_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Spot seleccionado'), findsNothing);
    expect(find.byTooltip('Salir de fullscreen'), findsOneWidget);
  });

  testWidgets('Meteoblue Sea supports fullscreen overlay', (tester) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        meteoblueCurrentDayClient: _FakeMeteoblueCurrentDayClient(),
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  if (provider == 'Meteoblue') {
                    return [_entry(hour: 0, windKnots: 12, gustKnots: 16)];
                  }
                  return [_entry(hour: 0, windKnots: 12, gustKnots: 16)];
                },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Proveedor meteo'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meteoblue').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        'Modelo de prevision',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sea').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Ampliar tabla').last);
    await tester.pumpAndSettle();

    expect(find.text('Spot seleccionado'), findsNothing);
    expect(find.byTooltip('Salir de fullscreen'), findsOneWidget);
    expect(find.text('Meteoblue Sea (1h)'), findsOneWidget);
    expect(find.text('6h'), findsOneWidget);
    expect(find.text('12h'), findsOneWidget);
    expect(find.text('24h'), findsOneWidget);
  });

  testWidgets('shows compact technical error for Open-Meteo failures', (
    tester,
  ) async {
    await _pumpSpotDetailPage(
      tester,
      SpotDetailPage(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        spotsModule: _buildTestModule(
          forecastPort: _FakeSpotsForecastPort(
            handler:
                ({
                  required spotName,
                  required area,
                  required provider,
                  required model,
                }) async {
                  throw Exception(
                    'OpenMeteo exploded because marine payload mismatch',
                  );
                },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sin datos disponibles'), findsOneWidget);
    expect(
      find.textContaining('OpenMeteo exploded because marine payload mismatch'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpSpotDetailPage(
  WidgetTester tester,
  SpotDetailPage page, {
  Size size = const Size(800, 1400),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(MaterialApp(home: page));
}

SpotsModule _buildTestModule({required SpotsForecastPort forecastPort}) {
  final catalogPort = _FakeSpotsCatalogPort();
  final remoteMediaPort = _FakeSpotsRemoteMediaPort();
  return SpotsModule(
    getSpots: GetSpotsUseCase(catalogPort),
    saveSpot: SaveSpotUseCase(catalogPort),
    deleteSpotByName: DeleteSpotByNameUseCase(catalogPort),
    getSpotForecast: GetSpotForecastUseCase(forecastPort),
    getSpotWebcams: GetSpotWebcamsUseCase(remoteMediaPort),
    getWebcamReferencePages: GetWebcamReferencePagesUseCase(remoteMediaPort),
  );
}

SpotForecastEntry _entry({
  required int hour,
  int windKnots = 12,
  int? gustKnots = 16,
  int windDeg = 90,
}) {
  return SpotForecastEntry(
    time: DateTime(2026, 3, 7, hour),
    windKnots: windKnots,
    gustKnots: gustKnots,
    windDeg: windDeg,
    airTempC: 19,
    waterTempC: 17,
    pressureHpa: 1014,
    cloudCoverPct: 20,
    waveM: 0.8,
    rainMm: 0,
  );
}

typedef _ForecastHandler =
    Future<List<SpotForecastEntry>> Function({
      required String spotName,
      required String area,
      required String provider,
      required String model,
    });

class _FakeSpotsForecastPort implements SpotsForecastPort {
  const _FakeSpotsForecastPort({required this.handler});

  final _ForecastHandler handler;

  @override
  Future<List<SpotForecastEntry>> getForecast({
    required SpotItem spot,
    required String provider,
    required String model,
  }) {
    return handler(
      spotName: spot.name,
      area: spot.area,
      provider: provider,
      model: model,
    );
  }
}

class _FakeSpotsCatalogPort implements SpotsCatalogPort {
  @override
  void deleteSpotByName(String name) {}

  @override
  List<SpotItem> getSpots() => const <SpotItem>[];

  @override
  Future<List<SpotItem>> hydrateSpots() async => getSpots();

  @override
  void saveSpot(SpotItem spot) {}
}

class _FakeSpotsRemoteMediaPort implements SpotsRemoteMediaPort {
  @override
  List<WebcamReferencePage> getRelatedPagesForWebcam(String webcamName) {
    return const <WebcamReferencePage>[];
  }

  @override
  List<SpotWebcam> getWebcamsForSpot({
    required String spotName,
    required bool isCustom,
  }) {
    return const <SpotWebcam>[];
  }
}

class _FakeMeteoblueCurrentDayClient extends MeteoblueCurrentDayClient {
  _FakeMeteoblueCurrentDayClient()
    : super(
        apiKey: 'test-key',
        fetchJson: (url) async {
          final seaTimes = List.generate(24, (index) {
            final time = DateTime(2026, 3, 7, 10).add(Duration(hours: index));
            String two(int input) => input.toString().padLeft(2, '0');
            return '${time.year}-${two(time.month)}-${two(time.day)} ${two(time.hour)}:00';
          });
          final seaValues = List.generate(24, (index) => index);
          return {
            'data_current': {
              'time': '2026-03-07 10:15',
              'temperature': 18.4,
              'windspeed': 15.2,
              'isobserveddata': 1,
            },
            'data_xmin': {
              'time': ['2026-03-07 10:15'],
              'winddirection': [115],
              'sealevelpressure': [1016],
              'totalcloudcover': [34],
            },
            'data_1h': {
              'time': seaTimes,
              'seasurfacetemperature': seaValues
                  .map((i) => 17.8 - (i * 0.1))
                  .toList(),
              'surfwave_height': seaValues.map((i) => 0.9 + (i * 0.1)).toList(),
              'significantwaveheight': seaValues
                  .map((i) => 1.1 + (i * 0.1))
                  .toList(),
              'swell_significantheight': seaValues
                  .map((i) => 0.8 + (i * 0.1))
                  .toList(),
              'swell_meanperiod': seaValues
                  .map((i) => 6.4 - (i * 0.1))
                  .toList(),
              'swell_meandirection': seaValues.map((i) => 96 + i).toList(),
              'windwave_height': seaValues
                  .map((i) => 0.2 + (i * 0.05))
                  .toList(),
              'mean_waveperiod': seaValues.map((i) => 5.7 + (i * 0.1)).toList(),
              'windwave_meanperiod': seaValues
                  .map((i) => 4.2 + (i * 0.1))
                  .toList(),
              'windwave_direction': seaValues.map((i) => 122 + i).toList(),
              'douglas_seastate': seaValues.map((_) => 3).toList(),
              'mean_wavedirection': seaValues.map((i) => 98 + i).toList(),
            },
            'data_day': {
              'time': ['2026-03-07', '2026-03-08'],
              'temperature_min': [14.0, 13.0],
              'temperature_max': [21.0, 20.0],
              'windspeed_mean': [12.0, 11.0],
              'precipitation': [0.0, 1.2],
              'predictability': [82, 74],
            },
          };
        },
      );
}

class _FakeMeteosourceCurrentDayClient extends MeteosourceCurrentDayClient {
  _FakeMeteosourceCurrentDayClient()
    : super(
        apiKey: 'test-key',
        fetchJson: (url) async {
          return {
            'current': {
              'summary': 'Mostly cloudy',
              'temperature': 14.5,
              'wind': {'speed': 1.5, 'angle': 91, 'dir': 'E'},
              'precipitation': {'total': 0.0, 'type': 'none'},
              'cloud_cover': 79,
            },
            'daily': {
              'data': [
                {
                  'day': '2026-03-08',
                  'summary': 'Mostly cloudy, more clouds in the afternoon.',
                  'all_day': {
                    'temperature_min': 8.2,
                    'temperature_max': 14.5,
                    'wind': {'speed': 1.2, 'angle': 337, 'dir': 'NNW'},
                    'precipitation': {'total': 0.4, 'type': 'rain'},
                  },
                },
              ],
            },
          };
        },
      );
}

class _FakeMeteostatDayClient extends MeteostatDayClient {
  _FakeMeteostatDayClient()
    : super(
        rapidApiKey: 'test-key',
        rapidApiHost: 'meteostat.p.rapidapi.com',
        fetchJson: (url) async {
          return {
            'data': [
              {
                'date': '2026-03-09 00:00:00',
                'tavg': 11.8,
                'tmin': 6.6,
                'tmax': 17.0,
                'prcp': 7.9,
                'wspd': 9.3,
                'wpgt': 31.5,
                'pres': 1019.8,
                'tsun': 240,
              },
              {
                'date': '2026-03-10 00:00:00',
                'tavg': 10.6,
                'tmin': 8.6,
                'tmax': 12.7,
                'prcp': 21.3,
                'wspd': 12.0,
                'wpgt': 37.0,
                'pres': 1019.2,
                'tsun': 160,
              },
            ],
          };
        },
      );
}

class _FakeInforatgeOlivaNovaClient extends InforatgeOlivaNovaClient {
  _FakeInforatgeOlivaNovaClient();

  @override
  Future<InforatgeOlivaNovaFeed> fetchFeed({
    String stationCode = '02',
    String liveUrl = InforatgeOlivaNovaClient.liveOlivaNovaUrl,
    String historyUrl = InforatgeOlivaNovaClient.historyOlivaUrl,
  }) async {
    if (stationCode == '01') {
      return InforatgeOlivaNovaFeed(
        points: <InforatgeOlivaNovaPoint>[
          InforatgeOlivaNovaPoint(
            time: DateTime(2026, 3, 8, 19, 40),
            windKnots: 9.4,
            windDirectionDeg: 12,
          ),
          InforatgeOlivaNovaPoint(
            time: DateTime(2026, 3, 8, 19, 50),
            windKnots: 10.1,
            windDirectionDeg: 18,
          ),
        ],
        latestSnapshot: InforatgeOlivaNovaSnapshot(
          observedAt: DateTime(2026, 3, 8, 19, 50),
          windKnots: 10,
          windDirectionDeg: 18,
          gustKnots: 15,
          tempC: 14.5,
          pressureHpa: 1014,
          humidityPct: 79,
          rainMm: 0,
        ),
      );
    }
    return InforatgeOlivaNovaFeed(
      points: <InforatgeOlivaNovaPoint>[
        InforatgeOlivaNovaPoint(
          time: DateTime(2026, 3, 8, 19, 40),
          windKnots: 12.4,
          windDirectionDeg: 96,
        ),
        InforatgeOlivaNovaPoint(
          time: DateTime(2026, 3, 8, 19, 45),
          windKnots: 12.9,
          windDirectionDeg: 100,
        ),
        InforatgeOlivaNovaPoint(
          time: DateTime(2026, 3, 8, 20, 0),
          windKnots: 13.2,
          windDirectionDeg: 104,
        ),
      ],
      latestSnapshot: InforatgeOlivaNovaSnapshot(
        observedAt: DateTime(2026, 3, 8, 20, 0),
        windKnots: 13,
        windDirectionDeg: 104,
        gustKnots: 18,
        tempC: 15.9,
        pressureHpa: 1014,
        humidityPct: 75,
        rainMm: 0,
      ),
    );
  }
}

class _FakeAiguaBlancaMeteoClient extends AiguaBlancaMeteoClient {
  _FakeAiguaBlancaMeteoClient();

  @override
  Future<AiguaBlancaMeteoFeed> fetchFeed() async {
    return AiguaBlancaMeteoFeed(
      points: <AiguaBlancaMeteoPoint>[
        AiguaBlancaMeteoPoint(
          time: DateTime(2026, 3, 8, 19, 40),
          windKnots: 11.2,
          gustKnots: 16.8,
          windDirectionDeg: 78,
        ),
        AiguaBlancaMeteoPoint(
          time: DateTime(2026, 3, 8, 19, 45),
          windKnots: 12.1,
          gustKnots: 17.3,
          windDirectionDeg: 82,
        ),
        AiguaBlancaMeteoPoint(
          time: DateTime(2026, 3, 8, 19, 50),
          windKnots: 12.8,
          gustKnots: 18.4,
          windDirectionDeg: 86,
        ),
      ],
      latestSnapshot: AiguaBlancaMeteoSnapshot(
        observedAt: DateTime(2026, 3, 8, 19, 50),
        windKnots: 13,
        windDirectionDeg: 86,
        gustKnots: 18,
        tempC: 16.2,
        pressureHpa: 1017,
        humidityPct: 73,
        rainMm: 0.7,
      ),
    );
  }
}
