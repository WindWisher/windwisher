part of '../spots_page.dart';

class _SpotMapPreviewCard extends StatelessWidget {
  const _SpotMapPreviewCard({
    required this.spot,
    required this.isSaved,
    required this.onClose,
    required this.onOpenSpot,
    required this.onShowLocation,
    required this.onAddSpot,
  });

  final _SpotItem spot;
  final bool isSaved;
  final VoidCallback onClose;
  final VoidCallback onOpenSpot;
  final VoidCallback onShowLocation;
  final VoidCallback onAddSpot;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      key: const Key('spot-map-preview-card'),
      elevation: 10,
      color: colorScheme.surface.withValues(alpha: 0.96),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spot.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        spot.area,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar ficha',
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                IconButton.filledTonal(
                  tooltip: 'Ver ubicacion',
                  onPressed: onShowLocation,
                  icon: const Icon(Icons.map_outlined),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (!isSaved) ...[
                  IconButton.filledTonal(
                    key: const Key('add-map-spot-to-list'),
                    tooltip: 'Agregar a Mis spots',
                    onPressed: onAddSpot,
                    icon: const Icon(Icons.star_border_rounded),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onOpenSpot,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Abrir spot'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
