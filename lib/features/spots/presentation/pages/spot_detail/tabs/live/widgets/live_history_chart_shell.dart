part of '../../../spot_detail_page.dart';

class _LiveHistoryChartShell extends StatelessWidget {
  const _LiveHistoryChartShell({
    required this.chart,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onOpenFullscreen,
  });

  final Widget chart;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onOpenFullscreen;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return SizedBox(
      height: 420,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(child: chart),
          Positioned(
            top: 10,
            right: 10,
            child: _LiveHistoryChartActionButton(
              tooltip: 'Refrescar grafica',
              surfaceColor: surfaceColor,
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
          Positioned(
            right: 10,
            bottom: 10,
            child: _LiveHistoryChartActionButton(
              tooltip: 'Pantalla completa',
              surfaceColor: surfaceColor,
              onPressed: onOpenFullscreen,
              icon: const Icon(Icons.fullscreen_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveHistoryChartActionButton extends StatelessWidget {
  const _LiveHistoryChartActionButton({
    required this.tooltip,
    required this.surfaceColor,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final Color surfaceColor;
  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      elevation: 2,
      shape: const CircleBorder(),
      child: IconButton(tooltip: tooltip, onPressed: onPressed, icon: icon),
    );
  }
}
