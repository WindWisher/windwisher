import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/config/env/env_config.dart';

class PushNotificationSubscriptionSyncClient {
  PushNotificationSubscriptionSyncClient._({
    required SupabaseClient? client,
    required bool useSupabase,
  }) : _client = client,
       _useSupabase = useSupabase;

  factory PushNotificationSubscriptionSyncClient.auto({SupabaseClient? client}) {
    final hasSupabase =
        EnvConfig.supabaseUrl.trim().isNotEmpty &&
        EnvConfig.supabaseAnonKey.trim().isNotEmpty;
    return PushNotificationSubscriptionSyncClient._(
      client: hasSupabase ? (client ?? Supabase.instance.client) : null,
      useSupabase: hasSupabase,
    );
  }

  final SupabaseClient? _client;
  final bool _useSupabase;

  bool get canSync => _useSupabase && _client?.auth.currentUser != null;

  String? get _currentUserId => _client?.auth.currentUser?.id;

  Future<void> upsertSubscription({
    required String deviceToken,
    required String platform,
    required String provider,
    String? deviceLabel,
    bool enabled = true,
  }) async {
    final userId = _currentUserId;
    if (!canSync || _client == null || userId == null || deviceToken.trim().isEmpty) {
      return;
    }
    await _client.from('user_push_subscriptions').upsert(
      <String, dynamic>{
        'user_id': userId,
        'device_token': deviceToken.trim(),
        'platform': platform.trim(),
        'provider': provider.trim(),
        'enabled': enabled,
        'device_label': deviceLabel?.trim(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,device_token',
    );
  }

  Future<void> setSubscriptionEnabled({
    required String deviceToken,
    required bool enabled,
  }) async {
    final userId = _currentUserId;
    if (!canSync || _client == null || userId == null || deviceToken.trim().isEmpty) {
      return;
    }
    await _client
        .from('user_push_subscriptions')
        .update(<String, dynamic>{
          'enabled': enabled,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('device_token', deviceToken.trim());
  }

  Future<void> deleteSubscription(String deviceToken) async {
    final userId = _currentUserId;
    if (!canSync || _client == null || userId == null || deviceToken.trim().isEmpty) {
      return;
    }
    await _client
        .from('user_push_subscriptions')
        .delete()
        .eq('user_id', userId)
        .eq('device_token', deviceToken.trim());
  }
}
