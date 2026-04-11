import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/material/profile_gear_material_card.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/profile_gear_section_data.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/setups/profile_gear_setups_card.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/usage/profile_gear_usage_stats_card.dart';

class ProfileGearSection extends StatelessWidget {
  const ProfileGearSection({
    required this.material,
    required this.setups,
    required this.usage,
    super.key,
  });

  final ProfileGearMaterialCardData material;
  final ProfileGearSetupsCardData setups;
  final ProfileGearUsageStatsCardData usage;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('equipo'),
      children: [
        ProfileGearMaterialCard(
          selectedGearConfigTabIndex: material.selectedGearConfigTabIndex,
          onSelectGearConfigTab: material.onSelectGearConfigTab,
          savedKitesCount: material.savedKitesCount,
          savedBoardsCount: material.savedBoardsCount,
          savedBarsCount: material.savedBarsCount,
          savedHarnessesCount: material.savedHarnessesCount,
          savedWetsuitsCount: material.savedWetsuitsCount,
          savedHelmetsCount: material.savedHelmetsCount,
          savedVestsCount: material.savedVestsCount,
          kiteManagement: material.kiteManagement,
          boardManagement: material.boardManagement,
          barManagement: material.barManagement,
          harnessManagement: material.harnessManagement,
          wetsuitManagement: material.wetsuitManagement,
          helmetManagement: material.helmetManagement,
          vestManagement: material.vestManagement,
          onOpenKiteDialog: material.onOpenKiteDialog,
          onOpenBoardDialog: material.onOpenBoardDialog,
          onOpenBarDialog: material.onOpenBarDialog,
          onOpenHarnessDialog: material.onOpenHarnessDialog,
          onOpenWetsuitDialog: material.onOpenWetsuitDialog,
          onOpenHelmetDialog: material.onOpenHelmetDialog,
          onOpenVestDialog: material.onOpenVestDialog,
        ),
        const SizedBox(height: AppSpacing.md),
        ProfileGearSetupsCard(
          savedGearSetups: setups.savedGearSetups,
          findKite: setups.findKite,
          findBar: setups.findBar,
          findBoard: setups.findBoard,
          findHarness: setups.findHarness,
          findWetsuit: setups.findWetsuit,
          findHelmet: setups.findHelmet,
          findVest: setups.findVest,
          onOpenGearSetupDialog: setups.onOpenGearSetupDialog,
          onConfirmDeleteItem: setups.onConfirmDeleteItem,
          onDeleteGearSetup: setups.onDeleteGearSetup,
        ),
        const SizedBox(height: AppSpacing.md),
        ProfileGearUsageStatsCard(
          savedGearSetups: usage.savedGearSetups,
          savedKites: usage.savedKites,
          savedBoards: usage.savedBoards,
          savedBars: usage.savedBars,
          savedHarnesses: usage.savedHarnesses,
          savedWetsuits: usage.savedWetsuits,
          savedHelmets: usage.savedHelmets,
          savedVests: usage.savedVests,
        ),
      ],
    );
  }
}
