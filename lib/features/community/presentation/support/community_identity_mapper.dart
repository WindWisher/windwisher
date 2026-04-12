import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';

final class CommunityIdentityMapper {
  static String normalizedUsername(String handle) {
    final cleaned = handle.replaceFirst('@', '').trim();
    return cleaned.isEmpty ? 'you_rider' : cleaned;
  }

  static String displayNameFromUsername(String username) {
    final parts = username.split('_').where((part) => part.isNotEmpty);
    return parts
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static UserProfileData profileForUsername({
    required String username,
    required UserProfileData currentProfile,
  }) {
    final normalizedUsername = username.toLowerCase();
    final normalizedCurrentUsername = normalizedUsernameFromProfile(
      currentProfile,
    );

    if (normalizedUsername == normalizedCurrentUsername ||
        normalizedUsername == 'you_rider') {
      return currentProfile;
    }

    final seed = username.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return currentProfile.copyWith(
      displayName: displayNameFromUsername(username),
      handle: '@$username',
      publicTagline: 'Perfil publico de la comunidad.',
      totalSessions: '${20 + (seed % 140)}',
      waterHours: '${50 + (seed % 260)}h',
      jumps: '${100 + (seed % 900)}',
      topJump: '${(9 + (seed % 90) / 10).toStringAsFixed(1)}m',
      avatarLocalPath: null,
      bannerLocalPath: null,
    );
  }

  static String normalizedUsernameFromProfile(UserProfileData profile) {
    return normalizedUsername(profile.handle).toLowerCase();
  }

  static String displayNameForUsername({
    required String username,
    required UserProfileData currentProfile,
  }) {
    final normalizedCurrentUsername = normalizedUsernameFromProfile(
      currentProfile,
    );
    return username == normalizedCurrentUsername
        ? currentProfile.displayName
        : displayNameFromUsername(username);
  }
}
