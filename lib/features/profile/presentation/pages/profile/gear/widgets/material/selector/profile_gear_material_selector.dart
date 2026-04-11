import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class ProfileGearMaterialSelector extends StatelessWidget {
  const ProfileGearMaterialSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<int>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.35)),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          foregroundColor: colorScheme.primary,
          selectedForegroundColor: Colors.white,
          selectedBackgroundColor: colorScheme.primary,
        ),
        segments: const [
          ButtonSegment<int>(value: 0, label: Text('Cometa')),
          ButtonSegment<int>(value: 1, label: Text('Tabla')),
          ButtonSegment<int>(value: 2, label: Text('Barra')),
          ButtonSegment<int>(value: 3, label: Text('Arnes')),
          ButtonSegment<int>(value: 4, label: Text('Traje')),
          ButtonSegment<int>(value: 5, label: Text('Casco')),
          ButtonSegment<int>(value: 6, label: Text('Chaleco')),
        ],
        selected: {selectedIndex},
        onSelectionChanged: (selection) => onSelect(selection.first),
      ),
    );
  }
}
