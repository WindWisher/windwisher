part of '../spots_page.dart';

class _SpotsHeaderCard extends StatelessWidget {
  const _SpotsHeaderCard({required this.hasAdvancedSpotAccess});

  final bool hasAdvancedSpotAccess;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spots', style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Aqui mostraremos spots guardados y meteo activa.',
              style: textTheme.bodyMedium,
            ),
            if (!hasAdvancedSpotAccess) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Plan user: maximo 2 spots oficiales. Sin spots custom y sin edicion o borrado.',
                style: textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptySpotsCard extends StatelessWidget {
  const _EmptySpotsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'Todavia no has agregado spots. Usa el boton + para anadir el primero.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _NoFilteredSpotsCard extends StatelessWidget {
  const _NoFilteredSpotsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'No hay spots para este filtro.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
