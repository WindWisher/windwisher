import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/app/router/app_routes.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_service.dart';
import 'package:windwisher/features/auth/presentation/onboarding/first_login_flow_remote_store.dart';
import 'package:windwisher/features/auth/presentation/onboarding/first_login_flow_store.dart';
import 'package:windwisher/features/auth/presentation/onboarding/terms_and_conditions_dialog.dart';

class TermsAcceptanceGate extends StatefulWidget {
  const TermsAcceptanceGate({super.key, required this.child});

  final Widget child;

  @override
  State<TermsAcceptanceGate> createState() => _TermsAcceptanceGateState();
}

class _TermsAcceptanceGateState extends State<TermsAcceptanceGate> {
  final FirstLoginFlowStore _localStore = FirstLoginFlowStore();
  final FirstLoginFlowRemoteStore _remoteStore = FirstLoginFlowRemoteStore();

  bool _isChecking = true;
  bool _isAccepted = false;
  bool _isRunningDialog = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_checkTermsAcceptance());
  }

  @override
  Widget build(BuildContext context) {
    if (_isAccepted) {
      return widget.child;
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _errorMessage == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _isChecking
                            ? null
                            : () => unawaited(_checkTermsAcceptance()),
                        child: const Text('Reintentar'),
                      ),
                      TextButton(
                        onPressed: _isChecking
                            ? null
                            : () => unawaited(
                                _signOutAndGoLogin(
                                  'No se ha podido validar la aceptacion de terminos.',
                                ),
                              ),
                        child: const Text('Salir'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkTermsAcceptance() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        context.go(AppRoutes.login);
      }
      return;
    }

    try {
      final remoteState = await _remoteStore.loadForUser(user.id);
      if (!mounted) {
        return;
      }
      if (remoteState.hasAcceptedCurrentTerms) {
        setState(() {
          _isAccepted = true;
          _isChecking = false;
        });
        return;
      }
      setState(() => _isChecking = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_runTermsDialog(user.id));
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isChecking = false;
        _errorMessage =
            'No se ha podido comprobar la aceptacion de los terminos.';
      });
    }
  }

  Future<void> _runTermsDialog(String userId) async {
    if (_isRunningDialog || !mounted) {
      return;
    }
    _isRunningDialog = true;
    try {
      final accepted = await TermsAndConditionsDialog.show(context);
      if (!mounted) {
        return;
      }
      if (!accepted) {
        await _signOutAndGoLogin(
          'Has cancelado la aceptacion de los terminos. Inicia sesion de nuevo para continuar.',
        );
        return;
      }

      final acceptedAt = DateTime.now().toUtc();
      try {
        await _remoteStore.saveTermsAcceptance(
          userId: userId,
          termsVersion: FirstLoginFlowState.currentTermsVersion,
          acceptedAtUtc: acceptedAt,
        );
        await _localStore.saveForUser(
          userId,
          FirstLoginFlowState(
            acceptedTermsVersion: FirstLoginFlowState.currentTermsVersion,
            acceptedTermsAtIso: acceptedAt.toIso8601String(),
          ),
        );
        if (!mounted) {
          return;
        }
        setState(() {
          _isAccepted = true;
          _errorMessage = null;
        });
      } catch (_) {
        await _signOutAndGoLogin(
          'No se pudo guardar la aceptacion de los terminos. Inicia sesion de nuevo para intentarlo.',
        );
      }
    } finally {
      _isRunningDialog = false;
    }
  }

  Future<void> _signOutAndGoLogin(String message) async {
    await PushNotificationSubscriptionService.instance
        .disableCurrentDeviceSubscriptionForSignedInUser();
    await Supabase.instance.client.auth.signOut();
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    context.go(AppRoutes.login);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    });
  }
}
