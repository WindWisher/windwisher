import 'package:flutter/widgets.dart';

class ProfileGearUsageSectionData {
  const ProfileGearUsageSectionData({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;
}
