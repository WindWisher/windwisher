import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/community/presentation/support/community_identity_mapper.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';

void main() {
  test('returns current profile for current username', () {
    final currentProfile = UserProfileData.initial();

    final profile = CommunityIdentityMapper.profileForUsername(
      username: 'rider_ks',
      currentProfile: currentProfile,
    );

    expect(profile.displayName, 'Rider Kitesurf');
    expect(profile.handle, '@rider_ks');
  });

  test('generates consistent third-user profile mapping', () {
    final currentProfile = UserProfileData.initial();

    final profile = CommunityIdentityMapper.profileForUsername(
      username: 'sofi_wind',
      currentProfile: currentProfile,
    );

    expect(profile.displayName, 'Sofi Wind');
    expect(profile.handle, '@sofi_wind');
    expect(profile.avatarLocalPath, isNull);
    expect(profile.bannerLocalPath, isNull);
  });
}
