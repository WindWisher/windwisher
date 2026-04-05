import 'dart:io';

import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/widgets/shared/session_device_action_chip.dart';
import 'package:windwisher/features/sessions/presentation/widgets/shared/session_gear_action_chip.dart';

class SessionHeroCard extends StatelessWidget {
  const SessionHeroCard({
    super.key,
    required this.title,
    required this.endedAt,
    required this.summary,
    required this.deviceName,
    required this.deviceKind,
    required this.gearSetupName,
    required this.sessionPhotoLocalPath,
    required this.spotBackgroundImagePath,
    required this.onDevicePressed,
    required this.onGearPressed,
  });

  final String title;
  final DateTime endedAt;
  final String summary;
  final String deviceName;
  final String deviceKind;
  final String? gearSetupName;
  final String? sessionPhotoLocalPath;
  final String? spotBackgroundImagePath;
  final VoidCallback onDevicePressed;
  final VoidCallback onGearPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasBackground =
        spotBackgroundImagePath != null && spotBackgroundImagePath!.isNotEmpty;
    final localPhotoPath = sessionPhotoLocalPath;
    final hasLocalPhoto =
        localPhotoPath != null && File(localPhotoPath).existsSync();

    final header = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              color: hasBackground ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${endedAt.day.toString().padLeft(2, '0')}/${endedAt.month.toString().padLeft(2, '0')} ${endedAt.hour.toString().padLeft(2, '0')}:${endedAt.minute.toString().padLeft(2, '0')}',
            style: textTheme.bodySmall?.copyWith(
              color: hasBackground ? Colors.white : null,
            ),
          ),
          if (hasLocalPhoto) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: double.infinity,
                height: 190,
                child: Image.file(
                  File(localPhotoPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          if (summary.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              summary,
              style: textTheme.bodyMedium?.copyWith(
                color: hasBackground ? Colors.white : null,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              SessionDeviceActionChip(
                deviceName: deviceName,
                deviceKind: deviceKind,
                onPressed: onDevicePressed,
              ),
              if (gearSetupName != null && gearSetupName!.isNotEmpty)
                SessionGearActionChip(
                  label: gearSetupName!,
                  onPressed: onGearPressed,
                ),
            ],
          ),
        ],
      ),
    );

    if (!hasBackground) {
      return Card(child: header);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              File(spotBackgroundImagePath!),
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
          header,
        ],
      ),
    );
  }

}
