part of '../../../spot_detail_page.dart';

class _LiveHistoryLoadCard extends StatelessWidget {
  const _LiveHistoryLoadCard({
    required this.sourceLabel,
    required this.stationName,
    required this.isLoading,
    required this.onLoad,
  });

  final String sourceLabel;
  final String stationName;
  final bool isLoading;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historico $sourceLabel · $stationName',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Carga el historico real solo cuando quieras consultar la grafica.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onLoad,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.show_chart_rounded),
                label: Text(
                  isLoading ? 'Cargando historico' : 'Cargar historico',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
