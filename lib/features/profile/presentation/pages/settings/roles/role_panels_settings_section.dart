import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/roles/role_panels_access.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_section_card.dart';

class RolePanelsSettingsSection extends StatelessWidget {
  const RolePanelsSettingsSection({
    super.key,
    required this.access,
    required this.onModeratorTap,
    required this.onManagerTap,
    required this.onAdminTap,
    required this.onSuperAdminTap,
  });

  final RolePanelsAccess access;
  final VoidCallback onModeratorTap;
  final VoidCallback onManagerTap;
  final VoidCallback onAdminTap;
  final VoidCallback onSuperAdminTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SettingsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel de roles',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Herramientas disponibles segun los permisos de esta cuenta.',
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: access.roles
                .map(
                  (role) => Chip(
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    labelStyle: textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                    label: Text(_roleLabel(role)),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: AppSpacing.md),
          if (access.hasModeratorPanel)
            _RolePanelTile(
              title: 'Panel moderador',
              subtitle: 'Moderacion de contenido y comunidad',
              icon: Icons.shield_outlined,
              color: const Color(0xFF00796B),
              onTap: onModeratorTap,
            ),
          if (access.hasManagerPanel)
            _RolePanelTile(
              title: 'Panel manager',
              subtitle: 'Gestion operativa de perfiles asignados',
              icon: Icons.manage_accounts_outlined,
              color: const Color(0xFF1565C0),
              onTap: onManagerTap,
            ),
          if (access.hasAdminPanel)
            _RolePanelTile(
              title: 'Panel admin',
              subtitle: 'Herramientas administrativas',
              icon: Icons.admin_panel_settings_outlined,
              color: const Color(0xFFE65100),
              onTap: onAdminTap,
            ),
          if (access.hasSuperAdminPanel)
            _RolePanelTile(
              title: 'Panel superadmin',
              subtitle: 'Acceso total a roles y auditoria',
              icon: Icons.workspace_premium_outlined,
              color: const Color(0xFF6A1B9A),
              onTap: onSuperAdminTap,
            ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    return switch (role) {
      'super_admin' => 'Superadmin',
      'admin' => 'Admin',
      'moderator' => 'Moderador',
      'manager' => 'Manager',
      'vip' => 'VIP',
      'pro' => 'Pro',
      _ => role,
    };
  }
}

class _RolePanelTile extends StatefulWidget {
  const _RolePanelTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_RolePanelTile> createState() => _RolePanelTileState();
}

class _RolePanelTileState extends State<_RolePanelTile> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() => _isPressed = value);
  }

  Future<void> _handleTap() async {
    _setPressed(true);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) {
      return;
    }
    widget.onTap();
    if (mounted) {
      _setPressed(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: AnimatedScale(
        scale: _isPressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: widget.color.withValues(alpha: 0.18),
            highlightColor: widget.color.withValues(alpha: 0.10),
            onHighlightChanged: _setPressed,
            onTap: _handleTap,
            child: Ink(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.color.withValues(
                    alpha: _isPressed ? 0.42 : 0.22,
                  ),
                ),
                gradient: LinearGradient(
                  colors: [
                    widget.color.withValues(alpha: _isPressed ? 0.20 : 0.13),
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 90),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(
                        alpha: _isPressed ? 0.24 : 0.15,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.icon, color: widget.color),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSlide(
                    offset: _isPressed ? const Offset(0.08, 0) : Offset.zero,
                    duration: const Duration(milliseconds: 90),
                    curve: Curves.easeOut,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: widget.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
