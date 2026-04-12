import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/features/community/application/use_cases/community_following_preferences_use_cases.dart';
import 'package:windwisher/features/community/di/community_module.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/dialogs/connections/profile_connections_dialog_shell.dart';

class FollowersDialog extends StatefulWidget {
  const FollowersDialog({
    super.key,
    required this.profile,
    this.behavior = ProfileConnectionsBehavior.readOnly,
  });

  final UserProfileData profile;
  final ProfileConnectionsBehavior behavior;

  @override
  State<FollowersDialog> createState() => _FollowersDialogState();
}

class _FollowersDialogState extends State<FollowersDialog> {
  late final GetFollowingUsernamesUseCase _getFollowingUsernames;
  late final SaveFollowingUsernamesUseCase _saveFollowingUsernames;

  bool _loading = true;
  List<String> _followerUsernames = const <String>[];
  Set<String> _followedUsernames = const <String>{};

  @override
  void initState() {
    super.initState();
    final communityModule = CommunityModule.auto();
    _getFollowingUsernames = communityModule.getFollowingUsernames;
    _saveFollowingUsernames = communityModule.saveFollowingUsernames;
    _hydrate();
  }

  Future<void> _hydrate() async {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;
    final followedUsernames = await _getFollowingUsernames.load() ?? <String>{};

    if (currentUser == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _followedUsernames = followedUsernames;
        _followerUsernames = const <String>[];
      });
      return;
    }

    final followerRows = await client
        .from('user_follows')
        .select('follower_user_id')
        .eq('followed_user_id', currentUser.id);

    final followerIds = (followerRows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((row) => row['follower_user_id'] as String?)
        .whereType<String>()
        .toList(growable: false);

    List<String> followerUsernames = const <String>[];
    if (followerIds.isNotEmpty) {
      final profileRows = await client
          .from('public_profiles')
          .select('id, handle')
          .inFilter('id', followerIds);
      followerUsernames = (profileRows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((row) => (row['handle'] as String? ?? '').trim())
          .where((handle) => handle.isNotEmpty)
          .toList(growable: false);
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _followedUsernames = followedUsernames;
      _followerUsernames = followerUsernames;
    });
  }

  Future<void> _persistFollowedUsernames(Set<String> usernames) {
    return _saveFollowingUsernames(usernames);
  }

  @override
  Widget build(BuildContext context) {
    final usernames = _followerUsernames;
    final total = usernames.length;

    return ProfileConnectionsDialogShell(
      profile: widget.profile,
      title: 'Seguidores',
      description: '$total personas siguen este perfil.',
      usernames: usernames,
      emptyMessage: 'Todavia no hay seguidores para mostrar.',
      behavior: widget.behavior,
      initialFollowedUsernames: _followedUsernames,
      onFollowedUsernamesChanged:
          widget.behavior == ProfileConnectionsBehavior.followersManage
          ? _persistFollowedUsernames
          : null,
      isLoading: _loading,
    );
  }
}
