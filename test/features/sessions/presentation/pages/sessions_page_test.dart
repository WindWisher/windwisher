import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/sessions/presentation/pages/sessions_page.dart';

void main() {
  Widget buildPage({bool useLocalPersistence = false}) => MaterialApp(
    home: SessionsPage(
      useLocalPersistence: useLocalPersistence,
      detectExternalSessionDevices: () async => const [],
    ),
  );

  testWidgets('uses the phone as the real default capture device', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());
    await tester.pump();

    expect(find.text('Start Session'), findsOneWidget);
    expect(find.textContaining('Telefono del usuario'), findsWidgets);
    expect(find.text('Captura de sesion'), findsOneWidget);
    expect(find.text('Iniciar sesion'), findsOneWidget);
  });

  testWidgets('shows physical and derived capabilities for the phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildPage());
    await tester.pump();

    await tester.tap(find.byTooltip('Ver capacidades del dispositivo'));
    await tester.pumpAndSettle();

    expect(find.text('Capacidades del dispositivo'), findsOneWidget);
    expect(find.text('Sensores físicos'), findsOneWidget);
    expect(find.text('Capacidades derivadas'), findsOneWidget);
    expect(find.textContaining('sensores físicos disponibles'), findsOneWidget);
  });

  testWidgets('offers real file import without creating simulated sessions', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());
    await tester.pump();

    expect(
      find.widgetWithText(OutlinedButton, 'Importar sesion real'),
      findsOneWidget,
    );
    expect(find.text('Sesion importada en Oliva Norte'), findsNothing);
  });

  testWidgets('switches between capture and saved sessions', (tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pump();

    await tester.tap(find.text('My Sessions'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Captura de sesion'), findsNothing);
  });

  testWidgets('persists the selected tab in local mode', (tester) async {
    final file = File(
      AppStoragePaths.resolve('session_view_preferences_v1.json'),
    );
    if (file.existsSync()) {
      file.deleteSync();
    }
    addTearDown(() {
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    await tester.pumpWidget(buildPage(useLocalPersistence: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Sessions'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(buildPage(useLocalPersistence: true));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Captura de sesion'), findsNothing);
  });
}
