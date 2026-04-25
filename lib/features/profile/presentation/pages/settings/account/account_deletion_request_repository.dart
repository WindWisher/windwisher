import 'package:supabase_flutter/supabase_flutter.dart';

class AccountDeletionRequestRepository {
  const AccountDeletionRequestRepository._();

  static SupabaseClient get _client => Supabase.instance.client;

  static String? get currentUserId => _client.auth.currentUser?.id;

  static Future<Map<String, dynamic>?> fetchLatestScheduledRequest() async {
    final userId = currentUserId;
    if (userId == null) {
      return null;
    }

    return await _client
        .from('account_deletion_requests')
        .select('id,status,created_at,updated_at,confirmed_at,execute_after')
        .eq('user_id', userId)
        .eq('status', 'scheduled')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  static Future<void> scheduleDeletion({
    required String confirmationNote,
    Duration gracePeriod = const Duration(days: 7),
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw const AuthException('No session');
    }

    final now = DateTime.now().toUtc();
    final executeAfter = now.add(gracePeriod);

    await _client.from('account_deletion_requests').insert({
      'user_id': userId,
      'note': confirmationNote,
      'status': 'scheduled',
      'confirmed_at': now.toIso8601String(),
      'execute_after': executeAfter.toIso8601String(),
    });
  }

  static Future<void> cancelRequest(String requestId) async {
    await _client
        .from('account_deletion_requests')
        .update({'status': 'cancelled'})
        .eq('id', requestId);
  }
}
