import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/presentation/pages/spots_page.dart';

void main() {
  testWidgets('adds a spot from floating action button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotsPage())),
    );

    expect(
      find.textContaining('Todavia no has agregado spots'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oliva Puerto',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Zona / provincia (opcional)'),
      'Valencia',
    );

    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    expect(find.text('Oliva Puerto'), findsOneWidget);
    expect(find.text('Valencia'), findsOneWidget);
  });

  testWidgets('suggests available spots while typing name', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotsPage())),
    );

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oli',
    );
    await tester.pumpAndSettle();

    expect(find.text('Oliva Puerto'), findsOneWidget);

    await tester.tap(find.text('Oliva Puerto'));
    await tester.pumpAndSettle();

    expect(find.text('Valencia'), findsOneWidget);
  });

  testWidgets('supports custom map point from Personalizado button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotsPage())),
    );

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();

    expect(find.text('Selecciona punto en el mapa'), findsOneWidget);

    await tester.tap(find.byKey(const Key('custom-map-area')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Usar punto'));
    await tester.pumpAndSettle();

    expect(find.text('Punto del mapa seleccionado'), findsOneWidget);
  });

  testWidgets('prevents adding duplicated spots', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotsPage())),
    );

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oliva Puerto',
    );
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oliva Puerto',
    );
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    expect(find.text('Ese spot ya esta agregado'), findsOneWidget);
  });

  testWidgets('allows deleting a spot from multi mode selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotsPage())),
    );

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oliva Puerto',
    );
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    expect(find.text('Oliva Puerto'), findsOneWidget);

    final state = tester.state<SpotsPageState>(find.byType(SpotsPage));
    state.deleteMultipleSpotsFromToolbar();
    await tester.pumpAndSettle();

    expect(find.textContaining('Modo eliminar varios'), findsOneWidget);

    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    expect(find.text('Oliva Puerto'), findsNothing);
    expect(
      find.textContaining('Todavia no has agregado spots'),
      findsOneWidget,
    );
  });

  testWidgets('hides per-card edit action for predefined list spots', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotsPage())),
    );

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oliva Puerto',
    );
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets('opens spot detail on card tap and supports app bar back', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotsPage())),
    );

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oliva Puerto',
    );
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oliva Puerto'));
    await tester.pumpAndSettle();

    expect(find.text('Spot seleccionado'), findsOneWidget);
    expect(find.text('Oliva Puerto'), findsOneWidget);
    expect(find.text('Forecast'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
    expect(find.text('Webcam'), findsOneWidget);
    expect(find.text('Social'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(SpotsPage), findsOneWidget);
  });

  testWidgets('opens wind map screen from forecast section', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotsPage())),
    );

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oliva Puerto',
    );
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oliva Puerto'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mapa de viento'));
    await tester.pumpAndSettle();

    expect(find.text('Mapa de viento'), findsOneWidget);
    expect(find.textContaining('Capa de viento'), findsOneWidget);
  });

  testWidgets('edits one custom spot from card selection mode', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotsPage())),
    );

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('custom-map-area')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar punto'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Custom Uno',
    );
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

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

  testWidgets('shows Oficial and Custom chips correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotsPage())),
    );

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oliva Puerto',
    );
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('custom-map-area')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar punto'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Spot libre',
    );
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    expect(find.text('Oficial'), findsOneWidget);
    expect(find.text('Custom'), findsWidgets);
  });

  testWidgets('filters spots by type', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotsPage())),
    );

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oliva Puerto',
    );
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('custom-map-area')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar punto'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Spot libre',
    );
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('spots-filter-custom')));
    await tester.pumpAndSettle();

    expect(find.text('Spot libre'), findsOneWidget);
    expect(find.text('Oliva Puerto'), findsNothing);

    await tester.tap(find.byKey(const Key('spots-filter-official')));
    await tester.pumpAndSettle();

    expect(find.text('Oliva Puerto'), findsOneWidget);
    expect(find.text('Spot libre'), findsNothing);
  });

  testWidgets('filters spots by search text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotsPage())),
    );

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Oliva Puerto',
    );
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Agregar spot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('custom-map-area')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar punto'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del spot'),
      'Mi custom',
    );
    await tester.tap(find.text('Guardar spot'));
    await tester.pumpAndSettle();

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
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotsPage())),
    );

    Future<void> addSpot(String name) async {
      await tester.tap(find.byTooltip('Agregar spot'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Nombre del spot'),
        name,
      );
      await tester.tap(find.text('Guardar spot'));
      await tester.pumpAndSettle();
    }

    await addSpot('Tarifa');
    await addSpot('Altea');

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
}
