import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:windwisher/app/router/app_routes.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/auth/presentation/pages/login_page.dart';
import 'package:windwisher/features/auth/presentation/pages/reset_password_page.dart';
import 'package:windwisher/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:windwisher/features/profile/presentation/pages/admin_console_page.dart';
import 'package:windwisher/features/profile/presentation/pages/donations_page.dart';
import 'package:windwisher/features/profile/presentation/pages/faq_page.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/settings_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final hasSupabase =
      EnvConfig.supabaseUrl.trim().isNotEmpty &&
      EnvConfig.supabaseAnonKey.trim().isNotEmpty;

  return GoRouter(
    redirect: (context, state) {
      final hasSession = hasSupabase
          ? Supabase.instance.client.auth.currentSession != null
          : false;
      final location = state.matchedLocation;
      final isLogin = location == AppRoutes.login;
      final isResetPassword = location == AppRoutes.resetPassword;

      if (isResetPassword) {
        return null;
      }

      if (!hasSession) {
        return isLogin ? null : AppRoutes.login;
      }

      return isLogin ? AppRoutes.dashboard : null;
    },
    errorBuilder: (context, state) => _RouterFallbackPage(
      hasSupabase: hasSupabase,
    ),
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, state) {
          final hasSession = hasSupabase
              ? Supabase.instance.client.auth.currentSession != null
              : false;
          return hasSession ? AppRoutes.dashboard : AppRoutes.login;
        },
      ),
      GoRoute(
        path: '/Home',
        redirect: (_, state) => AppRoutes.dashboard,
      ),
      GoRoute(
        path: '/home',
        redirect: (_, state) => AppRoutes.dashboard,
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.adminConsole,
        builder: (context, state) => const AdminConsolePage(),
      ),
      GoRoute(
        path: AppRoutes.faq,
        builder: (context, state) => const FaqPage(),
      ),
      GoRoute(
        path: AppRoutes.donations,
        builder: (context, state) => const DonationsPage(),
      ),
    ],
  );
});

class _RouterFallbackPage extends StatefulWidget {
  const _RouterFallbackPage({required this.hasSupabase});

  final bool hasSupabase;

  @override
  State<_RouterFallbackPage> createState() => _RouterFallbackPageState();
}

class _RouterFallbackPageState extends State<_RouterFallbackPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final hasSession = widget.hasSupabase
          ? Supabase.instance.client.auth.currentSession != null
          : false;
      context.go(hasSession ? AppRoutes.dashboard : AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
