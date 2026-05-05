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
part 'spot_add_builder.dart';
part 'spot_add_sheet_state.dart';
part 'spot_add_suggestions_helper.dart';
part 'spot_custom_map_coordinate_parser.dart';
part 'spot_custom_map_models.dart';
part 'spots_webcam_distance_helper.dart';

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
part 'widgets/spot_pending_action_card.dart';
part 'widgets/spot_search_field.dart';
part 'widgets/spot_suggestions_list.dart';

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

  List<_SpotItem> get _filteredSpots {
    return _filterAndSortSpots(
      spots: _spots,
      searchQuery: _searchQuery,
      filter: _filter,
      sort: _sort,
    );
  }

  int _nearbyWebcamCount(_SpotItem spot) {
    return _nearbySpotWebcamCount(spot: spot, spotsModule: _spotsModule);
  }

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
