import 'dart:convert';
import 'dart:typed_data';

class GarminSessionEnvelopeConverter {
  const GarminSessionEnvelopeConverter();

  static const _knownFrameTypes = <String>{
    'SESSION_START',
    'POSITION',
    'HEART_RATE',
    'PRESSURE',
    'RUNTIME',
    'QUALITY',
    'CHECKPOINT',
    'SESSION_STOP',
    'SESSION_FINAL',
  };

  Uint8List convert(Uint8List input) {
    try {
      return _convert(input);
    } on FormatException {
      throw const FormatException(
        'La sesion Garmin es invalida o esta incompleta.',
      );
    }
  }

  Uint8List _convert(Uint8List input) {
    if (input.isEmpty || input.length > 2 * 1024 * 1024) _bad();
    final text = utf8.decode(input, allowMalformed: false);
    if (!text.endsWith('\n')) _bad();
    final lines = text.split('\n')..removeLast();
    if (lines.length < 4 || lines.length > 1026) _bad();

    final manifest = _map(lines.first);
    _exact(manifest, const {'recordType', 'transferVersion', 'sessionId'});
    final sessionId = manifest['sessionId'];
    if (manifest['recordType'] != 'manifest' ||
        manifest['transferVersion'] != 1 ||
        sessionId is! String ||
        !RegExp(r'^[A-Za-z0-9_-]{1,96}$').hasMatch(sessionId)) {
      _bad();
    }

    var streamAdler = _adler32('WWSE_TRANSFER|1|$sessionId\n');
    final frames = <_GarminFrame>[];
    for (var index = 1; index < lines.length - 1; index++) {
      if (utf8.encode(lines[index]).length > 4096) _bad();
      final record = _map(lines[index]);
      _exact(record, const {'recordType', 'frame'});
      if (record['recordType'] != 'frame') _bad();
      final frame = _frame(record['frame'], frames.length);
      if ((frames.isEmpty && frame.type != 'SESSION_START') ||
          (frames.isNotEmpty &&
              (frame.type == 'SESSION_START' ||
                  frames.last.type == 'SESSION_FINAL'))) {
        _bad();
      }
      frames.add(frame);
      streamAdler = _adler32('${frame.canonical}\n', streamAdler);
    }

    final completion = _map(lines.last);
    _exact(completion, const {'recordType', 'frameCount', 'streamAdler32'});
    if (frames.length < 2 ||
        frames.length > 1024 ||
        frames.last.type != 'SESSION_FINAL' ||
        completion['recordType'] != 'completion' ||
        completion['frameCount'] != frames.length ||
        completion['streamAdler32'] != streamAdler) {
      _bad();
    }
    return _toCanonical(sessionId, frames);
  }

  _GarminFrame _frame(Object? value, int expectedSequence) {
    if (value is! Map<String, dynamic>) _bad();
    _exact(value, const {
      'magic',
      'formatVersion',
      'sequence',
      'frameType',
      'payloadLength',
      'payload',
      'checksum',
    });
    final sequence = value['sequence'];
    final type = value['frameType'];
    final payload = value['payload'];
    if (value['magic'] != 'WWJF' ||
        value['formatVersion'] != 1 ||
        sequence is! int ||
        sequence != expectedSequence ||
        type is! String ||
        !_knownFrameTypes.contains(type) ||
        payload is! String ||
        payload.length > 512 ||
        !RegExp(r'^[\x20-\x7e]*$').hasMatch(payload) ||
        value['payloadLength'] != payload.length) {
      _bad();
    }
    final frame = _GarminFrame(sequence, type, payload);
    if (value['checksum'] != _adler32(frame.canonical)) _bad();
    return frame;
  }

  Uint8List _toCanonical(String sessionId, List<_GarminFrame> frames) {
    final parsed = frames
        .map((frame) => (frame: frame, fields: _fields(frame.payload)))
        .toList(growable: false);
    final start = parsed.first.fields;
    final finalFields = parsed.last.fields;
    if (start['schema'] != '1.0.0') _bad();
    final elapsed = _number(finalFields, 'elapsed', integer: true)!.toInt();
    final started = _number(start, 'wall', integer: true)!.toInt();
    final ended = _number(finalFields, 'completed', integer: true)!.toInt();
    final recovered = finalFields['recovered'];
    if (ended < started || (recovered != null && recovered != 'true')) {
      _bad();
    }

    final observed = <String, int>{
      'position': 0,
      'heartRate': 0,
      'pressure': 0,
    };
    final quality = <String, int>{};
    final records =
        <({int sequence, String type, Map<String, Object?> payload})>[];
    var previousTime = 0;
    for (final item in parsed) {
      final frame = item.frame;
      final fields = item.fields;
      if (fields.containsKey('t')) {
        final time = _number(
          fields,
          't',
          integer: true,
          maximum: elapsed.toDouble(),
        )!.toInt();
        if (time < previousTime) _bad();
        previousTime = time;
      }
      switch (frame.type) {
        case 'SESSION_START':
          records.add((
            sequence: frame.sequence,
            type: frame.type,
            payload: <String, Object?>{'wallClockAnchorEpochSeconds': started},
          ));
        case 'POSITION':
          observed['position'] = observed['position']! + 1;
          if (fields['usable'] != '0' && fields['usable'] != '1') _bad();
          records.add((
            sequence: frame.sequence,
            type: frame.type,
            payload: <String, Object?>{
              'relativeMilliseconds': _number(
                fields,
                't',
                integer: true,
              )!.toInt(),
              'latitudeDegrees': _number(
                fields,
                'lat',
                minimum: -90,
                maximum: 90,
              )!,
              'longitudeDegrees': _number(
                fields,
                'lon',
                minimum: -180,
                maximum: 180,
              )!,
              'groundSpeedMps': _number(
                fields,
                'speed',
                nullable: true,
                maximum: 80,
              ),
              'quality': _number(
                fields,
                'quality',
                integer: true,
                maximum: 100,
              )!.toInt(),
              'usable': fields['usable'] == '1',
              'timestampProvenance': 'SESSION_MONOTONIC',
            },
          ));
        case 'HEART_RATE':
          observed['heartRate'] = observed['heartRate']! + 1;
          if (fields['source'] != 'platform') _bad();
          records.add((
            sequence: frame.sequence,
            type: frame.type,
            payload: <String, Object?>{
              'relativeMilliseconds': _number(
                fields,
                't',
                integer: true,
              )!.toInt(),
              'bpm': _number(
                fields,
                'bpm',
                integer: true,
                minimum: 20,
                maximum: 250,
              )!.toInt(),
              'source': 'platform',
              'quality': 'unknown',
            },
          ));
        case 'PRESSURE':
          observed['pressure'] = observed['pressure']! + 1;
          records.add((
            sequence: frame.sequence,
            type: frame.type,
            payload: <String, Object?>{
              'relativeMilliseconds': _number(
                fields,
                't',
                integer: true,
              )!.toInt(),
              'pressurePascals': _number(
                fields,
                'pascals',
                minimum: 10000,
                maximum: 120000,
              )!,
            },
          ));
        case 'QUALITY':
          final code = fields['code'];
          if (code == null ||
              !RegExp(r'^[A-Z][A-Z0-9_]{2,63}$').hasMatch(code)) {
            _bad();
          }
          quality[code] = (quality[code] ?? 0) + 1;
          records.add((
            sequence: frame.sequence,
            type: frame.type,
            payload: <String, Object?>{
              'code': code,
              'elapsedMilliseconds': _number(
                fields,
                't',
                integer: true,
              )!.toInt(),
            },
          ));
        case 'SESSION_FINAL':
          records.add((
            sequence: frame.sequence,
            type: frame.type,
            payload: <String, Object?>{
              'elapsedMilliseconds': elapsed,
              'completedAtEpochSeconds': ended,
              'recovered': recovered == 'true',
              'sampleCounters': observed,
              'qualityCounters': quality,
              'metricState': <String, Object?>{
                'distanceMeters': _number(finalFields, 'dist')!,
                'maximumSpeedMps': _number(
                  finalFields,
                  'max',
                  nullable: true,
                  maximum: 80,
                ),
              },
            },
          ));
        default:
          records.add((
            sequence: frame.sequence,
            type: frame.type,
            payload: fields.containsKey('t')
                ? <String, Object?>{
                    'relativeMilliseconds': _number(
                      fields,
                      't',
                      integer: true,
                    )!.toInt(),
                  }
                : <String, Object?>{},
          ));
      }
    }

    if (observed['position'] !=
            _number(finalFields, 'pos', integer: true)!.toInt() ||
        observed['heartRate'] !=
            _number(finalFields, 'hr', integer: true)!.toInt() ||
        observed['pressure'] !=
            _number(finalFields, 'pressure', integer: true)!.toInt()) {
      _bad();
    }
    final declaredQuality = _number(
      finalFields,
      'quality',
      integer: true,
    )!.toInt();
    final recordedQuality = quality.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );
    if (declaredQuality < recordedQuality) _bad();
    if (declaredQuality > recordedQuality) {
      quality['UNCLASSIFIED_SOURCE_QUALITY'] =
          declaredQuality - recordedQuality;
    }
    return _encodeCanonical(
      sessionId: sessionId,
      started: started,
      ended: ended,
      elapsed: elapsed,
      recovered: recovered == 'true',
      records: records,
      observed: observed,
      quality: quality,
      distance: _number(finalFields, 'dist')!,
      maximumSpeed: _number(finalFields, 'max', nullable: true, maximum: 80),
    );
  }

  Uint8List _encodeCanonical({
    required String sessionId,
    required int started,
    required int ended,
    required int elapsed,
    required bool recovered,
    required List<({int sequence, String type, Map<String, Object?> payload})>
    records,
    required Map<String, int> observed,
    required Map<String, int> quality,
    required num distance,
    required num? maximumSpeed,
  }) {
    final counts = <String, int>{
      'track': observed['position']!,
      'heartRate': observed['heartRate']!,
      'pressure': observed['pressure']!,
      'quality': quality.values.fold<int>(0, (sum, count) => sum + count),
    };
    final completionStatus = recovered
        ? 'RECOVERED_THEN_COMPLETED'
        : 'COMPLETED';
    final sections = <String>[
      if (counts['track']! > 0) 'track',
      if (counts['heartRate']! > 0) 'heart_rate',
      if (counts['pressure']! > 0) 'pressure',
      'quality',
      'operational_summary',
      'completion',
    ];
    final classifications = <String>[
      'PUBLIC_METADATA',
      'OPERATIONAL',
      if (counts['track']! > 0) 'SENSITIVE_LOCATION',
      if (counts['heartRate']! > 0) 'SENSITIVE_HEALTH',
    ];
    final lines = <String>[];
    var streamState = 0xffffffff;
    var sequence = 0;

    void emit(String type, Map<String, Object?> payload, {bool stream = true}) {
      final core = <String, Object?>{
        'canonicalSchemaVersion': '1.0.0',
        'recordSequence': sequence++,
        'recordType': type,
        'payload': payload,
      };
      final checksum = _crcHex(utf8.encode(jsonEncode(core)));
      final line =
          '${jsonEncode(<String, Object?>{...core, 'checksumAlgorithm': 'crc32', 'checksum': checksum})}\n';
      if (utf8.encode(line).length > 16384) _bad();
      lines.add(line);
      if (stream) streamState = _crc32(utf8.encode(line), streamState);
    }

    emit('manifest', <String, Object?>{
      'sessionId': sessionId,
      'producer': <String, Object?>{
        'platform': 'garmin',
        'producerVersion': '0.1.0-m4',
        'journalFormatVersion': 1,
        'metricProjectionVersion': '1.0.0',
      },
      'device': <String, Object?>{'platform': 'garmin'},
      'lifecycle': <String, Object?>{'completionStatus': completionStatus},
      'timing': <String, Object?>{
        'startedAt': DateTime.fromMillisecondsSinceEpoch(
          started * 1000,
          isUtc: true,
        ).toIso8601String(),
        'endedAt': DateTime.fromMillisecondsSinceEpoch(
          ended * 1000,
          isUtc: true,
        ).toIso8601String(),
        'elapsedDurationMilliseconds': elapsed,
      },
      'sections': sections,
      'privacy': <String, Object?>{
        'visibility': 'private',
        'classifications': classifications,
      },
    });

    final emitted = <String, int>{
      'track': 0,
      'heartRate': 0,
      'pressure': 0,
      'quality': 0,
    };
    final notable = <Map<String, Object?>>[];
    for (final record in records) {
      switch (record.type) {
        case 'POSITION':
          emitted['track'] = emitted['track']! + 1;
          emit('track', <String, Object?>{
            'journalSequence': record.sequence,
            'relativeMilliseconds': record.payload['relativeMilliseconds'],
            'latitudeDegrees': record.payload['latitudeDegrees'],
            'longitudeDegrees': record.payload['longitudeDegrees'],
            'groundSpeedMps': record.payload['groundSpeedMps'],
            'fixQuality': record.payload['quality'],
            'usable': record.payload['usable'],
            'source': 'device_gps',
            'timestampProvenance': 'SESSION_MONOTONIC',
          });
        case 'HEART_RATE':
          emitted['heartRate'] = emitted['heartRate']! + 1;
          emit('heart_rate', <String, Object?>{
            'journalSequence': record.sequence,
            'relativeMilliseconds': record.payload['relativeMilliseconds'],
            'bpm': record.payload['bpm'],
            'source': 'platform_fused',
            'quality': 'unknown',
          });
        case 'PRESSURE':
          emitted['pressure'] = emitted['pressure']! + 1;
          emit('pressure', <String, Object?>{
            'journalSequence': record.sequence,
            'relativeMilliseconds': record.payload['relativeMilliseconds'],
            'pressurePascals': record.payload['pressurePascals'],
            'source': 'platform_sensor',
          });
        case 'QUALITY':
          if (notable.length < 16) {
            notable.add(<String, Object?>{
              'code': record.payload['code'],
              'relativeMilliseconds': record.payload['elapsedMilliseconds'],
            });
          }
      }
    }
    emit('quality', <String, Object?>{
      'counters': quality,
      'notableEvents': notable,
    });
    emitted['quality'] = 1;
    emit('operational_summary', <String, Object?>{
      'projectionKind': 'WATCH_OPERATIONAL_PROJECTION',
      'elapsedDurationMilliseconds': elapsed,
      'distanceMeters': distance,
      'maximumSpeedMps': maximumSpeed,
      'sampleCounts': counts,
      'qualityCounters': quality,
    });
    emit('completion', <String, Object?>{
      'completionStatus': completionStatus,
      'sourceJournalIntegrity': 'VALID',
      'recordCounts': emitted,
      'streamChecksumAlgorithm': 'crc32',
      'streamChecksum': _crcHexFromState(streamState),
    }, stream: false);
    return Uint8List.fromList(utf8.encode(lines.join()));
  }

  Map<String, String> _fields(String payload) {
    final result = <String, String>{};
    for (final part in payload.split(';')) {
      final separator = part.indexOf('=');
      if (separator <= 0 || separator != part.lastIndexOf('=')) _bad();
      final key = part.substring(0, separator);
      final value = part.substring(separator + 1);
      if (!RegExp(r'^[A-Za-z][A-Za-z0-9]*$').hasMatch(key) ||
          result.containsKey(key)) {
        _bad();
      }
      result[key] = value;
    }
    return result;
  }

  num? _number(
    Map<String, String> fields,
    String key, {
    bool nullable = false,
    double minimum = 0,
    double maximum = 9007199254740991,
    bool integer = false,
  }) {
    final text = fields[key];
    if (nullable && text == '-') return null;
    if (text == null ||
        !RegExp(
          r'^[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$',
        ).hasMatch(text)) {
      _bad();
    }
    final value = num.parse(text);
    if (!value.isFinite ||
        value < minimum ||
        value > maximum ||
        (integer && value != value.roundToDouble())) {
      _bad();
    }
    return value;
  }

  Map<String, dynamic> _map(String line) {
    final value = jsonDecode(line);
    if (value is! Map<String, dynamic>) _bad();
    return value;
  }

  void _exact(Map<String, dynamic> value, Set<String> keys) {
    if (value.length != keys.length || !value.keys.toSet().containsAll(keys)) {
      _bad();
    }
  }

  int _adler32(String text, [int seed = 1]) {
    var a = seed & 0xffff;
    var b = seed >>> 16;
    for (final byte in ascii.encode(text)) {
      a = (a + byte) % 65521;
      b = (b + a) % 65521;
    }
    return b * 65536 + a;
  }

  int _crc32(List<int> bytes, [int state = 0xffffffff]) {
    var crc = state;
    for (final byte in bytes) {
      crc ^= byte;
      for (var bit = 0; bit < 8; bit++) {
        crc = ((crc >> 1) ^ ((crc & 1) != 0 ? 0xedb88320 : 0)) & 0xffffffff;
      }
    }
    return crc;
  }

  String _crcHex(List<int> bytes) => _crcHexFromState(_crc32(bytes));
  String _crcHexFromState(int state) =>
      ((state ^ 0xffffffff) & 0xffffffff).toRadixString(16).padLeft(8, '0');

  Never _bad() => throw const FormatException();
}

class _GarminFrame {
  const _GarminFrame(this.sequence, this.type, this.payload);
  final int sequence;
  final String type;
  final String payload;
  String get canonical => 'WWJF|1|$sequence|$type|$payload';
}
