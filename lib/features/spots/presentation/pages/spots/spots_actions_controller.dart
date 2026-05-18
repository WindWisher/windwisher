// ignore_for_file: invalid_use_of_protected_member

part of 'spots_page.dart';

extension SpotsActionsController on SpotsPageState {
  bool _canRenderLocalImage(String? path) {
    return !kIsWeb && path != null && path.isNotEmpty;
  }

  bool _canShowSpotMap(_SpotItem spot) {
    return _spotLocationPoint(spot) != null ||
        _spotNavigationPoint(spot) != null;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No hay spots para editar')));
      return;
    }

    setState(() {
      _pendingCardAction = _PendingCardAction.edit;
      _selectedSpotNames.clear();
    });
  }

  Future<void> openSpotChatFromNotification({
    required String spotName,
    required String spotArea,
  }) async {
    _SpotItem? spot;
    for (final candidate in _spots) {
      if (candidate.name.trim().toLowerCase() ==
              spotName.trim().toLowerCase() &&
          candidate.area.trim().toLowerCase() ==
              spotArea.trim().toLowerCase()) {
        spot = candidate;
        break;
      }
    }
    if (spot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontro el spot $spotName.')),
      );
      return;
    }
    await _openSpotDetail(spot, openChatInitially: true);
  }

  Future<void> _handleCardTap(_SpotItem spot) async {
    if (_pendingCardAction == _PendingCardAction.none) {
      await _openSpotDetail(spot);
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
      _toggleSpotSelection(spot);
      return;
    }

    return;
  }

  Future<void> _openSpotDetail(
    _SpotItem spot, {
    bool openChatInitially = false,
  }) async {
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
          capabilities: spot.capabilities,
          spotsModule: _spotsModule,
          openChatInitially: openChatInitially,
        ),
      ),
    );
  }

  Future<void> _showSpotMapDialog(_SpotItem spot) async {
    final spotPoint = _spotLocationPoint(spot);
    final navigationPoint = _spotNavigationPoint(spot);
    final primaryPoint = navigationPoint ?? spotPoint;
    if (primaryPoint == null) {
      return;
    }
    final showSeparateNavigationPoint =
        spotPoint != null &&
        navigationPoint != null &&
        !_sameMapPoint(spotPoint, navigationPoint);
    final initialCenter = showSeparateNavigationPoint
        ? LatLng(
            (spotPoint.latitude + navigationPoint.latitude) / 2,
            (spotPoint.longitude + navigationPoint.longitude) / 2,
          )
        : primaryPoint.latLng;
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = math.min(screenSize.width * 0.94, 720.0);
    final mapHeight = math.min(screenSize.height * 0.55, 460.0);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: SizedBox(
            width: dialogWidth,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot.name,
                    style: Theme.of(dialogContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    spot.area,
                    style: Theme.of(dialogContext).textTheme.bodyMedium
                        ?.copyWith(
                          color: Theme.of(
                            dialogContext,
                          ).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: mapHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(dialogContext).colorScheme.outline,
                          ),
                        ),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: initialCenter,
                            initialZoom: showSeparateNavigationPoint ? 13 : 14,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.windwisher.app',
                            ),
                            MarkerLayer(
                              markers: [
                                if (spotPoint != null)
                                  Marker(
                                    point: spotPoint.latLng,
                                    width: 42,
                                    height: 42,
                                    child: const Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 38,
                                    ),
                                  ),
                                if (navigationPoint != null)
                                  Marker(
                                    point: navigationPoint.latLng,
                                    width: 42,
                                    height: 42,
                                    child: Icon(
                                      showSeparateNavigationPoint
                                          ? Icons.local_parking_rounded
                                          : Icons.directions_car_filled,
                                      color: Colors.blue,
                                      size: 34,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (spotPoint != null)
                    Text(
                      'Spot: ${spotPoint.latitude.toStringAsFixed(6)}, '
                      '${spotPoint.longitude.toStringAsFixed(6)}',
                      style: Theme.of(dialogContext).textTheme.bodySmall,
                    ),
                  if (navigationPoint != null)
                    Text(
                      'Llegada: ${navigationPoint.label} '
                      '(${navigationPoint.latitude.toStringAsFixed(6)}, '
                      '${navigationPoint.longitude.toStringAsFixed(6)})',
                      style: Theme.of(dialogContext).textTheme.bodySmall,
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cerrar'),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      FilledButton.icon(
                        onPressed: () => _openSpotInGoogleMaps(
                          latitude: primaryPoint.latitude,
                          longitude: primaryPoint.longitude,
                        ),
                        icon: const Icon(Icons.directions_outlined),
                        label: const Text('Google Maps'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openSpotInGoogleMaps({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$latitude,$longitude'
      '&travelmode=driving',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Google Maps.')),
      );
    }
  }

  _SpotMapPoint? _spotLocationPoint(_SpotItem spot) {
    final latitude = spot.latitude;
    final longitude = spot.longitude;
    if (latitude == null || longitude == null) {
      return null;
    }
    return _SpotMapPoint(
      latitude: latitude,
      longitude: longitude,
      label: spot.name,
    );
  }

  _SpotMapPoint? _spotNavigationPoint(_SpotItem spot) {
    final capabilities = spot.capabilities;
    final latitude = capabilities.navigationLatitude;
    final longitude = capabilities.navigationLongitude;
    if (latitude == null || longitude == null) {
      return null;
    }
    return _SpotMapPoint(
      latitude: latitude,
      longitude: longitude,
      label: capabilities.navigationLabel ?? spot.name,
    );
  }

  bool _sameMapPoint(_SpotMapPoint a, _SpotMapPoint b) {
    return (a.latitude - b.latitude).abs() < 0.00001 &&
        (a.longitude - b.longitude).abs() < 0.00001;
  }
}

class _SpotMapPoint {
  const _SpotMapPoint({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  final double latitude;
  final double longitude;
  final String label;

  LatLng get latLng => LatLng(latitude, longitude);
}
