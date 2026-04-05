import 'dart:io';

import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class MySessionCard extends StatelessWidget {
  const MySessionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.gearSetupName,
    required this.kiteLabel,
    required this.boardLabel,
    required this.localPhotoPath,
    required this.durationLabel,
    required this.jumpLabel,
    required this.hangtimeLabel,
    required this.jumpDistanceLabel,
    required this.maxSpeedLabel,
    required this.isNarrowPhone,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final String summary;
  final String gearSetupName;
  final String kiteLabel;
  final String boardLabel;
  final String? localPhotoPath;
  final String durationLabel;
  final String jumpLabel;
  final String hangtimeLabel;
  final String jumpDistanceLabel;
  final String maxSpeedLabel;
  final bool isNarrowPhone;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasPhotoPreview =
        localPhotoPath != null && File(localPhotoPath!).existsSync();

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
                  ? Image.file(
                      File(localPhotoPath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 170,
                    )
                  : Container(
                      width: double.infinity,
                      height: 120,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.photo_camera_back_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (summary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.checkroom_rounded, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          gearSetupName,
                          style: textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(kiteLabel, style: textTheme.bodySmall),
                  Text(boardLabel, style: textTheme.bodySmall),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChip(label: 'Duracion $durationLabel'),
                        const SizedBox(width: AppSpacing.xs),
                        _buildChip(label: 'Salto $jumpLabel'),
                        const SizedBox(width: AppSpacing.xs),
                        _buildChip(label: 'Hangtime $hangtimeLabel'),
                        const SizedBox(width: AppSpacing.xs),
                        _buildChip(label: 'Dist salto $jumpDistanceLabel'),
                        const SizedBox(width: AppSpacing.xs),
                        _buildChip(label: 'Vel max $maxSpeedLabel'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            minimumSize: const Size(0, 36),
                          ),
                          icon: isNarrowPhone
                              ? const SizedBox.shrink()
                              : const Icon(Icons.edit_rounded, size: 16),
                          label: const Text('Editar'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Tooltip(
                        message: 'Eliminar sesion',
                        child: SizedBox(
                          height: 36,
                          width: 44,
                          child: OutlinedButton(
                            onPressed: onDelete,
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({required String label}) {
    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(label),
    );
  }
}
