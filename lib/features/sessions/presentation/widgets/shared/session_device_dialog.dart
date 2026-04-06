import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';

class SessionDeviceDialog extends StatelessWidget {
  const SessionDeviceDialog({
    super.key,
    required this.deviceName,
    required this.deviceKind,
    this.deviceSensorKeys = const <String>[],
  });

  final String deviceName;
  final String deviceKind;
  final List<String> deviceSensorKeys;

  static Future<void> show(
    BuildContext context, {
    required String deviceName,
    required String deviceKind,
    List<String> deviceSensorKeys = const <String>[],
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return SessionDeviceDialog(
          deviceName: deviceName,
          deviceKind: deviceKind,
          deviceSensorKeys: deviceSensorKeys,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderedKeys = deviceSensorKeys.toSet().toList(growable: false)
      ..sort((a, b) {
        final order = SessionInsightData.physicalSensorOrder;
        final aIndex = order.indexOf(a);
        final bIndex = order.indexOf(b);
        final normalizedA = aIndex == -1 ? 999 : aIndex;
        final normalizedB = bIndex == -1 ? 999 : bIndex;
        return normalizedA.compareTo(normalizedB);
      });
    final derivedCapabilities = SessionInsightData.derivedCapabilityOrder
        .where(
          (key) => SessionInsightData.derivedCapabilitiesForPhysicalSensors(
            orderedKeys,
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
              deviceName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              deviceKind,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              orderedKeys.length == 1
                  ? '1 sensor físico disponible'
                  : '${orderedKeys.length} sensores físicos disponibles',
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
            if (orderedKeys.isEmpty)
              Text(
                'Aún no hemos detectado sensores físicos utilizables para este dispositivo.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: orderedKeys
                    .map(
                      (key) => Chip(
                        avatar: const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Color(0xFF2E7D32),
                        ),
                        label: Text(
                          SessionInsightData.physicalSensorLabels[key] ?? key,
                        ),
                        backgroundColor: const Color(0x1F2E7D32),
                      ),
                    )
                    .toList(growable: false),
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
                children: derivedCapabilities
                    .map(
                      (key) => Chip(
                        avatar: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: Color(0xFF1565C0),
                        ),
                        label: Text(
                          SessionInsightData.derivedCapabilityLabels[key] ?? key,
                        ),
                        backgroundColor: const Color(0x1F1565C0),
                      ),
                    )
                    .toList(growable: false),
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
