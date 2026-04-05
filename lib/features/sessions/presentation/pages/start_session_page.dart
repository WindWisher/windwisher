import 'package:flutter/material.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_start_panel.dart';

class StartSessionPage extends StatelessWidget {
  const StartSessionPage({
    super.key,
    required this.data,
    required this.panel,
    this.descriptionTextStyle,
  });

  final StartSessionPageData data;
  final SessionStartPanel panel;
  final TextStyle? descriptionTextStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data.description, style: descriptionTextStyle),
        panel,
      ],
    );
  }
}
