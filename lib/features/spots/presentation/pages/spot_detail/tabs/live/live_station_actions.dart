// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailLiveStationActions on _SpotDetailPageState {
  Future<void> _showLiveStationMapDialog(_NearbyStation station) async {
    final latLng = LatLng(station.latitude, station.longitude);

    await showDialog<void>(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.sizeOf(context);
        final dialogWidth = screenSize.width * 0.96;
        final dialogHeight = math.min(
          (dialogWidth * 9 / 16) + 116,
          screenSize.height * 0.9,
        );

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estacion · ${station.name}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: latLng,
                            initialZoom: 12,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.windwisher.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: latLng,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 36,
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
                  Text(
                    '${station.latitude.toStringAsFixed(4)}, ${station.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
