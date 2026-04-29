import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:windwisher/app/router/app_routes.dart';
import 'package:windwisher/core/i18n/language_picker.dart';

class AppSettingsLauncher {
  const AppSettingsLauncher._();

  static void showLanguagePickerDialog(BuildContext context, WidgetRef ref) {
    showLanguagePicker(context, ref);
  }

  static void openFaq(BuildContext context) {
    context.push(AppRoutes.faq);
  }
}
