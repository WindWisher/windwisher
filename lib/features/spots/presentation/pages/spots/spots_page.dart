import 'dart:io';
import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/spots/di/spots_module.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/spot_detail_page.dart';

part 'available_spots_catalog.dart';
part 'add_spot_sheet.dart';
part 'custom_map_picker_dialog.dart';
part 'edit_spot_sheet.dart';
part 'spot_add_form_fields.dart';
part 'spot_add_header.dart';
part 'spot_add_status_messages.dart';
part 'spot_background_image_picker.dart';
part 'spot_suggestions_list.dart';
part 'spots_actions_controller.dart';
part 'spots_list_section.dart';

typedef _SpotItem = SpotItem;

class SpotsPage extends StatefulWidget {
  const SpotsPage({
    super.key,
    this.spotsModule,
    this.useLocalPersistence = EnvConfig.spotsLocalPersistenceEnabled,
  });

  final SpotsModule? spotsModule;
  final bool useLocalPersistence;

  @override
  State<SpotsPage> createState() => SpotsPageState();
}

class SpotsPageState extends State<SpotsPage> {
  static const double _nearbyWebcamThresholdKm = 8;
  late final SpotsModule _spotsModule;
  final List<_SpotItem> _spots = <_SpotItem>[];
  final _searchController = TextEditingController();
  _SpotFilter _filter = _SpotFilter.all;
  _SpotSort _sort = _SpotSort.recent;
  _PendingCardAction _pendingCardAction = _PendingCardAction.none;
  final Set<String> _selectedSpotNames = <String>{};
  String _searchQuery = '';
  StreamSubscription<AuthState>? _authStateSubscription;
  Set<String> _myRoles = const <String>{};

  @override
  void initState() {
    super.initState();
    _spotsModule =
        widget.spotsModule ??
        (widget.useLocalPersistence
            ? SpotsModule.auto()
            : SpotsModule.inMemory());
    _spots.addAll(_spotsModule.getSpots());
    _hydrateSpotsCatalog();
    unawaited(_loadMyRoles());
    _subscribeToAuthChanges();
  }

  void _subscribeToAuthChanges() {
    if (!EnvConfig.supabaseConfigured) {
      return;
    }
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange
        .listen((_) {
          unawaited(_loadMyRoles());
          unawaited(_hydrateSpotsCatalog());
        });
  }

  Future<void> _loadMyRoles() async {
    if (!EnvConfig.supabaseConfigured) {
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _myRoles = const <String>{};
      });
      return;
    }
    try {
      final rows = await Supabase.instance.client
          .from('user_roles')
          .select('role')
          .eq('user_id', user.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _myRoles = (rows as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((row) => (row['role'] as String? ?? '').trim())
            .where((role) => role.isNotEmpty)
            .toSet();
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _myRoles = const <String>{};
      });
    }
  }

  bool get _hasAdvancedSpotAccess {
    return _myRoles.any(
      (role) => const <String>{
        'pro',
        'vip',
        'moderator',
        'admin',
        'super_admin',
      }.contains(role),
    );
  }

  bool get _canCreateCustomSpots => _hasAdvancedSpotAccess;

  bool get _canEditOrDeleteSavedSpots => _hasAdvancedSpotAccess;

  int get _officialSpotCount => _spots.where((spot) => !spot.isCustom).length;

  Future<void> _hydrateSpotsCatalog() async {
    final spots = await _spotsModule.getSpots.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _spots
        ..clear()
        ..addAll(spots);
    });
  }

  Future<void> _refreshSpotsAfterSave(_SpotItem spot) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) {
      return;
    }
    await _hydrateSpotsCatalog();
  }

  List<_SpotItem> get _filteredSpots {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = _spots.where((spot) {
      final matchesQuery = query.isEmpty
          ? true
          : spot.name.toLowerCase().contains(query) ||
                spot.area.toLowerCase().contains(query);
      if (!matchesQuery) {
        return false;
      }

      switch (_filter) {
        case _SpotFilter.all:
          return true;
        case _SpotFilter.official:
          return !spot.isCustom;
        case _SpotFilter.custom:
          return spot.isCustom;
      }
    }).toList();

    filtered.sort((a, b) {
      switch (_sort) {
        case _SpotSort.recent:
          return b.createdAt.compareTo(a.createdAt);
        case _SpotSort.az:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _SpotSort.za:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      }
    });

    return filtered;
  }

  Future<void> _showAddSpotSheet() async {
    if (!_hasAdvancedSpotAccess && _officialSpotCount >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Como usuario normal solo puedes guardar 2 spots oficiales.',
          ),
        ),
      );
      return;
    }

    final existingNames = _spots
        .map((spot) => spot.name.trim().toLowerCase())
        .toSet();

    final result = await showModalBottomSheet<_SpotItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _AddSpotSheet(
        existingSpotNames: existingNames,
        allowCustomMode: _canCreateCustomSpots,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _spots.removeWhere(
        (spot) =>
            spot.name.trim().toLowerCase() == result.name.trim().toLowerCase(),
      );
      _spots.insert(0, result);
      _filter = _SpotFilter.all;
      _sort = _SpotSort.recent;
      _searchQuery = '';
      _searchController.clear();
      _spotsModule.saveSpot(result);
    });
    unawaited(_refreshSpotsAfterSave(result));
  }

  int _nearbyWebcamCount(_SpotItem spot) {
    final spotLat = spot.latitude;
    final spotLon = spot.longitude;
    if (spotLat == null || spotLon == null) {
      return 0;
    }
    final webcams = _spotsModule.getSpotWebcams(
      spotName: spot.name,
      isCustom: spot.isCustom,
    );
    var count = 0;
    for (final webcam in webcams) {
      final webcamLat = webcam.latitude;
      final webcamLon = webcam.longitude;
      if (webcamLat == null || webcamLon == null) {
        continue;
      }
      final distanceKm = _distanceKm(
        latitudeA: spotLat,
        longitudeA: spotLon,
        latitudeB: webcamLat,
        longitudeB: webcamLon,
      );
      if (distanceKm <= _nearbyWebcamThresholdKm) {
        count += 1;
      }
    }
    return count;
  }

  double _distanceKm({
    required double latitudeA,
    required double longitudeA,
    required double latitudeB,
    required double longitudeB,
  }) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(latitudeB - latitudeA);
    final dLon = _toRadians(longitudeB - longitudeA);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitudeA)) *
            math.cos(_toRadians(latitudeB)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double value) => value * (math.pi / 180);

  void _setFilter(_SpotFilter value) {
    setState(() {
      _filter = value;
    });
  }

  void _setSearchQuery(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearchQuery() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _setSort(_SpotSort value) {
    setState(() {
      _sort = value;
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        ScrollConfiguration(
          behavior: const _VerticalBounceNoStretchBehavior(),
          child: ListView(
            physics: kAppBouncingScrollPhysics,
            padding: const EdgeInsets.all(AppSpacing.md),
            children: _buildSpotsListSection(textTheme),
          ),
        ),
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.lg,
          child: FloatingActionButton(
            onPressed: _showAddSpotSheet,
            tooltip: 'Agregar spot',
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _VerticalBounceNoStretchBehavior extends AppScrollBehavior {
  const _VerticalBounceNoStretchBehavior();
}

enum _PendingCardAction { none, edit, deleteMany }

enum _SpotFilter { all, official, custom }

enum _SpotSort { recent, az, za }
