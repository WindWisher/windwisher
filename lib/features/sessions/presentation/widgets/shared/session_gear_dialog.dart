import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_detail_dialog.dart';
import 'package:windwisher/core/ui/app_equipment_detail_list.dart';

class SessionGearDialog extends StatelessWidget {
  const SessionGearDialog({
    super.key,
    required this.gearSetupName,
    this.gearSetupDetailLines = const <String>[],
  });

  final String gearSetupName;
  final List<String> gearSetupDetailLines;

  static Future<void> show(
    BuildContext context, {
    required String gearSetupName,
    List<String> gearSetupDetailLines = const <String>[],
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return SessionGearDialog(
          gearSetupName: gearSetupName,
          gearSetupDetailLines: gearSetupDetailLines,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailDialog(
      title: 'Equipo utilizado',
      maxWidth: 460,
      maxHeight: 420,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gearSetupName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: SingleChildScrollView(
                child: AppEquipmentDetailList(
                  lines: gearSetupDetailLines,
                  emptyMessage:
                      'No hay mas detalle disponible para este equipo.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
