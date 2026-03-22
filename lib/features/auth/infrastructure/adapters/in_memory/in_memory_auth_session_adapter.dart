import 'package:windwisher/features/auth/domain/ports/out/auth_session_port.dart';

class InMemoryAuthSessionAdapter implements AuthSessionPort {
  @override
  Future<String?> signInWithEmail(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return 'Introduce un email valido';
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));
    return null;
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
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return null;
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
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return null;
  }

  @override
  Future<String?> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return null;
  }

  @override
  Future<String?> signInWithApple() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return null;
  }

  @override
  Future<void> signInDev() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<String?> sendPasswordRecoveryEmail(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return 'Introduce un email valido';
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return null;
  }
}
