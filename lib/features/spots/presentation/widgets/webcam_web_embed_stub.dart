import 'package:flutter/widgets.dart';

class WebcamWebEmbed extends StatelessWidget {
  const WebcamWebEmbed({
    super.key,
    this.html,
    this.url,
  });

  final String? html;
  final String? url;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
