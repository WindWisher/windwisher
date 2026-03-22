import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windwisher/features/auth/presentation/providers/auth_session_provider.dart';

void main() {
  test('signInWithEmail returns error when email is empty', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(authSessionProvider.notifier);
    final error = await notifier.signInWithEmail('');

    expect(error, isNotNull);
  });
}
