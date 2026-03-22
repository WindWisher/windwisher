import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:windwisher/app/router/app_routes.dart';
import 'package:windwisher/core/i18n/app_locale_controller.dart';
import 'package:windwisher/core/i18n/app_strings.dart';
import 'package:windwisher/core/i18n/language_picker.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_service.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/auth/presentation/providers/auth_session_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = PushNotificationSubscriptionService.instance.enabled;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = ref.watch(appLocaleControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final pushService = PushNotificationSubscriptionService.instance;
    final pushStatus = pushService.currentStatus;
    final pushToken = pushService.deviceToken;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: kAppBouncingScrollPhysics,
        children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unidades', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSettingTile(
                      context,
                      'Velocidad',
                      'Nudos (kt)',
                      Icons.speed,
                    ),
                    _buildSettingTile(
                      context,
                      'Distancia',
                      'Kilometros (km)',
                      Icons.straighten,
                    ),
                    _buildSettingTile(
                      context,
                      'Temperatura',
                      'Celsius (C)',
                      Icons.thermostat,
                    ),
                    _buildSettingTile(
                      context,
                      'Altura',
                      'Metros (m)',
                      Icons.height,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notificaciones', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSwitchTile(
                      'Activar notificaciones',
                      _notificationsEnabled,
                      (newValue) async {
                        final messenger = ScaffoldMessenger.of(context);
                        final status = await PushNotificationSubscriptionService
                            .instance
                            .setEnabled(newValue);
                        if (!mounted) {
                          return;
                        }
                        setState(() => _notificationsEnabled = newValue);
                        switch (status) {
                          case PushSubscriptionSyncStatus.synced:
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Suscripcion push del dispositivo sincronizada.',
                                ),
                              ),
                            );
                            break;
                          case PushSubscriptionSyncStatus.disabled:
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Notificaciones desactivadas en este dispositivo.'),
                              ),
                            );
                            break;
                          case PushSubscriptionSyncStatus.unauthenticated:
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Inicia sesion para sincronizar alarmas push entre dispositivos.'),
                              ),
                            );
                            break;
                          case PushSubscriptionSyncStatus.providerNotConfigured:
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Push remotas pendientes de configurar en la app. De momento solo estan listas las notificaciones locales.'),
                              ),
                            );
                            break;
                          case PushSubscriptionSyncStatus.missingDeviceToken:
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Proveedor push listo, pero este dispositivo aun no tiene token registrado.'),
                              ),
                            );
                            break;
                        }
                      },
                    ),
                    if (!PushNotificationSubscriptionService
                        .instance
                        .remoteProviderConfigured)
                      const Padding(
                        padding: EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          'Las push remotas para alarmas con la app cerrada siguen pendientes de configurar.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estado push: ${_pushSyncStatusLabel(pushStatus)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              pushToken == null || pushToken.isEmpty
                                  ? 'Token: pendiente'
                                  : 'Token: ${_obfuscatedToken(pushToken)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('App', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSettingTile(
                      context,
                      strings.language,
                      strings.languageName(locale.languageCode),
                      Icons.language,
                      onTap: () => showLanguagePicker(context, ref),
                    ),
                    _buildSettingTile(
                      context,
                      'Tema',
                      'Sistema',
                      Icons.palette,
                    ),
                    _buildSettingTile(
                      context,
                      'Version',
                      '2.0.0',
                      Icons.info_outline,
                    ),
                    _buildSettingTile(
                      context,
                      'Panel admin',
                      null,
                      Icons.admin_panel_settings_outlined,
                    ),
                    _buildSettingTile(context, 'FAQ', null, Icons.help_outline),
                    _buildSettingTile(
                      context,
                      'Donaciones',
                      null,
                      Icons.favorite,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cuenta', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSettingTile(
                      context,
                      'Editar perfil',
                      null,
                      Icons.edit,
                    ),
                    _buildSettingTile(
                      context,
                      'Cambiar contrasena',
                      null,
                      Icons.lock,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: _isSigningOut
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        _isSigningOut ? 'Cerrando sesion...' : 'Cerrar sesion',
                        style: const TextStyle(color: Colors.red),
                      ),
                      onTap: _isSigningOut ? null : _handleSignOut,
                    ),
                  ],
                ),
              ),
            ),
          ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String? subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: subtitle != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
                const Icon(Icons.chevron_right),
              ],
            )
          : const Icon(Icons.chevron_right),
      onTap: onTap ??
          (title == 'FAQ'
          ? () => context.push('/settings/faq')
          : title == 'Panel admin'
          ? () => context.push('/settings/admin')
          : title == 'Donaciones'
          ? () => context.push('/settings/donations')
          : () {}),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  String _pushSyncStatusLabel(PushSubscriptionSyncStatus status) {
    switch (status) {
      case PushSubscriptionSyncStatus.synced:
        return 'sincronizado';
      case PushSubscriptionSyncStatus.disabled:
        return 'desactivado';
      case PushSubscriptionSyncStatus.unauthenticated:
        return 'sin sesion';
      case PushSubscriptionSyncStatus.providerNotConfigured:
        return 'provider no configurado';
      case PushSubscriptionSyncStatus.missingDeviceToken:
        return 'sin token';
    }
  }

  String _obfuscatedToken(String token) {
    if (token.length <= 12) {
      return token;
    }
    return '${token.substring(0, 6)}...${token.substring(token.length - 6)}';
  }

  Future<void> _handleSignOut() async {
    setState(() => _isSigningOut = true);
    try {
      await ref.read(authSessionProvider.notifier).signOut();
      if (!mounted) {
        return;
      }
      context.go(AppRoutes.login);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cerrar sesion. Intentalo de nuevo.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }
}
