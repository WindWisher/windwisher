part of '../spots_page.dart';

class _SpotAddHeader extends StatelessWidget {
  const _SpotAddHeader({
    required this.allowCustomMode,
    required this.onPickCustomPoint,
  });

  final bool allowCustomMode;
  final VoidCallback onPickCustomPoint;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Agregar spot', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        if (allowCustomMode)
          OutlinedButton.icon(
            onPressed: onPickCustomPoint,
            icon: const Icon(Icons.map_outlined),
            label: const Text('Personalizado'),
          )
        else
          Text(
            'Con el plan user solo puedes guardar spots oficiales.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
