import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:windwisher/app/router/app_routes.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/i18n/app_locale_controller.dart';
import 'package:windwisher/core/i18n/language_picker.dart';
import 'package:windwisher/core/i18n/app_strings.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:windwisher/features/auth/presentation/providers/recent_auth_accounts_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const Duration _emailCooldown = Duration(seconds: 45);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  DateTime? _emailCooldownUntil;
  _AuthAccessMode _mode = _AuthAccessMode.password;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _runProviderSignIn(Future<String?> Function() action) async {
    setState(() {
      _isSubmitting = true;
    });

    final error = await action();
    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    context.go(AppRoutes.dashboard);
  }

  Future<void> _submitEmailSignIn(String email) async {
    final strings = AppStrings.of(context);
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      _showSnack(strings.enterEmail, isError: true);
      return;
    }

    final cooldownRemaining = _emailCooldownRemaining;
    if (cooldownRemaining > 0) {
      _showSnack(strings.emailCooldown(cooldownRemaining), isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final error = await ref
        .read(authSessionProvider.notifier)
        .signInWithEmail(trimmedEmail);
    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    if (EnvConfig.supabaseConfigured &&
        Supabase.instance.client.auth.currentSession == null) {
      setState(() {
        _emailCooldownUntil = DateTime.now().add(_emailCooldown);
      });
      _showSnack(strings.emailSent(trimmedEmail));
      return;
    }

    context.go(AppRoutes.dashboard);
  }

  Future<void> _submitPasswordSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isSubmitting = true;
    });

    final error = await ref
        .read(authSessionProvider.notifier)
        .signInWithPassword(email: email, password: password);
    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    context.go(AppRoutes.dashboard);
  }

  Future<void> _submitSignUp() async {
    final strings = AppStrings.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isSubmitting = true;
    });

    final error = await ref
        .read(authSessionProvider.notifier)
        .signUpWithPassword(email: email, password: password);
    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    if (EnvConfig.supabaseConfigured &&
        Supabase.instance.client.auth.currentSession == null) {
      _showSnack(strings.accountCreated);
      return;
    }

    context.go(AppRoutes.dashboard);
  }

  Future<void> _submitPasswordRecovery() async {
    final strings = AppStrings.of(context);
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack(strings.enterEmail, isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final error = await ref
        .read(authSessionProvider.notifier)
        .sendPasswordRecoveryEmail(email);
    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    _showSnack(strings.recoveryEmailSent(email));
  }

  void _showSnack(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  String _initialsFromEmail(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) {
      return 'WW';
    }

    final chunks = local
        .split(RegExp(r'[._\\-\\s]+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (chunks.length >= 2) {
      return '${chunks.first[0]}${chunks[1][0]}'.toUpperCase();
    }

    if (local.length == 1) {
      return local[0].toUpperCase();
    }

    return local.substring(0, 2).toUpperCase();
  }

  int get _emailCooldownRemaining {
    final until = _emailCooldownUntil;
    if (until == null) {
      return 0;
    }
    final seconds = until.difference(DateTime.now()).inSeconds;
    return seconds > 0 ? seconds : 0;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final currentLocale = ref.watch(appLocaleControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authSessionProvider);
    final recentEmailsState = ref.watch(recentAuthEmailsProvider);
    final recentAccountsActions = ref.watch(recentAuthAccountsActionsProvider);
    final isBusy = authState.isLoading || _isSubmitting;
    final cooldownRemaining = _emailCooldownRemaining;
    final emailActionEnabled = !isBusy && cooldownRemaining == 0;
    final showsPasswordField = true;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.40),
              colorScheme.secondaryContainer.withValues(alpha: 0.18),
              colorScheme.surface,
              colorScheme.surface,
            ],
            stops: const [0, 0.22, 0.7, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -40,
              child: _AmbientBlob(
                size: 240,
                color: colorScheme.secondary.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              top: 180,
              left: -60,
              child: _AmbientBlob(
                size: 180,
                color: colorScheme.primary.withValues(alpha: 0.10),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () => showLanguagePicker(context, ref),
                            icon: const Icon(Icons.language),
                            label: Text(
                              currentLocale.languageCode == 'zh'
                                  ? strings.languageSelector
                                  : currentLocale.languageCode.toUpperCase(),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildBrandHeader(context, textTheme, colorScheme, strings),
                        const SizedBox(height: AppSpacing.lg),
                        _buildFormPanel(
                          context,
                          textTheme,
                          colorScheme,
                          isBusy: isBusy,
                          emailActionEnabled: emailActionEnabled,
                          cooldownRemaining: cooldownRemaining,
                          showsPasswordField: showsPasswordField,
                          recentEmailsState: recentEmailsState,
                          recentAccountsActions: recentAccountsActions,
                          strings: strings,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandHeader(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppStrings strings,
  ) {
    return Column(
      children: [
        Container(
          width: 168,
          height: 168,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surface.withValues(alpha: 0.82),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerLowest,
            ),
            child: ClipOval(
              child: OverflowBox(
                maxWidth: 188,
                maxHeight: 188,
                child: Transform.scale(
                  scale: 1.12,
                  child: Image.asset(
                    'assets/branding/LogoWindWisher.png',
                    width: 168,
                    height: 168,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          strings.appName,
          textAlign: TextAlign.center,
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          strings.taglinePrimary,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          strings.taglineSecondary,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildFormPanel(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme, {
    required bool isBusy,
    required bool emailActionEnabled,
    required int cooldownRemaining,
    required bool showsPasswordField,
    required AsyncValue<List<String>> recentEmailsState,
    required dynamic recentAccountsActions,
    required AppStrings strings,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _mode == _AuthAccessMode.signUp
                  ? strings.createAccountHeadline
                  : strings.loginHeadline,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: strings.email,
                hintText: strings.emailHint,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
            ),
            if (showsPasswordField) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) async {
                  if (isBusy) {
                    return;
                  }
                  if (_mode == _AuthAccessMode.password) {
                    await _submitPasswordSignIn();
                  } else {
                    await _submitSignUp();
                  }
                },
                decoration: InputDecoration(
                  labelText: _mode == _AuthAccessMode.signUp
                      ? strings.newPassword
                      : strings.password,
                  hintText: strings.passwordHint,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isBusy
                    ? null
                    : () async {
                        final email = _emailController.text.trim();
                        if (email.isNotEmpty) {
                          await recentAccountsActions.add(email);
                        }
                        if (_mode == _AuthAccessMode.password) {
                          await _submitPasswordSignIn();
                        } else if (_mode == _AuthAccessMode.signUp) {
                          await _submitSignUp();
                        } else {
                          await _submitEmailSignIn(email);
                        }
                      },
                icon: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _mode == _AuthAccessMode.signUp
                            ? Icons.person_add_alt_1_rounded
                            : Icons.login_rounded,
                      ),
                label: Text(
                  _mode == _AuthAccessMode.password
                      ? strings.signIn
                      : _mode == _AuthAccessMode.signUp
                      ? strings.createAccount
                      : strings.signIn,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: isBusy
                    ? null
                    : () {
                        setState(() {
                          _mode = _mode == _AuthAccessMode.password
                              ? _AuthAccessMode.signUp
                              : _AuthAccessMode.password;
                        });
                      },
                child: Text(
                  _mode == _AuthAccessMode.password
                      ? strings.createAccountPrompt
                      : strings.existingAccountPrompt,
                ),
              ),
            ),
            if (_mode == _AuthAccessMode.password) ...[
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: isBusy ? null : _submitPasswordRecovery,
                  child: Text(strings.forgotPassword),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (cooldownRemaining > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  strings.resendAvailable(cooldownRemaining),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: !emailActionEnabled
                    ? null
                    : () async {
                        final email = _emailController.text.trim();
                        if (email.isNotEmpty) {
                          await recentAccountsActions.add(email);
                        }
                        await _submitEmailSignIn(email);
                      },
                icon: const Icon(Icons.mark_email_unread_outlined),
                label: Text(
                  cooldownRemaining > 0
                      ? '${strings.magicLink} ${cooldownRemaining}s'
                      : strings.magicLink,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(
                    strings.socialAccess,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isBusy || !EnvConfig.googleAuthEnabled
                    ? null
                    : () async {
                        await _runProviderSignIn(
                          () => ref
                              .read(authSessionProvider.notifier)
                              .signInWithGoogle(),
                        );
                      },
                icon: const Icon(Icons.account_circle_outlined),
                label: Text(
                  EnvConfig.googleAuthEnabled
                      ? strings.continueGoogle
                      : strings.googleUnavailable,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isBusy || !EnvConfig.appleAuthEnabled
                    ? null
                    : () async {
                        await _runProviderSignIn(
                          () => ref
                              .read(authSessionProvider.notifier)
                              .signInWithApple(),
                        );
                      },
                icon: const Icon(Icons.apple),
                label: Text(
                  EnvConfig.appleAuthEnabled
                      ? strings.continueApple
                      : strings.appleUnavailable,
                ),
              ),
            ),
            if (EnvConfig.devBypassEnabled || kDebugMode) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: isBusy
                      ? null
                      : () async {
                          await ref
                              .read(authSessionProvider.notifier)
                              .signInDev();
                          if (!context.mounted) {
                            return;
                          }
                          context.go(AppRoutes.dashboard);
                        },
                  child: Text(strings.devBypass),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            recentEmailsState.when(
              data: (emails) {
                if (emails.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.recentAccounts,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...emails.take(3).map(
                        (email) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              child: Text(_initialsFromEmail(email)),
                            ),
                            title: Text(email),
                            subtitle: Text(strings.recentQuickAccess),
                            trailing: IconButton(
                              onPressed: isBusy
                                  ? null
                                  : () async {
                                      await recentAccountsActions.remove(email);
                                    },
                              icon: const Icon(Icons.close, size: 18),
                              tooltip: strings.removeRecent,
                            ),
                            onTap: isBusy
                                ? null
                                : () {
                                    setState(() {
                                      _emailController.text = email;
                                    });
                                  },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AuthAccessMode { password, signUp }

class _AmbientBlob extends StatelessWidget {
  const _AmbientBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: color.a * 0.25),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
