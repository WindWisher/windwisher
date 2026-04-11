import 'dart:async';

import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_records_port.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSessionRecordsAdapter implements SessionRecordsPort {
  SupabaseSessionRecordsAdapter({
    required Object? Function(Object value) encodeInsights,
    required Object Function(Object? value) decodeInsights,
    SupabaseClient? client,
    SessionRecordsPort? localFallback,
  }) : _encodeInsights = encodeInsights,
       _decodeInsights = decodeInsights,
       _client = client ?? Supabase.instance.client,
       _localFallback =
           localFallback ??
           LocalFileSessionRecordsAdapter(
             encodeInsights: encodeInsights,
             decodeInsights: decodeInsights,
           );

  final Object? Function(Object value) _encodeInsights;
  final Object Function(Object? value) _decodeInsights;
  final SupabaseClient _client;
  final SessionRecordsPort _localFallback;
  final List<RecordedSession> _sessions = <RecordedSession>[];

  @override
  List<RecordedSession> getRecordedSessions() {
    return List<RecordedSession>.unmodifiable(_sessions);
  }

  @override
  Future<List<RecordedSession>> loadRecordedSessions() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _sessions
        ..clear()
        ..addAll(await _localFallback.loadRecordedSessions());
      return getRecordedSessions();
    }

    try {
      final gearSetupRows = await _client
          .from('user_gear_setups')
          .select('id, name')
          .eq('user_id', user.id);
      final gearSetupIdsByName = <String, String>{};
      for (final row
          in (gearSetupRows as List<dynamic>)
              .whereType<Map<String, dynamic>>()) {
        final name = (row['name'] as String?)?.trim();
        final id = row['id'] as String?;
        if (name == null || name.isEmpty || id == null || id.isEmpty) {
          continue;
        }
        gearSetupIdsByName.putIfAbsent(name, () => id);
      }

      final response = await _client
          .from('sessions')
          .select()
          .eq('user_id', user.id)
          .order('ended_at', ascending: false);

      final repairedSessions = <RecordedSession>[];
      _sessions
        ..clear()
        ..addAll(
          (response as List<dynamic>).whereType<Map<String, dynamic>>().map(
            (row) => _fromSupabaseRow(
              row,
              gearSetupIdsByName: gearSetupIdsByName,
              repairedSessions: repairedSessions,
            ),
          ),
        );
      await _mergePendingLocalSessions();
      for (final session in repairedSessions) {
        unawaited(saveRecordedSession(session));
      }
    } catch (_) {
      _sessions
        ..clear()
        ..addAll(await _localFallback.loadRecordedSessions());
    }
    return getRecordedSessions();
  }

  @override
  Future<void> saveRecordedSession(RecordedSession session) async {
    _upsertLocal(session);

    final user = _client.auth.currentUser;
    if (user == null) {
      await _localFallback.saveRecordedSession(session);
      return;
    }

    try {
      final remoteSessionPhotoPath =
          _isRemoteSessionPhotoPath(session.sessionPhotoLocalPath)
          ? session.sessionPhotoLocalPath
          : null;
      await _client.from('sessions').upsert(<String, dynamic>{
        'id': session.id,
        'user_id': user.id,
        'title': session.title,
        'summary': session.summary,
        'device_name': session.deviceName,
        'ended_at': session.endedAt.toUtc().toIso8601String(),
        'duration_seconds': session.duration.inSeconds,
        'gear_setup_id': session.gearSetupId,
        'gear_setup_name': session.gearSetupName,
        'session_media_label': session.sessionMediaLabel,
        'session_photo_path': remoteSessionPhotoPath,
        'has_session_photo': remoteSessionPhotoPath != null,
        'spot_name': session.spotName,
        'insights': _encodeInsights(session.insights),
        'highest_jump_m': _doubleFromInsights(
          session.insights,
          legacyKey: 'maxJumpHeightMeters',
          advancedMetricKey: SessionMetricKeys.highestJump,
        ),
        'distance_km': _doubleFromInsights(
          session.insights,
          legacyKey: 'distanceKm',
          advancedMetricKey: SessionMetricKeys.distanceTotal,
        ),
        'big_air_score': _intFromInsights(
          session.insights,
          legacyKey: 'jumpsCount',
          advancedMetricKey: SessionMetricKeys.bigAirScore,
        ),
        'is_public': true,
      });
      await _localFallback.deleteRecordedSession(session.id);
    } catch (_) {
      await _localFallback.saveRecordedSession(session);
    }
  }

  @override
  Future<void> deleteRecordedSession(String sessionId) async {
    _sessions.removeWhere((item) => item.id == sessionId);
    await _localFallback.deleteRecordedSession(sessionId);

    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client
        .from('sessions')
        .delete()
        .eq('id', sessionId)
        .eq('user_id', user.id);
  }

  void _upsertLocal(RecordedSession session) {
    final index = _sessions.indexWhere((item) => item.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
      return;
    }
    _sessions.insert(0, session);
    _sessions.sort((a, b) => b.endedAt.compareTo(a.endedAt));
  }

  Future<void> _mergePendingLocalSessions() async {
    final localSessions = await _localFallback.loadRecordedSessions();
    final remoteIds = _sessions.map((session) => session.id).toSet();
    for (final local in localSessions) {
      if (remoteIds.contains(local.id)) {
        await _localFallback.deleteRecordedSession(local.id);
        continue;
      }
      _upsertLocal(local);
    }
  }

  RecordedSession _fromSupabaseRow(
    Map<String, dynamic> row, {
    required Map<String, String> gearSetupIdsByName,
    required List<RecordedSession> repairedSessions,
  }) {
    final gearSetupName = row['gear_setup_name'] as String?;
    final repairedGearSetupId =
        row['gear_setup_id'] as String? ??
        (gearSetupName == null ? null : gearSetupIdsByName[gearSetupName]);
    final session = RecordedSession(
      id: row['id'] as String? ?? '',
      title: row['title'] as String? ?? 'Sesion',
      deviceName: row['device_name'] as String? ?? 'Dispositivo',
      endedAt:
          DateTime.tryParse(row['ended_at'] as String? ?? '') ?? DateTime.now(),
      duration: Duration(
        seconds: (row['duration_seconds'] as num?)?.toInt() ?? 0,
      ),
      summary: row['summary'] as String? ?? '',
      gearSetupId: repairedGearSetupId,
      gearSetupName: gearSetupName,
      hasSessionPhoto: row['has_session_photo'] as bool? ?? false,
      sessionMediaLabel:
          row['session_media_label'] as String? ??
          'Pantallazo del mapa del spot',
      sessionPhotoLocalPath: row['session_photo_path'] as String?,
      spotName: row['spot_name'] as String?,
      insights: _decodeInsights(row['insights']),
    );
    if (row['gear_setup_id'] == null && repairedGearSetupId != null) {
      repairedSessions.add(session);
    }
    return session;
  }

  double _doubleFromInsights(
    Object insights, {
    required String legacyKey,
    required String advancedMetricKey,
  }) {
    if (insights case final SessionInsightData sessionInsights) {
      final advanced = sessionInsights.advancedMetrics.doubleValue(
        advancedMetricKey,
      );
      if (advanced != null) {
        return advanced;
      }
    }

    final encoded = _encodeInsights(insights);
    if (encoded is Map<String, dynamic>) {
      final advanced = _parseLeadingDouble(
        _advancedMetricValueFromEncoded(encoded, advancedMetricKey),
      );
      if (advanced != null) {
        return advanced;
      }
      return (encoded[legacyKey] as num?)?.toDouble() ?? 0;
    }
    return 0;
  }

  int _intFromInsights(
    Object insights, {
    required String legacyKey,
    required String advancedMetricKey,
  }) {
    if (insights case final SessionInsightData sessionInsights) {
      final advanced = sessionInsights.advancedMetrics.intValue(
        advancedMetricKey,
      );
      if (advanced != null) {
        return advanced;
      }
    }

    final encoded = _encodeInsights(insights);
    if (encoded is Map<String, dynamic>) {
      final advanced = _parseLeadingDouble(
        _advancedMetricValueFromEncoded(encoded, advancedMetricKey),
      );
      if (advanced != null) {
        return advanced.round();
      }
      return (encoded[legacyKey] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  String? _advancedMetricValueFromEncoded(
    Map<String, dynamic> encoded,
    String advancedMetricKey,
  ) {
    final advancedMetrics = encoded['advancedMetrics'];
    if (advancedMetrics is! Map<String, dynamic>) {
      return null;
    }
    final groups = advancedMetrics['groups'];
    if (groups is! List<dynamic>) {
      return null;
    }
    for (final group in groups.whereType<Map<String, dynamic>>()) {
      final items = group['items'];
      if (items is! List<dynamic>) {
        continue;
      }
      for (final item in items.whereType<Map<String, dynamic>>()) {
        final key = item['key'] as String?;
        final available = item['available'] as bool? ?? false;
        if (key == advancedMetricKey && available) {
          return item['value'] as String?;
        }
      }
    }
    return null;
  }

  double? _parseLeadingDouble(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final normalized = value.replaceAll(',', '.');
    final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(normalized);
    if (match == null) {
      return null;
    }
    return double.tryParse(match.group(0)!);
  }

  bool _isRemoteSessionPhotoPath(String? path) {
    if (path == null) {
      return false;
    }
    final normalized = path.trim().toLowerCase();
    return normalized.startsWith('http://') ||
        normalized.startsWith('https://');
  }
}
