part of '../spots_page.dart';

class _SpotAddStatusMessages extends StatelessWidget {
  const _SpotAddStatusMessages({
    required this.customPoint,
    required this.selectedOfficialSpot,
    required this.hasSelectedOfficialSpot,
    required this.requiresCoordinates,
    required this.allowTextFields,
  });

  final _CustomSpotPoint? customPoint;
  final _AvailableSpot? selectedOfficialSpot;
  final bool hasSelectedOfficialSpot;
  final bool requiresCoordinates;
  final bool allowTextFields;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (customPoint != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text('Punto del mapa seleccionado', style: textStyle),
        ],
        if (hasSelectedOfficialSpot && selectedOfficialSpot != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Spot oficial seleccionado: ${selectedOfficialSpot!.name}',
            style: textStyle,
          ),
        ],
        if (requiresCoordinates && customPoint == null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Selecciona un punto en el mapa para guardar.',
            style: textStyle?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        if (!allowTextFields) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Selecciona primero un punto para desbloquear los campos.',
            style: textStyle,
          ),
        ],
      ],
    );
  }
}

class _SpotAddErrorMessage extends StatelessWidget {
  const _SpotAddErrorMessage({required this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    if (error == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        error,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
