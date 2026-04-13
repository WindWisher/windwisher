import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/domain/entities/profile_kpi_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/dialogs/edit/edit_profile_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/dialogs/stats/profile_stats_details_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/dialogs/preview/profile_public_preview_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/dialogs/connections/followers_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/dialogs/connections/following_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/dialogs/connections/profile_connections_dialog_shell.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/stats/profile_summary_overview_card.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/profile_summary_card.dart';

class ProfileOverviewSection extends StatelessWidget {
  const ProfileOverviewSection({
    super.key,
    required this.profile,
    required this.kpis,
    required this.onProfileUpdated,
    required this.isHandleAvailable,
    required this.savedGearSetups,
    required this.findKite,
    required this.findBar,
    required this.findBoard,
    required this.findHarness,
    required this.findWetsuit,
    required this.findHelmet,
    required this.findVest,
  });

  final UserProfileData profile;
  final ProfileKpiSnapshot kpis;
  final Future<bool> Function(UserProfileData) onProfileUpdated;
  final Future<bool> Function(String handle) isHandleAvailable;
  final List<GearSetup> savedGearSetups;
  final KiteItem? Function(String id) findKite;
  final BarItem? Function(String id) findBar;
  final BoardItem? Function(String id) findBoard;
  final HarnessItem? Function(String id) findHarness;
  final WetsuitItem? Function(String id) findWetsuit;
  final HelmetItem? Function(String id) findHelmet;
  final VestItem? Function(String id) findVest;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('perfil'),
      children: [
        ProfileSummaryCard(
          profile: profile,
          kpis: kpis,
          onPublicPreviewPressed: () => _openPublicProfilePreview(context),
          onEditPressed: () => _openEditProfile(context),
          onFollowersPressed: () => _openFollowers(context),
          onFollowingPressed: () => _openFollowing(context),
          savedGearSetups: savedGearSetups,
          findKite: findKite,
          findBar: findBar,
          findBoard: findBoard,
          findHarness: findHarness,
          findWetsuit: findWetsuit,
          findHelmet: findHelmet,
          findVest: findVest,
        ),
        const SizedBox(height: AppSpacing.md),
        ProfileSummaryOverviewCard(
          kpis: kpis,
          onDetailsPressed: () => _openProfileStatsDetails(context),
        ),
      ],
    );
  }

  Future<void> _openFollowers(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => FollowersDialog(
        profile: profile,
        behavior: ProfileConnectionsBehavior.followersManage,
      ),
    );
  }

  Future<void> _openFollowing(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => FollowingDialog(
        profile: profile,
        behavior: ProfileConnectionsBehavior.followingManage,
      ),
    );
  }

  Future<void> _openEditProfile(BuildContext context) async {
    await EditProfileDialog.show(
      context,
      initialData: profile,
      onSave: onProfileUpdated,
      isHandleAvailable: isHandleAvailable,
    );
  }

  Future<void> _openPublicProfilePreview(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => ProfilePublicPreviewDialog(
        profile: profile,
        kpis: kpis,
        savedGearSetups: savedGearSetups,
        findKite: findKite,
        findBar: findBar,
        findBoard: findBoard,
        findHarness: findHarness,
        findWetsuit: findWetsuit,
        findHelmet: findHelmet,
        findVest: findVest,
      ),
    );
  }

  Future<void> _openProfileStatsDetails(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => ProfileStatsDetailsDialog(kpis: kpis),
    );
  }
}
