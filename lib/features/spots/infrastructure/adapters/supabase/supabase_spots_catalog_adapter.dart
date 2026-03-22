import 'dart:async';

import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_catalog_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSpotsCatalogAdapter implements SpotsCatalogPort {
  SupabaseSpotsCatalogAdapter({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  static final List<SpotItem> _spots = <SpotItem>[];

  final SupabaseClient _client;

  @override
  List<SpotItem> getSpots() {
    return List<SpotItem>.unmodifiable(_spots);
  }

  @override
  Future<List<SpotItem>> hydrateSpots() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _spots.clear();
      return getSpots();
    }

    final rows = await _client
        .from('user_saved_spots')
        .select(
          'custom_name, area, is_custom, latitude, longitude, aemet_municipality_code, aemet_beach_code, aemet_beach_codes, background_image_path, created_at',
        )
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    final remoteSpots = (rows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(_mapRow)
        .toList(growable: false);
    final mergedByName = <String, SpotItem>{
      for (final spot in remoteSpots) spot.name.trim().toLowerCase(): spot,
    };
    for (final spot in _spots) {
      mergedByName.putIfAbsent(spot.name.trim().toLowerCase(), () => spot);
    }

    final mergedSpots = mergedByName.values.toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _spots
      ..clear()
      ..addAll(mergedSpots);
    return getSpots();
  }

  @override
  void saveSpot(SpotItem spot) {
    final index = _spots.indexWhere(
      (entry) =>
          entry.name.trim().toLowerCase() == spot.name.trim().toLowerCase(),
    );
    if (index >= 0) {
      _spots[index] = spot;
    } else {
      _spots.insert(0, spot);
    }
    unawaited(_saveRemote(spot));
  }

  @override
  void deleteSpotByName(String name) {
    final normalized = name.trim().toLowerCase();
    _spots.removeWhere(
      (entry) => entry.name.trim().toLowerCase() == normalized,
    );
    unawaited(_deleteRemote(name));
  }

  Future<void> _saveRemote(SpotItem spot) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client
        .from('user_saved_spots')
        .delete()
        .eq('user_id', user.id)
        .eq('custom_name', spot.name);
    await _client.from('user_saved_spots').insert(<String, dynamic>{
      'user_id': user.id,
      'custom_name': spot.name,
      'area': spot.area,
      'is_custom': spot.isCustom,
      'latitude': spot.latitude,
      'longitude': spot.longitude,
      'aemet_municipality_code': spot.aemetMunicipalityCode,
      'aemet_beach_code': spot.aemetBeachCode,
      'aemet_beach_codes': spot.resolvedAemetBeachCodes,
      'background_image_path': spot.backgroundImagePath,
      'created_at': spot.createdAt.toUtc().toIso8601String(),
    });
  }

  Future<void> _deleteRemote(String name) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client
        .from('user_saved_spots')
        .delete()
        .eq('user_id', user.id)
        .eq('custom_name', name);
  }

  SpotItem _mapRow(Map<String, dynamic> row) {
    final rawBeachCodes = row['aemet_beach_codes'];
    final beachCodes = rawBeachCodes is List
        ? rawBeachCodes.whereType<String>().toList(growable: false)
        : const <String>[];
    return SpotItem(
      name: (row['custom_name'] as String?) ?? '',
      area: (row['area'] as String?) ?? '',
      isCustom: (row['is_custom'] as bool?) ?? false,
      createdAt:
          DateTime.tryParse((row['created_at'] as String?) ?? '')?.toLocal() ??
          DateTime.now(),
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      aemetMunicipalityCode: row['aemet_municipality_code'] as String?,
      aemetBeachCode: row['aemet_beach_code'] as String?,
      aemetBeachCodes: beachCodes,
      backgroundImagePath: row['background_image_path'] as String?,
    );
  }
}
