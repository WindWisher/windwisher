import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:windwisher/app/router/app_routes.dart';
import 'package:windwisher/core/i18n/app_locale_controller.dart';
import 'package:windwisher/core/i18n/app_strings.dart';
import 'package:windwisher/core/notifications/firebase_push_messaging_service.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_service.dart';
import 'package:windwisher/core/notifications/push_notification_preferences.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/account/dialogs/change_password_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/account/dialogs/delete_account_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/account/account_deletion_request_presenter.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/account/account_deletion_request_repository.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/account/account_session_repository.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/account/account_settings_section.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/app/app_settings_launcher.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/app/app_settings_section.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/app/app_version_repository.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/legal/legal_settings_launcher.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/legal/legal_settings_section.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/notifications/notifications_settings_controller.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/notifications/notifications_settings_section.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/notifications/notification_permission_service.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/roles/role_panels_access.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/roles/role_panels_settings_section.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/roles/user_roles_repository.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/units/units_settings_section.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with WidgetsBindingObserver {
  bool _notificationsEnabled = false;
  bool _isUpdatingNotifications = true;
  bool _enableNotificationsAfterSettings = false;
  NotificationPermissionState _notificationPermissionState =
      NotificationPermissionState.unknown;
  bool _isSigningOut = false;
  bool _isLoadingRoles = false;
  bool _isLoadingDeletionRequest = false;
  String _appVersionLabel = '...';
  Set<String> _myRoles = const <String>{};
  Map<String, dynamic>? _accountDeletionRequest;
  Timer? _accountDeletionCountdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PushNotificationSubscriptionService.instance.addListener(
      _handlePushSubscriptionChanged,
    );
    _notificationsEnabled =
        PushNotificationSubscriptionService.instance.enabled;
    unawaited(_refreshNotificationState());
    unawaited(_loadMyRoles());
    unawaited(_loadAccountDeletionRequest());
    unawaited(_loadAppVersionLabel());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PushNotificationSubscriptionService.instance.removeListener(
      _handlePushSubscriptionChanged,
    );
    _accountDeletionCountdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshNotificationState());
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = ref.watch(appLocaleControllerProvider);
    final pushService = PushNotificationSubscriptionService.instance;
    final pushStatus = pushService.currentStatus;
    final rolesAccess = RolePanelsAccess.fromRoles(_myRoles);
    final sessionSummary = AccountSessionRepository.currentSummary();
    final deletionStatusRaw = (_accountDeletionRequest?['status'] as String?)
        ?.trim();
    final deletionStatusLabel = AccountDeletionRequestPresenter.statusLabel(
      deletionStatusRaw,
    );
    final deletionCountdownLabel =
        AccountDeletionRequestPresenter.countdownLabel(
          _accountDeletionRequest?['execute_after'],
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: kAppBouncingScrollPhysics,
        children: [
          const UnitsSettingsSection(),
          const SizedBox(height: AppSpacing.md),
          NotificationsSettingsSection(
            notificationsEnabled: _notificationsEnabled,
            permissionState: _notificationPermissionState,
            syncStatus: pushStatus,
            remoteProviderConfigured: pushService.remoteProviderConfigured,
            isBusy: _isUpdatingNotifications,
            onNotificationsChanged: (newValue) =>
                unawaited(_setNotificationsEnabled(newValue)),
            spotAlarmsEnabled: pushService.spotAlarmsEnabled,
            directMessagesEnabled: pushService.directMessagesEnabled,
            spotChatMentionsEnabled: pushService.spotChatMentionsEnabled,
            onSpotAlarmsChanged: (value) => unawaited(
              _setNotificationCategory(
                PushNotificationCategory.spotAlarms,
                value,
              ),
            ),
            onDirectMessagesChanged: (value) => unawaited(
              _setNotificationCategory(
                PushNotificationCategory.directMessages,
                value,
              ),
            ),
            onSpotChatMentionsChanged: (value) => unawaited(
              _setNotificationCategory(
                PushNotificationCategory.spotChatMentions,
                value,
              ),
            ),
            onOpenSystemSettings: () =>
                unawaited(_openNotificationSystemSettings()),
            onRetry: () => unawaited(_retryNotificationRegistration()),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSettingsSection(
            languageTitle: strings.language,
            languageLabel: strings.languageName(locale.languageCode),
            versionLabel: _appVersionLabel,
            onLanguageTap: () =>
                AppSettingsLauncher.showLanguagePickerDialog(context, ref),
            onFaqTap: () => AppSettingsLauncher.openFaq(context),
          ),
          const SizedBox(height: AppSpacing.md),
          LegalSettingsSection(
            onTermsTap: () => LegalSettingsLauncher.showTerms(context),
            onPrivacyTap: () => LegalSettingsLauncher.showPrivacy(context),
            onLegalNoticeTap: () =>
                LegalSettingsLauncher.showLegalNotice(context),
            onWeatherSafetyTap: () =>
                LegalSettingsLauncher.showWeatherSafetyDisclaimer(context),
            onCommunityGuidelinesTap: () =>
                LegalSettingsLauncher.showCommunityGuidelines(context),
            onDataSourcesLicensesTap: () =>
                LegalSettingsLauncher.showDataSourcesLicenses(context),
          ),
          if (!_isLoadingRoles && rolesAccess.hasAnyPanel) ...[
            const SizedBox(height: AppSpacing.md),
            RolePanelsSettingsSection(
              access: rolesAccess,
              onModeratorTap: _showRolePanelComingSoon,
              onManagerTap: _showRolePanelComingSoon,
              onAdminTap: () => context.push(AppRoutes.adminConsole),
              onSuperAdminTap: () => context.push(AppRoutes.superAdminConsole),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AccountSettingsSection(
            sessionSummary: sessionSummary,
            isLoadingDeletionRequest: _isLoadingDeletionRequest,
            deletionStatusLabel: deletionStatusLabel,
            deletionCountdownLabel: deletionCountdownLabel,
            deletionCountdownColor:
                AccountDeletionRequestPresenter.countdownColor(
                  context,
                  _accountDeletionRequest?['execute_after'],
                ),
            isSigningOut: _isSigningOut,
            onChangePasswordTap: _openChangePasswordDialog,
            onDeleteAccountTap: _openDeleteAccountDialog,
            onSignOutTap: _handleSignOut,
          ),
        ],
      ),
    );
  }

  void _handlePushSubscriptionChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      _notificationsEnabled =
          PushNotificationSubscriptionService.instance.enabled;
    });
  }

  Future<void> _refreshNotificationState() async {
    if (mounted) {
      setState(() => _isUpdatingNotifications = true);
    }
    try {
      await PushNotificationSubscriptionService.instance.initialize();
      final permissionState = await NotificationsSettingsController
          .permissionService
          .currentState();
      if (permissionState != NotificationPermissionState.granted &&
          permissionState != NotificationPermissionState.unknown &&
          PushNotificationSubscriptionService.instance.enabled) {
        await NotificationsSettingsController.setEnabled(
          false,
          pushInitError:
              FirebasePushMessagingService.instance.lastInitializationError,
        );
      }
      if (_enableNotificationsAfterSettings &&
          permissionState == NotificationPermissionState.granted) {
        _enableNotificationsAfterSettings = false;
        if (!mounted) {
          return;
        }
        setState(() {
          _notificationPermissionState = permissionState;
          _isUpdatingNotifications = false;
        });
        await _setNotificationsEnabled(true);
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _notificationPermissionState = permissionState;
        _notificationsEnabled =
            PushNotificationSubscriptionService.instance.enabled;
        _isUpdatingNotifications = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _notificationPermissionState = NotificationPermissionState.unknown;
        _isUpdatingNotifications = false;
      });
    }
  }

  Future<void> _setNotificationsEnabled(bool newValue) async {
    if (_isUpdatingNotifications) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isUpdatingNotifications = true);
    try {
      final result = await NotificationsSettingsController.setEnabled(
        newValue,
        pushInitError:
            FirebasePushMessagingService.instance.lastInitializationError,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _notificationsEnabled = result.enabled;
        _notificationPermissionState = result.permissionState;
      });
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'No se ha podido actualizar la configuracion. Intentalo de nuevo.',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingNotifications = false);
      }
    }
  }

  Future<void> _setNotificationCategory(
    PushNotificationCategory category,
    bool enabled,
  ) async {
    if (_isUpdatingNotifications) {
      return;
    }
    setState(() => _isUpdatingNotifications = true);
    try {
      await NotificationsSettingsController.setCategoryEnabled(
        category,
        enabled,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'No se ha podido actualizar esta preferencia. Intentalo de nuevo.',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingNotifications = false);
      }
    }
  }

  Future<void> _openNotificationSystemSettings() async {
    _enableNotificationsAfterSettings = true;
    var opened = false;
    try {
      opened = await NotificationsSettingsController.permissionService
          .openSystemSettings();
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      _enableNotificationsAfterSettings = false;
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se han podido abrir los ajustes del dispositivo.'),
        ),
      );
    }
  }

  Future<void> _retryNotificationRegistration() async {
    if (_isUpdatingNotifications) {
      return;
    }
    setState(() => _isUpdatingNotifications = true);
    try {
      await FirebasePushMessagingService.instance.refreshDeviceRegistration();
      await _refreshNotificationState();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido conectar el servicio. Intentalo de nuevo.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingNotifications = false);
      }
    }
  }

  Future<void> _loadMyRoles() async {
    setState(() => _isLoadingRoles = true);
    try {
      final roles = await UserRolesRepository.fetchCurrentUserRoles();
      if (!mounted) {
        return;
      }
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

  Future<void> _loadAppVersionLabel() async {
    try {
      final versionLabel = await AppVersionRepository.loadVersionLabel();
      if (!mounted) {
        return;
      }
      setState(() => _appVersionLabel = versionLabel);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _appVersionLabel = 'Version no disponible');
    }
  }

  Future<void> _loadAccountDeletionRequest() async {
    setState(() => _isLoadingDeletionRequest = true);
    try {
      final row =
          await AccountDeletionRequestRepository.fetchLatestScheduledRequest();
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
      builder: (_) => const ChangePasswordDialog(),
    );
  }

  Future<void> _openDeleteAccountDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const DeleteAccountDialog(),
    );
    if (!mounted) {
      return;
    }
    await _loadAccountDeletionRequest();
  }

  Duration? _accountDeletionRemainingTime() {
    return AccountDeletionRequestPresenter.remainingTime(
      _accountDeletionRequest?['execute_after'],
    );
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

  void _showRolePanelComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Este panel todavia no esta disponible.')),
    );
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
