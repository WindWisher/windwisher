import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/auth/application/use_cases/auth_sign_in_use_cases.dart';
import 'package:windwisher/features/auth/application/use_cases/recent_auth_accounts_use_cases.dart';
import 'package:windwisher/features/auth/infrastructure/adapters/in_memory/in_memory_auth_session_adapter.dart';
import 'package:windwisher/features/auth/infrastructure/adapters/in_memory/in_memory_recent_auth_accounts_adapter.dart';
import 'package:windwisher/features/auth/infrastructure/adapters/supabase/supabase_auth_session_adapter.dart';

class AuthModule {
  const AuthModule({
    required this.signInWithEmail,
    required this.signInWithPassword,
    required this.signUpWithPassword,
    required this.signInWithGoogle,
    required this.signInWithApple,
    required this.signInWithDev,
    required this.signOut,
    required this.sendPasswordRecoveryEmail,
    required this.getRecentAuthEmails,
    required this.addRecentAuthEmail,
    required this.removeRecentAuthEmail,
  });

  final SignInWithEmailUseCase signInWithEmail;
  final SignInWithPasswordUseCase signInWithPassword;
  final SignUpWithPasswordUseCase signUpWithPassword;
  final SignInWithGoogleUseCase signInWithGoogle;
  final SignInWithAppleUseCase signInWithApple;
  final SignInWithDevUseCase signInWithDev;
  final SignOutUseCase signOut;
  final SendPasswordRecoveryEmailUseCase sendPasswordRecoveryEmail;

  final GetRecentAuthEmailsUseCase getRecentAuthEmails;
  final AddRecentAuthEmailUseCase addRecentAuthEmail;
  final RemoveRecentAuthEmailUseCase removeRecentAuthEmail;

  factory AuthModule.inMemory() {
    final authSession = InMemoryAuthSessionAdapter();
    final recentAccounts = InMemoryRecentAuthAccountsAdapter();

    return AuthModule(
      signInWithEmail: SignInWithEmailUseCase(authSession),
      signInWithPassword: SignInWithPasswordUseCase(authSession),
      signUpWithPassword: SignUpWithPasswordUseCase(authSession),
      signInWithGoogle: SignInWithGoogleUseCase(authSession),
      signInWithApple: SignInWithAppleUseCase(authSession),
      signInWithDev: SignInWithDevUseCase(authSession),
      signOut: SignOutUseCase(authSession),
      sendPasswordRecoveryEmail: SendPasswordRecoveryEmailUseCase(authSession),
      getRecentAuthEmails: GetRecentAuthEmailsUseCase(recentAccounts),
      addRecentAuthEmail: AddRecentAuthEmailUseCase(recentAccounts),
      removeRecentAuthEmail: RemoveRecentAuthEmailUseCase(recentAccounts),
    );
  }

  factory AuthModule.auto() {
    final hasSupabase =
        EnvConfig.supabaseUrl.trim().isNotEmpty &&
        EnvConfig.supabaseAnonKey.trim().isNotEmpty;
    final authSession = hasSupabase
        ? SupabaseAuthSessionAdapter()
        : InMemoryAuthSessionAdapter();
    final recentAccounts = InMemoryRecentAuthAccountsAdapter();

    return AuthModule(
      signInWithEmail: SignInWithEmailUseCase(authSession),
      signInWithPassword: SignInWithPasswordUseCase(authSession),
      signUpWithPassword: SignUpWithPasswordUseCase(authSession),
      signInWithGoogle: SignInWithGoogleUseCase(authSession),
      signInWithApple: SignInWithAppleUseCase(authSession),
      signInWithDev: SignInWithDevUseCase(authSession),
      signOut: SignOutUseCase(authSession),
      sendPasswordRecoveryEmail: SendPasswordRecoveryEmailUseCase(authSession),
      getRecentAuthEmails: GetRecentAuthEmailsUseCase(recentAccounts),
      addRecentAuthEmail: AddRecentAuthEmailUseCase(recentAccounts),
      removeRecentAuthEmail: RemoveRecentAuthEmailUseCase(recentAccounts),
    );
  }
}
