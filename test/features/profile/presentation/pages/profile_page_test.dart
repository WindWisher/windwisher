import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/profile_page.dart';

void main() {
  testWidgets('profile shows three tabs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Mi equipo'), findsOneWidget);
    expect(find.text('Mensajes'), findsOneWidget);
  });

  testWidgets('perfil tab shows user info', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    expect(find.text('Rider Kitesurf'), findsOneWidget);
    expect(find.text('@rider_ks'), findsOneWidget);
    expect(find.text('Estadisticas'), findsOneWidget);
    expect(find.text('Detalles'), findsOneWidget);
  });

  testWidgets('perfil stats details opens KPI screen', (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    final detailsButton = find.widgetWithText(OutlinedButton, 'Detalles');
    await tester.ensureVisible(detailsButton);
    await tester.tap(detailsButton);
    await tester.pumpAndSettle();

    expect(find.text('KPIs del perfil'), findsOneWidget);
    expect(find.text('Rendimiento y contexto'), findsOneWidget);
  });

  testWidgets('perfil tab opens public profile preview', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    await tester.tap(find.text('Vista publica'));
    await tester.pumpAndSettle();

    expect(find.text('Vista publica'), findsOneWidget);
    expect(find.text('Actividad publica reciente'), findsOneWidget);
  });

  testWidgets('perfil tab opens edit profile screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    await tester.tap(find.text('Editar perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
  });

  testWidgets('mi equipo tab shows quiver form', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    await tester.tap(find.text('Mi equipo'));
    await tester.pumpAndSettle();

    expect(find.text('Configurar quiver'), findsOneWidget);
    expect(find.text('Configurar cometa'), findsOneWidget);
    expect(find.text('Configurar equipacion'), findsOneWidget);
  });

  testWidgets('mensajes tab shows direct manager and global search', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    await tester.tap(find.text('Mensajes'));
    await tester.pumpAndSettle();

    expect(find.text('Directos'), findsOneWidget);
    expect(find.text('Buscar en app'), findsOneWidget);
    expect(find.text('Gestor de mensajes directos'), findsOneWidget);

    await tester.tap(find.text('Buscar en app'));
    await tester.pumpAndSettle();

    expect(find.text('Buscador de mis mensajes en la app'), findsOneWidget);
    expect(find.text('Ver comentario'), findsWidgets);
  });

  testWidgets('search card opens indexed comment detail page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    await tester.tap(find.text('Mensajes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buscar en app'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver comentario').first);
    await tester.pumpAndSettle();

    expect(find.text('Comentario'), findsOneWidget);
  });

  testWidgets('comment detail opens full thread view', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    await tester.tap(find.text('Mensajes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buscar en app'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver comentario').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ir al hilo'));
    await tester.pumpAndSettle();

    expect(find.text('Hilo completo'), findsOneWidget);
    expect(find.text('Original'), findsOneWidget);
  });

  testWidgets('direct messages manager opens direct chat screen', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    await tester.tap(find.text('Mensajes'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded).first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Chat con '), findsOneWidget);
    expect(find.text('Escribe un mensaje...'), findsOneWidget);
  });

  testWidgets('direct chat app bar shows edit and multi-delete options', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    await tester.tap(find.text('Mensajes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();

    expect(find.text('Editar mensaje'), findsOneWidget);
    expect(find.text('Eliminar mensaje'), findsOneWidget);
  });

  testWidgets('mi equipo allows saving products and one gear setup', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    await tester.tap(find.text('Mi equipo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Configurar cometa'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Marca cometa'),
      'Duotone',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Modelo cometa'),
      'Evo',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Tamano cometa (m)'),
      '12',
    );
    await tester.tap(find.text('Guardar cometa'));
    await tester.pumpAndSettle();
    expect(find.text('Cometas guardadas (1)'), findsOneWidget);

    await tester.tap(find.text('Barra').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurar barra'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Marca barra'),
      'North',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Modelo barra'),
      'Navigator',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Longitud lineas (m)'),
      '22',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Ancho barra (cm)'),
      '50',
    );
    await tester.tap(find.text('Guardar barra'));
    await tester.pumpAndSettle();
    expect(find.text('Barras guardadas (1)'), findsOneWidget);

    await tester.tap(find.text('Tabla').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurar tabla'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Marca tabla'),
      'Cabrinha',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Modelo tabla'),
      'Spectrum',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Tamano tabla (cm)'),
      '136',
    );
    await tester.tap(find.text('Guardar tabla'));
    await tester.pumpAndSettle();
    expect(find.text('Tablas guardadas (1)'), findsOneWidget);

    await tester.tap(find.text('Arnes').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurar arnes'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Marca arnes'),
      'Ride Engine',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Modelo arnes'),
      'Elite',
    );
    await tester.tap(find.text('Guardar arnes'));
    await tester.pumpAndSettle();
    expect(find.text('Arneses guardados (1)'), findsOneWidget);

    await tester.tap(find.text('Traje').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurar traje'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Marca traje'),
      'O\'Neill',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Modelo traje'),
      'Psycho',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Grosor traje (mm)'),
      '4/3',
    );
    await tester.tap(find.text('Guardar traje'));
    await tester.pumpAndSettle();
    expect(find.text('Trajes guardados (1)'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Configurar equipacion'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.tap(find.text('Configurar equipacion'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre de equipacion'),
      'Big Air 30kt',
    );

    await tester.tap(find.text('Guardar equipacion'));
    await tester.pumpAndSettle();

    expect(find.text('Big Air 30kt'), findsOneWidget);
  });
}
