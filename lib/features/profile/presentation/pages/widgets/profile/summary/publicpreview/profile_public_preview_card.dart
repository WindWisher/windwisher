import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/application/profile_kpi_aggregator.dart';
import 'package:windwisher/features/profile/domain/entities/profile_community_stats_snapshot.dart';
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
      kpis: ProfileKpiAggregator.build(
        profile,
        ProfileSessionStatsSnapshot.fromLegacyProfile(profile),
        ProfileCommunityStatsSnapshot(
          followersLabel: profile.followers,
          followingLabel: profile.following,
          rankingLabel: profile.ranking,
          sharedSessionsCountLabel: '--',
          commentsReceivedLabel: '--',
          likesReceivedLabel: '--',
          followersFollowingRatioLabel: '--',
          commentsPerSharedSessionLabel: '--',
          likesPerSharedSessionLabel: '--',
          mostCommentedSessionLabel: '--',
          mostLikedSessionLabel: '--',
          engagementRateLabel: '--',
          sharedSessionsLast30DaysLabel: '--',
          commentsReceivedLast30DaysLabel: '--',
          hasSharedSessions: false,
          hasCommentsReceived: false,
          hasLikesReceived: false,
          hasFollowersFollowingRatio: false,
          hasCommentsPerSharedSession: false,
          hasLikesPerSharedSession: false,
          hasMostCommentedSession: false,
          hasMostLikedSession: false,
          hasEngagementRate: false,
          hasSharedSessionsLast30Days: false,
          hasCommentsReceivedLast30Days: false,
        ),
      ),
      showPublicPreviewButton: false,
      showEditButton: false,
      onFollowersPressed: () => _openFollowers(context),
      onFollowingPressed: () => _openFollowing(context),
    );
  }
}
