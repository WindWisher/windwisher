import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';

final appLocaleControllerProvider =
    NotifierProvider<AppLocaleController, Locale>(AppLocaleController.new);

class AppLocaleController extends Notifier<Locale> {
  static const _fileName = 'app_locale.json';
  static Locale _initialLocale = const Locale('es');

  static Future<void> initialize() async {
    if (kIsWeb) {
      _initialLocale = const Locale('es');
      return;
    }
    final file = File(AppStoragePaths.resolve(_fileName));
    if (!file.existsSync()) {
      return;
    }
    try {
      final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final code = (raw['languageCode'] as String?)?.trim();
      if (code != null && code.isNotEmpty) {
        _initialLocale = Locale(code);
      }
    } catch (_) {
      _initialLocale = const Locale('es');
    }
  }

  @override
  Locale build() => _initialLocale;

  Future<void> setLocale(Locale locale) async {
    if (state.languageCode == locale.languageCode) {
      return;
    }
    state = locale;
    _initialLocale = locale;
    if (kIsWeb) {
      return;
    }
    final file = File(AppStoragePaths.resolve(_fileName));
    await file.writeAsString(
      jsonEncode({'languageCode': locale.languageCode}),
      flush: true,
    );
  }
}
