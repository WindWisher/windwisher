import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/units/app_units_controller.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_section_card.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_tile.dart';

class UnitsSettingsSection extends StatefulWidget {
  const UnitsSettingsSection({super.key});

  @override
  State<UnitsSettingsSection> createState() => _UnitsSettingsSectionState();
}

class _UnitsSettingsSectionState extends State<UnitsSettingsSection> {
  bool _isExpanded = false;

  AppUnitsController get _unitsController => AppUnitsController.instance;

  @override
  void initState() {
    super.initState();
    _unitsController.addListener(_handleUnitsChanged);
  }

  @override
  void dispose() {
    _unitsController.removeListener(_handleUnitsChanged);
    super.dispose();
  }

  void _handleUnitsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _selectWindSpeedUnit() async {
    final selected = await _showUnitPicker<WindSpeedUnit>(
      title: 'Unidad de velocidad',
      values: WindSpeedUnit.values,
      selectedValue: _unitsController.windSpeedUnit,
      displayName: (unit) => unit.displayName,
      shortLabel: (unit) => unit.shortLabel,
    );
    if (selected != null) {
      await _unitsController.setWindSpeedUnit(selected);
    }
  }

  Future<void> _selectDistanceUnit() async {
    final selected = await _showUnitPicker<DistanceUnit>(
      title: 'Unidad de distancia',
      values: DistanceUnit.values,
      selectedValue: _unitsController.distanceUnit,
      displayName: (unit) => unit.displayName,
      shortLabel: (unit) => unit.shortLabel,
    );
    if (selected != null) {
      await _unitsController.setDistanceUnit(selected);
    }
  }

  Future<void> _selectTemperatureUnit() async {
    final selected = await _showUnitPicker<TemperatureUnit>(
      title: 'Unidad de temperatura',
      values: TemperatureUnit.values,
      selectedValue: _unitsController.temperatureUnit,
      displayName: (unit) => unit.displayName,
      shortLabel: (unit) => unit.shortLabel,
    );
    if (selected != null) {
      await _unitsController.setTemperatureUnit(selected);
    }
  }

  Future<void> _selectHeightUnit() async {
    final selected = await _showUnitPicker<HeightUnit>(
      title: 'Unidad de altura',
      values: HeightUnit.values,
      selectedValue: _unitsController.heightUnit,
      displayName: (unit) => unit.displayName,
      shortLabel: (unit) => unit.shortLabel,
    );
    if (selected != null) {
      await _unitsController.setHeightUnit(selected);
    }
  }

  Future<T?> _showUnitPicker<T>({
    required String title,
    required List<T> values,
    required T selectedValue,
    required String Function(T value) displayName,
    required String Function(T value) shortLabel,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              for (final value in values)
                ListTile(
                  title: Text(displayName(value)),
                  subtitle: Text(shortLabel(value)),
                  trailing: Icon(
                    value == selectedValue
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () => Navigator.of(context).pop(value),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        maintainState: true,
        leading: const Icon(Icons.straighten),
        title: Text('Unidades', style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          _isExpanded
              ? 'Preferencias de medida'
              : '${_unitsController.windSpeedUnit.shortLabel}, '
                    '${_unitsController.distanceUnit.shortLabel}, '
                    '${_unitsController.temperatureUnit.shortLabel}, '
                    '${_unitsController.heightUnit.shortLabel}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        onExpansionChanged: (value) {
          setState(() => _isExpanded = value);
        },
        children: [
          const SizedBox(height: AppSpacing.xs),
          SettingsTile(
            title: 'Velocidad',
            subtitle:
                '${_unitsController.windSpeedUnit.displayName} (${_unitsController.windSpeedUnit.shortLabel})',
            icon: Icons.speed,
            onTap: _selectWindSpeedUnit,
          ),
          SettingsTile(
            title: 'Distancia',
            subtitle:
                '${_unitsController.distanceUnit.displayName} (${_unitsController.distanceUnit.shortLabel})',
            icon: Icons.straighten,
            onTap: _selectDistanceUnit,
          ),
          SettingsTile(
            title: 'Temperatura',
            subtitle:
                '${_unitsController.temperatureUnit.displayName} (${_unitsController.temperatureUnit.shortLabel})',
            icon: Icons.thermostat,
            onTap: _selectTemperatureUnit,
          ),
          SettingsTile(
            title: 'Altura',
            subtitle:
                '${_unitsController.heightUnit.displayName} (${_unitsController.heightUnit.shortLabel})',
            icon: Icons.height,
            onTap: _selectHeightUnit,
          ),
        ],
      ),
    );
  }
}
