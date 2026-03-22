import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windwisher/main.dart';

void main() {
  testWidgets('app no longer renders counter template', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AppBootstrap()));
    await tester.pumpAndSettle();

    expect(
      find.text('You have pushed the button this many times:'),
      findsNothing,
    );
    expect(find.text('MeteoKite'), findsOneWidget);
    expect(find.text('Spots'), findsWidgets);
  });
}
