import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/spots/di/spots_module.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/data/spot_capabilities_catalog.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/spot_detail_page.dart';

part 'available_spots_catalog.dart';
part 'spot_add_builder.dart';
part 'spot_add_sheet_state.dart';
part 'spot_add_suggestions_helper.dart';
part 'spot_custom_map_coordinate_parser.dart';
part 'spot_custom_map_models.dart';

part 'add_spot_sheet.dart';
part 'custom_map_picker_dialog.dart';
part 'edit_spot_sheet.dart';

part 'spots_access_controller.dart';
part 'spots_actions_controller.dart';
part 'spots_add_controller.dart';
part 'spots_catalog_controller.dart';
part 'spots_delete_controller.dart';
part 'spots_edit_controller.dart';
part 'spots_filter_controller.dart';
part 'spots_list_section.dart';
part 'spots_map_section.dart';
part 'spots_order_controller.dart';

part 'widgets/spot_add_form_fields.dart';
part 'widgets/spot_add_header.dart';
part 'widgets/spot_add_sheet_content.dart';
part 'widgets/spot_add_status_messages.dart';
part 'widgets/spot_background_image_picker.dart';
part 'widgets/spot_card.dart';
part 'widgets/spot_custom_map_controls.dart';
part 'widgets/spot_custom_map_dialog_content.dart';
part 'widgets/spot_custom_map_view.dart';
part 'widgets/spot_edit_sheet_content.dart';
part 'widgets/spot_filter_sort_chips.dart';
part 'widgets/spot_list_state_cards.dart';
part 'widgets/spot_map_preview_card.dart';
part 'widgets/spot_pending_action_card.dart';
part 'widgets/spot_search_field.dart';
part 'widgets/spot_suggestions_list.dart';
part 'widgets/spot_view_toggle.dart';

typedef _SpotItem = SpotItem;

class SpotsPage extends StatefulWidget {
  const SpotsPage({
    super.key,
    this.spotsModule,
    this.useLocalPersistence = EnvConfig.spotsLocalPersistenceEnabled,
    this.initialRoles = const <String>{},
    this.initiallyShowMap = true,
    this.onMapViewChanged,
  });

  final SpotsModule? spotsModule;
  final bool useLocalPersistence;
  final Set<String> initialRoles;
  final bool initiallyShowMap;
  final ValueChanged<bool>? onMapViewChanged;

  @override
  State<SpotsPage> createState() => SpotsPageState();
}

class SpotsPageState extends State<SpotsPage> {
  late final SpotsModule _spotsModule;
  late final List<_SpotItem> _catalogSpots;
  final List<_SpotItem> _spots = <_SpotItem>[];
  final _searchController = TextEditingController();
  _SpotSort _sort = _SpotSort.manual;
  late _SpotsViewMode _viewMode;
  _PendingCardAction _pendingCardAction = _PendingCardAction.none;
  final Set<String> _selectedSpotNames = <String>{};
  final MapController _spotsMapController = MapController();
  _SpotItem? _selectedMapSpot;
  bool _showMapSearchSuggestions = false;
  bool _isSpotsMapLoading = true;
  bool _hasScheduledSpotsMapLoaded = false;
  List<String> _spotOrderKeys = const <String>[];
  String _searchQuery = '';
  StreamSubscription<AuthState>? _authStateSubscription;
  Set<String> _myRoles = const <String>{};

  @override
  void initState() {
    super.initState();
    _viewMode = widget.initiallyShowMap
        ? _SpotsViewMode.map
        : _SpotsViewMode.list;
    _catalogSpots = List<_SpotItem>.unmodifiable(
      _availableSpots.map((spot) => spot.toSpotItem()),
    );
    _spotsModule =
        widget.spotsModule ??
        (widget.useLocalPersistence
            ? SpotsModule.auto()
            : SpotsModule.inMemory());
    _myRoles = Set<String>.unmodifiable(widget.initialRoles);
    _spotOrderKeys = _loadSpotOrderKeys();
    _spots.addAll(_spotsModule.getSpots());
    _applyStoredSpotOrder();
    _hydrateSpotsCatalog();
    unawaited(_loadMyRoles());
    _subscribeToAuthChanges();
  }

  List<_SpotItem> get _filteredSpots {
    return _filterAndSortSpots(
      spots: _spots,
      searchQuery: _searchQuery,
      sort: _sort,
    );
  }

  List<_SpotItem> get _filteredMapSpots {
    final query = _searchQuery.trim().toLowerCase();
    return _catalogSpots
        .where((spot) => _matchesSpotQuery(spot, query))
        .toList(growable: false);
  }

  List<_SpotItem> get _mapSearchSuggestions {
    if (!_showMapSearchSuggestions) {
      return const <_SpotItem>[];
    }
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return const <_SpotItem>[];
    }
    final matches = _catalogSpots
        .where((spot) => _matchesSpotQuery(spot, query))
        .where((spot) => _spotLocationPoint(spot) != null)
        .toList();
    matches.sort((a, b) {
      final aStarts = a.name.toLowerCase().startsWith(query);
      final bStarts = b.name.toLowerCase().startsWith(query);
      if (aStarts != bStarts) {
        return aStarts ? -1 : 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return matches.take(6).toList(growable: false);
  }

  void _setSearchQuery(String value) {
    setState(() {
      _searchQuery = value;
      _selectedMapSpot = null;
      _showMapSearchSuggestions =
          _viewMode == _SpotsViewMode.map && value.trim().isNotEmpty;
    });
  }

  void _showMapSuggestionsForCurrentQuery() {
    if (_viewMode != _SpotsViewMode.map || _searchQuery.trim().isEmpty) {
      return;
    }
    setState(() => _showMapSearchSuggestions = true);
  }

  void _selectMapSearchSuggestion(_SpotItem spot) {
    final point = _spotLocationPoint(spot);
    if (point == null) {
      return;
    }
    _searchController
      ..text = spot.name
      ..selection = TextSelection.collapsed(offset: spot.name.length);
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _searchQuery = spot.name;
      _selectedMapSpot = spot;
      _showMapSearchSuggestions = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _spotsMapController.move(point.latLng, 16);
      }
    });
  }

  void _clearSearchQuery() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedMapSpot = null;
      _showMapSearchSuggestions = false;
    });
  }

  void _setSort(_SpotSort value) {
    setState(() {
      _sort = value;
    });
  }

  void _setViewMode(_SpotsViewMode value) {
    if (_viewMode == value) {
      return;
    }
    setState(() {
      _viewMode = value;
      _selectedMapSpot = null;
      _showMapSearchSuggestions = false;
      if (value == _SpotsViewMode.map) {
        _pendingCardAction = _PendingCardAction.none;
        _selectedSpotNames.clear();
        _isSpotsMapLoading = true;
        _hasScheduledSpotsMapLoaded = false;
      }
    });
    widget.onMapViewChanged?.call(value == _SpotsViewMode.map);
  }

  void _selectMapSpot(_SpotItem spot) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _selectedMapSpot = spot;
      _showMapSearchSuggestions = false;
    });
  }

  void _clearSelectedMapSpot() {
    if (_selectedMapSpot == null) {
      return;
    }
    setState(() => _selectedMapSpot = null);
  }

  void _markSpotsMapLoaded() {
    if (!mounted || !_isSpotsMapLoading) {
      return;
    }
    setState(() => _isSpotsMapLoading = false);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _searchController.dispose();
    _spotsMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        if (_viewMode == _SpotsViewMode.list)
          ScrollConfiguration(
            behavior: const _VerticalBounceNoStretchBehavior(),
            child: CustomScrollView(
              physics: kAppBouncingScrollPhysics,
              slivers: _buildSpotsListSection(textTheme),
            ),
          )
        else
          _buildSpotsMapSection(textTheme),
        if (_viewMode == _SpotsViewMode.list)
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

enum _SpotSort { manual, recent, az, za }

enum _SpotsViewMode { list, map }
