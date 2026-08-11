import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  Widget buildSpotsTestApp({SpotsModule? spotsModule}) {
    return MaterialApp(
      home: Scaffold(
        body: SpotsPage(
          spotsModule: spotsModule,
          useLocalPersistence: false,
          initialRoles: const {'pro'},
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

  testWidgets('supports custom map point from Personalizado button', (
    tester,
  ) async {
    await tester.pumpWidget(buildSpotsTestApp());

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();

    expect(find.text('Selecciona punto en el mapa'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Latitud'),
      '38.920000',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Longitud'),
      '-0.090000',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Usar punto'));
    await tester.pumpAndSettle();

    expect(find.text('Punto del mapa seleccionado'), findsOneWidget);
  });

  testWidgets('prevents adding duplicated spots', (tester) async {
    final module = buildSpotsModule([
      buildSpot('Spot duplicado', isCustom: true),
    ]);
    await tester.pumpWidget(buildSpotsTestApp(spotsModule: module));

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Latitud'),
      '38.920000',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Longitud'),
      '-0.090000',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar punto'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Spot duplicado',
    );
    await tester.ensureVisible(find.text('Guardar spot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    expect(find.text('Ese spot ya esta agregado'), findsOneWidget);
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

  testWidgets('filters spots by type', (tester) async {
    final module = buildSpotsModule([
      buildSpot(officialSpotName),
      buildSpot('Spot libre', isCustom: true),
    ]);
    await tester.pumpWidget(buildSpotsTestApp(spotsModule: module));

    await tester.tap(find.byKey(const Key('spots-filter-custom')));
    await tester.pumpAndSettle();

    expect(find.text('Spot libre'), findsOneWidget);
    expect(find.text(officialSpotName), findsNothing);

    await tester.tap(find.byKey(const Key('spots-filter-official')));
    await tester.pumpAndSettle();

    expect(find.text(officialSpotName), findsOneWidget);
    expect(find.text('Spot libre'), findsNothing);
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

  testWidgets('opens map view and previews a selected spot marker', (
    tester,
  ) async {
    final spotsModule = SpotsModule.inMemory();
    const spotName = 'Spot mapa test';
    spotsModule.saveSpot(
      SpotItem(
        name: spotName,
        area: 'Costa test',
        isCustom: true,
        createdAt: DateTime(2026),
        latitude: 38.92,
        longitude: -0.09,
      ),
    );

    await tester.pumpWidget(buildSpotsTestApp(spotsModule: spotsModule));
    await tester.pump();

    await tester.tap(find.text('Mapa'));
    await tester.pump();

    expect(find.byKey(const Key('spots-explorer-map')), findsOneWidget);
    expect(find.byKey(const Key('spot-map-marker-$spotName')), findsOneWidget);

    await tester.tap(find.byKey(const Key('spot-map-marker-$spotName')));
    await tester.pump();

    expect(find.byKey(const Key('spot-map-preview-card')), findsOneWidget);
    expect(find.text(spotName), findsOneWidget);
    expect(find.text('Abrir spot'), findsOneWidget);

    spotsModule.deleteSpotByName(spotName);
  });
}
