part of '../../../spot_detail_page.dart';

class _LiveHistoryHeader extends StatelessWidget {
  const _LiveHistoryHeader({
    required this.intraday,
    required this.providerLabel,
    required this.stationName,
    required this.diagnosticLabel,
  });

  final bool intraday;
  final String providerLabel;
  final String stationName;
  final String? diagnosticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${intraday ? 'Historico intradia $providerLabel' : 'Historico diario $providerLabel'} · $stationName',
          style: theme.textTheme.titleMedium,
        ),
        if (diagnosticLabel != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            diagnosticLabel!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
