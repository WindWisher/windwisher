import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/units/app_units_remote_store.dart';

class SupabaseAppUnitsRemoteStore implements AppUnitsRemoteStore {
  SupabaseAppUnitsRemoteStore(this._client);

  static const _table = 'user_unit_preferences';

  final SupabaseClient _client;

  @override
  Future<Map<String, String>?> load(String userId) async {
    _ensureCurrentUser(userId);
    final row = await _client
        .from(_table)
        .select('wind_speed_unit, distance_unit, temperature_unit, height_unit')
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return <String, String>{
      'wind_speed_unit': row['wind_speed_unit'] as String,
      'distance_unit': row['distance_unit'] as String,
      'temperature_unit': row['temperature_unit'] as String,
      'height_unit': row['height_unit'] as String,
    };
  }

  @override
  Future<void> save(String userId, Map<String, String> values) async {
    _ensureCurrentUser(userId);
    await _client.from(_table).upsert(<String, dynamic>{
      'user_id': userId,
      ...values,
    }, onConflict: 'user_id');
  }

  void _ensureCurrentUser(String userId) {
    if (_client.auth.currentUser?.id != userId) {
      throw StateError('Unit preferences can only access the current user.');
    }
  }
}
