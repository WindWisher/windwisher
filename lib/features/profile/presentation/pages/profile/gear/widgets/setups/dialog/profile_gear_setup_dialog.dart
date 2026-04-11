import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

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
    return AlertDialog(
      title: const Text('Equipacion guardada'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(setupName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (detailLines.isNotEmpty)
            ...detailLines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(line),
              ),
            )
          else
            const Text('No hay mas detalle disponible para esta equipacion.'),
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
