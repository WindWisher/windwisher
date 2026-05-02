part of '../../spot_detail_page.dart';

extension _SpotDetailLiveWindLegendDialog on _SpotDetailPageState {
  Future<void> _showWindSemaforoLegendDialog() {
    return showDialog<void>(
      context: context,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.traffic_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Leyenda del semaforo de viento'),
                    const SizedBox(height: 2),
                    Text(
                      'Guia rapida para interpretar viento y tamano orientativo de cometa.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWindSemaforoLegendCard(textTheme),
                const SizedBox(height: AppSpacing.sm),
                _buildKiteSizeGuideCard(textTheme),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWindSemaforoLegendCard(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.45),
            Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Escala de viento', style: textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(8),
            title: _formatWindRangeLabel(upperExclusiveKnots: 10),
            description: 'No navegable',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(12),
            title: _formatWindRangeLabel(
              lowerInclusiveKnots: 10,
              upperInclusiveKnots: 14,
            ),
            description: 'Viento muy flojo',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(16),
            title: _formatWindRangeLabel(
              lowerInclusiveKnots: 14,
              upperInclusiveKnots: 18,
            ),
            description: 'Viento flojo',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(22),
            title: _formatWindRangeLabel(
              lowerInclusiveKnots: 18,
              upperInclusiveKnots: 26,
            ),
            description: 'Viento optimo',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(29),
            title: _formatWindRangeLabel(
              lowerInclusiveKnots: 26,
              upperInclusiveKnots: 32,
            ),
            description: 'Viento fuerte',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(36),
            title: _formatWindRangeLabel(
              lowerInclusiveKnots: 32,
              upperInclusiveKnots: 40,
            ),
            description: 'Viento muy fuerte',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(45),
            title: _formatWindRangeLabel(lowerExclusiveKnots: 40),
            description: 'Viento super fuerte',
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildWindSemaforoLegendRow({
    required Color color,
    required String title,
    required String description,
    required TextTheme textTheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Wrap(
            children: [
              Text(
                '$title: ',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(description, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKiteSizeGuideCard(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.air_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Tamano orientativo de cometa', style: textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildKiteSizeGuideRow(
            windRange: _formatWindRangeLabel(
              lowerInclusiveKnots: 10,
              upperInclusiveKnots: 14,
            ),
            kiteSize: '14 m o +',
            textTheme: textTheme,
          ),
          _buildKiteSizeGuideRow(
            windRange: _formatWindRangeLabel(
              lowerInclusiveKnots: 14,
              upperInclusiveKnots: 18,
            ),
            kiteSize: '12-14 m',
            textTheme: textTheme,
          ),
          _buildKiteSizeGuideRow(
            windRange: _formatWindRangeLabel(
              lowerInclusiveKnots: 18,
              upperInclusiveKnots: 22,
            ),
            kiteSize: '9-12 m',
            textTheme: textTheme,
          ),
          _buildKiteSizeGuideRow(
            windRange: _formatWindRangeLabel(
              lowerInclusiveKnots: 22,
              upperInclusiveKnots: 26,
            ),
            kiteSize: '7-9 m',
            textTheme: textTheme,
          ),
          _buildKiteSizeGuideRow(
            windRange: _formatWindRangeLabel(
              lowerInclusiveKnots: 26,
              upperInclusiveKnots: 32,
            ),
            kiteSize: '5-7 m',
            textTheme: textTheme,
          ),
          _buildKiteSizeGuideRow(
            windRange: _formatWindRangeLabel(lowerExclusiveKnots: 32),
            kiteSize: '4-5 m',
            textTheme: textTheme,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildKiteSizeGuideRow({
    required String windRange,
    required String kiteSize,
    required TextTheme textTheme,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: isLast ? 0 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.18),
                ),
              ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              windRange,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            kiteSize,
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
