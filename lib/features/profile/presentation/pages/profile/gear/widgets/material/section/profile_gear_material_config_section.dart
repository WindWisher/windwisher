import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class ProfileGearMaterialConfigSection extends StatelessWidget {
  const ProfileGearMaterialConfigSection({
    super.key,
    required this.title,
    required this.buttonLabel,
    required this.icon,
    required this.savedLabel,
    required this.onPressed,
    required this.managementWidget,
  });

  final String title;
  final String buttonLabel;
  final IconData icon;
  final String savedLabel;
  final VoidCallback onPressed;
  final Widget managementWidget;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        FilledButton.tonalIcon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(buttonLabel),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(savedLabel),
        managementWidget,
        Text(
          'Disponible en el desplegable de equipacion personalizada.',
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
