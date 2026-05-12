part of '../../../spot_detail_page.dart';

class _LiveProviderLabel extends StatelessWidget {
  const _LiveProviderLabel({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final value = text;
    if (value == null) {
      return const SizedBox.shrink();
    }
    return Text(
      value,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
