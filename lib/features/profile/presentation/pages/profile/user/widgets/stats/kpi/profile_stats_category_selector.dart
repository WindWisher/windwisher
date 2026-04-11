import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/stats/kpi/profile_kpi_catalog.dart';

class ProfileStatsCategorySelector extends StatelessWidget {
  const ProfileStatsCategorySelector({
    super.key,
    required this.sections,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ProfileKpiSectionData> sections;
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
        if (value != null) {
          onSelected(value);
        }
      },
    );
  }
}
