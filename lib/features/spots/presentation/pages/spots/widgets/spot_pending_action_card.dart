part of '../spots_page.dart';

class _SpotPendingActionCard extends StatelessWidget {
  const _SpotPendingActionCard({
    required this.label,
    required this.isMultiMode,
    required this.selectedCount,
    required this.onCancel,
    required this.onApply,
  });

  final String label;
  final bool isMultiMode;
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.bodyMedium),
            if (isMultiMode) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('$selectedCount seleccionados', style: textTheme.bodySmall),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  FilledButton(
                    onPressed: onApply,
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
