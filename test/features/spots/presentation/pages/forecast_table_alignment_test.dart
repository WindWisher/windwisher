import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/infrastructure/services/aemet_beach_forecast_client.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/forecast/widgets/tables/aemet/aemet_forecast_tables.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/forecast/widgets/tables/shared/forecast_table_chrome.dart';

void main() {
  testWidgets('bounded fullscreen table keeps tall final rows reachable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 320,
              height: 100,
              child: ForecastStickyLabelTable(
                labelColumnWidth: 100,
                valueColumnWidth: 80,
                rows: [
                  for (var row = 0; row < 8; row++)
                    TableRow(
                      children: [
                        SizedBox(height: 60, child: Text('label $row')),
                        SizedBox(
                          key: ValueKey('value-$row'),
                          height: 80,
                          child: Text('value $row'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(ForecastStickyLabelTable),
      const Offset(0, -800),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(const ValueKey('value-7'))).bottom,
      lessThanOrEqualTo(100.01),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('table supports empty data and changing forecast column counts', (
    tester,
  ) async {
    for (final count in [0, 12, 2, 0, 6]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ForecastStickyLabelTable(
                labelColumnWidth: 100,
                valueColumnWidth: 80,
                rows: count == 0
                    ? []
                    : [
                        TableRow(
                          children: [
                            const Text('Hora'),
                            for (var i = 0; i < count; i++) Text('hour $i'),
                          ],
                        ),
                      ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hora'), count == 0 ? findsNothing : findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
  for (final scale in [1.0, 1.6, 2.0]) {
    testWidgets(
      'AEMET beach handles wrapped descriptions at text scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: SingleChildScrollView(
                  child: AemetBeachForecastTable(
                    data: AemetBeachForecastData(
                      beachName: 'Playa de prueba',
                      beachId: null,
                      issuedAt: null,
                      days: [
                        AemetBeachForecastDay(
                          date: DateTime(2026, 11, 15),
                          skyMorning: 'nuboso con intervalos despejados',
                          skyAfternoon: 'nuboso',
                          windMorning: 'moderado',
                          windAfternoon: 'flojo',
                          waveMorning: 'moderado',
                          waveAfternoon: 'debil',
                          maxTempC: 28,
                          waterTempC: 19,
                          thermalSensation: 'agradable',
                          uvMax: null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final label = tester.getRect(
          find
              .ancestor(
                of: find.text('Cielo'),
                matching: find.byWidgetPredicate(
                  (widget) => widget is SizedBox && widget.width == 116,
                ),
              )
              .first,
        );
        final value = tester.getRect(
          find
              .ancestor(
                of: find.text('Mañana: nuboso con intervalos despejados'),
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Container &&
                      widget.constraints?.maxWidth == 148,
                ),
              )
              .first,
        );
        expect(value.top, closeTo(label.top, .01));
        expect(value.height, closeTo(label.height, .01));
      },
    );
  }
  for (final width in [320.0, 390.0, 844.0]) {
    for (final scale in [1.0, 1.6, 2.0]) {
      testWidgets('shared row geometry at width $width and text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: SingleChildScrollView(
                  child: ForecastStickyLabelTable(
                    labelColumnWidth: 104,
                    valueColumnWidth: 78,
                    border: TableBorder.all(),
                    rows: [
                      for (var row = 0; row < 4; row++)
                        TableRow(
                          children: [
                            Container(
                              key: ValueKey('label-$row'),
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                row == 1
                                    ? 'Periodo (mar de viento)'
                                    : 'Fila $row',
                              ),
                            ),
                            for (var col = 0; col < 12; col++)
                              Container(
                                key: ValueKey('cell-$row-$col'),
                                padding: const EdgeInsets.all(8),
                                child: row == 2 && col == 3
                                    ? const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.arrow_upward),
                                          Text('NNW'),
                                        ],
                                      )
                                    : Text(
                                        row == 3 && col == 1
                                            ? 'Mar muy gruesa'
                                            : '-',
                                      ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        void checkRows() {
          for (var row = 0; row < 4; row++) {
            final label = tester.getRect(find.byKey(ValueKey('label-$row')));
            for (var col = 0; col < 12; col++) {
              final cell = tester.getRect(
                find.byKey(ValueKey('cell-$row-$col')),
              );
              expect(cell.top, closeTo(label.top, .01));
              expect(cell.height, closeTo(label.height, .01));
              expect(cell.width, closeTo(78, .01));
            }
          }
          expect(tester.takeException(), isNull);
        }

        checkRows();
        final labelBefore = tester.getRect(
          find.byKey(const ValueKey('label-0')),
        );
        final valueBefore = tester.getRect(
          find.byKey(const ValueKey('cell-0-0')),
        );
        await tester.drag(
          find.byType(ForecastStickyLabelTable),
          const Offset(-200, 0),
        );
        await tester.pumpAndSettle();
        checkRows();
        expect(
          tester.getRect(find.byKey(const ValueKey('label-0'))).left,
          closeTo(labelBefore.left, .01),
        );
        expect(
          tester.getRect(find.byKey(const ValueKey('cell-0-0'))).left,
          lessThan(valueBefore.left),
        );
      });
    }
  }
}
