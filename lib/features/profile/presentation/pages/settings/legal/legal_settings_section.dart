import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_section_card.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_tile.dart';

class LegalSettingsSection extends StatefulWidget {
  const LegalSettingsSection({
    super.key,
    required this.onTermsTap,
    required this.onPrivacyTap,
    required this.onLegalNoticeTap,
    required this.onWeatherSafetyTap,
    required this.onCommunityGuidelinesTap,
    required this.onDataSourcesLicensesTap,
  });

  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onLegalNoticeTap;
  final VoidCallback onWeatherSafetyTap;
  final VoidCallback onCommunityGuidelinesTap;
  final VoidCallback onDataSourcesLicensesTap;

  @override
  State<LegalSettingsSection> createState() => _LegalSettingsSectionState();
}

class _LegalSettingsSectionState extends State<LegalSettingsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            initiallyExpanded: _isExpanded,
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            maintainState: true,
            leading: const Icon(Icons.policy_outlined),
            title: Text(
              'Informacion legal',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              _isExpanded
                  ? 'Documentos legales disponibles en la app'
                  : 'Terminos, privacidad y seguridad',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            onExpansionChanged: (value) {
              setState(() => _isExpanded = value);
            },
            children: [
              const SizedBox(height: AppSpacing.xs),
              SettingsTile(
                title: 'Terminos y condiciones',
                icon: Icons.description_outlined,
                onTap: widget.onTermsTap,
              ),
              SettingsTile(
                title: 'Politica de privacidad',
                icon: Icons.privacy_tip_outlined,
                onTap: widget.onPrivacyTap,
              ),
              SettingsTile(
                title: 'Aviso legal',
                icon: Icons.balance_outlined,
                onTap: widget.onLegalNoticeTap,
              ),
              SettingsTile(
                title: 'Descargo de meteo y seguridad',
                icon: Icons.waves_outlined,
                onTap: widget.onWeatherSafetyTap,
              ),
              SettingsTile(
                title: 'Normas de comunidad y rankings',
                icon: Icons.groups_outlined,
                onTap: widget.onCommunityGuidelinesTap,
              ),
              SettingsTile(
                title: 'Fuentes de datos y licencias',
                icon: Icons.dataset_linked_outlined,
                onTap: widget.onDataSourcesLicensesTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
