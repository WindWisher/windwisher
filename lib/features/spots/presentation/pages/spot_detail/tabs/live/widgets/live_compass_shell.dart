part of '../../../spot_detail_page.dart';

class _LiveCompassShell extends StatelessWidget {
  const _LiveCompassShell({
    required this.child,
    required this.compassEnabled,
    required this.canToggleCompass,
    required this.isRefreshing,
    required this.onToggleCompass,
    required this.onRefresh,
  });

  final Widget child;
  final bool compassEnabled;
  final bool canToggleCompass;
  final bool isRefreshing;
  final VoidCallback onToggleCompass;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: AppSpacing.xs,
          left: AppSpacing.xs,
          child: IconButton.filledTonal(
            tooltip: compassEnabled ? 'Desactivar brujula' : 'Activar brujula',
            onPressed: canToggleCompass ? onToggleCompass : null,
            icon: Icon(
              compassEnabled
                  ? Icons.explore_off_rounded
                  : Icons.explore_rounded,
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.xs,
          right: AppSpacing.xs,
          child: IconButton.filledTonal(
            tooltip: 'Refrescar estacion',
            onPressed: isRefreshing ? null : onRefresh,
            icon: isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ),
      ],
    );
  }
}
