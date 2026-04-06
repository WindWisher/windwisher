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
    final physicalSensors = SessionInsightData.physicalSensorOrder
        .where((key) => capabilities.contains(key))
        .toList(growable: false);
    final derivedCapabilities = SessionInsightData.derivedCapabilityOrder
        .where(
          (key) => SessionInsightData.derivedCapabilitiesForPhysicalSensors(
            capabilities,
          ).contains(key),
        )
        .toList(growable: false);

    return AlertDialog(
      title: const Text('Capacidades del dispositivo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              physicalSensors.length == 1
                  ? '1 sensor físico disponible'
                  : '${physicalSensors.length} sensores físicos disponibles',
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Primero mostramos hardware real del dispositivo y después las capacidades calculadas a partir de esos sensores.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sensores físicos',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            if (physicalSensors.isEmpty)
              Text(
                'Aún no hemos detectado sensores físicos utilizables para este dispositivo.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: physicalSensors.map((key) {
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
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Capacidades derivadas',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            if (derivedCapabilities.isEmpty)
              Text(
                'No hay capacidades derivadas calculables con este conjunto de sensores.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: derivedCapabilities.map((key) {
                  final label =
                      SessionInsightData.derivedCapabilityLabels[key] ?? key;
                  return Chip(
                    avatar: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: Color(0xFF1565C0),
                    ),
                    label: Text(label),
                    backgroundColor: const Color(0x1F1565C0),
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
