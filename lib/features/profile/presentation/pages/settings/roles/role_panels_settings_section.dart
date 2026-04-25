import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/roles/role_panels_access.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_section_card.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_tile.dart';

class RolePanelsSettingsSection extends StatelessWidget {
  const RolePanelsSettingsSection({
    super.key,
    required this.isLoading,
    required this.access,
    required this.onAdminTap,
    required this.onSuperAdminTap,
  });

  final bool isLoading;
  final RolePanelsAccess access;
  final VoidCallback onAdminTap;
  final VoidCallback onSuperAdminTap;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paneles por perfil',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: LinearProgressIndicator(),
            )
          else ...[
            if (access.roles.isNotEmpty)
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: access.roles
                    .map((role) => Chip(label: Text(role)))
                    .toList(growable: false),
              ),
            if (access.roles.isNotEmpty) const SizedBox(height: AppSpacing.sm),
            if (access.hasAdminPanel)
              SettingsTile(
                title: 'Panel admin',
                subtitle: access.hasSuperAdminPanel
                    ? 'Acceso ampliado de administracion'
                    : 'Herramientas administrativas',
                icon: Icons.admin_panel_settings_outlined,
                onTap: onAdminTap,
              ),
            if (access.hasSuperAdminPanel)
              SettingsTile(
                title: 'Panel superadmin',
                subtitle: 'Acceso total a roles y auditoria',
                icon: Icons.workspace_premium_outlined,
                onTap: onSuperAdminTap,
              ),
          ],
        ],
      ),
    );
  }
}
