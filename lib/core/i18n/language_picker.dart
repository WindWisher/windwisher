import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windwisher/core/i18n/app_locale_controller.dart';
import 'package:windwisher/core/i18n/app_strings.dart';

Future<void> showLanguagePicker(
  BuildContext context,
  WidgetRef ref,
) {
  final strings = AppStrings.of(context);
  final currentLocale = ref.read(appLocaleControllerProvider);

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                strings.chooseLanguage,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...AppStrings.supportedLocales.map((locale) {
              final selected =
                  currentLocale.languageCode == locale.languageCode;
              return ListTile(
                leading: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(strings.languageName(locale.languageCode)),
                onTap: () async {
                  await ref
                      .read(appLocaleControllerProvider.notifier)
                      .setLocale(locale);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              );
            }),
          ],
        ),
      );
    },
  );
}
