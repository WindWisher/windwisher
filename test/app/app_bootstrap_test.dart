import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windwisher/main.dart';

void main() {
  testWidgets('app starts on login route when there is no session', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: AppBootstrap()));
    await tester.pumpAndSettle();

    expect(find.text('WindWisher'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
