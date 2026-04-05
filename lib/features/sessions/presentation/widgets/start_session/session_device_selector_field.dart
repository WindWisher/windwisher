import 'package:flutter/material.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class SessionDeviceSelectorField extends StatelessWidget {
  const SessionDeviceSelectorField({
    super.key,
    required this.selectedDeviceId,
    required this.devices,
    required this.onChanged,
  });

  final String? selectedDeviceId;
  final List<SessionDeviceSelectorItemData> devices;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedDeviceId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Seleccionar dispositivo',
        border: OutlineInputBorder(),
      ),
      items: devices
          .map(
            (device) => DropdownMenuItem(
              value: device.id,
              child: Text(
                device.label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        onChanged(value);
      },
    );
  }
}
