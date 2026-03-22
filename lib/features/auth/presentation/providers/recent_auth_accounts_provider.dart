import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windwisher/features/auth/presentation/providers/auth_di_providers.dart';

final recentAuthEmailsProvider = FutureProvider<List<String>>((ref) async {
  final module = ref.watch(authModuleProvider);
  return module.getRecentAuthEmails();
});

final recentAuthAccountsActionsProvider = Provider<RecentAuthAccountsActions>(
  (ref) => RecentAuthAccountsActions(ref),
);

class RecentAuthAccountsActions {
  RecentAuthAccountsActions(this._ref);

  final Ref _ref;

  Future<void> add(String email) async {
    final module = _ref.read(authModuleProvider);
    await module.addRecentAuthEmail(email);
    _ref.invalidate(recentAuthEmailsProvider);
  }

  Future<void> remove(String email) async {
    final module = _ref.read(authModuleProvider);
    await module.removeRecentAuthEmail(email);
    _ref.invalidate(recentAuthEmailsProvider);
  }
}
