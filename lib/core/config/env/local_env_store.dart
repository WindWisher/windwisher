import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract final class LocalEnvStore {
  static Map<String, dynamic> _values = const <String, dynamic>{};
  static const _assetPath = 'local.env.json';

  static Future<void> initialize() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _values = decoded;
        return;
      }
    } catch (_) {
      // Try filesystem fallback for local development.
    }

    if (kIsWeb) {
      _values = const <String, dynamic>{};
      return;
    }

    try {
      final file = File('local.env.json');
      if (await file.exists()) {
        final raw = await file.readAsString();
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _values = decoded;
          return;
        }
      }
    } catch (_) {
      // Ignore missing/malformed local env file and keep defaults.
    }

    _values = const <String, dynamic>{};
  }

  static String get aemetOpenDataApiKey {
    final value = _values['AEMET_OPENDATA_API_KEY'];
    return value is String ? value : '';
  }

  static String get meteoblueApiKey {
    final value = _values['METEOBLUE_API_KEY'];
    return value is String ? value : '';
  }

  static String get meteosourceApiKey {
    final value = _values['METEOSOURCE_API_KEY'];
    return value is String ? value : '';
  }

  static String get meteostatRapidApiKey {
    final value = _values['METEOSTAT_RAPIDAPI_KEY'];
    return value is String ? value : '';
  }

  static String get meteostatRapidApiHost {
    final value = _values['METEOSTAT_RAPIDAPI_HOST'];
    return value is String ? value : '';
  }

  static String get supabaseUrl {
    final value = _values['SUPABASE_URL'];
    return value is String ? value : '';
  }

  static String get supabaseAnonKey {
    final value = _values['SUPABASE_ANON_KEY'];
    return value is String ? value : '';
  }
}
