import 'package:windwisher/core/config/env/local_env_store.dart';

abstract final class EnvConfig {
  static const googleAuthEnabled = false;
  static const appleAuthEnabled = false;
  static const devBypassEnabled = false;
  static const profileLocalPersistenceEnabled = true;
  static const communityLocalPersistenceEnabled = true;
  static const sessionsLocalPersistenceEnabled = true;
  static const spotsLocalPersistenceEnabled = true;

  static String get aemetOpenDataApiKey {
    final localValue = LocalEnvStore.aemetOpenDataApiKey;
    if (localValue.isNotEmpty) {
      return localValue;
    }
    return const String.fromEnvironment(
      'AEMET_OPENDATA_API_KEY',
      defaultValue: '',
    );
  }

  static String get meteoblueApiKey {
    final localValue = LocalEnvStore.meteoblueApiKey;
    if (localValue.isNotEmpty) {
      return localValue;
    }
    return const String.fromEnvironment('METEOBLUE_API_KEY', defaultValue: '');
  }

  static String get meteosourceApiKey {
    final localValue = LocalEnvStore.meteosourceApiKey;
    if (localValue.isNotEmpty) {
      return localValue;
    }
    return const String.fromEnvironment(
      'METEOSOURCE_API_KEY',
      defaultValue: '',
    );
  }

  static String get meteostatRapidApiKey {
    final localValue = LocalEnvStore.meteostatRapidApiKey;
    if (localValue.isNotEmpty) {
      return localValue;
    }
    return const String.fromEnvironment(
      'METEOSTAT_RAPIDAPI_KEY',
      defaultValue: '',
    );
  }

  static String get meteostatRapidApiHost {
    final localValue = LocalEnvStore.meteostatRapidApiHost;
    if (localValue.isNotEmpty) {
      return localValue;
    }
    return const String.fromEnvironment(
      'METEOSTAT_RAPIDAPI_HOST',
      defaultValue: 'meteostat.p.rapidapi.com',
    );
  }

  static String get supabaseUrl {
    final localValue = LocalEnvStore.supabaseUrl;
    if (localValue.isNotEmpty) {
      return localValue;
    }
    return const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  }

  static String get supabaseAnonKey {
    final localValue = LocalEnvStore.supabaseAnonKey;
    if (localValue.isNotEmpty) {
      return localValue;
    }
    return const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  }

  static bool get supabaseConfigured {
    return supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
  }

  static bool get aemetAccessConfigured {
    return aemetOpenDataApiKey.trim().isNotEmpty || supabaseConfigured;
  }

  static bool get meteoblueAccessConfigured {
    return meteoblueApiKey.trim().isNotEmpty || supabaseConfigured;
  }

  static bool get meteosourceAccessConfigured {
    return meteosourceApiKey.trim().isNotEmpty || supabaseConfigured;
  }

  static bool get meteostatAccessConfigured {
    return meteostatRapidApiKey.trim().isNotEmpty || supabaseConfigured;
  }
}
