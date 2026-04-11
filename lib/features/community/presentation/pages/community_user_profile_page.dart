import 'package:windwisher/core/config/env/env_config.dart';
import 'package:flutter/material.dart';
import 'package:windwisher/features/community/presentation/support/community_identity_mapper.dart';
import 'package:windwisher/features/profile/di/profile_module.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/profile_aux_pages.dart';

class CommunityUserProfilePage extends StatelessWidget {
  const CommunityUserProfilePage({
    super.key,
    required this.username,
    this.useLocalPersistence = EnvConfig.profileLocalPersistenceEnabled,
  });

  final String username;
  final bool useLocalPersistence;

  @override
  Widget build(BuildContext context) {
    final profile = _resolveProfile();
    return PublicProfilePreviewPage(
      profile: profile,
      title: 'Perfil de usuario',
    );
  }

  UserProfileData _resolveProfile() {
    final currentProfile = useLocalPersistence
        ? ProfileModule.localFile().profileController.profile
        : ProfileModule.inMemory().profileController.profile;
    return CommunityIdentityMapper.profileForUsername(
      username: username,
      currentProfile: currentProfile,
    );
  }
}
