import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_section_card.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_tile.dart';

class UnitsSettingsSection extends StatelessWidget {
  const UnitsSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unidades'),
          SizedBox(height: AppSpacing.sm),
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
