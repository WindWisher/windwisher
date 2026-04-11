import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class ProfileGearMaterialHeader extends StatelessWidget {
  const ProfileGearMaterialHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tu material', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Primero configura las piezas de tu quiver. Luego podras crear equipaciones con ese material.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Gestionar piezas del quiver', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Cometas, tablas, barras y resto de material disponible para tus equipaciones.',
        ),
      ],
    );
  }
}
