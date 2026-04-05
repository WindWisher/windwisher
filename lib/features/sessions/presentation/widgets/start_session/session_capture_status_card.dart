import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class SessionCaptureStatusCard extends StatelessWidget {
  const SessionCaptureStatusCard({
    super.key,
    required this.statusText,
    required this.stepProgress,
    required this.elapsedLabel,
    required this.gpsLabel,
    required this.gpsBackgroundColor,
    required this.gpsForegroundColor,
    required this.gpsIcon,
    required this.autoPauseLabel,
    required this.autoPauseBackgroundColor,
    required this.autoPauseForegroundColor,
    required this.autoPauseIcon,
    required this.currentSpeedLabel,
    required this.maxSpeedLabel,
    required this.activeLabel,
    required this.pausedLabel,
    required this.saveReadinessLabel,
    required this.saveReadinessBackgroundColor,
    required this.saveReadinessForegroundColor,
    required this.saveReadinessIcon,
    required this.actionLabel,
    required this.actionIcon,
    required this.actionTextStyle,
    required this.onActionPressed,
    required this.actionEnabled,
  });

  final String statusText;
  final double stepProgress;
  final String elapsedLabel;
  final String gpsLabel;
  final Color gpsBackgroundColor;
  final Color gpsForegroundColor;
  final IconData gpsIcon;
  final String autoPauseLabel;
  final Color autoPauseBackgroundColor;
  final Color autoPauseForegroundColor;
  final IconData autoPauseIcon;
  final String currentSpeedLabel;
  final String maxSpeedLabel;
  final String activeLabel;
  final String pausedLabel;
  final String saveReadinessLabel;
  final Color saveReadinessBackgroundColor;
  final Color saveReadinessForegroundColor;
  final IconData saveReadinessIcon;
  final String actionLabel;
  final IconData actionIcon;
  final TextStyle? actionTextStyle;
  final VoidCallback? onActionPressed;
  final bool actionEnabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          statusText,
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: stepProgress,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            Chip(
              avatar: const Icon(Icons.timer_outlined, size: 18),
              label: Text(
                'Tiempo: $elapsedLabel',
                style: textTheme.bodyMedium,
              ),
            ),
            Chip(
              backgroundColor: gpsBackgroundColor,
              avatar: Icon(
                gpsIcon,
                size: 18,
                color: gpsForegroundColor,
              ),
              label: Text(
                gpsLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: gpsForegroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Chip(
              backgroundColor: autoPauseBackgroundColor,
              avatar: Icon(
                autoPauseIcon,
                size: 18,
                color: autoPauseForegroundColor,
              ),
              label: Text(
                autoPauseLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: autoPauseForegroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Chip(
              avatar: const Icon(Icons.speed_rounded, size: 18),
              label: Text('Actual: $currentSpeedLabel'),
            ),
            Chip(
              avatar: const Icon(Icons.bolt_rounded, size: 18),
              label: Text('Max: $maxSpeedLabel'),
            ),
            Chip(
              avatar: const Icon(Icons.kayaking_rounded, size: 18),
              label: Text('Activo: $activeLabel'),
            ),
            Chip(
              avatar: const Icon(Icons.pause_circle_outline_rounded, size: 18),
              label: Text('Parado: $pausedLabel'),
            ),
            Chip(
              backgroundColor: saveReadinessBackgroundColor,
              avatar: Icon(
                saveReadinessIcon,
                size: 18,
                color: saveReadinessForegroundColor,
              ),
              label: Text(
                saveReadinessLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: saveReadinessForegroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
              textStyle: actionTextStyle,
            ),
            onPressed: actionEnabled ? onActionPressed : null,
            icon: Icon(actionIcon),
            label: Text(actionLabel),
          ),
        ),
      ],
    );
  }
}
