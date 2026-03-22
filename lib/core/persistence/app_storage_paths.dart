import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

abstract final class AppStoragePaths {
  static String? _documentsPath;

  static Future<void> ensureInitialized() async {
    if (_documentsPath != null) {
      return;
    }
    if (kIsWeb) {
      _documentsPath = '';
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final appDir = Directory('${dir.path}${Platform.pathSeparator}windwisher');
    if (!appDir.existsSync()) {
      appDir.createSync(recursive: true);
    }
    _documentsPath = appDir.path;
  }

  static String resolve(String fileName) {
    if (kIsWeb) {
      return fileName;
    }
    final base = _documentsPath;
    if (base != null) {
      return '$base${Platform.pathSeparator}$fileName';
    }
    final fallback = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}windwisher',
    );
    if (!fallback.existsSync()) {
      fallback.createSync(recursive: true);
    }
    return '${fallback.path}${Platform.pathSeparator}$fileName';
  }
}
