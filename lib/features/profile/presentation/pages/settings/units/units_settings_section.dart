import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_section_card.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_tile.dart';

class UnitsSettingsSection extends StatefulWidget {
  const UnitsSettingsSection({super.key});

  @override
  State<UnitsSettingsSection> createState() => _UnitsSettingsSectionState();
}

class _UnitsSettingsSectionState extends State<UnitsSettingsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        maintainState: true,
        leading: const Icon(Icons.straighten),
        title: Text('Unidades', style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          _isExpanded ? 'Preferencias de medida' : 'kt, km, C, m',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        onExpansionChanged: (value) {
          setState(() => _isExpanded = value);
        },
        children: const [
          SizedBox(height: AppSpacing.xs),
          SettingsTile(
            title: 'Velocidad',
            subtitle: 'Nudos (kt)',
            icon: Icons.speed,
          ),
          SettingsTile(
            title: 'Distancia',
            subtitle: 'Kilometros (km)',
            icon: Icons.straighten,
          ),
          SettingsTile(
            title: 'Temperatura',
            subtitle: 'Celsius (C)',
            icon: Icons.thermostat,
          ),
          SettingsTile(
            title: 'Altura',
            subtitle: 'Metros (m)',
            icon: Icons.height,
          ),
        ],
      ),
    );
  }
}
