import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/config/env/env_config.dart';

SupabaseClient? resolveInitializedSupabaseClient([SupabaseClient? client]) {
  if (client != null) {
    return client;
  }
  if (!EnvConfig.supabaseConfigured) {
    return null;
  }
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}
