part of '../spots_page.dart';

class _CustomMapView extends StatelessWidget {
  const _CustomMapView({
    required this.height,
    required this.point,
    required this.currentZoom,
    required this.mapController,
    required this.onPositionChanged,
    required this.onPointSelected,
  });

  final double height;
  final _CustomSpotPoint? point;
  final double currentZoom;
  final MapController mapController;
  final ValueChanged<double> onPositionChanged;
  final ValueChanged<LatLng> onPointSelected;

  LatLng get _center {
    return point?.toLatLng() ?? const LatLng(39.5, -0.5);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: currentZoom,
                  onPositionChanged: (position, _) {
                    onPositionChanged(position.zoom);
                  },
                  onTap: (_, latLng) {
                    onPointSelected(latLng);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.windwisher.app',
                  ),
                  if (point != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point!.toLatLng(),
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
                child: _CustomMapCenterButton(
                  enabled: point != null,
                  onPressed: () {
                    final point = this.point;
                    if (point == null) {
                      return;
                    }
                    onPointSelected(point.toLatLng());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomMapCenterButton extends StatelessWidget {
  const _CustomMapCenterButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: 'Centrar en el punto',
        icon: const Icon(Icons.my_location_rounded, size: 18),
        color: Colors.white,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}
