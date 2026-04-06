import 'dart:io';

import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/my_sessions_models.dart';
import 'package:windwisher/features/sessions/presentation/widgets/shared/session_device_action_chip.dart';
import 'package:windwisher/features/sessions/presentation/widgets/shared/session_gear_action_chip.dart';

class MySessionCard extends StatelessWidget {
  const MySessionCard({
    super.key,
    required this.data,
    required this.onTap,
    required this.onDevicePressed,
    required this.onGearPressed,
  });

  final MySessionCardData data;
  final VoidCallback onTap;
  final VoidCallback onDevicePressed;
  final VoidCallback onGearPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final photoPath = data.localPhotoPath;
    final hasRemotePhoto =
        photoPath != null &&
        (photoPath.startsWith('http://') || photoPath.startsWith('https://'));
    final hasPhotoPreview =
        hasRemotePhoto ||
        (photoPath != null && File(photoPath).existsSync());
    final metricChips = <Widget>[
      _buildChip(
        context: context,
        icon: Icons.timer_outlined,
        label: data.durationLabel,
      ),
      if (data.maxSpeedLabel != null)
        _buildChip(
          context: context,
          icon: Icons.speed_rounded,
          label: data.maxSpeedLabel!,
        ),
      if (data.hangtimeLabel != null)
        _buildChip(
          context: context,
          icon: Icons.air_rounded,
          label: 'Hangtime ${data.hangtimeLabel}',
        ),
      if (data.jumpLabel != null)
        _buildChip(
          context: context,
          icon: Icons.arrow_upward_rounded,
          label: 'Salto ${data.jumpLabel}',
        ),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: hasPhotoPreview
                  ? (hasRemotePhoto
                      ? Image.network(
                          photoPath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 170,
                        )
                      : Image.file(
                          File(photoPath),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 170,
                        ))
                  : Container(
                      width: double.infinity,
                      height: 88,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera_back_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sin foto',
                            style: textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (data.summary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      data.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      SessionDeviceActionChip(
                        deviceName: data.deviceName,
                        deviceKind: data.deviceKind,
                        onPressed: onDevicePressed,
                      ),
                      if (data.gearSetupName != null &&
                          data.gearSetupName!.isNotEmpty)
                        SessionGearActionChip(
                          label: data.gearSetupName!,
                          onPressed: onGearPressed,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < metricChips.length; i++) ...[
                          if (i > 0) const SizedBox(width: AppSpacing.xs),
                          metricChips[i],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
