part of '../spots_page.dart';

class _SpotMapPreviewCard extends StatelessWidget {
  const _SpotMapPreviewCard({
    required this.spot,
    required this.onClose,
    required this.onOpenSpot,
    required this.onShowLocation,
    required this.onNavigate,
  });

  final _SpotItem spot;
  final VoidCallback onClose;
  final VoidCallback onOpenSpot;
  final VoidCallback onShowLocation;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final capabilities = spot.capabilities;
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
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                if (capabilities.liveStationProfile != null)
                  const _SpotMapFeatureChip(
                    icon: Icons.air_rounded,
                    label: 'Live',
                  ),
                if (capabilities.webcamProfile != null)
                  const _SpotMapFeatureChip(
                    icon: Icons.videocam_outlined,
                    label: 'Webcam',
                  ),
                const _SpotMapFeatureChip(
                  icon: Icons.query_stats_rounded,
                  label: 'Forecast',
                ),
                if (spot.isCustom)
                  const _SpotMapFeatureChip(
                    icon: Icons.person_pin_circle_outlined,
                    label: 'Custom',
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
                const SizedBox(width: AppSpacing.xs),
                IconButton.filledTonal(
                  tooltip: 'Como llegar',
                  onPressed: onNavigate,
                  icon: const Icon(Icons.directions_outlined),
                ),
                const SizedBox(width: AppSpacing.sm),
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

class _SpotMapFeatureChip extends StatelessWidget {
  const _SpotMapFeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: colorScheme.onSecondaryContainer),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
