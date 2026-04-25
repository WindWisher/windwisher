import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_section_card.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_tile.dart';

class LegalSettingsSection extends StatelessWidget {
  const LegalSettingsSection({
    super.key,
    required this.onTermsTap,
    required this.onPrivacyTap,
    required this.onLegalNoticeTap,
  });

  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onLegalNoticeTap;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informacion legal',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Consulta los documentos legales provisionales disponibles dentro de la app.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Terminos y condiciones',
            icon: Icons.description_outlined,
            onTap: onTermsTap,
          ),
          SettingsTile(
            title: 'Politica de privacidad',
            icon: Icons.privacy_tip_outlined,
            onTap: onPrivacyTap,
          ),
          SettingsTile(
            title: 'Aviso legal',
            icon: Icons.balance_outlined,
            onTap: onLegalNoticeTap,
          ),
        ],
      ),
    );
  }
}
