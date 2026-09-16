import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:windwisher/features/sessions/domain/ports/out/private_canonical_inbox_port.dart';
import 'package:windwisher/features/sessions/domain/services/private_canonical_validator.dart';

class PrivateCanonicalInbox implements PrivateCanonicalInboxPort {
  PrivateCanonicalInbox(this.root, this.validator);
  final Directory root;
  final PrivateCanonicalValidator validator;
  static bool _busy = false;

  static Directory accountRoot(Directory installationRoot, String accountId) {
    final normalizedAccountId = accountId.trim();
    if (normalizedAccountId.isEmpty) {
      throw ArgumentError.value(
        accountId,
        'accountId',
        'No puede estar vacío.',
      );
    }
    final accountKey = sha256
        .convert(utf8.encode(normalizedAccountId))
        .toString();
    return Directory(
      '${installationRoot.path}${Platform.pathSeparator}accounts'
      '${Platform.pathSeparator}$accountKey',
    );
  }

  Future<Uint8List> _read(File file) async {
    if (await FileSystemEntity.type(file.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw const FormatException('Archivo no válido.');
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in file.openRead()) {
      if (builder.length + chunk.length > PrivateCanonicalValidator.maxBytes) {
        throw const FormatException('Archivo demasiado grande.');
      }
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  @override
  Future<List<PrivateCanonicalSession>> list() async {
    await root.create(recursive: true);
    final entries = await root.list(followLinks: false).take(65).toList();
    if (entries.length > 64) {
      throw const FormatException('Límite de bandeja alcanzado.');
    }
    final result = <PrivateCanonicalSession>[];
    for (final entry in entries) {
      final name = entry.path.split(Platform.pathSeparator).last;
      if (name.startsWith('.pending-')) {
        continue; // Keep interrupted writes for recovery, never erase.
      }
      if (entry is! Directory || !RegExp(r'^[a-f0-9]{64}$').hasMatch(name)) {
        throw const FormatException('Bandeja no válida.');
      }
      final session = validator.validate(
        await _read(File('${entry.path}/source.jsonl')),
      );
      if (sha256.convert(utf8.encode(session.sourceId)).toString() != name) {
        throw const FormatException('Identidad no válida.');
      }
      result.add(session);
    }
    result.sort(
      (a, b) => DateTime.parse(b.endedAt).compareTo(DateTime.parse(a.endedAt)),
    );
    return result;
  }

  @override
  Future<PrivateCanonicalSession> validateBytes(Uint8List bytes) async {
    return validator.validate(bytes);
  }

  /// Returns false for an identical import. Same identity/different bytes is a conflict.
  @override
  Future<bool> importBytes(Uint8List bytes) async {
    if (_busy) throw StateError('Importación en curso.');
    _busy = true;
    try {
      final session = validator.validate(bytes);
      final existing = await list();
      for (final item in existing) {
        if (item.sourceId == session.sourceId) {
          if (item.digest != session.digest) {
            throw const FormatException(
              'Conflicto: la sesión ya existe con otro contenido.',
            );
          }
          return false;
        }
      }
      if (existing.length >= 32) {
        throw const FormatException('Bandeja llena (32 sesiones).');
      }
      final key = sha256.convert(utf8.encode(session.sourceId)).toString();
      final pending = await root.createTemp('.pending-');
      final file = File('${pending.path}/source.jsonl');
      await file.writeAsBytes(bytes, flush: true);
      if (validator.validate(await _read(file)).digest != session.digest) {
        throw const FormatException('Fallo de verificación local.');
      }
      await pending.rename('${root.path}/$key');
      return true;
    } finally {
      _busy = false;
    }
  }
}
