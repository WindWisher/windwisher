// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

class WindguruWebEmbed extends StatefulWidget {
  const WindguruWebEmbed({
    super.key,
    required this.html,
  });

  final String html;

  @override
  State<WindguruWebEmbed> createState() => _WindguruWebEmbedState();
}

class _WindguruWebEmbedState extends State<WindguruWebEmbed> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType =
        'windguru-embed-${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'transparent'
        ..srcdoc = widget.html;
      iframe.setAttribute(
        'sandbox',
        'allow-scripts allow-same-origin allow-popups allow-popups-to-escape-sandbox',
      );
      iframe.setAttribute('referrerpolicy', 'no-referrer-when-downgrade');
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
