abstract class AuthSessionPort {
  Future<String?> signInWithEmail(String email);

  Future<String?> signInWithPassword({
    required String email,
    required String password,
  });

  Future<String?> signUpWithPassword({
    required String email,
    required String password,
  });

  Future<String?> signInWithGoogle();

  Future<String?> signInWithApple();

  Future<void> signInDev();

  Future<void> signOut();

  Future<String?> sendPasswordRecoveryEmail(String email);

  Future<String?> updatePassword(String password);
}
