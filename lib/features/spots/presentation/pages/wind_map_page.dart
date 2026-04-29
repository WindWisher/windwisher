import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WindMapSample {
  const WindMapSample({
    required this.time,
    required this.windKnots,
    required this.windDeg,
    this.gustKnots,
    this.waveM,
  });

  final DateTime time;
  final int windKnots;
  final int windDeg;
  final int? gustKnots;
  final double? waveM;
}

class WindMapPage extends StatefulWidget {
  const WindMapPage({
    super.key,
    required this.spotName,
    required this.center,
    required this.samples,
    required this.providerLabel,
    required this.modelLabel,
    this.gridSnapshots = const <dynamic>[],
  });

  final String spotName;
  final LatLng center;
  final List<WindMapSample> samples;
  final String providerLabel;
  final String modelLabel;
  final List<dynamic> gridSnapshots;

  @override
  State<WindMapPage> createState() => _WindMapPageState();
}

class _WindMapPageState extends State<WindMapPage> {
  static const _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

  WebViewController? _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initPortusController();
  }

  @override
  void didUpdateWidget(covariant WindMapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.center != widget.center) {
      _controller?.loadRequest(Uri.parse(_portusWindViewerUrl(widget.center)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de viento')),
      body: _buildBody(context),
    );
  }

  void _initPortusController() {
    if (_isFlutterTest || kIsWeb || WebViewPlatform.instance == null) {
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = 0;
            });
          },
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = 100;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_portusWindViewerUrl(widget.center)));
  }

  Widget _buildBody(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = _controller;
    if (controller == null) {
      return _UnsupportedPortusMap(center: widget.center);
    }

    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (_loadingProgress < 100)
          LinearProgressIndicator(
            value: _loadingProgress <= 0 ? null : _loadingProgress / 100,
            minHeight: 3,
            color: colorScheme.primary,
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
          ),
      ],
    );
  }
}

class _UnsupportedPortusMap extends StatelessWidget {
  const _UnsupportedPortusMap({required this.center});

  final LatLng center;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.blur_on_rounded, size: 42, color: colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              'Mapa Portus no disponible en esta plataforma',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El mapa oficial de viento necesita WebView nativo. En Android e iOS debería cargarse dentro de la app.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              _portusWindViewerUrl(center),
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _portusWindViewerUrl(LatLng center) {
  final query = Uri(
    queryParameters: {
      'resourceId': 'viento',
      'var': 'WIND',
      'modelo': 'portus',
      'zoom': '10',
      'lat': center.latitude.toStringAsFixed(5),
      'lon': center.longitude.toStringAsFixed(5),
      'vec': 'true',
      'part': 'true',
      'locale': 'es',
      'theme': 'light',
    },
  ).query;
  return 'https://portus.puertos.es/#/predictionWidget?$query';
}
