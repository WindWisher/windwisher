import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/profile_page.dart';

void main() {
  Widget buildPage() => const MaterialApp(home: Scaffold(body: ProfilePage()));

  testWidgets('profile shows its three primary tabs', (tester) async {
    await tester.pumpWidget(buildPage());

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Alarmas'), findsOneWidget);
    expect(find.text('Mensajes'), findsOneWidget);
  });

  testWidgets('profile shows the user summary and internal sections', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());

    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('Equipo'), findsOneWidget);
    expect(find.text('Rider Kitesurf'), findsOneWidget);
    expect(find.text('@rider_ks'), findsOneWidget);
    expect(find.text('Estadisticas'), findsOneWidget);
  });

  testWidgets('profile statistics opens the current KPI dialog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildPage());
    final detailsButton = find.widgetWithText(OutlinedButton, 'Detalles');
    await tester.ensureVisible(detailsButton);
    await tester.tap(detailsButton);
    await tester.pumpAndSettle();

    expect(find.text('Detalle estadisticas del perfil'), findsOneWidget);
    expect(find.textContaining('Resumen extendido del perfil'), findsOneWidget);
  });

  testWidgets('profile opens its public preview from the accessible action', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());

    await tester.tap(find.byTooltip('Vista publica'));
    await tester.pumpAndSettle();

    expect(find.text('Vista publica'), findsOneWidget);
    expect(find.textContaining('Asi veran otros usuarios'), findsOneWidget);
  });

  testWidgets('profile opens the edit-user dialog', (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildPage());

    final editButton = find.text('Editar usuario');
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    expect(find.text('Editar usuario'), findsWidgets);
    expect(find.text('Nombre'), findsOneWidget);
  });

  testWidgets('equipment section exposes material and setup controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildPage());
    await tester.tap(find.text('Equipo'));
    await tester.pumpAndSettle();

    expect(find.text('Configurar cometa'), findsOneWidget);
    expect(find.text('Nueva equipacion'), findsOneWidget);
    expect(find.text('Estadisticas de uso de equipacion'), findsOneWidget);
  });

  testWidgets('messages tab shows direct conversations and search', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());
    await tester.tap(find.text('Mensajes'));
    await tester.pumpAndSettle();

    expect(find.text('Buscar'), findsOneWidget);
    expect(find.text('Juan Kitesurf'), findsOneWidget);
    expect(find.text('Marta Loop'), findsOneWidget);
  });

  testWidgets('direct conversation opens the real chat dialog', (tester) async {
    await tester.pumpWidget(buildPage());
    await tester.tap(find.text('Mensajes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Juan Kitesurf'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Cerrar chat'), findsOneWidget);
    expect(find.text('Escribe al chat del spot...'), findsOneWidget);
  });
}
