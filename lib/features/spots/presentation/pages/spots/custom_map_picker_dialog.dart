part of 'spots_page.dart';

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
                                  userAgentPackageName: 'com.windwisher.app',
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
