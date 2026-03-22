import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/profile/di/profile_module.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/sessions/presentation/pages/sessions_page.dart';

Finder _sessionControlLabel(String label) => find.text(label);

void main() {
  testWidgets('includes phone device in linked devices list', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SessionsPage(useLocalPersistence: false)),
    );

    await tester.tap(find.textContaining('Woo Sports 3 ·').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Telefono del usuario ·'), findsWidgets);
    expect(find.textContaining('Woo Sports 3 ·'), findsWidgets);
  });

  testWidgets('shows selected device capabilities and updates when changed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: SessionsPage(useLocalPersistence: false)),
    );

    final capabilitiesButton = find.byTooltip(
      'Ver capacidades del dispositivo',
    );
    await tester.ensureVisible(capabilitiesButton);
    await tester.tap(capabilitiesButton);
    await tester.pumpAndSettle();
    expect(find.text('Capacidades del dispositivo'), findsOneWidget);
    expect(find.text('7/9 sensores disponibles'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cerrar'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Woo Sports 3 ·').first);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Apple Watch Ultra ·').last);
    await tester.pumpAndSettle();

    await tester.tap(capabilitiesButton);
    await tester.pumpAndSettle();
    expect(find.text('9/9 sensores disponibles'), findsOneWidget);
  });

  testWidgets('imports file and creates session with jump history', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SessionsPage(useLocalPersistence: false)),
    );

    final importButton = find.widgetWithText(OutlinedButton, 'Importar sesion');

    await tester.ensureVisible(importButton);
    await tester.pumpAndSettle();

    await tester.tap(importButton);
    await tester.pumpAndSettle();

    expect(find.text('Sesion importada en Oliva Norte'), findsOneWidget);

    await tester.tap(find.text('Sesion importada en Oliva Norte'));
    await tester.pumpAndSettle();

    expect(find.text('Contexto de sesion'), findsOneWidget);
    expect(find.text('Origen: My Sessions'), findsOneWidget);
    expect(
      find.textContaining('Importada desde archivo del dispositivo'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Historico de saltos'),
      250,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('Historico de saltos'), findsOneWidget);
    expect(find.text('Min:Seg'), findsOneWidget);
  });

  testWidgets('syncs selected device session from selected device card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: SessionsPage(useLocalPersistence: false)),
    );

    final syncButton = find.widgetWithText(
      OutlinedButton,
      'Sincronizar dispositivo',
    );
    if (syncButton.evaluate().isEmpty) {
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Woo Sports 3').last);
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(syncButton);
    await tester.tap(syncButton);
    await tester.pumpAndSettle();

    expect(find.text('Sesiones sincronizadas del dispositivo'), findsOneWidget);
    expect(find.text('Sesion importada en Oliva Norte'), findsOneWidget);
    expect(find.byTooltip('Eliminar sesion sincronizada'), findsWidgets);
    await tester.tap(find.byTooltip('Eliminar sesion sincronizada').first);
    await tester.pumpAndSettle();
    expect(find.text('Eliminar sesion sincronizada'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Configurar').first);
    await tester.pumpAndSettle();

    expect(find.text('Configurar sesion'), findsOneWidget);
    final dialogUploadButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Subir sesion'),
    );
    await tester.tap(dialogUploadButton);
    await tester.pumpAndSettle();

    expect(find.text('Configurar sesion'), findsNothing);
    expect(find.text('Sesion sincronizada en El Saler'), findsOneWidget);
  });

  testWidgets('allows selecting custom gear setup when uploading session', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final gearController = ProfileModule.inMemory().gearController;
    for (final setup in List<GearSetup>.from(gearController.savedGearSetups)) {
      gearController.deleteGearSetup(setup.id);
    }
    gearController.saveKite(
      KiteItem(
        id: 'kite-1',
        brand: 'Duotone',
        model: 'Evo SLS',
        sizeMeters: '9',
        year: '2025',
      ),
    );
    gearController.saveBoard(
      BoardItem(
        id: 'board-1',
        brand: 'North',
        model: 'Atmos',
        type: 'Twin tip',
        sizeCm: '136x40',
        year: '2024',
      ),
    );
    gearController.saveBar(
      BarItem(
        id: 'bar-1',
        brand: 'Duotone',
        model: 'Click Bar',
        lineLengthMeters: '24',
        widthCm: '52',
        year: '2024',
      ),
    );
    gearController.saveHarness(
      HarnessItem(
        id: 'harness-1',
        brand: 'Mystic',
        model: 'Stealth',
        size: 'M',
        year: '2025',
      ),
    );
    gearController.saveWetsuit(
      WetsuitItem(
        id: 'wetsuit-1',
        brand: 'ION',
        model: 'Seek',
        thickness: '4/3',
        size: 'M',
        year: '2024',
      ),
    );
    gearController.saveHelmet(
      HelmetItem(id: 'helmet-1', brand: 'Gath', model: 'Gedi', year: '2024'),
    );
    gearController.saveVest(
      VestItem(
        id: 'vest-1',
        brand: 'Mystic',
        model: 'Impact',
        size: 'M',
        year: '2025',
      ),
    );
    gearController.saveGearSetup(
      GearSetup(
        id: 'setup-1',
        name: 'Big Air 30kt',
        kiteId: 'kite-1',
        barId: 'bar-1',
        boardId: 'board-1',
        harnessId: 'harness-1',
        wetsuitId: 'wetsuit-1',
        helmetId: 'helmet-1',
        vestId: 'vest-1',
        createdAt: DateTime(2026, 3, 3, 23, 13),
      ),
    );
    addTearDown(() {
      for (final setup in List<GearSetup>.from(
        gearController.savedGearSetups,
      )) {
        gearController.deleteGearSetup(setup.id);
      }
    });

    await tester.pumpWidget(
      const MaterialApp(home: SessionsPage(useLocalPersistence: false)),
    );

    final startButton = _sessionControlLabel('Iniciar sesion');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();
    final stopButton = _sessionControlLabel('Detener sesion');
    await tester.ensureVisible(stopButton);
    await tester.tap(stopButton);
    await tester.pumpAndSettle();
    final uploadControl = _sessionControlLabel('Subir sesion');
    await tester.ensureVisible(uploadControl.first);
    await tester.tap(uploadControl.first);
    await tester.pumpAndSettle();

    expect(find.text('Equipo utilizado (opcional)'), findsOneWidget);

    await tester.tap(find.text('Sin equipacion'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Big Air 30kt').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Cometa: Duotone Evo SLS 9m'), findsOneWidget);
    expect(find.textContaining('Tabla: North Atmos 136x40'), findsOneWidget);
    expect(
      find.textContaining('Barra: Duotone Click Bar · 24m/52cm'),
      findsOneWidget,
    );
    expect(find.textContaining('Arnes: Mystic Stealth · M'), findsOneWidget);
    expect(find.textContaining('Traje: ION Seek · 4/3 · M'), findsOneWidget);
    expect(find.textContaining('Casco: Gath Gedi (2024)'), findsOneWidget);
    expect(
      find.textContaining('Chaleco: Mystic Impact · M (2025)'),
      findsOneWidget,
    );

    final dialogUploadButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Subir sesion'),
    );
    await tester.tap(dialogUploadButton);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Sessions'));
    await tester.pumpAndSettle();

    expect(find.text('Big Air 30kt'), findsWidgets);

    await tester.tap(find.text('Start Session'));
    await tester.pumpAndSettle();

    final newSessionButton = _sessionControlLabel('Nueva sesion');
    if (newSessionButton.evaluate().isNotEmpty) {
      await tester.tap(newSessionButton);
      await tester.pumpAndSettle();
    }
    await tester.tap(_sessionControlLabel('Iniciar sesion'));
    await tester.pumpAndSettle();
    await tester.tap(_sessionControlLabel('Detener sesion'));
    await tester.pumpAndSettle();
    await tester.tap(_sessionControlLabel('Subir sesion').first);
    await tester.pumpAndSettle();

    expect(find.text('Big Air 30kt'), findsWidgets);
  });

  testWidgets('keeps upload dialog stable when typing session summary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: SessionsPage(useLocalPersistence: false)),
    );

    await tester.tap(_sessionControlLabel('Iniciar sesion'));
    await tester.pumpAndSettle();
    await tester.tap(_sessionControlLabel('Detener sesion'));
    await tester.pumpAndSettle();
    await tester.tap(_sessionControlLabel('Subir sesion').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'Sesion con rachas fuertes y buen control.',
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Configurar sesion'), findsOneWidget);
  });

  testWidgets('keeps upload dialog stable when selecting gallery media', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: SessionsPage(useLocalPersistence: false)),
    );

    final startButton = _sessionControlLabel('Iniciar sesion');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();
    final stopButton = _sessionControlLabel('Detener sesion');
    await tester.ensureVisible(stopButton);
    await tester.tap(stopButton);
    await tester.pumpAndSettle();
    final uploadButton = _sessionControlLabel('Subir sesion').first;
    await tester.ensureVisible(uploadButton);
    await tester.tap(uploadButton);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Galeria'));
    await tester.tap(find.text('Galeria'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Configurar sesion'), findsOneWidget);
  });

  testWidgets(
    'persists session tab and filters across page instances in local mode',
    (tester) async {
      final files = <File>[
        File(AppStoragePaths.resolve('sessions_view_preferences_v1.json')),
        File(AppStoragePaths.resolve('sessions_devices_v1.json')),
        File(AppStoragePaths.resolve('sessions_records_v1.json')),
      ];
      for (final file in files) {
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
      addTearDown(() {
        for (final file in files) {
          if (file.existsSync()) {
            file.deleteSync();
          }
        }
      });

      await tester.pumpWidget(
        const MaterialApp(home: SessionsPage(useLocalPersistence: true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Sessions'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Woo Sports 3').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mas recientes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mas antiguas').last);
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        const MaterialApp(home: SessionsPage(useLocalPersistence: true)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Buscar sesiones...'), findsOneWidget);
      expect(find.text('Woo Sports 3'), findsOneWidget);
      expect(find.text('Mas antiguas'), findsOneWidget);
    },
  );

  testWidgets(
    'persists last used gear setup and upload spot across page instances',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final files = <File>[
        File(AppStoragePaths.resolve('sessions_view_preferences_v1.json')),
        File(AppStoragePaths.resolve('sessions_devices_v1.json')),
        File(AppStoragePaths.resolve('sessions_records_v1.json')),
      ];
      for (final file in files) {
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
      addTearDown(() {
        for (final file in files) {
          if (file.existsSync()) {
            file.deleteSync();
          }
        }
      });

      final gearController = ProfileModule.localFile().gearController;
      for (final setup in List<GearSetup>.from(
        gearController.savedGearSetups,
      )) {
        gearController.deleteGearSetup(setup.id);
      }
      gearController.saveKite(
        KiteItem(
          id: 'kite-last-used',
          brand: 'North',
          model: 'Orbit',
          sizeMeters: '10',
          year: '2025',
        ),
      );
      gearController.saveBoard(
        BoardItem(
          id: 'board-last-used',
          brand: 'Duotone',
          model: 'Select',
          type: 'Twin tip',
          sizeCm: '138x41',
          year: '2024',
        ),
      );
      gearController.saveGearSetup(
        GearSetup(
          id: 'setup-last-used',
          name: 'Last Used Rig',
          kiteId: 'kite-last-used',
          boardId: 'board-last-used',
          createdAt: DateTime(2026, 3, 4, 21, 0),
        ),
      );
      addTearDown(() {
        for (final setup in List<GearSetup>.from(
          gearController.savedGearSetups,
        )) {
          gearController.deleteGearSetup(setup.id);
        }
      });

      await tester.pumpWidget(
        const MaterialApp(home: SessionsPage(useLocalPersistence: true)),
      );
      await tester.pumpAndSettle();

      final startButton = _sessionControlLabel('Iniciar sesion');
      await tester.ensureVisible(startButton);
      await tester.tap(startButton);
      await tester.pumpAndSettle();
      final stopButton = _sessionControlLabel('Detener sesion');
      await tester.ensureVisible(stopButton);
      await tester.tap(stopButton);
      await tester.pumpAndSettle();
      final uploadButton = _sessionControlLabel('Subir sesion').first;
      await tester.ensureVisible(uploadButton);
      await tester.tap(uploadButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sin equipacion'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last Used Rig').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Oliva Norte'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gandia Harbor').last);
      await tester.pumpAndSettle();

      final dialogUploadButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Subir sesion'),
      );
      await tester.tap(dialogUploadButton);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        const MaterialApp(home: SessionsPage(useLocalPersistence: true)),
      );
      await tester.pumpAndSettle();

      final newSessionButton = _sessionControlLabel('Nueva sesion');
      if (newSessionButton.evaluate().isNotEmpty) {
        await tester.tap(newSessionButton.first);
        await tester.pumpAndSettle();
      }
      final startButtonAgain = _sessionControlLabel('Iniciar sesion');
      await tester.ensureVisible(startButtonAgain);
      await tester.tap(startButtonAgain);
      await tester.pumpAndSettle();
      final stopButtonAgain = _sessionControlLabel('Detener sesion');
      await tester.ensureVisible(stopButtonAgain);
      await tester.tap(stopButtonAgain);
      await tester.pumpAndSettle();
      final uploadButtonAgain = _sessionControlLabel('Subir sesion').first;
      await tester.ensureVisible(uploadButtonAgain);
      await tester.tap(uploadButtonAgain);
      await tester.pumpAndSettle();

      expect(find.text('Last Used Rig'), findsWidgets);
      expect(find.text('Gandia Harbor'), findsWidgets);
    },
  );
}
