import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/features/auth/presentation/onboarding/first_login_flow_store.dart';

class FirstLoginFlowRemoteStore {
  FirstLoginFlowRemoteStore({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  static const _acceptedTermsVersionColumn = 'accepted_terms_version';
  static const _acceptedTermsAtColumn = 'accepted_terms_at';
  static const _welcomeCompletedAtColumn = 'onboarding_welcome_completed_at';

  final SupabaseClient _client;
  final Set<String> _unsupportedSelectColumns = <String>{};
  final Set<String> _unsupportedUpdateColumns = <String>{};

  Future<FirstLoginFlowState> loadForUser(String userId) async {
    final row = await _selectProfileRow(userId);
    if (row == null) {
      return const FirstLoginFlowState();
    }
    return FirstLoginFlowState(
      acceptedTermsVersion: row[_acceptedTermsVersionColumn] as String?,
      acceptedTermsAtIso: _toIsoString(row[_acceptedTermsAtColumn]),
      welcomeCompletedAtIso: _toIsoString(row[_welcomeCompletedAtColumn]),
    );
  }

  Future<void> saveTermsAcceptance({
    required String userId,
    required String termsVersion,
    required DateTime acceptedAtUtc,
  }) async {
    await _upsertProfileColumns(<String, dynamic>{
      'id': userId,
      _acceptedTermsVersionColumn: termsVersion,
      _acceptedTermsAtColumn: acceptedAtUtc.toUtc().toIso8601String(),
    });
  }

  Future<void> saveWelcomeCompleted({
    required String userId,
    required DateTime completedAtUtc,
  }) async {
    await _upsertProfileColumns(<String, dynamic>{
      'id': userId,
      _welcomeCompletedAtColumn: completedAtUtc.toUtc().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> _selectProfileRow(String userId) async {
    final selectColumns = <String>[
      _acceptedTermsVersionColumn,
      _acceptedTermsAtColumn,
      _welcomeCompletedAtColumn,
    ].where((column) => !_unsupportedSelectColumns.contains(column)).toList();
    if (selectColumns.isEmpty) {
      return null;
    }

    try {
      return await _client
          .from('profiles')
          .select(selectColumns.join(','))
          .eq('id', userId)
          .maybeSingle();
    } catch (error) {
      final unsupportedColumn = _extractUnsupportedProfileColumn(error);
      if (unsupportedColumn == null || !selectColumns.contains(unsupportedColumn)) {
        rethrow;
      }
      _unsupportedSelectColumns.add(unsupportedColumn);
      return _selectProfileRow(userId);
    }
  }

  Future<void> _upsertProfileColumns(Map<String, dynamic> payload) async {
    final filteredPayload = Map<String, dynamic>.from(payload)
      ..removeWhere((key, _) => _unsupportedUpdateColumns.contains(key));

    try {
      await _client.from('profiles').upsert(filteredPayload);
    } catch (error) {
      final unsupportedColumn = _extractUnsupportedProfileColumn(error);
      if (unsupportedColumn == null ||
          !filteredPayload.containsKey(unsupportedColumn)) {
        rethrow;
      }
      _unsupportedUpdateColumns.add(unsupportedColumn);
      final fallbackPayload = Map<String, dynamic>.from(filteredPayload)
        ..remove(unsupportedColumn);
      await _client.from('profiles').upsert(fallbackPayload);
    }
  }

  String? _toIsoString(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    return value.toString();
  }

  String? _extractUnsupportedProfileColumn(Object error) {
    final message = error.toString();
    final match = RegExp(
      "column ['\"]?([a-zA-Z0-9_]+)['\"]?",
      caseSensitive: false,
    ).firstMatch(message);
    if (match == null) {
      return null;
    }
    final column = match.group(1);
    if (column == null || column.isEmpty) {
      return null;
    }
    final normalized = column.toLowerCase();
    if (message.toLowerCase().contains('profiles') ||
        message.toLowerCase().contains('schema cache')) {
      return normalized;
    }
    return null;
  }
}
