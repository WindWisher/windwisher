import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';

class SessionDeviceCapabilitiesDialog extends StatelessWidget {
  const SessionDeviceCapabilitiesDialog({
    super.key,
    required this.capabilities,
  });

  final Set<String> capabilities;

  static Future<void> show(
    BuildContext context, {
    required Set<String> capabilities,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return SessionDeviceCapabilitiesDialog(capabilities: capabilities);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = capabilities.length;
    final availableCapabilities = SessionInsightData.physicalSensorOrder
        .where((key) => capabilities.contains(key))
        .toList(growable: false);

    return AlertDialog(
      title: const Text('Capacidades del dispositivo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              available == 1
                  ? '1 sensor disponible'
                  : '$available sensores disponibles',
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Aquí solo mostramos sensores físicos reales del dispositivo.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            if (availableCapabilities.isEmpty)
              Text(
                'Aun no hemos detectado capacidades utilizables para este dispositivo.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: availableCapabilities.map((key) {
                  final label =
                      SessionInsightData.physicalSensorLabels[key] ?? key;
                  return Chip(
                    avatar: const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Color(0xFF2E7D32),
                    ),
                    label: Text(label),
                    backgroundColor: const Color(0x1F2E7D32),
                  );
                }).toList(growable: false),
              ),
          ],
        ),
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
