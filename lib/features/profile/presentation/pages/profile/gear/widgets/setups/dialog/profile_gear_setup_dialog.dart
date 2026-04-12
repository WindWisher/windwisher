import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_equipment_detail_list.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/details/dialog/profile_gear_detail_dialog.dart';

class ProfileGearSetupDialog extends StatelessWidget {
  const ProfileGearSetupDialog({
    super.key,
    required this.setupName,
    required this.detailLines,
  });

  final String setupName;
  final List<String> detailLines;

  static Future<void> show(
    BuildContext context, {
    required String setupName,
    List<String> detailLines = const <String>[],
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return ProfileGearSetupDialog(
          setupName: setupName,
          detailLines: detailLines,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ProfileGearDetailDialog(
      title: 'Equipacion guardada',
      maxWidth: 460,
      maxHeight: 420,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(setupName, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: SingleChildScrollView(
                child: AppEquipmentDetailList(
                  lines: detailLines,
                  emptyMessage:
                      'No hay mas detalle disponible para esta equipacion.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
