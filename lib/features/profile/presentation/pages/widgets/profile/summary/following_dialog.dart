import 'package:flutter/material.dart';
import 'package:windwisher/features/community/application/use_cases/community_following_preferences_use_cases.dart';
import 'package:windwisher/features/community/di/community_module.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/presentation/pages/widgets/profile/summary/profile_connections_dialog_shell.dart';

class FollowingDialog extends StatefulWidget {
  const FollowingDialog({
    super.key,
    required this.profile,
    this.behavior = ProfileConnectionsBehavior.readOnly,
  });

  final UserProfileData profile;
  final ProfileConnectionsBehavior behavior;

  @override
  State<FollowingDialog> createState() => _FollowingDialogState();
}

class _FollowingDialogState extends State<FollowingDialog> {
  late final GetFollowingUsernamesUseCase _getFollowingUsernames;
  late final SaveFollowingUsernamesUseCase _saveFollowingUsernames;

  bool _loading = true;
  Set<String> _followingUsernames = const <String>{};

  @override
  void initState() {
    super.initState();
    final communityModule = CommunityModule.auto();
    _getFollowingUsernames = communityModule.getFollowingUsernames;
    _saveFollowingUsernames = communityModule.saveFollowingUsernames;
    _hydrate();
  }

  Future<void> _hydrate() async {
    final usernames = await _getFollowingUsernames.load() ?? <String>{};
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _followingUsernames = usernames;
    });
  }

  Future<void> _persistFollowedUsernames(Set<String> usernames) async {
    await _saveFollowingUsernames(usernames);
    if (!mounted) {
      return;
    }
    setState(() {
      _followingUsernames = usernames;
    });
  }

  @override
  Widget build(BuildContext context) {
    final usernames = _followingUsernames.toList(growable: false);
    final total = usernames.length;

    return ProfileConnectionsDialogShell(
      profile: widget.profile,
      title: 'Siguiendo',
      description: 'Este perfil sigue a $total personas.',
      usernames: usernames,
      emptyMessage: 'Todavia no sigue a nadie.',
      behavior: widget.behavior,
      initialFollowedUsernames: _followingUsernames,
      onFollowedUsernamesChanged:
          widget.behavior == ProfileConnectionsBehavior.followingManage
          ? _persistFollowedUsernames
          : null,
      isLoading: _loading,
    );
  }
}
