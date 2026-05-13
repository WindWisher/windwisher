part of '../../../spot_detail_page.dart';

class _LiveAlarmRepeatControls extends StatelessWidget {
  const _LiveAlarmRepeatControls({
    required this.repeatWindow,
    required this.maxRepeats,
    required this.onRepeatWindowChanged,
    required this.onMaxRepeatsChanged,
  });

  final AlarmRepeatWindow repeatWindow;
  final int maxRepeats;
  final ValueChanged<AlarmRepeatWindow> onRepeatWindowChanged;
  final ValueChanged<int> onMaxRepeatsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<AlarmRepeatWindow>(
          initialValue: repeatWindow,
          decoration: const InputDecoration(
            labelText: 'Repetir cada',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: AlarmRepeatWindow.min1,
              child: Text('1 min'),
            ),
            DropdownMenuItem(
              value: AlarmRepeatWindow.min5,
              child: Text('5 min'),
            ),
            DropdownMenuItem(
              value: AlarmRepeatWindow.min10,
              child: Text('10 min'),
            ),
            DropdownMenuItem(
              value: AlarmRepeatWindow.min15,
              child: Text('15 min'),
            ),
            DropdownMenuItem(
              value: AlarmRepeatWindow.min30,
              child: Text('30 min'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onRepeatWindowChanged(value);
            }
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<int>(
          initialValue: maxRepeats,
          decoration: const InputDecoration(
            labelText: 'Maximo de avisos seguidos',
            border: OutlineInputBorder(),
          ),
          items: List.generate(6, (index) {
            final value = index + 1;
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value aviso${value == 1 ? '' : 's'}'),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              onMaxRepeatsChanged(value);
            }
          },
        ),
      ],
    );
  }
}

class _LiveAlarmSaveButton extends StatelessWidget {
  const _LiveAlarmSaveButton({
    required this.isEditing,
    required this.onPressed,
  });

  final bool isEditing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.alarm_add_rounded),
        label: Text(isEditing ? 'Guardar cambios' : 'Guardar alarma'),
      ),
    );
  }
}
