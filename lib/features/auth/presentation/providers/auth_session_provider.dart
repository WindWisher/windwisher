import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windwisher/features/auth/presentation/providers/auth_di_providers.dart';

final authSessionProvider = AsyncNotifierProvider<AuthSessionNotifier, void>(
  AuthSessionNotifier.new,
);

class AuthSessionNotifier extends AsyncNotifier<void> {
  late final Future<String?> Function(String email) _signInWithEmail;
  late final Future<String?> Function({
    required String email,
    required String password,
  })
  _signInWithPassword;
  late final Future<String?> Function({
    required String email,
    required String password,
  })
  _signUpWithPassword;
  late final Future<String?> Function() _signInWithGoogle;
  late final Future<String?> Function() _signInWithApple;
  late final Future<void> Function() _signInWithDev;
  late final Future<void> Function() _signOut;
  late final Future<String?> Function(String email) _sendPasswordRecoveryEmail;

  @override
  FutureOr<void> build() {
    final module = ref.read(authModuleProvider);
    _signInWithEmail = module.signInWithEmail.call;
    _signInWithPassword = module.signInWithPassword.call;
    _signUpWithPassword = module.signUpWithPassword.call;
    _signInWithGoogle = module.signInWithGoogle.call;
    _signInWithApple = module.signInWithApple.call;
    _signInWithDev = module.signInWithDev.call;
    _signOut = module.signOut.call;
    _sendPasswordRecoveryEmail = module.sendPasswordRecoveryEmail.call;
  }

  Future<String?> signInWithEmail(String email) async {
    state = const AsyncLoading();
    final result = await _signInWithEmail(email);
    state = const AsyncData(null);
    return result;
  }

  Future<String?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await _signInWithPassword(email: email, password: password);
    state = const AsyncData(null);
    return result;
  }

  Future<String?> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await _signUpWithPassword(email: email, password: password);
    state = const AsyncData(null);
    return result;
  }

  Future<String?> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await _signInWithGoogle();
    state = const AsyncData(null);
    return result;
  }

  Future<String?> signInWithApple() async {
    state = const AsyncLoading();
    final result = await _signInWithApple();
    state = const AsyncData(null);
    return result;
  }

  Future<void> signInDev() async {
    state = const AsyncLoading();
    await _signInWithDev();
    state = const AsyncData(null);
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await _signOut();
    state = const AsyncData(null);
  }

  Future<String?> sendPasswordRecoveryEmail(String email) async {
    state = const AsyncLoading();
    final result = await _sendPasswordRecoveryEmail(email);
    state = const AsyncData(null);
    return result;
  }
}
