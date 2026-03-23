import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/app/router/app_routes.dart';
import 'package:windwisher/core/i18n/app_strings.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/auth/presentation/providers/auth_session_provider.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  StreamSubscription<AuthState>? _authSubscription;
  _RecoverySessionState _recoveryState = _RecoverySessionState.checking;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeRecoveryState());
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final event = data.event;
      if (!mounted) {
        return;
      }
      if (event == AuthChangeEvent.passwordRecovery ||
          event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        _refreshRecoveryState();
      }
    });
  }

  Future<void> _initializeRecoveryState() async {
    _refreshRecoveryState();
    if (!_expectedRecoveryLink ||
        Supabase.instance.client.auth.currentSession != null) {
      return;
    }

    try {
      await Supabase.instance.client.auth.getSessionFromUrl(Uri.base);
    } on AuthException {
      if (!mounted) {
        return;
      }
      setState(() {
        _recoveryState = _RecoverySessionState.invalid;
      });
      return;
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _recoveryState = _RecoverySessionState.invalid;
      });
      return;
    }

    if (!mounted) {
      return;
    }
    _refreshRecoveryState();
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted || _recoveryState == _RecoverySessionState.ready) {
        return;
      }
      setState(() {
        _recoveryState = _RecoverySessionState.invalid;
      });
    });
  }

  void _refreshRecoveryState() {
    final hasSession = Supabase.instance.client.auth.currentSession != null;
    setState(() {
      _recoveryState = hasSession
          ? _RecoverySessionState.ready
          : _expectedRecoveryLink
          ? _RecoverySessionState.checking
          : _RecoverySessionState.invalid;
    });
  }

  bool get _expectedRecoveryLink {
    final fragment = Uri.base.fragment;
    final query = Uri.base.query;
    return fragment.contains('type=recovery') ||
        fragment.contains('access_token=') ||
        query.contains('type=recovery') ||
        query.contains('code=');
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final strings = AppStrings.of(context);
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.trim().length < 6) {
      _showSnack(strings.passwordTooShort, isError: true);
      return;
    }
    if (password != confirmPassword) {
      _showSnack(strings.passwordsDoNotMatch, isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final error = await ref
        .read(authSessionProvider.notifier)
        .updatePassword(password);

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

    _showSnack(strings.passwordUpdated);
    await Supabase.instance.client.auth.signOut();
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.login);
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

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      strings.resetPasswordTitle,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _recoveryState == _RecoverySessionState.ready
                          ? strings.resetPasswordHelp
                          : _recoveryState == _RecoverySessionState.checking
                          ? strings.recoveryLinkChecking
                          : strings.invalidRecoveryLink,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_recoveryState == _RecoverySessionState.checking) ...[
                      const Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    ],
                    if (_recoveryState == _RecoverySessionState.ready) ...[
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: strings.newPassword,
                          hintText: strings.passwordHint,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        onSubmitted: (_) async {
                          if (!_isSubmitting) {
                            await _submit();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: strings.confirmPassword,
                          hintText: strings.passwordHint,
                          prefixIcon: const Icon(Icons.lock_reset_rounded),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
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
                    const SizedBox(height: AppSpacing.xs),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: Text(strings.backToLogin),
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

enum _RecoverySessionState { checking, ready, invalid }
