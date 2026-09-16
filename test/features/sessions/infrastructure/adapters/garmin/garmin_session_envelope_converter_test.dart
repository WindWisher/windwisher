import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/sessions/domain/services/private_canonical_validator.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/garmin/garmin_session_envelope_converter.dart';

void main() {
  const converter = GarminSessionEnvelopeConverter();
  final schema =
      jsonDecode(
            File(
              'assets/contracts/canonical-session-record.schema.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final validator = PrivateCanonicalValidator(schema);

  test('converts a verified Garmin envelope into accepted canonical JSONL', () {
    final canonical = converter.convert(_envelope());
    final session = validator.validate(canonical);

    expect(session.sourceId, 'garmin-session-1');
    expect(session.durationMs, 1000);
    expect(session.endedAt, '2023-11-14T22:13:21.000Z');
    expect(session.recordCount, 7);
    expect(utf8.decode(canonical), contains('SENSITIVE_LOCATION'));
    expect(utf8.decode(canonical), contains('SENSITIVE_HEALTH'));
  });

  test('conversion is deterministic and supports recovered source quality', () {
    final first = converter.convert(_envelope(recovered: true));
    final second = converter.convert(_envelope(recovered: true));

    expect(first, second);
    expect(validator.validate(first).sourceId, 'garmin-session-1');
    expect(utf8.decode(first), contains('RECOVERED_THEN_COMPLETED'));
    expect(utf8.decode(first), contains('UNCLASSIFIED_SOURCE_QUALITY'));
  });

  test('rejects truncation, reordered frames and inconsistent semantics', () {
    final valid = utf8.decode(_envelope()).trim().split('\n');
    final reordered = [...valid];
    final swap = reordered[1];
    reordered[1] = reordered[2];
    reordered[2] = swap;

    for (final bytes in <Uint8List>[
      Uint8List.fromList(
        utf8.encode('${valid.take(valid.length - 1).join('\n')}\n'),
      ),
      Uint8List.fromList(utf8.encode('${reordered.join('\n')}\n')),
      _envelope(positionCount: 2),
    ]) {
      expect(() => converter.convert(bytes), throwsFormatException);
    }
  });
}

Uint8List _envelope({bool recovered = false, int positionCount = 1}) {
  final source = <(String, String)>[
    ('SESSION_START', 'schema=1.0.0;wall=1700000000;mono=100'),
    ('POSITION', 't=100;lat=0;lon=0;speed=2;quality=4;usable=1'),
    ('HEART_RATE', 't=200;bpm=80;source=platform'),
    ('PRESSURE', 't=300;pascals=101325'),
    ('QUALITY', 't=400;code=GPS_UNAVAILABLE'),
    (
      'SESSION_FINAL',
      'elapsed=1000;pos=$positionCount;hr=1;pressure=1;quality=${recovered ? 2 : 1};dist=2;max=2;completed=1700000001${recovered ? ';recovered=true' : ''}',
    ),
  ];
  const sessionId = 'garmin-session-1';
  var stream = _adler('WWSE_TRANSFER|1|$sessionId\n');
  final records = <Map<String, Object?>>[
    <String, Object?>{
      'recordType': 'manifest',
      'transferVersion': 1,
      'sessionId': sessionId,
    },
  ];
  for (var sequence = 0; sequence < source.length; sequence++) {
    final (type, payload) = source[sequence];
    final canonical = 'WWJF|1|$sequence|$type|$payload';
    records.add(<String, Object?>{
      'recordType': 'frame',
      'frame': <String, Object?>{
        'magic': 'WWJF',
        'formatVersion': 1,
        'sequence': sequence,
        'frameType': type,
        'payloadLength': payload.length,
        'payload': payload,
        'checksum': _adler(canonical),
      },
    });
    stream = _adler('$canonical\n', stream);
  }
  records.add(<String, Object?>{
    'recordType': 'completion',
    'frameCount': source.length,
    'streamAdler32': stream,
  });
  return Uint8List.fromList(
    utf8.encode('${records.map(jsonEncode).join('\n')}\n'),
  );
}

int _adler(String text, [int seed = 1]) {
  var a = seed & 0xffff;
  var b = seed >>> 16;
  for (final byte in ascii.encode(text)) {
    a = (a + byte) % 65521;
    b = (b + a) % 65521;
  }
  return b * 65536 + a;
}
