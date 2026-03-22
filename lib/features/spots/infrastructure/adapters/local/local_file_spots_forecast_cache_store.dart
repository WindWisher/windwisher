import 'dart:convert';
import 'dart:io';

import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';

abstract class SpotsForecastCacheStore {
  List<SpotForecastEntry>? read({
    required String key,
    required Duration maxAge,
  });

  void write({required String key, required List<SpotForecastEntry> entries});
}

class LocalFileSpotsForecastCacheStore implements SpotsForecastCacheStore {
  LocalFileSpotsForecastCacheStore({
    String fileName = 'spots_forecast_cache_v1.json',
  }) : _file = File(AppStoragePaths.resolve(fileName));

  final File _file;

  @override
  List<SpotForecastEntry>? read({
    required String key,
    required Duration maxAge,
  }) {
    final data = _load();
    final rawEntries = data['entries'];
    if (rawEntries is! Map<String, dynamic>) {
      return null;
    }

    final rawCache = rawEntries[key];
    if (rawCache is! Map<String, dynamic>) {
      return null;
    }

    final createdAtRaw = rawCache['createdAt']?.toString();
    final createdAt = createdAtRaw == null
        ? null
        : DateTime.tryParse(createdAtRaw);
    if (createdAt == null || DateTime.now().difference(createdAt) > maxAge) {
      return null;
    }

    final items = rawCache['entries'];
    if (items is! List) {
      return null;
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(SpotForecastEntry.fromJson)
        .toList(growable: false);
  }

  @override
  void write({required String key, required List<SpotForecastEntry> entries}) {
    final data = _load();
    final rawEntries =
        (data['entries'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    rawEntries[key] = <String, dynamic>{
      'createdAt': DateTime.now().toIso8601String(),
      'entries': entries.map((entry) => entry.toJson()).toList(growable: false),
    };
    data['entries'] = rawEntries;
    _save(data);
  }

  Map<String, dynamic> _load() {
    if (!_file.existsSync()) {
      return <String, dynamic>{'entries': <String, dynamic>{}};
    }
    try {
      final raw = _file.readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Ignore malformed cache file and rebuild it on next write.
    }
    return <String, dynamic>{'entries': <String, dynamic>{}};
  }

  void _save(Map<String, dynamic> data) {
    _file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }
}
