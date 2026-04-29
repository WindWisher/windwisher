import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_section_card.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_tile.dart';

class AppSettingsSection extends StatefulWidget {
  const AppSettingsSection({
    super.key,
    required this.languageTitle,
    required this.languageLabel,
    required this.versionLabel,
    required this.onLanguageTap,
    required this.onFaqTap,
  });

  final String languageTitle;
  final String languageLabel;
  final String versionLabel;
  final VoidCallback onLanguageTap;
  final VoidCallback onFaqTap;

  @override
  State<AppSettingsSection> createState() => _AppSettingsSectionState();
}

class _AppSettingsSectionState extends State<AppSettingsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        maintainState: true,
        leading: const Icon(Icons.apps_outlined),
        title: Text('App', style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          _isExpanded ? 'Preferencias y ayuda' : widget.versionLabel,
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
            title: widget.languageTitle,
            subtitle: widget.languageLabel,
            icon: Icons.language,
            onTap: widget.onLanguageTap,
          ),
          const SettingsTile(
            title: 'Tema',
            subtitle: 'Sistema',
            icon: Icons.palette,
          ),
          SettingsTile(
            title: 'Version',
            subtitle: widget.versionLabel,
            icon: Icons.info_outline,
          ),
          SettingsTile(
            title: 'FAQ',
            icon: Icons.help_outline,
            onTap: widget.onFaqTap,
          ),
        ],
      ),
    );
  }
}
