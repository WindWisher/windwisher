import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:windwisher/app/router/app_routes.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/auth/presentation/pages/login_page.dart';
import 'package:windwisher/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:windwisher/features/profile/presentation/pages/admin_console_page.dart';
import 'package:windwisher/features/profile/presentation/pages/donations_page.dart';
import 'package:windwisher/features/profile/presentation/pages/faq_page.dart';
import 'package:windwisher/features/profile/presentation/pages/settings_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final hasSupabase =
      EnvConfig.supabaseUrl.trim().isNotEmpty &&
      EnvConfig.supabaseAnonKey.trim().isNotEmpty;
  final hasSession = hasSupabase
      ? Supabase.instance.client.auth.currentSession != null
      : false;

  return GoRouter(
    initialLocation: hasSession ? AppRoutes.dashboard : AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
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
