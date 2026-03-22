import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windwisher/features/auth/presentation/providers/recent_auth_accounts_provider.dart';

void main() {
  test('add email stores most recent first and deduplicates', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final actions = container.read(recentAuthAccountsActionsProvider);

    await actions.add('user@example.com');
    await actions.add('user@example.com');

    final list = await container.read(recentAuthEmailsProvider.future);
    expect(list.first, 'user@example.com');
    expect(list.length, 1);
  });
}
