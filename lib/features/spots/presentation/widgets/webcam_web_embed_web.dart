// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

class WebcamWebEmbed extends StatefulWidget {
  const WebcamWebEmbed({
    super.key,
    this.html,
    this.url,
  });

  final String? html;
  final String? url;

  @override
  State<WebcamWebEmbed> createState() => _WebcamWebEmbedState();
}

class _WebcamWebEmbedState extends State<WebcamWebEmbed> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType =
        'webcam-embed-${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final htmlContent = widget.html?.trim();
      final url = widget.url?.trim();
      if (htmlContent != null && htmlContent.isNotEmpty) {
        final iframe = html.IFrameElement()
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.backgroundColor = '#000'
          ..srcdoc = htmlContent;
        iframe.setAttribute(
          'sandbox',
          'allow-scripts allow-same-origin allow-popups allow-popups-to-escape-sandbox allow-forms',
        );
        iframe.setAttribute('allow', 'autoplay; fullscreen');
        iframe.setAttribute('referrerpolicy', 'no-referrer-when-downgrade');
        return iframe;
      }
      final iframe = html.IFrameElement()
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'transparent';
      if (url != null && url.isNotEmpty) {
        iframe.src = url;
        iframe.setAttribute(
          'sandbox',
          'allow-scripts allow-same-origin allow-popups allow-popups-to-escape-sandbox allow-forms',
        );
      }
      iframe.setAttribute('allow', 'autoplay; fullscreen');
      iframe.setAttribute('referrerpolicy', 'no-referrer-when-downgrade');
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
