import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/account/account_session_summary.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_section_card.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_tile.dart';

class AccountSettingsSection extends StatefulWidget {
  const AccountSettingsSection({
    super.key,
    required this.sessionSummary,
    required this.isLoadingDeletionRequest,
    required this.deletionStatusLabel,
    required this.deletionCountdownLabel,
    required this.deletionCountdownColor,
    required this.isSigningOut,
    required this.onChangePasswordTap,
    required this.onDeleteAccountTap,
    required this.onSignOutTap,
  });

  final AccountSessionSummary sessionSummary;
  final bool isLoadingDeletionRequest;
  final String? deletionStatusLabel;
  final String? deletionCountdownLabel;
  final Color? deletionCountdownColor;
  final bool isSigningOut;
  final VoidCallback onChangePasswordTap;
  final VoidCallback onDeleteAccountTap;
  final VoidCallback onSignOutTap;

  @override
  State<AccountSettingsSection> createState() => _AccountSettingsSectionState();
}

class _AccountSettingsSectionState extends State<AccountSettingsSection> {
  bool _isSecurityExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cuenta', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sessionSummary.email == null ||
                          widget.sessionSummary.email!.isEmpty
                      ? 'Sesion activa'
                      : widget.sessionSummary.email!,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.sessionSummary.provider == null ||
                          widget.sessionSummary.provider!.isEmpty
                      ? 'Cuenta autenticada en este dispositivo.'
                      : 'Proveedor de acceso: ${widget.sessionSummary.provider}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (widget.isLoadingDeletionRequest) ...[
                  const SizedBox(height: AppSpacing.xs),
                  const LinearProgressIndicator(),
                ] else if (widget.deletionStatusLabel != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Solicitud de eliminacion: ${widget.deletionStatusLabel}',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  if (widget.deletionCountdownLabel != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.deletionCountdownLabel!,
                      style: textTheme.bodySmall?.copyWith(
                        color: widget.deletionCountdownColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ExpansionTile(
            initiallyExpanded: _isSecurityExpanded,
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            maintainState: true,
            leading: const Icon(Icons.security_outlined),
            title: const Text('Seguridad y cuenta'),
            subtitle: Text(
              _isSecurityExpanded
                  ? 'Contrasena y eliminacion'
                  : widget.deletionCountdownLabel ??
                        'Cambiar contrasena o eliminar cuenta',
              style: textTheme.bodySmall?.copyWith(
                color:
                    widget.deletionCountdownColor ??
                    colorScheme.onSurfaceVariant,
                fontWeight: widget.deletionCountdownLabel == null
                    ? FontWeight.w400
                    : FontWeight.w600,
              ),
            ),
            onExpansionChanged: (value) {
              setState(() => _isSecurityExpanded = value);
            },
            children: [
              const SizedBox(height: AppSpacing.xs),
              SettingsTile(
                title: 'Cambiar contrasena',
                icon: Icons.lock,
                onTap: widget.onChangePasswordTap,
              ),
              SettingsTile(
                title: 'Eliminar cuenta',
                subtitle: widget.deletionCountdownLabel,
                subtitleStyle: TextStyle(
                  color: widget.deletionCountdownColor,
                  fontWeight: FontWeight.w600,
                ),
                icon: Icons.delete_outline,
                onTap: widget.onDeleteAccountTap,
              ),
            ],
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: widget.isSigningOut
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout, color: Colors.red),
            title: Text(
              widget.isSigningOut ? 'Cerrando sesion...' : 'Cerrar sesion',
              style: const TextStyle(color: Colors.red),
            ),
            onTap: widget.isSigningOut ? null : widget.onSignOutTap,
          ),
        ],
      ),
    );
  }
}
