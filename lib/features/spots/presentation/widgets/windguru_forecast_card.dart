import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WindguruForecastCard extends StatelessWidget {
  const WindguruForecastCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.height,
    required this.controller,
    required this.isFullscreenActive,
    required this.onOpenFullscreen,
  });

  final Widget title;
  final String subtitle;
  final double height;
  final WebViewController controller;
  final bool isFullscreenActive;
  final VoidCallback onOpenFullscreen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Expanded(child: title)]),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                if (!isFullscreenActive)
                  WebViewWidget(controller: controller)
                else
                  ColoredBox(color: Theme.of(context).colorScheme.surface),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: IconButton(
                    onPressed: onOpenFullscreen,
                    tooltip: 'Ampliar tabla',
                    icon: const Icon(Icons.fullscreen_rounded),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WindguruFullscreenOverlay extends StatelessWidget {
  const WindguruFullscreenOverlay({
    super.key,
    required this.controller,
    required this.isSupported,
    required this.unsupportedMessage,
    required this.onClose,
  });

  final WebViewController? controller;
  final bool isSupported;
  final String unsupportedMessage;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;

    return Positioned.fill(
      child: Stack(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: isSupported && controller != null
                ? SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final webview = WebViewWidget(controller: controller!);
                        if (isLandscape) {
                          return SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: webview,
                          );
                        }
                        return SizedBox(
                          width: constraints.maxHeight,
                          height: constraints.maxWidth,
                          child: RotatedBox(quarterTurns: 1, child: webview),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      unsupportedMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
          Positioned(
            right: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: SafeArea(
              child: SizedBox(
                width: 34,
                height: 34,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: 'windguruFullscreenClose',
                  tooltip: 'Salir de fullscreen',
                  elevation: 0,
                  highlightElevation: 0,
                  backgroundColor: Colors.black.withValues(alpha: 0.22),
                  foregroundColor: Colors.white.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  onPressed: onClose,
                  child: const Icon(Icons.close_rounded, size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
