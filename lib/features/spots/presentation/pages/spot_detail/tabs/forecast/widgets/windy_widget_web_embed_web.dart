// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

class WindyWidgetWebEmbed extends StatefulWidget {
  const WindyWidgetWebEmbed({
    super.key,
    required this.html,
    required this.viewTypePrefix,
  });

  final String html;
  final String viewTypePrefix;

  @override
  State<WindyWidgetWebEmbed> createState() => _WindyWidgetWebEmbedState();
}

class _WindyWidgetWebEmbedState extends State<WindyWidgetWebEmbed> {
  static final Set<String> _registeredViewTypes = <String>{};

  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = '${widget.viewTypePrefix}-${widget.html.hashCode}';
    if (_registeredViewTypes.add(_viewType)) {
      final widgetHtml = widget.html;
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final iframe = html.IFrameElement()
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.backgroundColor = '#ffffff'
          ..srcdoc = widgetHtml;
        iframe.setAttribute(
          'sandbox',
          'allow-scripts allow-same-origin allow-popups allow-popups-to-escape-sandbox',
        );
        iframe.setAttribute('referrerpolicy', 'no-referrer-when-downgrade');
        return iframe;
      });
    }
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
