import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_section_card.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_tile.dart';

class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({
    super.key,
    required this.languageTitle,
    required this.languageLabel,
    required this.versionLabel,
    required this.onLanguageTap,
    required this.onFaqTap,
    required this.onDonationsTap,
  });

  final String languageTitle;
  final String languageLabel;
  final String versionLabel;
  final VoidCallback onLanguageTap;
  final VoidCallback onFaqTap;
  final VoidCallback onDonationsTap;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('App', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: languageTitle,
            subtitle: languageLabel,
            icon: Icons.language,
            onTap: onLanguageTap,
          ),
          const SettingsTile(
            title: 'Tema',
            subtitle: 'Sistema',
            icon: Icons.palette,
          ),
          SettingsTile(
            title: 'Version',
            subtitle: versionLabel,
            icon: Icons.info_outline,
          ),
          SettingsTile(
            title: 'FAQ',
            icon: Icons.help_outline,
            onTap: onFaqTap,
          ),
          SettingsTile(
            title: 'Donaciones',
            icon: Icons.favorite,
            onTap: onDonationsTap,
          ),
        ],
      ),
    );
  }
}
