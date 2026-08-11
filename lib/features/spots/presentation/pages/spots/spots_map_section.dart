part of 'spots_page.dart';

extension _SpotsMapSection on SpotsPageState {
  Widget _buildSpotsMapSection(TextTheme textTheme) {
    final mappedSpots = _filteredSpots
        .where((spot) => _spotLocationPoint(spot) != null)
        .toList(growable: false);
    final selectedSpot = _selectedMapSpot;

    return Column(
      children: [
        Material(
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
                  _buildFilterChips(),
                  const SizedBox(height: AppSpacing.xs),
                  _buildSearchField(),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: mappedSpots.isEmpty
              ? _buildNoMappedSpots(textTheme)
              : Stack(
                  children: [
                    Positioned.fill(child: _buildSpotsMap(mappedSpots)),
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: _SpotMapCountBadge(count: mappedSpots.length),
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: FloatingActionButton.small(
                        heroTag: 'fit-spots-map',
                        tooltip: 'Ver todos los spots',
                        onPressed: () => _fitMappedSpots(mappedSpots),
                        child: const Icon(Icons.center_focus_strong),
                      ),
                    ),
                    if (selectedSpot != null)
                      Positioned(
                        left: AppSpacing.sm,
                        right: AppSpacing.sm,
                        bottom: AppSpacing.sm,
                        child: SafeArea(
                          top: false,
                          child: _SpotMapPreviewCard(
                            spot: selectedSpot,
                            onClose: _clearSelectedMapSpot,
                            onOpenSpot: () => _openSpotDetail(selectedSpot),
                            onShowLocation: () =>
                                _showSpotMapDialog(selectedSpot),
                            onNavigate: () =>
                                _navigateToMappedSpot(selectedSpot),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
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

  Widget _buildSpotsMap(List<_SpotItem> spots) {
    final points = spots
        .map(_spotLocationPoint)
        .nonNulls
        .map((point) => point.latLng)
        .toList(growable: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileStyle = isDark ? 'dark_all' : 'light_all';

    return FlutterMap(
      key: const Key('spots-explorer-map'),
      mapController: _spotsMapController,
      options: MapOptions(
        initialCenter: points.first,
        initialZoom: 12,
        initialCameraFit: points.length > 1
            ? CameraFit.coordinates(
                coordinates: points,
                padding: const EdgeInsets.fromLTRB(44, 64, 44, 90),
                maxZoom: 13,
              )
            : null,
        onTap: (_, _) {
          _clearSelectedMapSpot();
        },
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/$tileStyle/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.windwisher.app',
          retinaMode: RetinaMode.isHighDensity(context),
        ),
        MarkerLayer(
          markers: [for (final spot in spots) _buildSpotMapMarker(spot)],
        ),
        SimpleAttributionWidget(
          source: const Text('OpenStreetMap · CARTO'),
          alignment: Alignment.topRight,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surface.withValues(alpha: 0.78),
        ),
      ],
    );
  }

  Marker _buildSpotMapMarker(_SpotItem spot) {
    final point = _spotLocationPoint(spot)!;
    final isSelected = identical(_selectedMapSpot, spot);
    final colorScheme = Theme.of(context).colorScheme;
    return Marker(
      point: point.latLng,
      width: isSelected ? 54 : 46,
      height: isSelected ? 54 : 46,
      child: Semantics(
        button: true,
        label: 'Ver spot ${spot.name}',
        child: GestureDetector(
          key: Key('spot-map-marker-${spot.name}'),
          behavior: HitTestBehavior.opaque,
          onTap: () => _selectMapSpot(spot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? colorScheme.tertiary : colorScheme.primary,
              border: Border.all(
                color: colorScheme.onPrimary,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.32),
                  blurRadius: isSelected ? 14 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              spot.isCustom ? Icons.person_pin_circle : Icons.kitesurfing,
              color: isSelected
                  ? colorScheme.onTertiary
                  : colorScheme.onPrimary,
              size: isSelected ? 28 : 23,
            ),
          ),
        ),
      ),
    );
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

  void _navigateToMappedSpot(_SpotItem spot) {
    final point = _spotNavigationPoint(spot) ?? _spotLocationPoint(spot);
    if (point == null) {
      return;
    }
    unawaited(
      _openSpotInGoogleMaps(
        latitude: point.latitude,
        longitude: point.longitude,
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
