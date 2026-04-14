import 'package:flutter/material.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/community/presentation/support/community_identity_mapper.dart';
import 'package:windwisher/features/community/presentation/support/community_public_profile_loader.dart';
import 'package:windwisher/features/profile/di/profile_module.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/dialogs/preview/public_profile_preview_page.dart';

class CommunityUserProfilePage extends StatefulWidget {
  const CommunityUserProfilePage({
    super.key,
    required this.username,
    this.useLocalPersistence = EnvConfig.profileLocalPersistenceEnabled,
  });

  final String username;
  final bool useLocalPersistence;

  @override
  State<CommunityUserProfilePage> createState() => _CommunityUserProfilePageState();
}

class _CommunityUserProfilePageState extends State<CommunityUserProfilePage> {
  late final UserProfileData _currentProfile;
  UserProfileData? _profile;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.useLocalPersistence
        ? ProfileModule.localFile().profileController.profile
        : ProfileModule.inMemory().profileController.profile;
    _profile = CommunityIdentityMapper.fallbackProfileForUsername(
      username: widget.username,
      currentProfile: _currentProfile,
    );
    _load();
  }

  Future<void> _load() async {
    if (EnvConfig.supabaseUrl.trim().isEmpty ||
        EnvConfig.supabaseAnonKey.trim().isEmpty) {
      return;
    }
    final profile = await CommunityPublicProfileLoader().loadByUsername(
      widget.username,
    );
    if (!mounted || profile == null) {
      return;
    }
    setState(() {
      _profile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PublicProfilePreviewPage(
      profile: _profile!,
      title: 'Perfil de usuario',
    );
  }
}
