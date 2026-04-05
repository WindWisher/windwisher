import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

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
    return AlertDialog(
      title: const Text('Equipo utilizado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gearSetupName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (gearSetupDetailLines.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ...gearSetupDetailLines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(line),
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            const Text('No hay mas detalle disponible para este equipo.'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
