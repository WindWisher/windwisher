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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          data.statusText,
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CaptureSummaryRow(
                icon: Icons.timer_outlined,
                label: 'Tiempo',
                value: data.elapsedLabel,
              ),
              const SizedBox(height: AppSpacing.xs),
              _CaptureSummaryRow(
                icon: Icons.keyboard_double_arrow_up_rounded,
                label: 'Ultimo salto',
                value: data.lastJumpLabel,
              ),
              const SizedBox(height: AppSpacing.xs),
              _CaptureSummaryRow(
                icon: Icons.speed_rounded,
                label: 'Velocidad',
                value: data.currentSpeedLabel,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
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

class _CaptureSummaryRow extends StatelessWidget {
  const _CaptureSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$label:',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
