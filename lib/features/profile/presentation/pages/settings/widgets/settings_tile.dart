import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.subtitleStyle,
    this.onTap,
    this.showChevron = true,
  });

  final String title;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: subtitle != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subtitle!,
                  style: subtitleStyle ?? const TextStyle(color: Colors.grey),
                ),
                if (showChevron) const Icon(Icons.chevron_right),
              ],
            )
          : showChevron
          ? const Icon(Icons.chevron_right)
          : null,
      onTap: onTap,
    );
  }
}
