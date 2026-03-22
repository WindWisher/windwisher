import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domain layer does not depend on UI or outer layers', () {
    final violations = <String>[];
    final files = _listDartFiles('lib/features');

    for (final file in files) {
      final normalizedPath = file.path.replaceAll('\\', '/');
      if (!normalizedPath.contains('/domain/')) {
        continue;
      }

      final imports = _readImports(file);
      for (final import in imports) {
        if (import.startsWith('package:flutter/') ||
            import.startsWith('package:flutter_riverpod/') ||
            import.startsWith('package:go_router/') ||
            import.contains('/presentation/') ||
            import.contains('/infrastructure/') ||
            import.contains('/data/')) {
          violations.add('$normalizedPath -> $import');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('presentation layer does not import infrastructure directly', () {
    final violations = <String>[];
    final files = _listDartFiles('lib/features');

    for (final file in files) {
      final normalizedPath = file.path.replaceAll('\\', '/');
      if (!normalizedPath.contains('/presentation/')) {
        continue;
      }

      final imports = _readImports(file);
      for (final import in imports) {
        if (import.contains('/infrastructure/')) {
          violations.add('$normalizedPath -> $import');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

List<File> _listDartFiles(String rootPath) {
  final root = Directory(rootPath);
  if (!root.existsSync()) {
    return const <File>[];
  }

  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList(growable: false);
}

List<String> _readImports(File file) {
  final importRegex = RegExp(r"^\s*import\s+'([^']+)';", multiLine: true);
  final content = file.readAsStringSync();
  return importRegex
      .allMatches(content)
      .map((match) => match.group(1)!)
      .toList(growable: false);
}
