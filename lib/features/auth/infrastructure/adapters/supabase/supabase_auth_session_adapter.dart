import 'package:windwisher/features/auth/domain/ports/out/auth_session_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthSessionAdapter implements AuthSessionPort {
  SupabaseAuthSessionAdapter({
    SupabaseClient? client,
    this.emailRedirectTo = 'windwisher://login-callback',
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final String emailRedirectTo;

  @override
  Future<String?> signInWithEmail(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return 'Introduce un email valido';
    }

    try {
      await _client.auth.signInWithOtp(
        email: trimmedEmail,
        emailRedirectTo: emailRedirectTo,
      );
      return null;
    } on AuthException catch (error) {
      if (error.message.toLowerCase().contains('rate limit')) {
        return 'Has intentado acceder demasiadas veces. Espera un poco antes de reenviar el enlace.';
      }
      return error.message;
    } catch (_) {
      return 'No se pudo iniciar sesion con Supabase.';
    }
  }

  @override
  Future<String?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return 'Introduce un email valido';
    }
    if (password.trim().length < 6) {
      return 'La contrasena debe tener al menos 6 caracteres';
    }

    try {
      await _client.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (_) {
      return 'No se pudo iniciar sesion con correo y contrasena.';
    }
  }

  @override
  Future<String?> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return 'Introduce un email valido';
    }
    if (password.trim().length < 6) {
      return 'La contrasena debe tener al menos 6 caracteres';
    }

    try {
      await _client.auth.signUp(email: trimmedEmail, password: password);
      return null;
    } on AuthException catch (error) {
      if (error.message.toLowerCase().contains('rate limit')) {
        return 'Has intentado crear o acceder demasiadas veces. Espera un poco antes de reintentar.';
      }
      return error.message;
    } catch (_) {
      return 'No se pudo crear la cuenta.';
    }
  }

  @override
  Future<String?> signInWithGoogle() async {
    return 'Google aun no esta configurado en Supabase.';
  }

  @override
  Future<String?> signInWithApple() async {
    return 'Apple aun no esta configurado en Supabase.';
  }

  @override
  Future<void> signInDev() async {
    final current = _client.auth.currentSession;
    if (current != null) {
      return;
    }
    try {
      await _client.auth.signInAnonymously();
    } on AuthException catch (error) {
      if (error.message.toLowerCase().contains('anonymous')) {
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<String?> sendPasswordRecoveryEmail(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return 'Introduce un email valido';
    }

    try {
      await _client.auth.resetPasswordForEmail(
        trimmedEmail,
        redirectTo: emailRedirectTo,
      );
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (_) {
      return 'No se pudo enviar el correo de recuperacion.';
    }
  }
}
