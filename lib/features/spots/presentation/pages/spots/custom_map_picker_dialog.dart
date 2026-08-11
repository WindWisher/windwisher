part of 'spots_page.dart';

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
    _syncCoordinateInputsWithPoint();
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
      _syncCoordinateInputsWithPoint();
    });
    if (moveMap) {
      _mapController.move(latLng, _currentZoom);
    }
  }

  void _applyCoordsFromInputs() {
    final latLng = _parseCustomMapCoordinates(
      latitudeText: _latController.text,
      longitudeText: _lonController.text,
    );
    if (latLng == null) {
      _syncCoordinateInputsWithPoint();
      return;
    }
    _setPointFromLatLng(latLng);
  }

  void _syncCoordinateInputsWithPoint() {
    final point = _point;
    if (point == null) {
      return;
    }
    _latController.text = point.latitude.toStringAsFixed(6);
    _lonController.text = point.longitude.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = math.min(screenSize.width * 0.94, 760.0);
    final mapHeight = math.max(
      120.0,
      math.min(screenSize.height - 260.0, 520.0),
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: _CustomMapDialogContent(
        width: dialogWidth,
        mapHeight: mapHeight,
        point: _point,
        currentZoom: _currentZoom,
        mapController: _mapController,
        latController: _latController,
        lonController: _lonController,
        latFocusNode: _latFocusNode,
        lonFocusNode: _lonFocusNode,
        onPositionChanged: (zoom) {
          _currentZoom = zoom;
        },
        onPointSelected: _setPointFromLatLng,
        onApplyCoords: _applyCoordsFromInputs,
        onCancel: () => Navigator.of(context).pop(),
        onUsePoint: () => Navigator.of(context).pop(_point),
      ),
    );
  }
}
