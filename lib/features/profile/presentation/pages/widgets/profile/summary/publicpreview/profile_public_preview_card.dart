import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/domain/entities/profile_session_stats_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/presentation/pages/widgets/profile/profile_summary_card.dart';
import 'package:windwisher/features/profile/presentation/pages/widgets/profile/summary/followers_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/widgets/profile/summary/following_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/widgets/profile/summary/profile_connections_dialog_shell.dart';

class ProfilePublicPreviewCard extends StatelessWidget {
  const ProfilePublicPreviewCard({super.key, required this.profile});

  final UserProfileData profile;

  Future<void> _openFollowers(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => FollowersDialog(
        profile: profile,
        behavior: ProfileConnectionsBehavior.readOnly,
      ),
    );
  }

  Future<void> _openFollowing(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => FollowingDialog(
        profile: profile,
        behavior: ProfileConnectionsBehavior.readOnly,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSummaryCard(
      profile: profile,
      stats: ProfileSessionStatsSnapshot.fromLegacyProfile(profile),
      showPublicPreviewButton: false,
      showEditButton: false,
      onFollowersPressed: () => _openFollowers(context),
      onFollowingPressed: () => _openFollowing(context),
    );
  }
}
