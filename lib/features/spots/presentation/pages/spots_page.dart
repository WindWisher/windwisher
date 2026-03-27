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
import 'package:windwisher/features/spots/presentation/pages/spot_detail_page.dart';

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
        (spot) => spot.name.trim().toLowerCase() == result.name.trim().toLowerCase(),
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

  bool _canRenderLocalImage(String? path) {
    return !kIsWeb && path != null && path.isNotEmpty;
  }

  Future<void> _showEditSpotSheet(_SpotItem spot) async {
    if (!_canEditOrDeleteSavedSpots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu plan actual no permite editar spots guardados'),
        ),
      );
      return;
    }

    final imagePicker = ImagePicker();
    final nameController = TextEditingController(text: spot.name);
    final areaController = TextEditingController(text: spot.area);
    String? backgroundImagePath = spot.backgroundImagePath;

    final edited = await showModalBottomSheet<_SpotItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final inset = MediaQuery.viewInsetsOf(context).bottom;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md + inset,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editar spot',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await imagePicker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 2200,
                          );
                          if (!mounted || picked == null) {
                            return;
                          }
                          setDialogState(() {
                            backgroundImagePath = picked.path;
                          });
                        },
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Galeria'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await imagePicker.pickImage(
                            source: ImageSource.camera,
                            maxWidth: 2200,
                          );
                          if (!mounted || picked == null) {
                            return;
                          }
                          setDialogState(() {
                            backgroundImagePath = picked.path;
                          });
                        },
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Camara'),
                      ),
                    ],
                  ),
                  if (_canRenderLocalImage(backgroundImagePath)) ...[
                    const SizedBox(height: AppSpacing.xs),
                    SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(backgroundImagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                tooltip: 'Eliminar foto',
                                icon: const Icon(Icons.close_rounded, size: 18),
                                color: Colors.white,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                                onPressed: () async {
                                  final shouldRemove = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Quitar foto'),
                                        content: const Text(
                                          'Quieres eliminar la foto seleccionada?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(false),
                                            child: const Text('Cancelar'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (!mounted || shouldRemove != true) {
                                    return;
                                  }
                                  setDialogState(() {
                                    backgroundImagePath = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  TextField(
                    controller: nameController,
                    enabled: spot.isCustom,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del spot',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: areaController,
                    enabled: spot.isCustom,
                    decoration: const InputDecoration(
                      labelText: 'Zona / provincia',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final nextName = nameController.text.trim();
                        final nextArea = areaController.text.trim();
                        if (nextName.isEmpty) {
                          return;
                        }
                        Navigator.of(context).pop(
                          _SpotItem(
                            name: spot.isCustom ? nextName : spot.name,
                            area: spot.isCustom
                                ? (nextArea.isEmpty
                                      ? 'Sin zona definida'
                                      : nextArea)
                                : spot.area,
                            isCustom: spot.isCustom,
                            createdAt: spot.createdAt,
                            latitude: spot.latitude,
                            longitude: spot.longitude,
                            aemetMunicipalityCode: spot.aemetMunicipalityCode,
                            aemetBeachCode: spot.aemetBeachCode,
                            aemetBeachCodes: spot.aemetBeachCodes,
                            backgroundImagePath: backgroundImagePath,
                          ),
                        );
                      },
                      child: const Text('Guardar cambios'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!mounted || edited == null) {
      return;
    }

    final duplicated = _spots.any(
      (entry) =>
          entry != spot &&
          entry.name.trim().toLowerCase() == edited.name.trim().toLowerCase(),
    );
    if (duplicated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ese spot ya esta agregado')),
      );
      return;
    }

    setState(() {
      final index = _spots.indexOf(spot);
      if (index != -1) {
        _spots[index] = edited;
        _spotsModule.deleteSpotByName(spot.name);
        _spotsModule.saveSpot(edited);
      }
    });
  }

  void editSpotFromToolbar() {
    if (!_canEditOrDeleteSavedSpots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu plan actual no permite editar spots guardados'),
        ),
      );
      return;
    }
    if (_spots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay spots para editar')),
      );
      return;
    }

    setState(() {
      _pendingCardAction = _PendingCardAction.edit;
      _selectedSpotNames.clear();
    });
  }

  void deleteMultipleSpotsFromToolbar() {
    if (!_canEditOrDeleteSavedSpots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu plan actual no permite eliminar spots guardados'),
        ),
      );
      return;
    }
    if (_spots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay spots para eliminar')),
      );
      return;
    }

    setState(() {
      _pendingCardAction = _PendingCardAction.deleteMany;
      _selectedSpotNames.clear();
    });
  }

  bool get _isMultiMode => _pendingCardAction == _PendingCardAction.deleteMany;

  void _cancelPendingActionMode() {
    setState(() {
      _pendingCardAction = _PendingCardAction.none;
      _selectedSpotNames.clear();
    });
  }

  Future<void> _applyPendingBatchAction() async {
    if (_selectedSpotNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un spot')),
      );
      return;
    }

    if (_pendingCardAction == _PendingCardAction.deleteMany) {
      setState(() {
        for (final name in _selectedSpotNames) {
          _spotsModule.deleteSpotByName(name);
        }
        _spots.removeWhere((spot) => _selectedSpotNames.contains(spot.name));
        _pendingCardAction = _PendingCardAction.none;
        _selectedSpotNames.clear();
      });
      return;
    }

    return;
  }

  Future<void> _handleCardTap(_SpotItem spot) async {
    if (_pendingCardAction == _PendingCardAction.none) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SpotDetailPage(
            name: spot.name,
            area: spot.area,
            isCustom: spot.isCustom,
            latitude: spot.latitude,
            longitude: spot.longitude,
            aemetMunicipalityCode: spot.aemetMunicipalityCode,
            aemetBeachCode: spot.aemetBeachCode,
            aemetBeachCodes: spot.aemetBeachCodes,
            backgroundImagePath: spot.backgroundImagePath,
            spotsModule: _spotsModule,
          ),
        ),
      );
      return;
    }

    if (_pendingCardAction == _PendingCardAction.edit) {
      setState(() {
        _pendingCardAction = _PendingCardAction.none;
      });
      await _showEditSpotSheet(spot);
      return;
    }

    if (_pendingCardAction == _PendingCardAction.deleteMany) {
      setState(() {
        if (_selectedSpotNames.contains(spot.name)) {
          _selectedSpotNames.remove(spot.name);
        } else {
          _selectedSpotNames.add(spot.name);
        }
      });
      return;
    }

    return;
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
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spots', style: textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Aqui mostraremos spots guardados y meteo activa.',
                        style: textTheme.bodyMedium,
                      ),
                      if (!_hasAdvancedSpotAccess) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Plan user: maximo 2 spots oficiales. Sin spots custom y sin edicion o borrado.',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_spots.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'Todavia no has agregado spots. Usa el boton + para anadir el primero.',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                )
              else ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        key: const Key('spots-filter-all'),
                        label: const Text('Todos'),
                        selected: _filter == _SpotFilter.all,
                        onSelected: (_) {
                          setState(() {
                            _filter = _SpotFilter.all;
                          });
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      ChoiceChip(
                        key: const Key('spots-filter-official'),
                        label: const Text('Oficiales'),
                        selected: _filter == _SpotFilter.official,
                        onSelected: (_) {
                          setState(() {
                            _filter = _SpotFilter.official;
                          });
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      ChoiceChip(
                        key: const Key('spots-filter-custom'),
                        label: const Text('Custom'),
                        selected: _filter == _SpotFilter.custom,
                        onSelected: (_) {
                          setState(() {
                            _filter = _SpotFilter.custom;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  key: const Key('spots-search-input'),
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Buscar spots',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            tooltip: 'Limpiar busqueda',
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                if (_pendingCardAction != _PendingCardAction.none) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(switch (_pendingCardAction) {
                            _PendingCardAction.edit =>
                              'Modo editar: toca un spot custom para editarlo',
                            _PendingCardAction.deleteMany =>
                              'Modo eliminar varios: selecciona spots y aplica',
                            _PendingCardAction.none => '',
                          }, style: textTheme.bodyMedium),
                          if (_isMultiMode) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '${_selectedSpotNames.length} seleccionados',
                              style: textTheme.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: _cancelPendingActionMode,
                                  child: const Text('Cancelar'),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                FilledButton(
                                  onPressed: _applyPendingBatchAction,
                                  child: const Text('Aplicar'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        key: const Key('spots-sort-recent'),
                        label: const Text('Recientes'),
                        selected: _sort == _SpotSort.recent,
                        onSelected: (_) {
                          setState(() {
                            _sort = _SpotSort.recent;
                          });
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      ChoiceChip(
                        key: const Key('spots-sort-az'),
                        label: const Text('A-Z'),
                        selected: _sort == _SpotSort.az,
                        onSelected: (_) {
                          setState(() {
                            _sort = _SpotSort.az;
                          });
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      ChoiceChip(
                        key: const Key('spots-sort-za'),
                        label: const Text('Z-A'),
                        selected: _sort == _SpotSort.za,
                        onSelected: (_) {
                          setState(() {
                            _sort = _SpotSort.za;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_filteredSpots.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        'No hay spots para este filtro.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ..._filteredSpots.map((spot) {
                  final hasBackground = _canRenderLocalImage(
                    spot.backgroundImagePath,
                  );
                  final nearbyWebcamCount = _nearbyWebcamCount(spot);
                  final tile = ListTile(
                    selected: _selectedSpotNames.contains(spot.name),
                    leading: const Icon(Icons.place_outlined),
                    title: Text(spot.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(spot.area),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            if (spot.isCustom)
                              Chip(
                                backgroundColor: hasBackground
                                    ? Colors.black.withValues(alpha: 0.4)
                                    : null,
                                label: Text(
                                  'Custom',
                                  style: hasBackground
                                      ? const TextStyle(color: Colors.white)
                                      : null,
                                ),
                              ),
                            if (nearbyWebcamCount > 0)
                              Chip(
                                backgroundColor: hasBackground
                                    ? Colors.black.withValues(alpha: 0.4)
                                    : null,
                                label: Icon(
                                  Icons.videocam_rounded,
                                  size: 16,
                                  color: hasBackground ? Colors.white : null,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: _isMultiMode
                        ? Icon(
                            _selectedSpotNames.contains(spot.name)
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: hasBackground ? Colors.white : null,
                          )
                        : null,
                    onTap: () => _handleCardTap(spot),
                    textColor: hasBackground ? Colors.white : null,
                    iconColor: hasBackground ? Colors.white : null,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          if (hasBackground)
                            Positioned.fill(
                              child: Image.file(
                                File(spot.backgroundImagePath!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (hasBackground)
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.45),
                                      Colors.black.withValues(alpha: 0.2),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          tile,
                        ],
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 96),
            ],
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

class _AvailableSpot {
  const _AvailableSpot({
    required this.name,
    required this.area,
    this.latitude,
    this.longitude,
    this.aemetMunicipalityCode,
    this.aemetBeachCode,
    this.aemetBeachCodes = const <String>[],
  });

  final String name;
  final String area;
  final double? latitude;
  final double? longitude;
  final String? aemetMunicipalityCode;
  final String? aemetBeachCode;
  final List<String> aemetBeachCodes;
}

const _availableSpots = <_AvailableSpot>[
  _AvailableSpot(
    name: 'Oliva Canal - Platja dels Gorgs',
    area: 'Valencia',
    latitude: 38.91397175799847,
    longitude: -0.07335473217682421,
    aemetMunicipalityCode: '46181',
    aemetBeachCode: '4618102',
    aemetBeachCodes: ['4618103'],
  ),
  _AvailableSpot(
    name: 'Piles',
    area: 'Valencia',
    latitude: 38.9402,
    longitude: -0.1324,
    aemetMunicipalityCode: '46197',
  ),
  _AvailableSpot(
    name: 'Punta de los Molinos',
    area: 'Denia, Alicante',
    latitude: 38.8462,
    longitude: 0.0916,
    aemetMunicipalityCode: '03063',
  ),
  _AvailableSpot(
    name: 'Calpe',
    area: 'Alicante',
    latitude: 38.6446,
    longitude: 0.0456,
    aemetMunicipalityCode: '03047',
  ),
  _AvailableSpot(
    name: 'Altea',
    area: 'Alicante',
    latitude: 38.6027,
    longitude: -0.0462,
    aemetMunicipalityCode: '03018',
  ),
  _AvailableSpot(
    name: 'Villajoyosa',
    area: 'Alicante',
    latitude: 38.5079,
    longitude: -0.2291,
    aemetMunicipalityCode: '03139',
  ),
  _AvailableSpot(
    name: 'Santa Pola',
    area: 'Alicante',
    latitude: 38.1923,
    longitude: -0.5556,
    aemetMunicipalityCode: '03121',
  ),
  _AvailableSpot(
    name: 'Cullera',
    area: 'Valencia',
    latitude: 39.1653,
    longitude: -0.2516,
    aemetMunicipalityCode: '46105',
  ),
  _AvailableSpot(
    name: 'Xeraco',
    area: 'Valencia',
    latitude: 39.0318,
    longitude: -0.2161,
    aemetMunicipalityCode: '46143',
  ),
  _AvailableSpot(
    name: 'El Perellonet',
    area: 'Valencia',
    latitude: 39.2763,
    longitude: -0.2758,
    aemetMunicipalityCode: '46250',
  ),
  _AvailableSpot(
    name: 'Tarifa',
    area: 'Cadiz',
    latitude: 36.0143,
    longitude: -5.6044,
    aemetMunicipalityCode: '11035',
  ),
];

class _AddSpotSheet extends StatefulWidget {
  const _AddSpotSheet({
    required this.existingSpotNames,
    required this.allowCustomMode,
  });

  final Set<String> existingSpotNames;
  final bool allowCustomMode;

  @override
  State<_AddSpotSheet> createState() => _AddSpotSheetState();
}

class _AddSpotSheetState extends State<_AddSpotSheet> {
  final _imagePicker = ImagePicker();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  List<_AvailableSpot> _suggestedSpots = const <_AvailableSpot>[];
  _AvailableSpot? _selectedOfficialSpot;
  _CustomSpotPoint? _customPoint;
  bool _customMode = false;
  String? _backgroundImagePath;
  String? _error;

  bool _canRenderLocalImage(String? path) {
    return !kIsWeb && path != null && path.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final query = _nameController.text.trim().toLowerCase();
    final selectedOfficialSpot = _selectedOfficialSpot;
    if (selectedOfficialSpot != null &&
        selectedOfficialSpot.name.toLowerCase() != query) {
      _selectedOfficialSpot = null;
    }
    if (query.isEmpty) {
      if (_suggestedSpots.isNotEmpty) {
        setState(() {
          _suggestedSpots = const <_AvailableSpot>[];
          _error = null;
        });
      }
      return;
    }

    final next = _availableSpots
        .where(
          (spot) =>
              spot.name.toLowerCase().contains(query) &&
              !widget.existingSpotNames.contains(spot.name.toLowerCase()),
        )
        .take(5)
        .toList();

    setState(() {
      _suggestedSpots = next;
      _error = null;
    });
  }

  void _selectSuggestedSpot(_AvailableSpot spot) {
    _nameController.text = spot.name;
    _areaController.text = spot.area;
    _nameController.selection = TextSelection.collapsed(
      offset: _nameController.text.length,
    );

    setState(() {
      _selectedOfficialSpot = spot;
      _suggestedSpots = const <_AvailableSpot>[];
      _error = null;
      _customPoint = null;
      _customMode = false;
      _backgroundImagePath = null;
    });
  }

  Future<void> _pickCustomPoint() async {
    setState(() {
      _customMode = true;
      _error = null;
    });
    final picked = await showDialog<_CustomSpotPoint>(
      context: context,
      builder: (context) => _CustomMapPickerDialog(initialPoint: _customPoint),
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _customPoint = picked;
      _selectedOfficialSpot = null;
      _error = null;
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = 'Spot personalizado';
      }
      _suggestedSpots = const <_AvailableSpot>[];
    });
  }

  Future<void> _pickBackgroundImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(source: source, maxWidth: 2200);
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      _backgroundImagePath = picked.path;
      _error = null;
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final area = _areaController.text.trim();
    final selectedOfficialSpot = _selectedOfficialSpot;
    final normalized = (selectedOfficialSpot?.name ?? name).toLowerCase();

    if (name.isEmpty) {
      setState(() {
        _error = 'El nombre del spot es obligatorio';
      });
      return;
    }

    if (widget.existingSpotNames.contains(normalized)) {
      setState(() {
        _error = 'Ese spot ya esta agregado';
      });
      return;
    }

    if (selectedOfficialSpot == null && _customPoint == null) {
      setState(() {
        _error = widget.allowCustomMode
            ? 'Para un spot personalizado debes seleccionar coordenadas.'
            : 'Debes seleccionar uno de los spots oficiales sugeridos.';
      });
      return;
    }

    if (!widget.allowCustomMode &&
        (selectedOfficialSpot == null || _customPoint != null)) {
      setState(() {
        _error = 'Con el plan user solo puedes guardar spots oficiales.';
      });
      return;
    }

    Navigator.of(context).pop(
      _SpotItem(
        name: selectedOfficialSpot?.name ?? name,
        area: area.isEmpty ? 'Sin zona definida' : area,
        isCustom: _customPoint != null || selectedOfficialSpot == null,
        createdAt: DateTime.now(),
        latitude: _customPoint?.latitude ?? selectedOfficialSpot?.latitude,
        longitude: _customPoint?.longitude ?? selectedOfficialSpot?.longitude,
        aemetMunicipalityCode: selectedOfficialSpot?.aemetMunicipalityCode,
        aemetBeachCode: selectedOfficialSpot?.aemetBeachCode,
        aemetBeachCodes:
            selectedOfficialSpot?.aemetBeachCodes ?? const <String>[],
        backgroundImagePath: _backgroundImagePath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final name = _nameController.text.trim();
    final selectedOfficialSpot = _selectedOfficialSpot;
    final hasSelectedOfficialSpot =
        name.isNotEmpty && selectedOfficialSpot != null;
    final requiresCoordinates = name.isNotEmpty && !hasSelectedOfficialSpot;
    final canSave =
        name.isNotEmpty && (!requiresCoordinates || _customPoint != null);
    final allowTextFields = !_customMode || _customPoint != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agregar spot', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            if (widget.allowCustomMode)
              OutlinedButton.icon(
                onPressed: _pickCustomPoint,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Personalizado'),
              )
            else
              Text(
                'Con el plan user solo puedes guardar spots oficiales.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (_customPoint != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Punto del mapa seleccionado',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (hasSelectedOfficialSpot) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Spot oficial seleccionado: ${selectedOfficialSpot.name}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (requiresCoordinates && _customPoint == null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Selecciona un punto en el mapa para guardar.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (!allowTextFields) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Selecciona primero un punto para desbloquear los campos.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (allowTextFields && _customMode) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _pickBackgroundImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galeria'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _pickBackgroundImage(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Camara'),
                  ),
                ],
              ),
              if (_canRenderLocalImage(_backgroundImagePath)) ...[
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_backgroundImagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            tooltip: 'Eliminar foto',
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: Colors.white,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            onPressed: () async {
                              final shouldRemove = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Quitar foto'),
                                    content: const Text(
                                      'Quieres eliminar la foto seleccionada?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (!mounted || shouldRemove != true) {
                                return;
                              }
                              setState(() {
                                _backgroundImagePath = null;
                              });
                            },
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              enabled: allowTextFields,
              decoration: const InputDecoration(labelText: 'Nombre del spot'),
            ),
            if (_suggestedSpots.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _suggestedSpots.length,
                    itemBuilder: (context, index) {
                      final spot = _suggestedSpots[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(spot.name),
                        subtitle: Text(spot.area),
                        onTap: () => _selectSuggestedSpot(spot),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _areaController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              enabled: allowTextFields,
              decoration: const InputDecoration(
                labelText: 'Zona / provincia (opcional)',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canSave ? _save : null,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Guardar spot'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomSpotPoint {
  const _CustomSpotPoint({
    required this.latitude,
    required this.longitude,
    required this.xFraction,
    required this.yFraction,
  });

  final double latitude;
  final double longitude;
  final double xFraction;
  final double yFraction;

  LatLng toLatLng() => LatLng(latitude, longitude);
}

class _CustomMapPickerDialog extends StatefulWidget {
  const _CustomMapPickerDialog({this.initialPoint});

  final _CustomSpotPoint? initialPoint;

  @override
  State<_CustomMapPickerDialog> createState() => _CustomMapPickerDialogState();
}

class _CustomMapPickerDialogState extends State<_CustomMapPickerDialog> {
  _CustomSpotPoint? _point;
  final _mapController = MapController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _latFocusNode = FocusNode();
  final _lonFocusNode = FocusNode();
  double _currentZoom = 7;

  @override
  void initState() {
    super.initState();
    _point = widget.initialPoint;
    if (_point != null) {
      _latController.text = _point!.latitude.toStringAsFixed(6);
      _lonController.text = _point!.longitude.toStringAsFixed(6);
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    _latFocusNode.dispose();
    _lonFocusNode.dispose();
    super.dispose();
  }

  void _setPointFromLatLng(LatLng latLng, {bool moveMap = true}) {
    setState(() {
      _point = _CustomSpotPoint(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        xFraction: 0,
        yFraction: 0,
      );
      _latController.text = latLng.latitude.toStringAsFixed(6);
      _lonController.text = latLng.longitude.toStringAsFixed(6);
    });
    if (moveMap) {
      _mapController.move(latLng, _currentZoom);
    }
  }

  void _applyCoordsFromInputs() {
    final latText = _latController.text.trim();
    final lonText = _lonController.text.trim();
    final lat = double.tryParse(latText);
    final lon = double.tryParse(lonText);
    final isValid =
        lat != null &&
        lon != null &&
        lat >= -90 &&
        lat <= 90 &&
        lon >= -180 &&
        lon <= 180;
    if (!isValid) {
      if (_point != null) {
        _latController.text = _point!.latitude.toStringAsFixed(6);
        _lonController.text = _point!.longitude.toStringAsFixed(6);
      }
      return;
    }
    _setPointFromLatLng(LatLng(lat, lon));
  }

  @override
  Widget build(BuildContext context) {
    final center = _point?.toLatLng() ?? const LatLng(39.5, -0.5);
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = math.min(screenSize.width * 0.94, 760.0);
    final mapHeight = math.min(screenSize.height * 0.62, 520.0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SizedBox(
        width: dialogWidth,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona punto en el mapa',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: mapHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: center,
                                initialZoom: _currentZoom,
                                onPositionChanged: (position, _) {
                                  _currentZoom = position.zoom;
                                },
                                onTap: (_, latLng) {
                                  _setPointFromLatLng(latLng);
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.windwisher.app',
                                ),
                                if (_point != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: _point!.toLatLng(),
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 32,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  tooltip: 'Centrar en el punto',
                                  icon: const Icon(
                                    Icons.my_location_rounded,
                                    size: 18,
                                  ),
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                  onPressed: _point == null
                                      ? null
                                      : () => _setPointFromLatLng(
                                          _point!.toLatLng(),
                                          moveMap: true,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          _applyCoordsFromInputs();
                        }
                      },
                      child: TextField(
                        controller: _latController,
                        focusNode: _latFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Latitud',
                          hintText: '38.913972',
                        ),
                        onSubmitted: (_) => _applyCoordsFromInputs(),
                        onEditingComplete: _applyCoordsFromInputs,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          _applyCoordsFromInputs();
                        }
                      },
                      child: TextField(
                        controller: _lonController,
                        focusNode: _lonFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Longitud',
                          hintText: '-0.073355',
                        ),
                        onSubmitted: (_) => _applyCoordsFromInputs(),
                        onEditingComplete: _applyCoordsFromInputs,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  FilledButton(
                    onPressed: _point == null
                        ? null
                        : () => Navigator.of(context).pop(_point),
                    child: const Text('Usar punto'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
