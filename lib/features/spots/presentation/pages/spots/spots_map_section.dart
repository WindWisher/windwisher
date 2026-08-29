part of 'spots_page.dart';

extension _SpotsMapSection on SpotsPageState {
  Widget _buildSpotsMapSection(TextTheme textTheme) {
    final mappedSpots = _filteredMapSpots
        .where((spot) => _spotLocationPoint(spot) != null)
        .toList(growable: false);
    final selectedSpot = _selectedMapSpot;
    final mapHeader = _buildSpotsMapHeader();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape =
            MediaQuery.orientationOf(context) == Orientation.landscape;
        final mapBody = _buildSpotsMapBody(
          mappedSpots: mappedSpots,
          selectedSpot: selectedSpot,
          textTheme: textTheme,
          isLandscape: isLandscape,
        );
        final mapHeight = isLandscape
            ? math.max(360.0, constraints.maxHeight * 0.9)
            : math.max(360.0, constraints.maxHeight - 140);
        return ScrollConfiguration(
          behavior: const _VerticalBounceNoStretchBehavior(),
          child: SingleChildScrollView(
            key: const Key('spots-map-scroll'),
            physics: isLandscape
                ? kAppBouncingScrollPhysics
                : const ClampingScrollPhysics(),
            child: Column(
              children: [
                mapHeader,
                SizedBox(height: mapHeight, child: mapBody),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpotsMapHeader() {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            children: [
              _buildViewToggle(),
              const SizedBox(height: AppSpacing.xs),
              _buildSearchField(onTap: _showMapSuggestionsForCurrentQuery),
              if (_mapSearchSuggestions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                _SpotMapSearchSuggestions(
                  spots: _mapSearchSuggestions,
                  onSelected: _selectMapSearchSuggestion,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpotsMapBody({
    required List<_SpotItem> mappedSpots,
    required _SpotItem? selectedSpot,
    required TextTheme textTheme,
    required bool isLandscape,
  }) {
    if (mappedSpots.isEmpty) {
      return _buildNoMappedSpots(textTheme);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: _buildSpotsMap(mappedSpots, isLandscape: isLandscape),
        ),
        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.sm,
          child: _SpotMapCountBadge(count: mappedSpots.length),
        ),
        if (selectedSpot == null)
          Positioned(
            bottom: AppSpacing.sm,
            right: AppSpacing.sm,
            child: _buildSpotMapControls(mappedSpots),
          ),
        IgnorePointer(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _isSpotsMapLoading
                ? const _SpotMapLoadingOverlay(key: Key('spots-map-loading'))
                : const SizedBox.shrink(),
          ),
        ),
        if (selectedSpot != null)
          Positioned(
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSpotMapControls(mappedSpots),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: _SpotMapPreviewCard(
                      spot: selectedSpot,
                      isSaved: _isSpotSaved(selectedSpot),
                      onClose: _clearSelectedMapSpot,
                      onOpenSpot: () => _openSpotDetail(selectedSpot),
                      onShowLocation: () => _showSpotMapDialog(selectedSpot),
                      onAddSpot: () => _addCatalogSpotFromMap(selectedSpot),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSpotMapControls(List<_SpotItem> mappedSpots) {
    return KeyedSubtree(
      key: const Key('spots-map-controls'),
      child: _SpotMapControlRail(
        onZoomIn: () => _zoomSpotsMap(1),
        onZoomOut: () => _zoomSpotsMap(-1),
        onFitSpots: () => _fitMappedSpots(mappedSpots),
      ),
    );
  }

  Widget _buildNoMappedSpots(TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off_outlined, size: 42),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No hay spots con ubicacion para este filtro.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpotsMap(List<_SpotItem> spots, {required bool isLandscape}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileStyle = isDark ? 'dark_all' : 'light_all';

    return FlutterMap(
      key: const Key('spots-explorer-map'),
      mapController: _spotsMapController,
      options: MapOptions(
        initialCenter: const LatLng(38.75, -0.2),
        initialZoom: 8,
        interactionOptions: _spotsMapInteractionOptions(
          isLandscape: isLandscape,
        ),
        onTap: (_, _) => _clearSelectedMapSpot(),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/$tileStyle/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.windwisher.app',
          retinaMode: false,
          panBuffer: 0,
          keepBuffer: 1,
          tileDisplay: const TileDisplay.instantaneous(),
          tileBuilder: _buildSpotMapTile,
        ),
        MarkerLayer(
          markers: [for (final spot in spots) _buildSpotMapMarker(spot)],
        ),
      ],
    );
  }

  InteractionOptions _spotsMapInteractionOptions({required bool isLandscape}) {
    if (kIsWeb) {
      return InteractionOptions(
        flags:
            InteractiveFlag.drag |
            InteractiveFlag.flingAnimation |
            InteractiveFlag.pinchMove |
            InteractiveFlag.pinchZoom |
            InteractiveFlag.doubleTapZoom |
            InteractiveFlag.doubleTapDragZoom |
            InteractiveFlag.scrollWheelZoom,
        scrollWheelVelocity: 0.0025,
        cursorKeyboardRotationOptions: CursorKeyboardRotationOptions.disabled(),
      );
    }
    if (isLandscape) {
      return const InteractionOptions(
        flags:
            InteractiveFlag.pinchMove |
            InteractiveFlag.pinchZoom |
            InteractiveFlag.doubleTapZoom |
            InteractiveFlag.scrollWheelZoom,
      );
    }
    return const InteractionOptions();
  }

  Marker _buildSpotMapMarker(_SpotItem spot) {
    final point = _spotLocationPoint(spot)!;
    final isSelected = identical(_selectedMapSpot, spot);
    final colorScheme = Theme.of(context).colorScheme;
    return Marker(
      point: point.latLng,
      width: isSelected ? 164 : 44,
      height: isSelected ? 64 : 38,
      alignment: Alignment.bottomCenter,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: 'Ver spot ${spot.name}',
        child: GestureDetector(
          key: Key('spot-map-marker-${spot.name}'),
          behavior: HitTestBehavior.opaque,
          onTap: () => _selectMapSpot(spot),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isSelected)
                Container(
                  key: Key('spot-map-marker-label-${spot.name}'),
                  constraints: const BoxConstraints(maxWidth: 168),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    spot.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (isSelected) const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isSelected ? 32 : 26,
                height: isSelected ? 32 : 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.primary,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onPrimary,
                    width: isSelected ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.42)
                          : Colors.black.withValues(alpha: 0.32),
                      blurRadius: isSelected ? 12 : 4,
                      spreadRadius: isSelected ? 2 : 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  spot.isCustom ? Icons.person_pin_circle : Icons.kitesurfing,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onPrimary,
                  size: isSelected ? 18 : 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpotMapTile(
    BuildContext context,
    Widget tileWidget,
    TileImage tile,
  ) {
    if (tile.imageInfo != null &&
        !tile.loadError &&
        _isSpotsMapLoading &&
        !_hasScheduledSpotsMapLoaded) {
      _hasScheduledSpotsMapLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _markSpotsMapLoaded();
      });
    }
    return tileWidget;
  }

  void _zoomSpotsMap(double delta) {
    final camera = _spotsMapController.camera;
    final zoom = (camera.zoom + delta).clamp(2, 18).toDouble();
    _spotsMapController.move(camera.center, zoom);
  }

  void _fitMappedSpots(List<_SpotItem> spots) {
    final points = spots
        .map(_spotLocationPoint)
        .nonNulls
        .map((point) => point.latLng)
        .toList(growable: false);
    if (points.isEmpty) {
      return;
    }
    _spotsMapController.rotate(0);
    if (points.length == 1) {
      _spotsMapController.move(points.first, 13);
      return;
    }
    _spotsMapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.fromLTRB(44, 64, 44, 90),
        maxZoom: 13,
      ),
    );
  }
}

class _SpotMapSearchSuggestions extends StatelessWidget {
  const _SpotMapSearchSuggestions({
    required this.spots,
    required this.onSelected,
  });

  final List<_SpotItem> spots;
  final ValueChanged<_SpotItem> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      key: const Key('spots-map-search-suggestions'),
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < spots.length; index++) ...[
            if (index > 0)
              Divider(height: 1, color: colorScheme.outlineVariant),
            ListTile(
              key: Key('spots-map-search-suggestion-${spots[index].name}'),
              dense: true,
              leading: const Icon(Icons.location_on_outlined),
              title: Text(
                spots[index].name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                spots[index].area,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.north_west, size: 18),
              onTap: () => onSelected(spots[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpotMapCountBadge extends StatelessWidget {
  const _SpotMapCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '$count ${count == 1 ? 'spot' : 'spots'}',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SpotMapControlRail extends StatelessWidget {
  const _SpotMapControlRail({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitSpots,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitSpots;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface.withValues(alpha: 0.92),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SpotMapControlButton(
            tooltip: 'Acercar mapa',
            icon: Icons.add_rounded,
            onPressed: onZoomIn,
          ),
          _SpotMapControlDivider(color: colorScheme.outlineVariant),
          _SpotMapControlButton(
            tooltip: 'Alejar mapa',
            icon: Icons.remove_rounded,
            onPressed: onZoomOut,
          ),
          _SpotMapControlDivider(color: colorScheme.outlineVariant),
          _SpotMapControlButton(
            tooltip: 'Ver todos los spots',
            icon: Icons.center_focus_strong_rounded,
            onPressed: onFitSpots,
          ),
        ],
      ),
    );
  }
}

class _SpotMapControlButton extends StatelessWidget {
  const _SpotMapControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 42, height: 42),
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
    );
  }
}

class _SpotMapControlDivider extends StatelessWidget {
  const _SpotMapControlDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 24, child: Divider(height: 1, color: color));
  }
}

class _SpotMapLoadingOverlay extends StatelessWidget {
  const _SpotMapLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Material(
        color: colorScheme.surface.withValues(alpha: 0.94),
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Cargando mapa...',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
