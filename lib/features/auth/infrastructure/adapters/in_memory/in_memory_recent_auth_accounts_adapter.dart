import 'package:windwisher/features/auth/domain/ports/out/recent_auth_accounts_port.dart';

class InMemoryRecentAuthAccountsAdapter implements RecentAuthAccountsPort {
  final List<String> _emails = [];

  @override
  Future<List<String>> getRecentEmails() async {
    return List<String>.unmodifiable(_emails);
  }

  @override
  Future<void> add(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) {
      return;
    }

    final next = <String>[
      normalized,
      ..._emails.where((entry) => entry != normalized),
    ].take(10).toList(growable: false);

    _emails
      ..clear()
      ..addAll(next);
  }

  @override
  Future<void> remove(String email) async {
    final normalized = email.trim().toLowerCase();
    _emails.removeWhere((entry) => entry == normalized);
  }
}
