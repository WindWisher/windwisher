import 'package:windwisher/features/auth/domain/ports/out/auth_session_port.dart';

class SignInWithEmailUseCase {
  const SignInWithEmailUseCase(this._port);

  final AuthSessionPort _port;

  Future<String?> call(String email) {
    return _port.signInWithEmail(email);
  }
}

class SignInWithPasswordUseCase {
  const SignInWithPasswordUseCase(this._port);

  final AuthSessionPort _port;

  Future<String?> call({
    required String email,
    required String password,
  }) {
    return _port.signInWithPassword(email: email, password: password);
  }
}

class SignUpWithPasswordUseCase {
  const SignUpWithPasswordUseCase(this._port);

  final AuthSessionPort _port;

  Future<String?> call({
    required String email,
    required String password,
  }) {
    return _port.signUpWithPassword(email: email, password: password);
  }
}

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._port);

  final AuthSessionPort _port;

  Future<String?> call() {
    return _port.signInWithGoogle();
  }
}

class SignInWithAppleUseCase {
  const SignInWithAppleUseCase(this._port);

  final AuthSessionPort _port;

  Future<String?> call() {
    return _port.signInWithApple();
  }
}

class SignInWithDevUseCase {
  const SignInWithDevUseCase(this._port);

  final AuthSessionPort _port;

  Future<void> call() {
    return _port.signInDev();
  }
}

class SignOutUseCase {
  const SignOutUseCase(this._port);

  final AuthSessionPort _port;

  Future<void> call() {
    return _port.signOut();
  }
}

class SendPasswordRecoveryEmailUseCase {
  const SendPasswordRecoveryEmailUseCase(this._port);

  final AuthSessionPort _port;

  Future<String?> call(String email) {
    return _port.sendPasswordRecoveryEmail(email);
  }
}

class UpdatePasswordUseCase {
  const UpdatePasswordUseCase(this._port);

  final AuthSessionPort _port;

  Future<String?> call(String password) {
    return _port.updatePassword(password);
  }
}
