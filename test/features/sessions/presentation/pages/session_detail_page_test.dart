import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/sessions/presentation/pages/session_detail_page.dart';

void main() {
  Widget buildPage() {
    return MaterialApp(
      home: SessionDetailPage(
        title: 'Sesion en Oliva Norte',
        deviceName: 'Woo Sports 3',
        endedAt: DateTime(2026, 2, 22, 18, 40),
        durationLabel: '1:12:30',
        summary: 'Viento estable de side-on con buenas rachas al final.',
        source: SessionDetailSource.mySessions,
        insights: SessionInsightData.fromSession(
          title: 'Sesion en Oliva Norte',
          deviceName: 'Woo Sports 3',
          deviceKind: 'Woo Sports',
          endedAt: DateTime(2026, 2, 22, 18, 40),
          durationLabel: '1:12:30',
        ),
      ),
    );
  }

  testWidgets('renders advanced metrics sections instead of placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());

    expect(find.text('Contexto de sesion'), findsOneWidget);
    expect(find.text('Origen: My Sessions'), findsOneWidget);
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
      find.text('Historico de saltos'),
      250,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('Historico de saltos'), findsOneWidget);
    expect(find.text('#'), findsOneWidget);
    expect(find.text('Altura'), findsOneWidget);
    expect(find.text('Hangtime'), findsOneWidget);
    expect(find.text('Caida'), findsOneWidget);
    expect(find.text('Min:Seg'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Timeline de rendimiento'),
      300,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('Timeline de rendimiento'), findsOneWidget);
    expect(find.byKey(const Key('session_timeline_chart')), findsOneWidget);
    expect(find.text('Social / Competicion'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Eventos detectados'),
      250,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('Eventos detectados'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Mediciones avanzadas'),
      250,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('Mediciones avanzadas'), findsOneWidget);
    expect(find.text('Core Session'), findsWidgets);

    expect(find.text('Metricas (placeholder)'), findsNothing);
  });
}
