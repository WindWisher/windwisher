import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/account/account_session_summary.dart';

class AccountSessionRepository {
  const AccountSessionRepository._();

  static AccountSessionSummary currentSummary() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    return AccountSessionSummary(
      email: currentUser?.email?.trim(),
      provider: currentUser?.appMetadata['provider'] as String?,
    );
  }
}
