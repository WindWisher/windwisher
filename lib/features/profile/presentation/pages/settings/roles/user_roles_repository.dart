import 'package:supabase_flutter/supabase_flutter.dart';

class UserRolesRepository {
  const UserRolesRepository._();

  static Future<Set<String>> fetchCurrentUserRoles() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      return const <String>{};
    }

    final rows = await client.rpc('current_user_roles');

    return (rows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((row) => (row['role'] as String? ?? '').trim())
        .where((role) => role.isNotEmpty)
        .toSet();
  }
}
