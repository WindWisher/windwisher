import 'package:flutter/material.dart';

class ProfileGearFormDialog extends StatelessWidget {
  const ProfileGearFormDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(title: Text(title), content: content, actions: actions);
  }
}
