import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';

class ProfileGearMaterialCardData {
  const ProfileGearMaterialCardData({
    required this.selectedGearConfigTabIndex,
    required this.onSelectGearConfigTab,
    required this.savedKitesCount,
    required this.savedBoardsCount,
    required this.savedBarsCount,
    required this.savedHarnessesCount,
    required this.savedWetsuitsCount,
    required this.savedHelmetsCount,
    required this.savedVestsCount,
    required this.kiteManagement,
    required this.boardManagement,
    required this.barManagement,
    required this.harnessManagement,
    required this.wetsuitManagement,
    required this.helmetManagement,
    required this.vestManagement,
    required this.onOpenKiteDialog,
    required this.onOpenBoardDialog,
    required this.onOpenBarDialog,
    required this.onOpenHarnessDialog,
    required this.onOpenWetsuitDialog,
    required this.onOpenHelmetDialog,
    required this.onOpenVestDialog,
  });

  final int selectedGearConfigTabIndex;
  final ValueChanged<int> onSelectGearConfigTab;
  final int savedKitesCount;
  final int savedBoardsCount;
  final int savedBarsCount;
  final int savedHarnessesCount;
  final int savedWetsuitsCount;
  final int savedHelmetsCount;
  final int savedVestsCount;
  final Widget kiteManagement;
  final Widget boardManagement;
  final Widget barManagement;
  final Widget harnessManagement;
  final Widget wetsuitManagement;
  final Widget helmetManagement;
  final Widget vestManagement;
  final VoidCallback onOpenKiteDialog;
  final VoidCallback onOpenBoardDialog;
  final VoidCallback onOpenBarDialog;
  final VoidCallback onOpenHarnessDialog;
  final VoidCallback onOpenWetsuitDialog;
  final VoidCallback onOpenHelmetDialog;
  final VoidCallback onOpenVestDialog;
}

class ProfileGearSetupsCardData {
  const ProfileGearSetupsCardData({
    required this.savedGearSetups,
    required this.findKite,
    required this.findBar,
    required this.findBoard,
    required this.findHarness,
    required this.findWetsuit,
    required this.findHelmet,
    required this.findVest,
    required this.onOpenGearSetupDialog,
    required this.onConfirmDeleteItem,
    required this.onDeleteGearSetup,
  });

  final List<GearSetup> savedGearSetups;
  final KiteItem? Function(String id) findKite;
  final BarItem? Function(String id) findBar;
  final BoardItem? Function(String id) findBoard;
  final HarnessItem? Function(String id) findHarness;
  final WetsuitItem? Function(String id) findWetsuit;
  final HelmetItem? Function(String id) findHelmet;
  final VestItem? Function(String id) findVest;
  final Future<void> Function({GearSetup? existing}) onOpenGearSetupDialog;
  final Future<bool> Function(String label) onConfirmDeleteItem;
  final void Function(String setupId) onDeleteGearSetup;
}

class ProfileGearUsageStatsCardData {
  const ProfileGearUsageStatsCardData({
    required this.savedGearSetups,
    required this.savedKites,
    required this.savedBoards,
    required this.savedBars,
    required this.savedHarnesses,
    required this.savedWetsuits,
    required this.savedHelmets,
    required this.savedVests,
    required this.recordedSessions,
  });

  final List<GearSetup> savedGearSetups;
  final List<KiteItem> savedKites;
  final List<BoardItem> savedBoards;
  final List<BarItem> savedBars;
  final List<HarnessItem> savedHarnesses;
  final List<WetsuitItem> savedWetsuits;
  final List<HelmetItem> savedHelmets;
  final List<VestItem> savedVests;
  final List<RecordedSession> recordedSessions;
}
