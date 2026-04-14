import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:windwisher/app/router/app_router.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/config/env/local_env_store.dart';
import 'package:windwisher/core/i18n/app_locale_controller.dart';
import 'package:windwisher/core/notifications/firebase_push_messaging_service.dart';
import 'package:windwisher/core/notifications/local_notifications_service.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_service.dart';
import 'package:windwisher/core/i18n/app_strings.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await AppStoragePaths.ensureInitialized();
  await LocalEnvStore.initialize();
  await AppLocaleController.initialize();
  await _initializeSupabaseIfConfigured();
  runApp(const ProviderScope(child: AppBootstrap()));
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeBackgroundServices());
  });
}

Future<void> _initializeSupabaseIfConfigured() async {
  final url = EnvConfig.supabaseUrl.trim();
  final anonKey = EnvConfig.supabaseAnonKey.trim();
  if (url.isEmpty || anonKey.isEmpty) {
    return;
  }

  await Supabase.initialize(url: url, anonKey: anonKey);
}

Future<void> _initializeBackgroundServices() async {
  await LocalNotificationsService.instance.initialize();
  await LocalNotificationsService.instance.ensurePermissions();
  await PushNotificationSubscriptionService.instance.initialize();
  await Future<void>.delayed(const Duration(seconds: 2));
  await FirebasePushMessagingService.instance.initialize();
}

class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appLocaleControllerProvider);
    return MaterialApp.router(
      title: 'WindWisher',
      locale: locale,
      scrollBehavior: const AppScrollBehavior(),
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: [
        ...AppStrings.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
