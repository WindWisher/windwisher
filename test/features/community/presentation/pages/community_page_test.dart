import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/community/presentation/pages/community_page.dart';
import 'package:windwisher/features/community/presentation/pages/community_user_profile_page.dart';
import 'package:windwisher/features/community/presentation/pages/community_user_sessions_page.dart';

Future<void> _openAirLucasFeed(WidgetTester tester) async {
  await tester.tap(find.text('Amigos'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Explorar'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'air_lucas');
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(TextButton, 'Seguir').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Feed'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('community shows leaderboard and following segments', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('Amigos'), findsOneWidget);
    expect(find.text('Salto mas alto (m)'), findsOneWidget);
  });

  testWidgets('leaderboard shows synced profile identity card', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    expect(
      find.byKey(const ValueKey<String>('community_leaderboard_identity_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('community_leaderboard_identity_banner'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('community_leaderboard_identity_display_name'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('leaderboard header changes with selected metric', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    await tester.tap(find.text('Mostrar filtros'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salto mas alto (m)').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Big Air score (pts)').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aplicar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Big Air score (pts)'), findsWidgets);
  });

  testWidgets('leaderboard filters are visible', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    await tester.tap(find.text('Mostrar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Periodo'), findsNothing);
    expect(find.text('Spot'), findsWidgets);
    expect(find.text('Scope'), findsWidgets);
    expect(find.text('Orden'), findsWidgets);
    expect(find.text('Aplicar filtros'), findsOneWidget);
  });

  testWidgets('amigos shows social tabs and feed actions', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    await tester.tap(find.text('Amigos'));
    await tester.pumpAndSettle();

    expect(find.text('Tu red'), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Siguiendo'), findsOneWidget);
    expect(find.text('Seguidores'), findsOneWidget);
    expect(find.text('Explorar'), findsOneWidget);

    expect(find.textContaining('Todavia no sigues a nadie'), findsOneWidget);
  });

  testWidgets('amigos explore lets follow and appears in siguiendo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    await tester.tap(find.text('Amigos'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explorar'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'sofi_wind');
    await tester.pumpAndSettle();

    expect(find.textContaining('@sofi_wind'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Seguir').first);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextButton, 'Siguiendo'), findsWidgets);
    await tester.tap(find.text('Siguiendo').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'sofi_wind');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextButton, 'Siguiendo'), findsWidgets);
  });

  testWidgets('amigos explore search works by display name', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    await tester.tap(find.text('Amigos'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explorar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'sofi wind');
    await tester.pumpAndSettle();

    expect(find.text('Sofi Wind · @sofi_wind'), findsOneWidget);
  });

  testWidgets('amigos feed exposes like controls', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    await _openAirLucasFeed(tester);

    expect(find.text('184 likes'), findsOneWidget);
    const firstSessionLikeKey = ValueKey<String>(
      'session_like_sess-air-lucas-20260223-1840',
    );
    final likeButtonFinder = find.byKey(firstSessionLikeKey);
    expect(likeButtonFinder, findsOneWidget);
  });

  testWidgets('amigos feed exposes comments controls', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    await _openAirLucasFeed(tester);

    expect(find.text('0 comentarios'), findsWidgets);

    final commentButtonFinder = find.byKey(
      const ValueKey<String>('session_comment_sess-air-lucas-20260223-1840'),
    );
    expect(commentButtonFinder, findsOneWidget);
  });

  testWidgets('comments modal shows unified identity label after posting', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    await _openAirLucasFeed(tester);

    final commentButton = find.byKey(
      const ValueKey<String>('session_comment_sess-air-lucas-20260223-1840'),
    );
    final buttonWidget = tester.widget<IconButton>(commentButton);
    buttonWidget.onPressed?.call();
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'Comentario de prueba',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Publicar'));
    await tester.pumpAndSettle();

    expect(find.text('Rider Kitesurf · @rider_ks'), findsOneWidget);
  });

  testWidgets('community actions navigate to placeholders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    await tester.tap(find.text('@air_lucas').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver perfil').first);
    await tester.pumpAndSettle();
    expect(find.text('Perfil de usuario'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('@air_lucas').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver sesiones').first);
    await tester.pumpAndSettle();
    expect(find.text('Sesiones de usuario'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('leaderboard actions modal shows unified user identity', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    await tester.tap(find.text('@air_lucas').first);
    await tester.pumpAndSettle();

    expect(find.text('Air Lucas · @air_lucas'), findsOneWidget);
    expect(find.text('Acciones de usuario'), findsOneWidget);
  });

  testWidgets('amigos session card exposes view session button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    await _openAirLucasFeed(tester);

    final viewSessionFinder = find.byKey(
      const ValueKey<String>('session_view_sess-air-lucas-20260223-1840'),
    );
    expect(viewSessionFinder, findsOneWidget);
  });

  testWidgets('community session detail shows contextual summary block', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    await _openAirLucasFeed(tester);

    final viewButton = find.byKey(
      const ValueKey<String>('session_view_sess-air-lucas-20260223-1840'),
    );
    final viewButtonWidget = tester.widget<OutlinedButton>(viewButton);
    viewButtonWidget.onPressed?.call();
    await tester.pumpAndSettle();

    expect(find.text('Detalle de sesión'), findsOneWidget);
    expect(find.text('Sesion sunset en Tarifa'), findsOneWidget);
    expect(find.text('Resumen post-sesion'), findsOneWidget);
  });

  testWidgets('amigos session card tap no longer opens detail', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );

    await _openAirLucasFeed(tester);

    final sessionPhotoFinder = find.text('Foto de la sesion').first;
    await tester.ensureVisible(sessionPhotoFinder);
    await tester.tap(sessionPhotoFinder);
    await tester.pumpAndSettle();

    expect(find.text('Detalle de sesion'), findsNothing);
  });

  testWidgets('community layout remains stable on narrow screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: CommunityPage(useLocalPersistence: false)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Amigos'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('user sessions page shows synced identity header', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CommunityUserSessionsPage(
          username: 'rider_ks',
          useLocalPersistence: false,
        ),
      ),
    );

    expect(find.text('Sesiones de usuario'), findsOneWidget);
    expect(find.text('Rider Kitesurf'), findsOneWidget);
    expect(find.text('@rider_ks'), findsOneWidget);
  });

  testWidgets('user profile and sessions use shared identity for third user', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CommunityUserProfilePage(
          username: 'sofi_wind',
          useLocalPersistence: false,
        ),
      ),
    );

    expect(find.text('Sofi Wind'), findsOneWidget);
    expect(find.text('@sofi_wind'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: CommunityUserSessionsPage(
          username: 'sofi_wind',
          useLocalPersistence: false,
        ),
      ),
    );

    expect(find.text('Sofi Wind'), findsOneWidget);
    expect(find.text('@sofi_wind'), findsOneWidget);
  });

  testWidgets(
    'following selection persists across page instances in local mode',
    (tester) async {
      final file = File(
        AppStoragePaths.resolve('community_social_state_v1.json'),
      );
      if (file.existsSync()) {
        file.deleteSync();
      }

      await tester.pumpWidget(
        const MaterialApp(home: CommunityPage(useLocalPersistence: true)),
      );

      await tester.tap(find.text('Amigos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Explorar'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'sofi_wind');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Seguir').first);
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        const MaterialApp(home: CommunityPage(useLocalPersistence: true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Amigos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiendo').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'sofi_wind');
      await tester.pumpAndSettle();

      expect(find.text('Sofi Wind · @sofi_wind'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Siguiendo'), findsWidgets);

      if (file.existsSync()) {
        file.deleteSync();
      }
    },
  );
}
