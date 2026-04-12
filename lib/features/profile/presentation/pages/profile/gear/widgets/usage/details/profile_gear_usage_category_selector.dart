import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/usage/details/profile_gear_usage_dialog_data.dart';

class ProfileGearUsageCategorySelector extends StatelessWidget {
  const ProfileGearUsageCategorySelector({
    super.key,
    required this.sections,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ProfileGearUsageSectionData> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: selectedIndex,
      decoration: const InputDecoration(
        labelText: 'Categoria',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.tune_rounded),
        isDense: true,
      ),
      items: [
        for (var index = 0; index < sections.length; index++)
          DropdownMenuItem<int>(
            value: index,
            child: Text(sections[index].title),
          ),
      ],
      onChanged: (value) {
        if (value != null) onSelected(value);
      },
    );
  }
}
