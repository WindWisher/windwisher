import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class SessionAddDeviceDialog extends StatefulWidget {
  const SessionAddDeviceDialog({
    super.key,
    required this.availableDevices,
  });

  final List<SessionDetectedCompatibleDeviceData> availableDevices;

  static Future<SessionDetectedCompatibleDeviceData?> show(
    BuildContext context, {
    required List<SessionDetectedCompatibleDeviceData> availableDevices,
  }) {
    return showDialog<SessionDetectedCompatibleDeviceData>(
      context: context,
      builder: (context) {
        return SessionAddDeviceDialog(availableDevices: availableDevices);
      },
    );
  }

  @override
  State<SessionAddDeviceDialog> createState() => _SessionAddDeviceDialogState();
}

class _SessionAddDeviceDialogState extends State<SessionAddDeviceDialog> {
  SessionDetectedCompatibleDeviceData? _selectedDevice;
  late final TextEditingController _customNameController;

  @override
  void initState() {
    super.initState();
    _selectedDevice = widget.availableDevices.isEmpty
        ? null
        : widget.availableDevices.first;
    _customNameController = TextEditingController(
      text: _selectedDevice?.defaultName ?? '',
    );
  }

  @override
  void dispose() {
    _customNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar dispositivo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aqui aparecen dispositivos detectados y aun no vinculados. Al elegir uno comprobaremos si realmente sirve para grabar sesiones.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (widget.availableDevices.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No se han detectado mas dispositivos por ahora. El teléfono del usuario ya queda disponible automaticamente.',
              ),
            )
          else ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedDevice?.id,
              decoration: const InputDecoration(
                labelText: 'Dispositivo detectado',
                border: OutlineInputBorder(),
              ),
              items: widget.availableDevices
                  .map(
                    (device) => DropdownMenuItem(
                      value: device.id,
                      child: Text('${device.defaultName} · ${device.kind}'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                SessionDetectedCompatibleDeviceData? next;
                for (final device in widget.availableDevices) {
                  if (device.id == value) {
                    next = device;
                    break;
                  }
                }
                if (next == null) {
                  return;
                }
                final nextDefaultName = next.defaultName;
                setState(() {
                  _selectedDevice = next;
                  _customNameController
                    ..text = nextDefaultName
                    ..selection = TextSelection.collapsed(
                      offset: nextDefaultName.length,
                    );
                });
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_selectedDevice != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedDevice!.defaultName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedDevice!.kind} · ${_selectedDevice!.status}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedDevice!.sensorSummary,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _customNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del dispositivo en la app',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _selectedDevice == null
              ? null
              : () {
                  final customName = _customNameController.text.trim();
                  Navigator.of(context).pop(
                    _selectedDevice!.copyWith(
                      customName: customName.isEmpty
                          ? _selectedDevice!.defaultName
                          : customName,
                    ),
                  );
                },
          icon: const Icon(Icons.link_rounded),
          label: const Text('Vincular'),
        ),
      ],
    );
  }
}
