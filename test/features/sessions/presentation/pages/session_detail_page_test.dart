import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';
import 'package:windwisher/features/sessions/presentation/pages/session_detail_page.dart';

void main() {
  Widget buildPage() {
    return MaterialApp(
      home: SessionDetailPage(
        title: 'Sesion en Oliva Norte',
        deviceName: 'Woo Sports 3',
        deviceKind: 'Woo Sports',
        deviceSensorKeys: const [
          'gps',
          'accelerometer',
          'gyroscope',
          'orientation',
        ],
        endedAt: DateTime(2026, 2, 22, 18, 40),
        durationLabel: '1:12:30',
        summary: 'Viento estable de side-on con buenas rachas al final.',
        source: SessionDetailSource.mySessions,
        insights:
            SessionInsightData.empty(
              deviceKind: 'Woo Sports',
              deviceSensorKeys: const [
                'gps',
                'accelerometer',
                'gyroscope',
                'orientation',
              ],
            ).copyWith(
              maxSpeedKnots: 24.3,
              jumpsCount: 2,
              maxJumpHeightMeters: 5.8,
              maxHangtimeSeconds: 2.7,
              jumpHistory: const [
                SessionJumpRecord(
                  index: 1,
                  heightMeters: 4.9,
                  hangtimeSeconds: 2.4,
                  landingG: 1.8,
                  maneuverG: 1.5,
                  maneuverRotationDegPerSec: 260,
                  recordedAt: Duration(minutes: 8, seconds: 12),
                ),
                SessionJumpRecord(
                  index: 2,
                  heightMeters: 5.8,
                  hangtimeSeconds: 2.7,
                  landingG: 2.0,
                  maneuverG: 1.7,
                  maneuverRotationDegPerSec: 310,
                  recordedAt: Duration(minutes: 14, seconds: 5),
                ),
              ],
              advancedMetrics: SessionAdvancedMetrics(
                groups: SessionInsightData.buildGroupsForRecordedSession(
                  values: const <String, String>{
                    'duracion_total': '72 min',
                    'distancia_total': '21.4 km',
                    'velocidad_max': '24.3 kt',
                    'velocidad_p95': '21.8 kt',
                    'salto_mas_alto': '5.8 m',
                    'hangtime_max': '2.7 s',
                  },
                ),
              ),
            ),
      ),
    );
  }

  testWidgets('renders advanced metrics sections instead of placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());

    expect(
      find.text('Viento estable de side-on con buenas rachas al final.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Resumen post-sesion'),
      200,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('Resumen post-sesion'), findsOneWidget);
    expect(find.text('Salto mas alto'), findsOneWidget);
    expect(find.text('Hangtime maximo'), findsOneWidget);
    expect(find.text('Duracion sesion'), findsOneWidget);
    expect(find.text('Velocidad max'), findsOneWidget);
    expect(find.text('Saltos'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Historial de saltos'),
      250,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('Historial de saltos'), findsOneWidget);
    expect(find.text('#'), findsOneWidget);
    expect(find.text('Altura est.'), findsOneWidget);
    expect(find.text('Hangtime'), findsOneWidget);
    expect(find.text('Maniobra'), findsOneWidget);
    expect(find.text('Recepcion'), findsOneWidget);
    expect(find.text('Min:Seg'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Mediciones avanzadas'),
      250,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('Mediciones avanzadas'), findsOneWidget);
    expect(find.text('Selector de KPIs'), findsOneWidget);
    expect(find.text('Timeline de rendimiento'), findsNothing);
    expect(find.text('Eventos detectados'), findsNothing);

    expect(find.text('Metricas (placeholder)'), findsNothing);
  });
}
