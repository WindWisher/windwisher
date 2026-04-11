import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/community/presentation/pages/community_user_profile_page.dart';
import 'package:windwisher/features/community/presentation/support/community_identity_mapper.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';

enum ProfileConnectionsBehavior { readOnly, followersManage, followingManage }

class ProfileConnectionsDialogShell extends StatefulWidget {
  const ProfileConnectionsDialogShell({
    super.key,
    required this.profile,
    required this.title,
    required this.description,
    required this.usernames,
    required this.emptyMessage,
    this.behavior = ProfileConnectionsBehavior.readOnly,
    this.initialFollowedUsernames = const <String>{},
    this.onFollowedUsernamesChanged,
    this.isLoading = false,
  });

  final UserProfileData profile;
  final String title;
  final String description;
  final List<String> usernames;
  final String emptyMessage;
  final ProfileConnectionsBehavior behavior;
  final Set<String> initialFollowedUsernames;
  final Future<void> Function(Set<String> usernames)?
  onFollowedUsernamesChanged;
  final bool isLoading;

  @override
  State<ProfileConnectionsDialogShell> createState() =>
      _ProfileConnectionsDialogShellState();
}

class _ProfileConnectionsDialogShellState
    extends State<ProfileConnectionsDialogShell> {
  late Set<String> _followedUsernames;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _followedUsernames = <String>{...widget.initialFollowedUsernames};
  }

  @override
  void didUpdateWidget(covariant ProfileConnectionsDialogShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFollowedUsernames != widget.initialFollowedUsernames) {
      _followedUsernames = <String>{...widget.initialFollowedUsernames};
    }
  }

  Future<bool> _confirmUnfollow(
    BuildContext context,
    String displayName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Dejar de seguir'),
          content: Text('Vas a dejar de seguir a $displayName.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  Future<void> _persistFollowedUsernames() async {
    if (widget.onFollowedUsernamesChanged == null) {
      return;
    }
    setState(() {
      _saving = true;
    });
    try {
      await widget.onFollowedUsernamesChanged!(
        Set<String>.from(_followedUsernames),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _handleFollowersAction(String username) async {
    final isFollowed = _followedUsernames.contains(username);
    setState(() {
      if (isFollowed) {
        _followedUsernames.remove(username);
      } else {
        _followedUsernames.add(username);
      }
    });
    await _persistFollowedUsernames();
  }

  Future<void> _handleFollowingAction(
    BuildContext context,
    String username,
    String displayName,
  ) async {
    final confirmed = await _confirmUnfollow(context, displayName);
    if (!confirmed || !mounted) {
      return;
    }
    setState(() {
      _followedUsernames.remove(username);
    });
    await _persistFollowedUsernames();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final visibleUsernames =
        widget.behavior == ProfileConnectionsBehavior.followingManage
        ? widget.usernames
              .where((username) => _followedUsernames.contains(username))
              .toList(growable: false)
        : widget.usernames;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_saving)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                widget.description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: widget.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        children: [
                          if (visibleUsernames.isEmpty)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Text(widget.emptyMessage),
                              ),
                            )
                          else
                            ...visibleUsernames.map(
                              (username) => _ConnectionUserTile(
                                username: username,
                                profile: widget.profile,
                                behavior: widget.behavior,
                                isFollowed: _followedUsernames.contains(
                                  username,
                                ),
                                onFollowersAction: () =>
                                    _handleFollowersAction(username),
                                onFollowingAction: (displayName) =>
                                    _handleFollowingAction(
                                      context,
                                      username,
                                      displayName,
                                    ),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionUserTile extends StatelessWidget {
  const _ConnectionUserTile({
    required this.username,
    required this.profile,
    required this.behavior,
    required this.isFollowed,
    required this.onFollowersAction,
    required this.onFollowingAction,
  });

  final String username;
  final UserProfileData profile;
  final ProfileConnectionsBehavior behavior;
  final bool isFollowed;
  final VoidCallback onFollowersAction;
  final Future<void> Function(String displayName) onFollowingAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userProfile = CommunityIdentityMapper.profileForUsername(
      username: username,
      currentProfile: profile,
    );

    Widget? trailing;
    switch (behavior) {
      case ProfileConnectionsBehavior.readOnly:
        trailing = const Icon(Icons.chevron_right_rounded);
      case ProfileConnectionsBehavior.followersManage:
        trailing = FilledButton.tonal(
          onPressed: onFollowersAction,
          child: Text(isFollowed ? 'Siguiendo' : 'Seguir'),
        );
      case ProfileConnectionsBehavior.followingManage:
        trailing = FilledButton.tonal(
          onPressed: () => onFollowingAction(userProfile.displayName),
          child: const Text('Dejar de seguir'),
        );
    }

    return Card(
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CommunityUserProfilePage(username: username),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            userProfile.displayName.substring(0, 1).toUpperCase(),
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(userProfile.displayName),
        subtitle: Text('${userProfile.handle} · ${userProfile.baseSpot}'),
        trailing: trailing,
      ),
    );
  }
}
