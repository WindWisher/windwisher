import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class SessionCaptureStatusCard extends StatelessWidget {
  const SessionCaptureStatusCard({
    super.key,
    required this.data,
    required this.onActionPressed,
  });

  final SessionCaptureStatusCardData data;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          data.statusText,
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: data.stepProgress,
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
                'Tiempo: ${data.elapsedLabel}',
                style: textTheme.bodyMedium,
              ),
            ),
            Chip(
              backgroundColor: data.gpsBackgroundColor,
              avatar: Icon(
                data.gpsIcon,
                size: 18,
                color: data.gpsForegroundColor,
              ),
              label: Text(
                data.gpsLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: data.gpsForegroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Chip(
              backgroundColor: data.autoPauseBackgroundColor,
              avatar: Icon(
                data.autoPauseIcon,
                size: 18,
                color: data.autoPauseForegroundColor,
              ),
              label: Text(
                data.autoPauseLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: data.autoPauseForegroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Chip(
              avatar: const Icon(Icons.speed_rounded, size: 18),
              label: Text('Actual: ${data.currentSpeedLabel}'),
            ),
            Chip(
              avatar: const Icon(Icons.bolt_rounded, size: 18),
              label: Text('Max: ${data.maxSpeedLabel}'),
            ),
            Chip(
              avatar: const Icon(Icons.kayaking_rounded, size: 18),
              label: Text('Activo: ${data.activeLabel}'),
            ),
            Chip(
              avatar: const Icon(Icons.pause_circle_outline_rounded, size: 18),
              label: Text('Parado: ${data.pausedLabel}'),
            ),
            Chip(
              backgroundColor: data.saveReadinessBackgroundColor,
              avatar: Icon(
                data.saveReadinessIcon,
                size: 18,
                color: data.saveReadinessForegroundColor,
              ),
              label: Text(
                data.saveReadinessLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: data.saveReadinessForegroundColor,
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
              textStyle: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: data.actionEnabled ? onActionPressed : null,
            icon: Icon(data.actionIcon),
            label: Text(data.actionLabel),
          ),
        ),
      ],
    );
  }
}
