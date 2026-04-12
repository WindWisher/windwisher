import 'dart:io';

import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/domain/errors/profile_handle_taken_exception.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_repository_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileRepositoryAdapter implements ProfileRepositoryPort {
  static const _avatarBucket = 'profile-avatars';
  static const _bannerBucket = 'profile-banners';
  static const _profileSelect = '''
    display_name,
    handle,
    public_tagline,
    total_sessions,
    water_hours,
    jumps,
    top_jump_m,
    avatar_path,
    banner_path
  ''';

  SupabaseProfileRepositoryAdapter({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final Set<String> _unsupportedProfileColumns = <String>{};
  final Set<String> _unsupportedProfileSelectColumns = <String>{};
  UserProfileData _profile = UserProfileData.initial();

  @override
  UserProfileData getProfile() {
    return _profile;
  }

  @override
  Future<UserProfileData> loadProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _profile = UserProfileData.initial();
      return _profile;
    }

    final response = await _selectProfileRow(user.id);

    if (response == null) {
      _profile = UserProfileData.initial().copyWith(
        displayName: user.email?.split('@').first ?? 'Rider',
        handle: '@${user.email?.split('@').first ?? 'rider'}',
      );
      return _profile;
    }

    _profile = _mapProfile(response);
    return _profile;
  }

  @override
  Future<bool> isHandleAvailable(String handle) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return true;
    }

    final normalizedHandle = _normalizeHandle(handle);
    final response = await _client
        .from('profiles')
        .select('id')
        .ilike('handle', normalizedHandle)
        .neq('id', user.id)
        .limit(1)
        .maybeSingle();
    return response == null;
  }

  @override
  Future<void> saveProfile(UserProfileData value) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _profile = value;
      return;
    }

    final previousAvatarPath = _profile.avatarLocalPath;
    final previousBannerPath = _profile.bannerLocalPath;
    final persistedValue = value.copyWith(
      avatarLocalPath: await _persistProfileMedia(
        candidatePath: value.avatarLocalPath,
        userId: user.id,
        bucket: _avatarBucket,
        folder: 'avatar',
      ),
      bannerLocalPath: await _persistProfileMedia(
        candidatePath: value.bannerLocalPath,
        userId: user.id,
        bucket: _bannerBucket,
        folder: 'banner',
      ),
    );

    await _upsertProfileRow({
      'id': user.id,
      'email': user.email,
      'display_name': persistedValue.displayName,
      'handle': _normalizeHandle(persistedValue.handle),
      'public_tagline': persistedValue.publicTagline,
      'avatar_path': persistedValue.avatarLocalPath,
      'banner_path': persistedValue.bannerLocalPath,
      'total_sessions': _parseInt(persistedValue.totalSessions),
      'water_hours': _parseNumericLabel(persistedValue.waterHours),
      'jumps': _parseInt(persistedValue.jumps),
      'top_jump_m': _parseNumericLabel(persistedValue.topJump),
    });

    _profile = persistedValue;
    await _deleteUnusedProfileMedia(
      previousPath: previousAvatarPath,
      persistedPath: persistedValue.avatarLocalPath,
      bucket: _avatarBucket,
    );
    await _deleteUnusedProfileMedia(
      previousPath: previousBannerPath,
      persistedPath: persistedValue.bannerLocalPath,
      bucket: _bannerBucket,
    );
  }

  Future<String?> _persistProfileMedia({
    required String? candidatePath,
    required String userId,
    required String bucket,
    required String folder,
  }) async {
    if (candidatePath == null || candidatePath.trim().isEmpty) {
      return null;
    }

    final trimmedPath = candidatePath.trim();
    final uri = Uri.tryParse(trimmedPath);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return trimmedPath;
    }

    final file = File(trimmedPath);
    if (!await file.exists()) {
      return trimmedPath;
    }

    final extension = _profileMediaExtension(trimmedPath);
    final storagePath =
        '$userId/$folder/${DateTime.now().millisecondsSinceEpoch}.$extension';
    await _client.storage
        .from(bucket)
        .upload(
          storagePath,
          file,
          fileOptions: FileOptions(
            contentType: _profileMediaContentType(trimmedPath),
            upsert: true,
          ),
        );
    return _client.storage.from(bucket).getPublicUrl(storagePath);
  }

  Future<void> _deleteUnusedProfileMedia({
    required String? previousPath,
    required String? persistedPath,
    required String bucket,
  }) async {
    final previousStoragePath = _storagePathFromPublicUrl(previousPath, bucket);
    if (previousStoragePath == null) {
      return;
    }
    final persistedStoragePath = _storagePathFromPublicUrl(
      persistedPath,
      bucket,
    );
    if (persistedStoragePath == previousStoragePath) {
      return;
    }
    try {
      await _client.storage.from(bucket).remove([previousStoragePath]);
    } catch (_) {
      // Best-effort cleanup: profile data is already persisted.
    }
  }

  String? _storagePathFromPublicUrl(String? value, String bucket) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    final segments = uri.pathSegments;
    final publicIndex = segments.indexOf('public');
    if (publicIndex == -1 || publicIndex + 1 >= segments.length) {
      return null;
    }
    if (segments[publicIndex + 1] != bucket) {
      return null;
    }
    final storageSegments = segments
        .skip(publicIndex + 2)
        .toList(growable: false);
    if (storageSegments.isEmpty) {
      return null;
    }
    return storageSegments.join('/');
  }

  Future<Map<String, dynamic>?> _selectProfileRow(String userId) async {
    final selectColumns = _profileSelect
        .split(',')
        .map((column) => column.trim())
        .where((column) => column.isNotEmpty)
        .where((column) => !_unsupportedProfileSelectColumns.contains(column))
        .toList(growable: false);

    try {
      return await _client
          .from('profiles')
          .select(selectColumns.join(','))
          .eq('id', userId)
          .maybeSingle();
    } catch (error) {
      final unsupportedColumn = _extractUnsupportedProfileColumn(error);
      if (unsupportedColumn == null ||
          !selectColumns.contains(unsupportedColumn)) {
        rethrow;
      }

      _unsupportedProfileSelectColumns.add(unsupportedColumn);
      final fallbackColumns = selectColumns
          .where((column) => column != unsupportedColumn)
          .toList(growable: false);
      return await _client
          .from('profiles')
          .select(fallbackColumns.join(','))
          .eq('id', userId)
          .maybeSingle();
    }
  }

  Future<void> _upsertProfileRow(Map<String, dynamic> payload) async {
    final filteredPayload = Map<String, dynamic>.from(payload)
      ..removeWhere((key, _) => _unsupportedProfileColumns.contains(key));

    try {
      await _client.from('profiles').upsert(filteredPayload);
    } catch (error) {
      if (_isHandleAlreadyTakenError(error)) {
        throw ProfileHandleTakenException(
          _displayHandle(filteredPayload['handle'] as String? ?? ''),
        );
      }
      final unsupportedColumn = _extractUnsupportedProfileColumn(error);
      if (unsupportedColumn == null ||
          !filteredPayload.containsKey(unsupportedColumn)) {
        rethrow;
      }

      _unsupportedProfileColumns.add(unsupportedColumn);
      final fallbackPayload = Map<String, dynamic>.from(filteredPayload)
        ..remove(unsupportedColumn);
      await _client.from('profiles').upsert(fallbackPayload);
    }
  }

  bool _isHandleAlreadyTakenError(Object error) {
    if (error is PostgrestException) {
      final message =
          '${error.message} ${error.details ?? ''} ${error.hint ?? ''}'
              .toLowerCase();
      return error.code == '23505' && message.contains('handle');
    }
    final message = error.toString().toLowerCase();
    return (message.contains('duplicate key value') ||
            message.contains('unique constraint') ||
            message.contains('already exists')) &&
        message.contains('handle');
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

  UserProfileData _mapProfile(Map<String, dynamic> row) {
    return UserProfileData(
      displayName: (row['display_name'] as String?) ?? '',
      handle: _displayHandle((row['handle'] as String?) ?? ''),
      publicTagline: (row['public_tagline'] as String?) ?? '',
      totalSessions: ((row['total_sessions'] as num?)?.toInt() ?? 0).toString(),
      waterHours: _formatHours(row['water_hours']),
      jumps: ((row['jumps'] as num?)?.toInt() ?? 0).toString(),
      topJump: _formatMeters(row['top_jump_m']),
      maxHangtime: UserProfileData.initial().maxHangtime,
      avatarLocalPath: row['avatar_path'] as String?,
      bannerLocalPath: row['banner_path'] as String?,
    );
  }

  String _profileMediaExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return 'jpg';
    }
    return path.substring(dotIndex + 1).toLowerCase();
  }

  String _profileMediaContentType(String path) {
    switch (_profileMediaExtension(path)) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      default:
        return 'image/jpeg';
    }
  }

  int _parseInt(String raw) {
    return int.tryParse(raw.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
  }

  double _parseNumericLabel(String raw) {
    final normalized = raw.replaceAll(',', '.');
    final match = RegExp(r'-?[0-9]+(?:\.[0-9]+)?').firstMatch(normalized);
    return double.tryParse(match?.group(0) ?? '') ?? 0;
  }

  String _formatHours(Object? value) {
    final numeric = (value as num?)?.toDouble() ?? 0;
    return '${numeric.toStringAsFixed(numeric.truncateToDouble() == numeric ? 0 : 1)}h';
  }

  String _formatMeters(Object? value) {
    final numeric = (value as num?)?.toDouble() ?? 0;
    return '${numeric.toStringAsFixed(1)}m';
  }

  String _normalizeHandle(String value) {
    final trimmed = value.trim().replaceFirst('@', '').toLowerCase();
    return trimmed.isEmpty ? 'rider' : trimmed;
  }

  String _displayHandle(String value) {
    if (value.isEmpty) {
      return '@rider';
    }
    return value.startsWith('@') ? value : '@$value';
  }
}
