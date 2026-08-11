import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/spots/di/spots_module.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/presentation/pages/spots/spots_page.dart';

void main() {
  const officialSpotName = 'Oliva Canal - Platja dels Gorgs';

  SpotItem buildSpot(String name, {bool isCustom = false}) {
    return SpotItem(
      name: name,
      area: 'Valencia',
      isCustom: isCustom,
      createdAt: DateTime(2026),
      latitude: 38.92,
      longitude: -0.09,
    );
  }

  SpotsModule buildSpotsModule(List<SpotItem> spots) {
    final module = SpotsModule.inMemory();
    for (final spot in spots) {
      module.saveSpot(spot);
    }
    return module;
  }

  Widget buildSpotsTestApp({
    SpotsModule? spotsModule,
    bool initiallyShowMap = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SpotsPage(
          spotsModule: spotsModule,
          useLocalPersistence: false,
          initialRoles: const {'pro'},
          initiallyShowMap: initiallyShowMap,
        ),
      ),
    );
  }

  testWidgets('adds a spot from floating action button', (tester) async {
    await tester.pumpWidget(buildSpotsTestApp());

    expect(
      find.textContaining('Todavia no has agregado spots'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oliva Canal',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(officialSpotName));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    expect(find.text(officialSpotName), findsOneWidget);
    expect(find.text('Valencia'), findsOneWidget);
  });

  testWidgets('suggests available spots while typing name', (tester) async {
    await tester.pumpWidget(buildSpotsTestApp());

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oli',
    );
    await tester.pumpAndSettle();

    expect(find.text(officialSpotName), findsOneWidget);

    await tester.tap(find.text(officialSpotName));
    await tester.pumpAndSettle();

    expect(find.text('Valencia'), findsOneWidget);
  });

  testWidgets('requires tapping the suggestion to save as official spot', (
    tester,
  ) async {
    await tester.pumpWidget(buildSpotsTestApp());

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oliva Canal',
    );
    await tester.pumpAndSettle();

    expect(find.text('Oliva Canal - Platja dels Gorgs'), findsOneWidget);
    expect(
      find.text('Selecciona un punto en el mapa para guardar.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Oliva Canal - Platja dels Gorgs'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    expect(find.text('Oliva Canal - Platja dels Gorgs'), findsOneWidget);
  });

  testWidgets('saves a selected official suggestion and shows its card', (
    tester,
  ) async {
    await tester.pumpWidget(buildSpotsTestApp());

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oliva Canal',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oliva Canal - Platja dels Gorgs'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    expect(find.text('Oliva Canal - Platja dels Gorgs'), findsOneWidget);
    expect(find.text('Valencia'), findsOneWidget);
  });

  testWidgets('does not offer custom spot creation', (tester) async {
    await tester.pumpWidget(buildSpotsTestApp());

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();

    expect(find.text('Personalizado'), findsNothing);
    expect(find.text('Selecciona punto en el mapa'), findsNothing);
  });

  testWidgets('does not show obsolete spot type filters', (tester) async {
    final module = buildSpotsModule([buildSpot(officialSpotName)]);
    await tester.pumpWidget(buildSpotsTestApp(spotsModule: module));

    expect(find.byKey(const Key('spots-filter-all')), findsNothing);
    expect(find.byKey(const Key('spots-filter-official')), findsNothing);
    expect(find.byKey(const Key('spots-filter-custom')), findsNothing);
  });

  testWidgets('allows deleting a spot from multi mode selection', (
    tester,
  ) async {
    final module = buildSpotsModule([buildSpot(officialSpotName)]);
    await tester.pumpWidget(buildSpotsTestApp(spotsModule: module));

    expect(find.text(officialSpotName), findsOneWidget);

    final state = tester.state<SpotsPageState>(find.byType(SpotsPage));
    state.deleteMultipleSpotsFromToolbar();
    await tester.pumpAndSettle();

    expect(find.textContaining('Modo eliminar varios'), findsOneWidget);

    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    expect(find.text(officialSpotName), findsNothing);
    expect(
      find.textContaining('Todavia no has agregado spots'),
      findsOneWidget,
    );
  });

  testWidgets('hides per-card edit action for predefined list spots', (
    tester,
  ) async {
    final module = buildSpotsModule([buildSpot(officialSpotName)]);
    await tester.pumpWidget(buildSpotsTestApp(spotsModule: module));

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets('opens spot detail on card tap and supports app bar back', (
    tester,
  ) async {
    final module = buildSpotsModule([buildSpot(officialSpotName)]);
    await tester.pumpWidget(buildSpotsTestApp(spotsModule: module));

    await tester.tap(find.text(officialSpotName));
    await tester.pumpAndSettle();

    expect(find.text('Spot seleccionado'), findsOneWidget);
    expect(find.text(officialSpotName), findsOneWidget);
    expect(find.text('Forecast'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
    expect(find.text('Webcam'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(SpotsPage), findsOneWidget);
  });

  testWidgets('opens the forecast section for a saved spot', (tester) async {
    final module = buildSpotsModule([buildSpot('Oliva Puerto')]);
    await tester.pumpWidget(buildSpotsTestApp(spotsModule: module));

    await tester.tap(find.text('Oliva Puerto'));
    await tester.pumpAndSettle();

    expect(find.text('Forecast'), findsOneWidget);
    expect(find.text('Proveedor meteo'), findsOneWidget);
  });

  testWidgets('edits one custom spot from card selection mode', (tester) async {
    final module = buildSpotsModule([buildSpot('Custom Uno', isCustom: true)]);
    await tester.pumpWidget(buildSpotsTestApp(spotsModule: module));

    final state = tester.state<SpotsPageState>(find.byType(SpotsPage));
    state.editSpotFromToolbar();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Custom Uno'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Zona / provincia'),
      'Zona editada',
    );
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(find.text('Zona editada'), findsOneWidget);
  });

  testWidgets('shows Custom chip only for custom spots', (tester) async {
    final module = buildSpotsModule([
      buildSpot(officialSpotName),
      buildSpot('Spot libre', isCustom: true),
    ]);
    await tester.pumpWidget(buildSpotsTestApp(spotsModule: module));

    expect(find.text('Oficial'), findsNothing);
    expect(
      find.descendant(of: find.byType(ListTile), matching: find.text('Custom')),
      findsOneWidget,
    );
  });

  testWidgets('filters spots by search text', (tester) async {
    final module = buildSpotsModule([
      buildSpot('Oliva Puerto'),
      buildSpot('Mi custom', isCustom: true),
    ]);
    await tester.pumpWidget(buildSpotsTestApp(spotsModule: module));

    await tester.enterText(
      find.byKey(const Key('spots-search-input')),
      'puerto',
    );
    await tester.pumpAndSettle();

    expect(find.text('Oliva Puerto'), findsOneWidget);
    expect(find.text('Mi custom'), findsNothing);

    await tester.tap(find.byTooltip('Limpiar busqueda'));
    await tester.pumpAndSettle();

    expect(find.text('Oliva Puerto'), findsOneWidget);
    expect(find.text('Mi custom'), findsOneWidget);
  });

  testWidgets('sorts spots by A-Z and Z-A', (tester) async {
    final module = buildSpotsModule([buildSpot('Tarifa'), buildSpot('Altea')]);
    await tester.pumpWidget(buildSpotsTestApp(spotsModule: module));

    await tester.tap(find.byKey(const Key('spots-sort-az')));
    await tester.pumpAndSettle();

    final azTitles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .toList();
    expect((azTitles.first.title as Text).data, 'Altea');

    await tester.tap(find.byKey(const Key('spots-sort-za')));
    await tester.pumpAndSettle();

    final zaTitles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .toList();
    expect((zaTitles.first.title as Text).data, 'Tarifa');
  });

  testWidgets('maps catalog spots and adds one to the saved list', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(450, 900);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final spotsModule = SpotsModule.inMemory();
    const spotName = 'Dakhla';

    await tester.pumpWidget(
      buildSpotsTestApp(spotsModule: spotsModule, initiallyShowMap: true),
    );
    await tester.pump();

    expect(
      tester.getCenter(find.text('Mapa')).dx,
      lessThan(tester.getCenter(find.text('Lista')).dx),
    );

    expect(find.byKey(const Key('spots-explorer-map')), findsOneWidget);
    expect(find.byKey(const Key('spots-map-loading')), findsOneWidget);
    expect(find.byTooltip('Agregar spot'), findsNothing);
    expect(find.byTooltip('Acercar mapa'), findsOneWidget);
    expect(find.byTooltip('Alejar mapa'), findsOneWidget);
    expect(find.byTooltip('Ver todos los spots'), findsOneWidget);

    await tester.tap(find.byTooltip('Ver todos los spots'));
    await tester.pump();
    expect(find.byKey(const Key('spot-map-marker-$spotName')), findsOneWidget);
    await tester.tap(find.byKey(const Key('spot-map-marker-$spotName')));
    await tester.pump();

    expect(find.byKey(const Key('spot-map-preview-card')), findsOneWidget);
    expect(
      find.byKey(const Key('spot-map-marker-label-$spotName')),
      findsOneWidget,
    );
    expect(find.text(spotName), findsNWidgets(2));
    expect(find.text('Abrir spot'), findsOneWidget);
    expect(find.byTooltip('Agregar a Mis spots'), findsOneWidget);
    expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    expect(find.byTooltip('Ver ubicacion'), findsOneWidget);
    expect(find.byTooltip('Como llegar'), findsNothing);
    expect(find.text('Live'), findsNothing);
    expect(find.text('Webcam'), findsNothing);
    expect(find.text('Forecast'), findsNothing);
    expect(find.textContaining('flutter_map'), findsNothing);
    expect(find.text('OpenStreetMap · CARTO'), findsNothing);
    expect(find.byTooltip('Fuentes del mapa'), findsNothing);
    final controlsRect = tester.getRect(
      find.byKey(const Key('spots-map-controls')),
    );
    final previewRect = tester.getRect(
      find.byKey(const Key('spot-map-preview-card')),
    );
    expect(
      previewRect.top - controlsRect.bottom,
      greaterThanOrEqualTo(AppSpacing.sm),
    );

    final map = tester.widget<FlutterMap>(
      find.byKey(const Key('spots-explorer-map')),
    );
    map.mapController?.rotate(35);
    await tester.pump();
    expect(map.mapController?.camera.rotation, 35);

    await tester.tap(find.byTooltip('Ver todos los spots'));
    await tester.pump();
    expect(map.mapController?.camera.rotation, 0);

    await tester.tap(find.byKey(const Key('add-map-spot-to-list')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byTooltip('Agregar a Mis spots'), findsNothing);

    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();

    expect(find.text(spotName), findsOneWidget);
    expect(find.byTooltip('Agregar spot'), findsOneWidget);
  });

  testWidgets('suggests map spots and zooms to the selected result', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(450, 900);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      buildSpotsTestApp(
        spotsModule: SpotsModule.inMemory(),
        initiallyShowMap: true,
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('spots-search-input')),
      'Oliva',
    );
    await tester.pump();

    final suggestion = find.byKey(
      const Key('spots-map-search-suggestion-Oliva Canal - Platja dels Gorgs'),
    );
    expect(suggestion, findsOneWidget);

    await tester.tap(suggestion);
    await tester.pump();

    expect(find.byKey(const Key('spots-map-search-suggestions')), findsNothing);
    expect(
      find.byKey(
        const Key('spot-map-marker-label-Oliva Canal - Platja dels Gorgs'),
      ),
      findsOneWidget,
    );
    final map = tester.widget<FlutterMap>(
      find.byKey(const Key('spots-explorer-map')),
    );
    expect(map.mapController?.camera.zoom, 16);
  });

  testWidgets('scrolls the complete map section in landscape', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 450);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      buildSpotsTestApp(
        spotsModule: SpotsModule.inMemory(),
        initiallyShowMap: true,
      ),
    );
    await tester.pump();

    final mapFinder = find.byKey(const Key('spots-explorer-map'));
    final controlsFinder = find.byKey(const Key('spots-map-controls'));
    final scrollFinder = find.byKey(const Key('spots-map-scroll'));
    expect(scrollFinder, findsOneWidget);

    final mapRect = tester.getRect(mapFinder);
    final controlsRect = tester.getRect(controlsFinder);
    expect(mapRect.bottom - controlsRect.bottom, closeTo(12, 1));

    final initialMapTop = mapRect.top;
    await tester.drag(scrollFinder, const Offset(0, -140));
    await tester.pump();

    expect(tester.getTopLeft(mapFinder).dy, lessThan(initialMapTop));
  });
}
