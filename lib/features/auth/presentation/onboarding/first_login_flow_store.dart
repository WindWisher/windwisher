import 'dart:convert';
import 'dart:io';

import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/auth/presentation/onboarding/terms_and_conditions_content.dart';

class FirstLoginFlowState {
  const FirstLoginFlowState({
    this.acceptedTermsVersion,
    this.acceptedTermsAtIso,
    this.welcomeCompletedAtIso,
  });

  static const currentTermsVersion = TermsAndConditionsContent.currentVersion;

  final String? acceptedTermsVersion;
  final String? acceptedTermsAtIso;
  final String? welcomeCompletedAtIso;

  bool get hasAcceptedCurrentTerms =>
      acceptedTermsVersion == currentTermsVersion;

  bool get hasCompletedWelcome => (welcomeCompletedAtIso ?? '').isNotEmpty;

  FirstLoginFlowState merge(FirstLoginFlowState other) {
    return FirstLoginFlowState(
      acceptedTermsVersion:
          _preferNonEmpty(other.acceptedTermsVersion, acceptedTermsVersion),
      acceptedTermsAtIso:
          _preferNonEmpty(other.acceptedTermsAtIso, acceptedTermsAtIso),
      welcomeCompletedAtIso:
          _preferNonEmpty(other.welcomeCompletedAtIso, welcomeCompletedAtIso),
    );
  }

  FirstLoginFlowState copyWith({
    String? acceptedTermsVersion,
    String? acceptedTermsAtIso,
    String? welcomeCompletedAtIso,
  }) {
    return FirstLoginFlowState(
      acceptedTermsVersion: acceptedTermsVersion ?? this.acceptedTermsVersion,
      acceptedTermsAtIso: acceptedTermsAtIso ?? this.acceptedTermsAtIso,
      welcomeCompletedAtIso:
          welcomeCompletedAtIso ?? this.welcomeCompletedAtIso,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'acceptedTermsVersion': acceptedTermsVersion,
      'acceptedTermsAtIso': acceptedTermsAtIso,
      'welcomeCompletedAtIso': welcomeCompletedAtIso,
    };
  }

  factory FirstLoginFlowState.fromJson(Map<String, dynamic> json) {
    return FirstLoginFlowState(
      acceptedTermsVersion: json['acceptedTermsVersion'] as String?,
      acceptedTermsAtIso: json['acceptedTermsAtIso'] as String?,
      welcomeCompletedAtIso: json['welcomeCompletedAtIso'] as String?,
    );
  }

  static String? _preferNonEmpty(String? preferred, String? fallback) {
    final trimmedPreferred = preferred?.trim();
    if (trimmedPreferred != null && trimmedPreferred.isNotEmpty) {
      return trimmedPreferred;
    }
    final trimmedFallback = fallback?.trim();
    if (trimmedFallback != null && trimmedFallback.isNotEmpty) {
      return trimmedFallback;
    }
    return null;
  }
}

class FirstLoginFlowStore {
  FirstLoginFlowStore({
    String fileName = 'first_login_flow_v1.json',
  }) : _fileName = fileName;

  final String _fileName;

  File get _file => File(AppStoragePaths.resolve(_fileName));

  Future<FirstLoginFlowState> loadForUser(String userId) async {
    final all = await _readAll();
    final raw = all[userId];
    if (raw is! Map<String, dynamic>) {
      return const FirstLoginFlowState();
    }
    return FirstLoginFlowState.fromJson(raw);
  }

  Future<void> saveForUser(String userId, FirstLoginFlowState state) async {
    final all = await _readAll();
    all[userId] = state.toJson();
    final encoded = const JsonEncoder.withIndent('  ').convert(all);
    await _file.writeAsString(encoded, flush: true);
  }

  Future<Map<String, dynamic>> _readAll() async {
    if (!await _file.exists()) {
      await _file.writeAsString('{}', flush: true);
      return <String, dynamic>{};
    }

    try {
      final raw = await _file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Fall through to reset the file.
    }

    await _file.writeAsString('{}', flush: true);
    return <String, dynamic>{};
  }
}
