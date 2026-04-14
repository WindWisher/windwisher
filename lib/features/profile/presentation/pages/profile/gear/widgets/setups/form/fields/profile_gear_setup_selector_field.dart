import 'package:flutter/material.dart';

class ProfileGearSetupSelectorField extends StatelessWidget {
  const ProfileGearSetupSelectorField({
    super.key,
    required this.fieldKey,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  final Key fieldKey;
  final String? value;
  final String label;
  final List<DropdownMenuItem<String?>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      key: fieldKey,
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: 360,
      decoration: InputDecoration(labelText: label),
      items: items,
      selectedItemBuilder: (context) {
        return items.map((item) {
          final child = item.child;
          if (child is Text) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                child.data ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }
          return Align(alignment: Alignment.centerLeft, child: child);
        }).toList(growable: false);
      },
      onChanged: (value) => onChanged(value),
    );
  }
}
