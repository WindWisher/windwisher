import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/material/header/profile_gear_material_header.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/material/section/profile_gear_material_config_section.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/material/selector/profile_gear_material_selector.dart';

class ProfileGearMaterialCard extends StatelessWidget {
  const ProfileGearMaterialCard({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileGearMaterialHeader(),
            const SizedBox(height: AppSpacing.sm),
            ProfileGearMaterialSelector(
              selectedIndex: selectedGearConfigTabIndex,
              onSelect: onSelectGearConfigTab,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSelectedGearConfigSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedGearConfigSection() {
    switch (selectedGearConfigTabIndex) {
      case 0:
        return ProfileGearMaterialConfigSection(
          title: 'Cometa',
          buttonLabel: 'Configurar cometa',
          icon: Icons.air,
          savedLabel: 'Cometas guardadas ($savedKitesCount)',
          onPressed: onOpenKiteDialog,
          managementWidget: kiteManagement,
        );
      case 1:
        return ProfileGearMaterialConfigSection(
          title: 'Tabla',
          buttonLabel: 'Configurar tabla',
          icon: Icons.surfing,
          savedLabel: 'Tablas guardadas ($savedBoardsCount)',
          onPressed: onOpenBoardDialog,
          managementWidget: boardManagement,
        );
      case 2:
        return ProfileGearMaterialConfigSection(
          title: 'Barra',
          buttonLabel: 'Configurar barra',
          icon: Icons.tune,
          savedLabel: 'Barras guardadas ($savedBarsCount)',
          onPressed: onOpenBarDialog,
          managementWidget: barManagement,
        );
      case 3:
        return ProfileGearMaterialConfigSection(
          title: 'Arnes',
          buttonLabel: 'Configurar arnes',
          icon: Icons.sports_martial_arts,
          savedLabel: 'Arneses guardados ($savedHarnessesCount)',
          onPressed: onOpenHarnessDialog,
          managementWidget: harnessManagement,
        );
      case 4:
        return ProfileGearMaterialConfigSection(
          title: 'Traje',
          buttonLabel: 'Configurar traje',
          icon: Icons.checkroom,
          savedLabel: 'Trajes guardados ($savedWetsuitsCount)',
          onPressed: onOpenWetsuitDialog,
          managementWidget: wetsuitManagement,
        );
      case 5:
        return ProfileGearMaterialConfigSection(
          title: 'Casco',
          buttonLabel: 'Configurar casco',
          icon: Icons.health_and_safety,
          savedLabel: 'Cascos guardados ($savedHelmetsCount)',
          onPressed: onOpenHelmetDialog,
          managementWidget: helmetManagement,
        );
      case 6:
        return ProfileGearMaterialConfigSection(
          title: 'Chaleco',
          buttonLabel: 'Configurar chaleco',
          icon: Icons.shield_outlined,
          savedLabel: 'Chalecos guardados ($savedVestsCount)',
          onPressed: onOpenVestDialog,
          managementWidget: vestManagement,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
