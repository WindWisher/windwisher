import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windwisher/main.dart';

void main() {
  testWidgets('app no longer renders counter template', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AppBootstrap()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.text('You have pushed the button this many times:'),
      findsNothing,
    );
    expect(find.text('WindWisher'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
