import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class PrivateCanonicalSession {
  const PrivateCanonicalSession(
    this.sourceId,
    this.digest,
    this.endedAt,
    this.durationMs,
    this.recordCount,
  );
  final String sourceId;
  final String digest;
  final String endedAt;
  final int durationMs;
  final int recordCount;
}

/// Validates the checked-in Watch v1 schema subset plus stream framing/integrity.
/// Unknown schema keywords fail closed. No network, identity rewrite or metrics.
class PrivateCanonicalValidator {
  PrivateCanonicalValidator(this.schema);
  final Map<String, dynamic> schema;
  static const maxBytes = 2 * 1024 * 1024;
  Never _bad() =>
      throw const FormatException('Archivo canónico inválido o incompleto.');
  void _check(bool value) {
    if (!value) _bad();
  }

  int _crc(List<int> bytes, [int state = 0xffffffff]) {
    var crc = state;
    for (final byte in bytes) {
      crc ^= byte;
      for (var bit = 0; bit < 8; bit++) {
        crc = ((crc >> 1) ^ ((crc & 1) != 0 ? 0xedb88320 : 0)) & 0xffffffff;
      }
    }
    return crc;
  }

  String _hex(int state) =>
      ((state ^ 0xffffffff) & 0xffffffff).toRadixString(16).padLeft(8, '0');

  // Bound decoder depth and reject ambiguous duplicate object keys before decode.
  void _checkJsonStructure(String line) {
    final stack = <Set<String>?>[];
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') {
        final start = i++;
        while (i < line.length && line[i] != '"') {
          if (line[i] == '\\') i++;
          i++;
        }
        _check(i < line.length);
        var next = i + 1;
        while (next < line.length && line[next].trim().isEmpty) {
          next++;
        }
        if (next < line.length && line[next] == ':') {
          _check(stack.isNotEmpty && stack.last != null);
          final key = jsonDecode(line.substring(start, i + 1)) as String;
          _check(stack.last!.add(key));
        }
      } else if (c == '{' || c == '[') {
        stack.add(c == '{' ? <String>{} : null);
        _check(stack.length <= 32);
      } else if (c == '}' || c == ']') {
        _check(stack.isNotEmpty);
        stack.removeLast();
      }
    }
    _check(stack.isEmpty);
  }

  bool _validDate(String value) {
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(\.\d+)?(Z|[+-](\d{2}):(\d{2}))$',
    ).firstMatch(value);
    if (match == null) return false;
    int part(int n) => int.parse(match.group(n)!);
    final date = DateTime.utc(part(1), part(2), part(3));
    return date.year == part(1) &&
        date.month == part(2) &&
        date.day == part(3) &&
        part(4) < 24 &&
        part(5) < 60 &&
        part(6) < 60 &&
        (match.group(8) == 'Z' || (part(9) < 24 && part(10) < 60)) &&
        DateTime.tryParse(value) != null;
  }

  PrivateCanonicalSession validate(Uint8List bytes) {
    try {
      return _validate(bytes);
    } on FormatException {
      _bad();
    }
  }

  PrivateCanonicalSession _validate(Uint8List bytes) {
    _check(bytes.isNotEmpty && bytes.length <= maxBytes);
    final text = utf8.decode(bytes, allowMalformed: false);
    _check(text.endsWith('\n'));
    var sequence = 0, state = 0xffffffff;
    Map<String, dynamic>? manifest, completion;
    final counts = {'track': 0, 'heartRate': 0, 'pressure': 0, 'quality': 0};
    var summaries = 0;
    for (final line in text.split('\n')) {
      if (line.isEmpty) continue;
      _check(
        completion == null &&
            utf8.encode(line).length <= 16384 &&
            sequence < 10000,
      );
      _checkJsonStructure(line);
      final record = jsonDecode(line);
      _check(record is Map<String, dynamic>);
      _schema(record, schema);
      _check(record['recordSequence'] == sequence++);
      // The current Watch producer appends these two fields to its exact JSON core.
      // Validate original bytes, avoiding Dart/JavaScript float reserialization drift.
      final suffix = RegExp(
        r',"checksumAlgorithm":"crc32","checksum":"([a-f0-9]{8})"}$',
      ).firstMatch(line);
      _check(suffix != null);
      final core = '${line.substring(0, suffix!.start)}}';
      _check(_hex(_crc(utf8.encode(core))) == suffix.group(1));
      final decodedCore = jsonDecode(core) as Map<String, dynamic>;
      _check(
        decodedCore.length == 4 &&
            decodedCore.containsKey('canonicalSchemaVersion') &&
            decodedCore.containsKey('payload') &&
            decodedCore.containsKey('recordSequence') &&
            decodedCore.containsKey('recordType'),
      );
      final type = record['recordType'];
      final payload = record['payload'] as Map<String, dynamic>;
      if (type == 'manifest') {
        _check(sequence == 1 && manifest == null);
        manifest = payload;
        _check(payload['privacy']['visibility'] == 'private');
      } else {
        _check(manifest != null);
        if (type == 'completion') {
          _check(payload['streamChecksum'] == _hex(state));
          completion = payload;
        } else if (type == 'operational_summary') {
          summaries++;
        } else {
          final key = type == 'heart_rate' ? 'heartRate' : type as String;
          _check(counts.containsKey(key));
          counts[key] = counts[key]! + 1;
        }
      }
      if (type != 'completion') state = _crc(utf8.encode('$line\n'), state);
    }
    _check(
      manifest != null &&
          completion != null &&
          summaries == 1 &&
          counts['quality'] == 1,
    );
    for (final entry in counts.entries) {
      _check(completion!['recordCounts'][entry.key] == entry.value);
    }
    _check(
      manifest!['lifecycle']['completionStatus'] ==
          completion!['completionStatus'],
    );
    final timing = manifest['timing'] as Map<String, dynamic>;
    _check(
      !DateTime.parse(
        timing['endedAt'],
      ).isBefore(DateTime.parse(timing['startedAt'])),
    );
    return PrivateCanonicalSession(
      manifest['sessionId'],
      sha256.convert(bytes).toString(),
      timing['endedAt'],
      (timing['elapsedDurationMilliseconds'] as num).toInt(),
      sequence,
    );
  }

  void _schema(dynamic value, Map<String, dynamic> rule) {
    const supported = {
      '\$schema',
      '\$id',
      '\$defs',
      'title',
      '\$ref',
      'type',
      'const',
      'enum',
      'allOf',
      'anyOf',
      'if',
      'then',
      'properties',
      'additionalProperties',
      'required',
      'propertyNames',
      'items',
      'minItems',
      'maxItems',
      'uniqueItems',
      'minLength',
      'maxLength',
      'pattern',
      'format',
      'minimum',
      'maximum',
      'exclusiveMaximum',
    };
    _check(rule.keys.every(supported.contains));
    if (rule.containsKey('\$ref')) {
      final ref = rule['\$ref'] as String;
      _check(ref.startsWith('#/\$defs/'));
      _schema(
        value,
        schema['\$defs'][ref.substring(8)] as Map<String, dynamic>,
      );
    }
    if (rule.containsKey('type')) {
      final types = rule['type'] is List
          ? rule['type'] as List
          : [rule['type']];
      _check(
        types.any(
          (t) => switch (t) {
            'object' => value is Map<String, dynamic>,
            'array' => value is List,
            'string' => value is String,
            'number' => value is num && value.isFinite,
            'integer' =>
              value is num && value.isFinite && value == value.roundToDouble(),
            'boolean' => value is bool,
            'null' => value == null,
            _ => false,
          },
        ),
      );
    }
    if (rule.containsKey('const')) _check(value == rule['const']);
    if (rule.containsKey('enum')) {
      _check((rule['enum'] as List).contains(value));
    }
    for (final child in rule['allOf'] as List? ?? []) {
      _schema(value, child as Map<String, dynamic>);
    }
    if (rule.containsKey('anyOf')) {
      _check((rule['anyOf'] as List).any((r) => _matches(value, r)));
    }
    if (rule.containsKey('if') && _matches(value, rule['if'])) {
      _schema(value, rule['then']);
    }
    if (value is Map<String, dynamic>) {
      final properties = rule['properties'] as Map<String, dynamic>? ?? {};
      for (final key in rule['required'] as List? ?? []) {
        _check(value.containsKey(key));
      }
      for (final key in value.keys) {
        if (rule.containsKey('propertyNames')) {
          _schema(key, rule['propertyNames']);
        }
        if (properties.containsKey(key)) {
          _schema(value[key], properties[key]);
        } else if (rule['additionalProperties'] == false) {
          _bad();
        } else if (rule['additionalProperties'] is Map<String, dynamic>) {
          _schema(value[key], rule['additionalProperties']);
        }
      }
    }
    if (value is List) {
      _check(
        value.length >= (rule['minItems'] ?? 0) &&
            value.length <= (rule['maxItems'] ?? 10000),
      );
      if (rule['uniqueItems'] == true) {
        _check(value.map(jsonEncode).toSet().length == value.length);
      }
      if (rule.containsKey('items')) {
        for (final item in value) {
          _schema(item, rule['items']);
        }
      }
    }
    if (value is String) {
      _check(
        value.length >= (rule['minLength'] ?? 0) &&
            value.length <= (rule['maxLength'] ?? maxBytes),
      );
      if (rule.containsKey('pattern')) {
        _check(RegExp(rule['pattern']).hasMatch(value));
      }
      if (rule.containsKey('format')) {
        _check(rule['format'] == 'date-time');
        _check(_validDate(value));
      }
    }
    if (value is num) {
      _check(value.isFinite);
      if (rule.containsKey('minimum')) _check(value >= rule['minimum']);
      if (rule.containsKey('maximum')) _check(value <= rule['maximum']);
      if (rule.containsKey('exclusiveMaximum')) {
        _check(value < rule['exclusiveMaximum']);
      }
    }
  }

  bool _matches(dynamic value, dynamic rule) {
    try {
      _schema(value, rule as Map<String, dynamic>);
      return true;
    } on FormatException {
      return false;
    }
  }
}
