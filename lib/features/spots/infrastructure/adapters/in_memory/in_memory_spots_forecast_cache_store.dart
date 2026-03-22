import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/local/local_file_spots_forecast_cache_store.dart';

class InMemorySpotsForecastCacheStore implements SpotsForecastCacheStore {
  final Map<String, ({DateTime createdAt, List<SpotForecastEntry> entries})>
  _entries =
      <String, ({DateTime createdAt, List<SpotForecastEntry> entries})>{};

  @override
  List<SpotForecastEntry>? read({
    required String key,
    required Duration maxAge,
  }) {
    final snapshot = _entries[key];
    if (snapshot == null) {
      return null;
    }
    if (DateTime.now().difference(snapshot.createdAt) > maxAge) {
      _entries.remove(key);
      return null;
    }
    return List<SpotForecastEntry>.from(snapshot.entries);
  }

  @override
  void write({required String key, required List<SpotForecastEntry> entries}) {
    _entries[key] = (
      createdAt: DateTime.now(),
      entries: List<SpotForecastEntry>.from(entries),
    );
  }
}
