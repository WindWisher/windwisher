part of '../spots_page.dart';

class _CustomMapDialogContent extends StatelessWidget {
  const _CustomMapDialogContent({
    required this.width,
    required this.mapHeight,
    required this.point,
    required this.currentZoom,
    required this.mapController,
    required this.latController,
    required this.lonController,
    required this.latFocusNode,
    required this.lonFocusNode,
    required this.onPositionChanged,
    required this.onPointSelected,
    required this.onApplyCoords,
    required this.onCancel,
    required this.onUsePoint,
  });

  final double width;
  final double mapHeight;
  final _CustomSpotPoint? point;
  final double currentZoom;
  final MapController mapController;
  final TextEditingController latController;
  final TextEditingController lonController;
  final FocusNode latFocusNode;
  final FocusNode lonFocusNode;
  final ValueChanged<double> onPositionChanged;
  final ValueChanged<LatLng> onPointSelected;
  final VoidCallback onApplyCoords;
  final VoidCallback onCancel;
  final VoidCallback onUsePoint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
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
            _CustomMapView(
              height: mapHeight,
              point: point,
              currentZoom: currentZoom,
              mapController: mapController,
              onPositionChanged: onPositionChanged,
              onPointSelected: onPointSelected,
            ),
            const SizedBox(height: AppSpacing.xs),
            _CustomMapCoordinateFields(
              latController: latController,
              lonController: lonController,
              latFocusNode: latFocusNode,
              lonFocusNode: lonFocusNode,
              onApplyCoords: onApplyCoords,
            ),
            const SizedBox(height: AppSpacing.sm),
            _CustomMapDialogActions(
              canUsePoint: point != null,
              onCancel: onCancel,
              onUsePoint: onUsePoint,
            ),
          ],
        ),
      ),
    );
  }
}
