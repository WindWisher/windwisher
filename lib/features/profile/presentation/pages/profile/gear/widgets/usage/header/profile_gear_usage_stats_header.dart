import 'package:flutter/material.dart';

class ProfileGearUsageStatsHeader extends StatelessWidget {
  const ProfileGearUsageStatsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Estadisticas de uso de equipacion',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
