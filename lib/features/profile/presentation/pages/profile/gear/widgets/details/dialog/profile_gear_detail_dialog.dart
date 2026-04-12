import 'package:flutter/material.dart';
import 'package:windwisher/core/ui/app_detail_dialog.dart';

class ProfileGearDetailDialog extends StatelessWidget {
  const ProfileGearDetailDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.maxWidth = 720,
    this.maxHeight = 760,
    this.actions = const <Widget>[],
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final double maxWidth;
  final double maxHeight;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppDetailDialog(
      title: title,
      subtitle: subtitle,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      actions: actions,
      child: child,
    );
  }
}
