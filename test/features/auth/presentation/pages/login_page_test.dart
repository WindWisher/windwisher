import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/core/i18n/app_strings.dart';
import 'package:windwisher/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('login page shows current access flow', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('es'),
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: [
            ...AppStrings.localizationsDelegates,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: LoginPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('WindWisher'), findsOneWidget);
    expect(find.text('Correo'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('The full kiteboarding experience.'), findsOneWidget);
    expect(find.text('No tienes cuenta? Crear cuenta'), findsOneWidget);
    expect(find.text('Entrar con magic link'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Contrasena'), findsOneWidget);
    expect(find.text('Google no disponible'), findsOneWidget);
    expect(find.text('Apple no disponible'), findsOneWidget);
    expect(find.text('Entrar con bypass'), findsOneWidget);
  });
}
