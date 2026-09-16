import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/sessions/domain/services/private_canonical_validator.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/local/private_canonical_inbox.dart';

String crc(String text) {
  var value = 0xffffffff;
  for (final byte in utf8.encode(text)) {
    value ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      value = ((value >> 1) ^ ((value & 1) == 1 ? 0xedb88320 : 0)) & 0xffffffff;
    }
  }
  return ((value ^ 0xffffffff) & 0xffffffff).toRadixString(16).padLeft(8, '0');
}

Uint8List rewrite(Uint8List bytes, void Function(List<dynamic>) mutate) {
  final records = utf8
      .decode(bytes)
      .trim()
      .split('\n')
      .map(jsonDecode)
      .toList();
  mutate(records);
  var stream = '';
  for (final record in records) {
    record.remove('checksumAlgorithm');
    record.remove('checksum');
    if (record['recordType'] == 'completion') {
      record['payload']['streamChecksum'] = crc(stream);
    }
    final checksum = crc(jsonEncode(record));
    record['checksumAlgorithm'] = 'crc32';
    record['checksum'] = checksum;
    stream += '${jsonEncode(record)}\n';
  }
  return Uint8List.fromList(utf8.encode(stream));
}

void main() {
  final schema =
      jsonDecode(
            File(
              'assets/contracts/canonical-session-record.schema.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final validator = PrivateCanonicalValidator(schema);
  final bytes = File('test/fixtures/private_canonical.jsonl').readAsBytesSync();
  test(
    'rejects invalid schema and semantics even with recomputed checksums',
    () {
      expect(validator.validate(rewrite(bytes, (_) {})).recordCount, 7);
      for (final mutate in <void Function(List<dynamic>)>[
        (r) => r.first['canonicalSchemaVersion'] = 'invalid',
        (r) => r.first['payload']['unexpected'] = true,
        (r) => r.first['payload']['privacy']['visibility'] = 'public',
        (r) => r.first['payload']['timing']['endedAt'] = '2023-02-31T12:00:00Z',
        (r) => r.first['payload']['timing']['endedAt'] = '2020-01-01T12:00:00Z',
        (r) => r.last['payload']['recordCounts']['track'] = 99,
        (r) => r[1]['recordSequence'] = 99,
      ]) {
        expect(
          () => validator.validate(rewrite(bytes, mutate)),
          throwsFormatException,
        );
      }
    },
  );
  test('rejects duplicate keys and excessive JSON depth before decoding', () {
    final text = utf8.decode(bytes);
    final duplicate = text.replaceFirst('{', '{"recordSequence":0,');
    final deep =
        '${List.filled(33, '[').join()}0${List.filled(33, ']').join()}\n';
    for (final bad in [duplicate, deep]) {
      expect(
        () => validator.validate(Uint8List.fromList(utf8.encode(bad))),
        throwsFormatException,
      );
    }
  });
  test('accepts host-produced stream with GPS HR pressure', () {
    final result = validator.validate(bytes);
    expect(result.sourceId, 'synthetic-inbox-session');
    expect(result.durationMs, 1000);
    expect(result.recordCount, 7);
    expect(result.digest.length, 64);
  });
  test(
    'rejects truncation, changed bytes, duplicate records, invalid UTF8 and oversize',
    () {
      final text = utf8.decode(bytes),
          lines = utf8.decode(bytes).trim().split('\n');
      for (final bad in [
        text.substring(0, text.length - 1),
        text.replaceFirst('2.25', '2.26'),
        '${lines.first}\n$text',
        '$text${lines.last}\n',
      ]) {
        expect(
          () => validator.validate(Uint8List.fromList(utf8.encode(bad))),
          throwsFormatException,
        );
      }
      expect(
        () => validator.validate(Uint8List.fromList([255, 10])),
        throwsFormatException,
      );
      expect(
        () => validator.validate(
          Uint8List.fromList(utf8.encode('not a canonical stream\n')),
        ),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'mensaje',
            'Archivo canónico inválido o incompleto.',
          ),
        ),
      );
      expect(
        () => validator.validate(
          Uint8List(PrivateCanonicalValidator.maxBytes + 1),
        ),
        throwsFormatException,
      );
    },
  );
  test(
    'private inbox survives reopen, deduplicates, rejects conflicts and never overwrites corrupt data',
    () async {
      final dir = await Directory.systemTemp.createTemp('ww-inbox-test-');
      addTearDown(() => dir.delete(recursive: true));
      final inbox = PrivateCanonicalInbox(dir, validator);
      expect(await inbox.importBytes(bytes), true);
      expect(
        await PrivateCanonicalInbox(dir, validator).importBytes(bytes),
        false,
      );
      expect((await inbox.list()).length, 1);
      // Adding an empty line retains valid framing but changes source bytes: conflict.
      await expectLater(
        inbox.importBytes(Uint8List.fromList([...bytes, 10])),
        throwsFormatException,
      );
      final modified = rewrite(bytes, (records) {
        records[1]['payload']['groundSpeedMps'] = 2.5;
      });
      expect(validator.validate(modified).sourceId, 'synthetic-inbox-session');
      await expectLater(inbox.importBytes(modified), throwsFormatException);
      final stored = await dir.list().single as Directory;
      final file = File('${stored.path}/source.jsonl');
      expect(await file.readAsBytes(), bytes);
      await file.writeAsString('corrupt');
      await expectLater(inbox.list(), throwsFormatException);
      expect(await file.readAsString(), 'corrupt');
    },
  );
  test(
    'interrupted staging directory is retained but never treated as imported',
    () async {
      final dir = await Directory.systemTemp.createTemp('ww-inbox-interrupt-');
      addTearDown(() => dir.delete(recursive: true));
      final pending = Directory('${dir.path}/.pending-interrupted');
      await pending.create();
      await File('${pending.path}/source.jsonl').writeAsString('partial');
      final inbox = PrivateCanonicalInbox(dir, validator);
      expect(await inbox.list(), isEmpty);
      expect(await inbox.importBytes(bytes), true);
      expect(await pending.exists(), true);
      expect((await inbox.list()).length, 1);
    },
  );
  test(
    'account roots are opaque and keep imported sessions isolated',
    () async {
      final installationRoot = await Directory.systemTemp.createTemp(
        'ww-account-inbox-test-',
      );
      addTearDown(() => installationRoot.delete(recursive: true));
      const firstAccount = 'user-one@example.test';
      const secondAccount = 'user-two@example.test';
      final firstRoot = PrivateCanonicalInbox.accountRoot(
        installationRoot,
        firstAccount,
      );
      final secondRoot = PrivateCanonicalInbox.accountRoot(
        installationRoot,
        secondAccount,
      );

      expect(firstRoot.path, isNot(secondRoot.path));
      expect(firstRoot.path, isNot(contains(firstAccount)));
      expect(secondRoot.path, isNot(contains(secondAccount)));
      expect(
        PrivateCanonicalInbox.accountRoot(installationRoot, firstAccount).path,
        firstRoot.path,
      );

      await PrivateCanonicalInbox(firstRoot, validator).importBytes(bytes);
      expect(
        (await PrivateCanonicalInbox(firstRoot, validator).list()).length,
        1,
      );
      expect(
        await PrivateCanonicalInbox(secondRoot, validator).list(),
        isEmpty,
      );
    },
  );
  test('account root rejects an empty identity', () {
    expect(
      () => PrivateCanonicalInbox.accountRoot(Directory('/tmp'), '  '),
      throwsArgumentError,
    );
  });
  test(
    'capacity is bounded and a full inbox still accepts identical retries',
    () async {
      final dir = await Directory.systemTemp.createTemp('ww-inbox-capacity-');
      addTearDown(() => dir.delete(recursive: true));
      final inbox = PrivateCanonicalInbox(dir, validator);
      for (var i = 0; i < 32; i++) {
        await inbox.importBytes(
          rewrite(
            bytes,
            (r) => r.first['payload']['sessionId'] = 'synthetic-$i',
          ),
        );
      }
      expect((await inbox.list()).length, 32);
      expect(
        await inbox.importBytes(
          rewrite(
            bytes,
            (r) => r.first['payload']['sessionId'] = 'synthetic-0',
          ),
        ),
        false,
      );
      await expectLater(inbox.importBytes(bytes), throwsFormatException);
      expect((await inbox.list()).length, 32);
    },
  );
}
