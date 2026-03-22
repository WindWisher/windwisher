import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/spots/domain/entities/spot_webcam.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebcamPlayerPage extends StatefulWidget {
  const WebcamPlayerPage({
    super.key,
    required this.webcamName,
    required this.source,
    required this.status,
    required this.resolution,
    required this.relatedPages,
    this.primaryPageUrl,
    this.summary,
    this.streamManifestUrl,
    this.previewImageUrl,
  });

  final String webcamName;
  final String source;
  final String status;
  final String resolution;
  final List<WebcamReferencePage> relatedPages;
  final String? primaryPageUrl;
  final String? summary;
  final String? streamManifestUrl;
  final String? previewImageUrl;

  @override
  State<WebcamPlayerPage> createState() => _WebcamPlayerPageState();
}

class _WebcamPlayerPageState extends State<WebcamPlayerPage> {
  static const _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');
  WebViewController? _controller;
  int _loadingProgress = 0;

  String get _pageUrl =>
      widget.primaryPageUrl ??
      (widget.relatedPages.isNotEmpty ? widget.relatedPages.first.url : '');

  String get _streamManifestUrl => widget.streamManifestUrl ?? '';

  String _streamEmbedHtml() {
    final posterAttribute = widget.previewImageUrl == null
        ? ''
        : 'poster="${widget.previewImageUrl!}"';
    return '''
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      background: #000;
      width: 100%;
      height: 100%;
      overflow: hidden;
    }
    body {
      display: flex;
      align-items: center;
      justify-content: center;
    }
    video {
      width: 100%;
      height: 100%;
      object-fit: cover;
      background: #000;
    }
  </style>
  <script src="https://www.comunitatvalenciana.com/o/external-deps-theme-contrib/js/shaka-player.js"></script>
  <script src="https://www.comunitatvalenciana.com/o/external-deps-theme-contrib/js/shaka-streaming-controls.js"></script>
</head>
<body>
  <video
    id="streaming-webcam"
    x-webkit-airplay="allow"
    controls
    muted
    autoplay
    playsinline
    $posterAttribute
  ></video>
  <script>
    document.addEventListener('DOMContentLoaded', function () {
      connect(
        document.querySelector('#streaming-webcam'),
        '$_streamManifestUrl'
      );
    });
  </script>
</body>
</html>
''';
  }

  @override
  void initState() {
    super.initState();
    if (_isFlutterTest) {
      return;
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
      );
    if (_streamManifestUrl.isNotEmpty) {
      _controller!.loadHtmlString(_streamEmbedHtml());
      return;
    }
    if (_pageUrl.isNotEmpty) {
      _controller!.loadRequest(Uri.parse(_pageUrl));
    }
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _WebcamFullscreenView(
          webcamName: widget.webcamName,
          streamManifestUrl: _streamManifestUrl,
          previewImageUrl: widget.previewImageUrl,
          pageUrl: _pageUrl,
        ),
      ),
    );
  }

  Future<void> _forcePortraitMode() async {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
  }

  Widget _buildPlayerSurface({
    BorderRadius? borderRadius,
    bool fill = false,
    bool showFullscreenButton = true,
  }) {
    final player = _controller == null
        ? Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Center(
              child: Text(
                _pageUrl.isEmpty
                    ? 'No hay una webcam publica configurada para esta entrada.'
                    : 'La webcam real no se inicializa en este entorno.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        : WebViewWidget(controller: _controller!);
    final content = borderRadius == null
        ? player
        : ClipRRect(borderRadius: borderRadius, child: player);

    return Stack(
      fit: fill ? StackFit.expand : StackFit.loose,
      children: [
        Positioned.fill(child: content),
        if (_controller != null && _loadingProgress < 100)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(
              value: _loadingProgress / 100,
              minHeight: 3,
            ),
          ),
        if (showFullscreenButton)
          Positioned(
            right: 10,
            bottom: 10,
            child: Material(
              color: Colors.white.withValues(alpha: 0.9),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Pantalla completa',
                onPressed: _openFullscreen,
                icon: const Icon(Icons.fullscreen_rounded),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFullscreenByRotation() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildPlayerSurface(fill: true, showFullscreenButton: false),
          Positioned(
            right: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: SafeArea(
              child: SizedBox(
                width: 38,
                height: 38,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: 'webcamRotateFullscreenClose',
                  tooltip: 'Salir de fullscreen',
                  elevation: 0,
                  highlightElevation: 0,
                  backgroundColor: Colors.black.withValues(alpha: 0.28),
                  foregroundColor: Colors.white.withValues(alpha: 0.92),
                  shape: const CircleBorder(),
                  onPressed: _forcePortraitMode,
                  child: const Icon(Icons.close_rounded, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);
    if (orientation == Orientation.landscape) {
      return _buildFullscreenByRotation();
    }
    final infoLines = <String>[
      widget.source,
      if (widget.summary != null && widget.summary!.trim().isNotEmpty)
        widget.summary!.trim(),
      if (_pageUrl.isNotEmpty) _pageUrl,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(widget.webcamName)),
      body: ScrollConfiguration(
        behavior: const _NoStretchScrollBehavior(),
        child: ListView(
          physics: kAppBouncingScrollPhysics,
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildPlayerSurface(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Webcam principal',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...infoLines.map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(line),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebcamFullscreenView extends StatelessWidget {
  const _WebcamFullscreenView({
    required this.webcamName,
    required this.pageUrl,
    required this.streamManifestUrl,
    this.previewImageUrl,
  });

  final String webcamName;
  final String pageUrl;
  final String streamManifestUrl;
  final String? previewImageUrl;

  String _streamEmbedHtml() {
    final posterAttribute = previewImageUrl == null
        ? ''
        : 'poster="${previewImageUrl!}"';
    return '''
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      background: #000;
      width: 100%;
      height: 100%;
      overflow: hidden;
    }
    body {
      display: flex;
      align-items: center;
      justify-content: center;
    }
    video {
      width: 100%;
      height: 100%;
      object-fit: cover;
      background: #000;
    }
  </style>
  <script src="https://www.comunitatvalenciana.com/o/external-deps-theme-contrib/js/shaka-player.js"></script>
  <script src="https://www.comunitatvalenciana.com/o/external-deps-theme-contrib/js/shaka-streaming-controls.js"></script>
</head>
<body>
  <video
    id="streaming-webcam"
    x-webkit-airplay="allow"
    controls
    muted
    autoplay
    playsinline
    $posterAttribute
  ></video>
  <script>
    document.addEventListener('DOMContentLoaded', function () {
      connect(
        document.querySelector('#streaming-webcam'),
        '$streamManifestUrl'
      );
    });
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return _WebcamFullscreenScaffold(
      webcamName: webcamName,
      pageUrl: pageUrl,
      streamManifestUrl: streamManifestUrl,
      previewImageUrl: previewImageUrl,
      streamEmbedHtml: _streamEmbedHtml(),
    );
  }
}

class _WebcamFullscreenScaffold extends StatefulWidget {
  const _WebcamFullscreenScaffold({
    required this.webcamName,
    required this.pageUrl,
    required this.streamManifestUrl,
    required this.streamEmbedHtml,
    this.previewImageUrl,
  });

  final String webcamName;
  final String pageUrl;
  final String streamManifestUrl;
  final String streamEmbedHtml;
  final String? previewImageUrl;

  @override
  State<_WebcamFullscreenScaffold> createState() =>
      _WebcamFullscreenScaffoldState();
}

class _WebcamFullscreenScaffoldState extends State<_WebcamFullscreenScaffold> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    if (widget.streamManifestUrl.isNotEmpty) {
      _controller!.loadHtmlString(widget.streamEmbedHtml);
    } else if (widget.pageUrl.isNotEmpty) {
      _controller!.loadRequest(Uri.parse(widget.pageUrl));
    }
  }

  Future<void> _closeFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller != null)
              WebViewWidget(controller: _controller!)
            else
              const ColoredBox(color: Colors.black),
            Positioned(
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: SafeArea(
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: 'webcamFullscreenClose',
                    tooltip: 'Salir de fullscreen',
                    elevation: 0,
                    highlightElevation: 0,
                    backgroundColor: Colors.black.withValues(alpha: 0.28),
                    foregroundColor: Colors.white.withValues(alpha: 0.92),
                    shape: const CircleBorder(),
                    onPressed: _closeFullscreen,
                    child: const Icon(Icons.close_rounded, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoStretchScrollBehavior extends AppScrollBehavior {
  const _NoStretchScrollBehavior();
}
