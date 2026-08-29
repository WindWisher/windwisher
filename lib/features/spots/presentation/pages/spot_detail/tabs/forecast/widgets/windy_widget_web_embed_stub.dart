import 'package:flutter/widgets.dart';

class WindyWidgetWebEmbed extends StatelessWidget {
  const WindyWidgetWebEmbed({
    super.key,
    required this.html,
    required this.viewTypePrefix,
  });

  final String html;
  final String viewTypePrefix;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
