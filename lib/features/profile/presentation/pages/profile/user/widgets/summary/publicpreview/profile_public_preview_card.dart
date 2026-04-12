import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/domain/entities/profile_kpi_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/dialogs/connections/followers_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/dialogs/connections/following_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/dialogs/connections/profile_connections_dialog_shell.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/profile_summary_card.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/stats/profile_summary_overview_card.dart';

class ProfilePublicPreviewCard extends StatelessWidget {
  const ProfilePublicPreviewCard({
    super.key,
    required this.profile,
    required this.kpis,
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
  final List<GearSetup> savedGearSetups;
  final KiteItem? Function(String id) findKite;
  final BarItem? Function(String id) findBar;
  final BoardItem? Function(String id) findBoard;
  final HarnessItem? Function(String id) findHarness;
  final WetsuitItem? Function(String id) findWetsuit;
  final HelmetItem? Function(String id) findHelmet;
  final VestItem? Function(String id) findVest;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileSummaryCard(
          profile: profile,
          kpis: kpis,
          showPublicPreviewButton: false,
          showEditButton: false,
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
        const SizedBox(height: 12),
        ProfileSummaryOverviewCard(kpis: kpis),
      ],
    );
  }
}
