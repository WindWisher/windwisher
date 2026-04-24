import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/app/router/app_routes.dart';
import 'package:windwisher/core/i18n/app_locale_controller.dart';
import 'package:windwisher/core/i18n/app_strings.dart';
import 'package:windwisher/core/i18n/language_picker.dart';
import 'package:windwisher/core/notifications/firebase_push_messaging_service.dart';
import 'package:windwisher/core/notifications/local_notifications_service.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_service.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/auth/presentation/onboarding/legal_notice_dialog.dart';
import 'package:windwisher/features/auth/presentation/onboarding/privacy_policy_dialog.dart';
import 'package:windwisher/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:windwisher/features/auth/presentation/onboarding/terms_and_conditions_dialog.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _isSigningOut = false;
  bool _isLoadingRoles = false;
  bool _isLoadingDeletionRequest = false;
  Set<String> _myRoles = const <String>{};
  Map<String, dynamic>? _accountDeletionRequest;
  Timer? _accountDeletionCountdownTimer;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled =
        PushNotificationSubscriptionService.instance.enabled;
    unawaited(_loadMyRoles());
    unawaited(_loadAccountDeletionRequest());
  }

  @override
  void dispose() {
    _accountDeletionCountdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = ref.watch(appLocaleControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final pushService = PushNotificationSubscriptionService.instance;
    final pushStatus = pushService.currentStatus;
    final pushToken = pushService.deviceToken;
    final pushInitError = FirebasePushMessagingService.instance.lastInitializationError;
    final hasModeratorPanel =
        _myRoles.contains('moderator') || _myRoles.contains('super_admin');
    final hasManagerPanel =
        _myRoles.contains('manager') || _myRoles.contains('super_admin');
    final hasAdminPanel =
        _myRoles.contains('admin') || _myRoles.contains('super_admin');
    final hasSuperAdminPanel = _myRoles.contains('super_admin');
    final hasVipPanel =
        _myRoles.contains('vip') || _myRoles.contains('super_admin');
    final currentUser = Supabase.instance.client.auth.currentUser;
    final accountEmail = currentUser?.email?.trim();
    final accountProvider = currentUser?.appMetadata['provider'] as String?;
    final deletionStatusRaw = (_accountDeletionRequest?['status'] as String?)
        ?.trim();
    final deletionStatusLabel = _accountDeletionStatusLabel(deletionStatusRaw);
    final deletionCountdownLabel = _accountDeletionCountdownLabel();

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
                  _buildSwitchTile('Activar notificaciones', _notificationsEnabled, (
                    newValue,
                  ) async {
                    final messenger = ScaffoldMessenger.of(context);
                    if (newValue) {
                      final permissionsGranted =
                          await LocalNotificationsService.instance
                              .ensurePermissions();
                      if (!permissionsGranted) {
                        if (!mounted) {
                          return;
                        }
                        setState(() => _notificationsEnabled = false);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'El sistema no ha concedido permisos de notificacion en este dispositivo.',
                            ),
                          ),
                        );
                        return;
                      }
                      await FirebasePushMessagingService.instance
                          .refreshDeviceRegistration();
                    }
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
                            content: Text(
                              'Notificaciones desactivadas en este dispositivo.',
                            ),
                          ),
                        );
                        break;
                      case PushSubscriptionSyncStatus.unauthenticated:
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Inicia sesion para sincronizar alarmas push entre dispositivos.',
                            ),
                          ),
                        );
                        break;
                      case PushSubscriptionSyncStatus.providerNotConfigured:
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              pushInitError == null || pushInitError.isEmpty
                                  ? 'Push remotas pendientes de configurar en la app. De momento solo estan listas las notificaciones locales.'
                                  : 'No se ha podido inicializar el push remoto: $pushInitError',
                            ),
                          ),
                        );
                        break;
                      case PushSubscriptionSyncStatus.missingDeviceToken:
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Proveedor push listo, pero este dispositivo aun no tiene token registrado.',
                            ),
                          ),
                        );
                        break;
                    }
                  }),
                  if (!PushNotificationSubscriptionService
                      .instance
                      .remoteProviderConfigured)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Las push remotas para alarmas con la app cerrada siguen pendientes de configurar.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          if (pushInitError != null && pushInitError.isNotEmpty)
                            Text(
                              'Detalle: $pushInitError',
                              style: const TextStyle(color: Colors.grey),
                            ),
                        ],
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
                  _buildSettingTile(context, 'Tema', 'Sistema', Icons.palette),
                  _buildSettingTile(
                    context,
                    'Version',
                    '2.0.0',
                    Icons.info_outline,
                  ),
                  _buildSettingTile(
                    context,
                    'FAQ',
                    null,
                    Icons.help_outline,
                  ),
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
                  Text('Informacion legal', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Consulta los documentos legales provisionales disponibles dentro de la app.',
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSettingTile(
                    context,
                    'Terminos y condiciones',
                    null,
                    Icons.description_outlined,
                    onTap: () => TermsAndConditionsDialog.showReadOnly(context),
                  ),
                  _buildSettingTile(
                    context,
                    'Politica de privacidad',
                    null,
                    Icons.privacy_tip_outlined,
                    onTap: () => PrivacyPolicyDialog.show(context),
                  ),
                  _buildSettingTile(
                    context,
                    'Aviso legal',
                    null,
                    Icons.balance_outlined,
                    onTap: () => LegalNoticeDialog.show(context),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoadingRoles || _myRoles.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paneles por perfil', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    if (_isLoadingRoles)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: LinearProgressIndicator(),
                      )
                    else ...[
                      if (_myRoles.isNotEmpty)
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: _myRoles
                              .map((role) => Chip(label: Text(role)))
                              .toList(growable: false),
                        ),
                      if (_myRoles.isNotEmpty)
                        const SizedBox(height: AppSpacing.sm),
                      if (hasModeratorPanel)
                        _buildSettingTile(
                          context,
                          'Panel moderador',
                          'Moderacion de spots asignados',
                          Icons.shield_outlined,
                          onTap: () => _showInfoMessage(
                            'El panel de moderacion por spot se conectara aqui.',
                          ),
                        ),
                      if (hasManagerPanel)
                        _buildSettingTile(
                          context,
                          'Panel manager',
                          'Gestion de VIP, patrocinios y publicidades',
                          Icons.storefront_outlined,
                          onTap: () => _showInfoMessage(
                            'El panel manager se conectara aqui mas adelante.',
                          ),
                        ),
                      if (hasAdminPanel)
                        _buildSettingTile(
                          context,
                          'Panel admin',
                          hasSuperAdminPanel
                              ? 'Acceso ampliado de administracion'
                              : 'Herramientas administrativas',
                          Icons.admin_panel_settings_outlined,
                          onTap: () => context.push(AppRoutes.adminConsole),
                        ),
                      if (hasSuperAdminPanel)
                        _buildSettingTile(
                          context,
                          'Panel superadmin',
                          'Acceso total a roles y auditoria',
                          Icons.workspace_premium_outlined,
                          onTap: () => context.push(AppRoutes.adminConsole),
                        ),
                      if (hasVipPanel)
                        _buildSettingTile(
                          context,
                          'Apartado VIP',
                          'Patrocinios y publicidades',
                          Icons.campaign_outlined,
                          onTap: () => _showInfoMessage(
                            'El apartado VIP se conectara aqui mas adelante.',
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cuenta', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          accountEmail == null || accountEmail.isEmpty
                              ? 'Sesion activa'
                              : accountEmail,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          accountProvider == null || accountProvider.isEmpty
                              ? 'Cuenta autenticada en este dispositivo.'
                              : 'Proveedor de acceso: $accountProvider',
                          style: textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (_isLoadingDeletionRequest) ...[
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
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Solicitud de eliminacion: $deletionStatusLabel',
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          if (deletionCountdownLabel != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              deletionCountdownLabel,
                              style: textTheme.bodySmall?.copyWith(
                                color: _accountDeletionCountdownColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSettingTile(
                    context,
                    'Cambiar contrasena',
                    null,
                    Icons.lock,
                    onTap: _openChangePasswordDialog,
                  ),
                  _buildSettingTile(
                    context,
                    'Eliminar cuenta',
                    deletionCountdownLabel,
                    Icons.delete_outline,
                    subtitleStyle: TextStyle(
                      color: _accountDeletionCountdownColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                    onTap: _openDeleteAccountDialog,
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

  Future<void> _loadMyRoles() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      return;
    }
    setState(() => _isLoadingRoles = true);
    try {
      final rows = await client
          .from('user_roles')
          .select('role')
          .eq('user_id', userId);
      if (!mounted) {
        return;
      }
      final roles = (rows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((row) => (row['role'] as String? ?? '').trim())
          .where((role) => role.isNotEmpty)
          .toSet();
      setState(() {
        _myRoles = roles;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _myRoles = const <String>{};
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingRoles = false);
      }
    }
  }

  Future<void> _loadAccountDeletionRequest() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return;
    }
    setState(() => _isLoadingDeletionRequest = true);
    try {
      final row = await Supabase.instance.client
          .from('account_deletion_requests')
          .select('id,status,created_at,execute_after')
          .eq('user_id', userId)
          .eq('status', 'scheduled')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (!mounted) {
        return;
      }
      setState(() {
        _accountDeletionRequest = row;
      });
      _syncAccountDeletionCountdown();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _accountDeletionRequest = null;
      });
      _syncAccountDeletionCountdown();
    } finally {
      if (mounted) {
        setState(() => _isLoadingDeletionRequest = false);
      }
    }
  }

  Future<void> _openChangePasswordDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _ChangePasswordDialog(),
    );
  }

  Future<void> _openDeleteAccountDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (!mounted) {
      return;
    }
    await _loadAccountDeletionRequest();
  }

  void _showInfoMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String? subtitle,
    IconData icon, {
    VoidCallback? onTap,
    TextStyle? subtitleStyle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: subtitle != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subtitle,
                  style: subtitleStyle ?? const TextStyle(color: Colors.grey),
                ),
                const Icon(Icons.chevron_right),
              ],
            )
          : const Icon(Icons.chevron_right),
      onTap:
          onTap ??
          (title == 'FAQ'
              ? () => context.push('/settings/faq')
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

  String? _accountDeletionStatusLabel(String? status) {
    switch (status) {
      case 'scheduled':
        return 'Programada';
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return null;
    }
  }

  DateTime? _parseDeletionTimestamp(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }

  Duration? _accountDeletionRemainingTime() {
    final executeAfter = _parseDeletionTimestamp(
      _accountDeletionRequest?['execute_after'],
    );
    if (executeAfter == null) {
      return null;
    }
    final remaining = executeAfter.difference(DateTime.now().toUtc());
    if (remaining.isNegative) {
      return Duration.zero;
    }
    return remaining;
  }

  String? _accountDeletionCountdownLabel() {
    final remaining = _accountDeletionRemainingTime();
    if (remaining == null) {
      return null;
    }
    if (remaining == Duration.zero) {
      return 'Pendiente de borrado';
    }

    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h restantes';
    }
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${minutes}m restantes';
    }
    return '${remaining.inMinutes}m restantes';
  }

  Color? _accountDeletionCountdownColor(BuildContext context) {
    final remaining = _accountDeletionRemainingTime();
    if (remaining == null) {
      return null;
    }
    final colorScheme = Theme.of(context).colorScheme;
    if (remaining == Duration.zero) {
      return colorScheme.error;
    }
    if (remaining <= const Duration(hours: 24)) {
      return colorScheme.tertiary;
    }
    return colorScheme.onSurfaceVariant;
  }

  void _syncAccountDeletionCountdown() {
    _accountDeletionCountdownTimer?.cancel();
    if (_accountDeletionRemainingTime() == null) {
      return;
    }
    _accountDeletionCountdownTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (!mounted) {
          return;
        }
        if (_accountDeletionRemainingTime() == null) {
          _accountDeletionCountdownTimer?.cancel();
          return;
        }
        setState(() {});
      },
    );
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

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isSaving = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }
    final strings = AppStrings.of(context);
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.trim().length < 6) {
      setState(() {
        _errorText = strings.passwordTooShort;
      });
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        _errorText = strings.passwordsDoNotMatch;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final result = await ref
        .read(authSessionProvider.notifier)
        .updatePassword(password);
    if (!mounted) {
      return;
    }

    if (result != null) {
      setState(() {
        _isSaving = false;
        _errorText = result;
      });
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.passwordUpdated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final hasMinLength = password.trim().length >= 6;
    final passwordsMatch = password.isNotEmpty && password == confirmPassword;
    final mediaQuery = MediaQuery.of(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: mediaQuery.viewInsets +
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 12,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 520,
                maxHeight: mediaQuery.size.height -
                    mediaQuery.viewInsets.bottom -
                    (AppSpacing.md * 2),
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cambiar contrasena',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Actualiza tu contrasena de acceso para esta cuenta.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: strings.newPassword,
                        hintText: strings.passwordHint,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Mostrar contrasena'
                              : 'Ocultar contrasena',
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          if (_errorText != null) {
                            _errorText = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _save(),
                      decoration: InputDecoration(
                        labelText: strings.confirmPassword,
                        hintText: strings.passwordHint,
                        border: const OutlineInputBorder(),
                        errorText: _errorText,
                        suffixIcon: IconButton(
                          tooltip: _obscureConfirmPassword
                              ? 'Mostrar contrasena'
                              : 'Ocultar contrasena',
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          if (_errorText != null) {
                            _errorText = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requisitos',
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          _PasswordRequirementRow(
                            label: 'Minimo 6 caracteres',
                            met: hasMinLength,
                          ),
                          _PasswordRequirementRow(
                            label: 'Las dos contrasenas coinciden',
                            met: passwordsMatch,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OverflowBar(
                      alignment: MainAxisAlignment.end,
                      spacing: AppSpacing.sm,
                      overflowSpacing: AppSpacing.sm,
                      children: [
                        TextButton(
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(strings.saveNewPassword),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordRequirementRow extends StatelessWidget {
  const _PasswordRequirementRow({
    required this.label,
    required this.met,
  });

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final color = met
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 18,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  static const _deleteConfirmationPhrase = 'ELIMINAR CUENTA';

  final TextEditingController _confirmationController = TextEditingController();
  Timer? _countdownTimer;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isCancelling = false;
  String? _errorText;
  Map<String, dynamic>? _existingRequest;

  @override
  void initState() {
    super.initState();
    unawaited(_loadExistingRequest());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingRequest() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorText = 'No se ha encontrado una sesion valida.';
      });
      return;
    }

    try {
      final row = await Supabase.instance.client
          .from('account_deletion_requests')
          .select('id,status,created_at,updated_at,confirmed_at,execute_after')
          .eq('user_id', userId)
          .eq('status', 'scheduled')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (!mounted) {
        return;
      }
      setState(() {
        _existingRequest = row;
        _isLoading = false;
      });
      _syncCountdown();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorText =
            'No se pudo consultar el estado de la solicitud. Intentalo de nuevo.';
      });
      _syncCountdown();
    }
  }

  Future<void> _submitRequest() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || _isSubmitting) {
      return;
    }

    final confirmationValue = _confirmationController.text.trim().toUpperCase();
    if (confirmationValue != _deleteConfirmationPhrase) {
      setState(() {
        _errorText =
            'Escribe exactamente "$_deleteConfirmationPhrase" para continuar.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final now = DateTime.now().toUtc();
    final executeAfter = now.add(const Duration(days: 7));

    try {
      await Supabase.instance.client.from('account_deletion_requests').insert({
        'user_id': userId,
        'note': 'Self-service confirmed by typed phrase',
        'status': 'scheduled',
        'confirmed_at': now.toIso8601String(),
        'execute_after': executeAfter.toIso8601String(),
      });
      if (!mounted) {
        return;
      }
      await _loadExistingRequest();
      setState(() {
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _errorText =
            'No se pudo registrar la solicitud. Si ya existe una programada, anula primero la anterior.';
      });
    }
  }

  Future<void> _cancelRequest() async {
    final requestId = _existingRequest?['id'];
    if (requestId == null || _isCancelling || !_canCancelExistingRequest) {
      return;
    }

    setState(() {
      _isCancelling = true;
      _errorText = null;
    });

    try {
      await Supabase.instance.client
          .from('account_deletion_requests')
          .update({'status': 'cancelled'})
          .eq('id', requestId);
      if (!mounted) {
        return;
      }
      await _loadExistingRequest();
      setState(() {
        _isCancelling = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isCancelling = false;
        _errorText =
            'No se pudo anular la solicitud. Intentalo de nuevo dentro del plazo.';
      });
    }
  }

  String? _statusLabel(String? status) {
    switch (status) {
      case 'scheduled':
        return 'Programada';
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }

  bool get _canCancelExistingRequest {
    final executeAfter = _parseTimestamp(_existingRequest?['execute_after']);
    if (executeAfter == null) {
      return false;
    }
    return DateTime.now().toUtc().isBefore(executeAfter);
  }

  String _formatTimestamp(dynamic value) {
    final timestamp = _parseTimestamp(value);
    if (timestamp == null) {
      return '-';
    }
    final local = timestamp.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString().padLeft(4, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Duration? _remainingTime() {
    final executeAfter = _parseTimestamp(_existingRequest?['execute_after']);
    if (executeAfter == null) {
      return null;
    }
    final remaining = executeAfter.difference(DateTime.now().toUtc());
    if (remaining.isNegative) {
      return Duration.zero;
    }
    return remaining;
  }

  String? _countdownLabel() {
    final remaining = _remainingTime();
    if (remaining == null) {
      return null;
    }
    if (remaining == Duration.zero) {
      return 'Pendiente de borrado';
    }

    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h restantes';
    }
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${minutes}m restantes';
    }
    return '${remaining.inMinutes}m restantes';
  }

  Color? _countdownColor(BuildContext context) {
    final remaining = _remainingTime();
    if (remaining == null) {
      return null;
    }
    final colorScheme = Theme.of(context).colorScheme;
    if (remaining == Duration.zero) {
      return colorScheme.error;
    }
    if (remaining <= const Duration(hours: 24)) {
      return colorScheme.tertiary;
    }
    return colorScheme.onSurfaceVariant;
  }

  void _syncCountdown() {
    _countdownTimer?.cancel();
    if (_remainingTime() == null) {
      return;
    }
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) {
        return;
      }
      if (_remainingTime() == null) {
        _countdownTimer?.cancel();
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final existingRequest = _existingRequest;
    final existingRequestStatus = _statusLabel(
      (existingRequest?['status'] as String?)?.trim(),
    );
    final executeAfter = existingRequest?['execute_after'];
    final canCancelExistingRequest = _canCancelExistingRequest;
    final countdownLabel = _countdownLabel();
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_forever_outlined,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                        'Eliminar cuenta',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Confirma manualmente la eliminacion y abre un periodo de 7 dias antes del borrado definitivo.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: LinearProgressIndicator(),
                )
              else if (existingRequest != null) ...[
                Text(
                  'La eliminacion de esta cuenta ya esta programada.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado: ${existingRequestStatus ?? 'Pendiente'}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (countdownLabel != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          countdownLabel,
                          style: textTheme.bodySmall?.copyWith(
                            color: _countdownColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Creada: ${_formatTimestamp(existingRequest['created_at'])}',
                        style: textTheme.bodySmall,
                      ),
                      if (executeAfter != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Se eliminara automaticamente a partir de: ${_formatTimestamp(executeAfter)}',
                          style: textTheme.bodySmall,
                        ),
                        if (!canCancelExistingRequest) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'El plazo de anulacion ya ha terminado y la cuenta queda pendiente de ejecucion automatica.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'Escribe manualmente la frase de confirmacion para programar la eliminacion de la cuenta. Desde ese momento empezara el periodo de 7 dias en el que todavia podras anular la solicitud.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _confirmationController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Escribe "$_deleteConfirmationPhrase"',
                    hintText: _deleteConfirmationPhrase,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    if (_errorText != null) {
                      setState(() => _errorText = null);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'No hay revision manual. Si confirmas, la cuenta quedara programada para borrado automatico al terminar el plazo.',
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorText!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: OverflowBar(
                  alignment: MainAxisAlignment.end,
                  spacing: AppSpacing.sm,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                    if (!_isLoading && existingRequest != null)
                      FilledButton.tonal(
                        onPressed: _isCancelling || !canCancelExistingRequest
                            ? null
                            : _cancelRequest,
                        child: _isCancelling
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Anular solicitud'),
                      ),
                    if (!_isLoading && existingRequest == null)
                      FilledButton.tonal(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Solicitar eliminacion'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
