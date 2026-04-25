import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/account/account_session_summary.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_section_card.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_tile.dart';

class AccountSettingsSection extends StatelessWidget {
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
                  sessionSummary.email == null || sessionSummary.email!.isEmpty
                      ? 'Sesion activa'
                      : sessionSummary.email!,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  sessionSummary.provider == null || sessionSummary.provider!.isEmpty
                      ? 'Cuenta autenticada en este dispositivo.'
                      : 'Proveedor de acceso: ${sessionSummary.provider}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isLoadingDeletionRequest) ...[
                  const SizedBox(height: AppSpacing.xs),
                  const LinearProgressIndicator(),
                ] else if (deletionStatusLabel != null) ...[
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
                      'Solicitud de eliminacion: $deletionStatusLabel',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  if (deletionCountdownLabel != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      deletionCountdownLabel!,
                      style: textTheme.bodySmall?.copyWith(
                        color: deletionCountdownColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Cambiar contrasena',
            icon: Icons.lock,
            onTap: onChangePasswordTap,
          ),
          SettingsTile(
            title: 'Eliminar cuenta',
            subtitle: deletionCountdownLabel,
            subtitleStyle: TextStyle(
              color: deletionCountdownColor,
              fontWeight: FontWeight.w600,
            ),
            icon: Icons.delete_outline,
            onTap: onDeleteAccountTap,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: isSigningOut
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout, color: Colors.red),
            title: Text(
              isSigningOut ? 'Cerrando sesion...' : 'Cerrar sesion',
              style: const TextStyle(color: Colors.red),
            ),
            onTap: isSigningOut ? null : onSignOutTap,
          ),
        ],
      ),
    );
  }
}
