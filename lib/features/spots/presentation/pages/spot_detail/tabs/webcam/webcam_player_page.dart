import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/spots/domain/entities/spot_webcam.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/webcam/widgets/webcam_web_embed.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

bool _isSkylineWebcamUrl(String url) {
  final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
  return host == 'skylinewebcams.com' || host == 'www.skylinewebcams.com';
}

bool _isMjpegStreamUrl(String url) {
  final uri = Uri.tryParse(url);
  final path = uri?.path.toLowerCase() ?? '';
  return path.contains('/mjpg/') ||
      path.endsWith('/mjpg/video.cgi') ||
      path.endsWith('/mjpeg') ||
      path.endsWith('/mjpeg.cgi');
}

String _mjpegEmbedHtml(String streamUrl) {
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
    img {
      width: 100%;
      height: 100%;
      object-fit: contain;
      background: #000;
    }
  </style>
</head>
<body>
  <img src="$streamUrl" alt="Webcam en directo">
</body>
</html>
''';
}

void _fitSkylineWebcamFrame(WebViewController? controller, String url) {
  if (controller == null || !_isSkylineWebcamUrl(url)) return;
  controller.runJavaScript(r'''
(function () {
  function fitWebcamFrame() {
    var webcam = document.querySelector('#webcam');
    if (!webcam) {
      return;
    }
    if (!document.getElementById('windwisher-skyline-frame-style')) {
      var style = document.createElement('style');
      style.id = 'windwisher-skyline-frame-style';
      style.textContent = `
        html, body {
          margin: 0 !important;
          padding: 0 !important;
          width: 100% !important;
          height: 100% !important;
          overflow: hidden !important;
          background: #000 !important;
        }
        body > *:not(.windwisher-skyline-frame-host) {
          display: none !important;
        }
        .windwisher-skyline-frame-host {
          position: fixed !important;
          inset: 0 !important;
          width: 100vw !important;
          height: 100vh !important;
          margin: 0 !important;
          padding: 0 !important;
          background: #000 !important;
          z-index: 2147483647 !important;
        }
        .windwisher-skyline-frame-host #webcam,
        .windwisher-skyline-frame-host #skylinewebcams,
        .windwisher-skyline-frame-host #live,
        .windwisher-skyline-frame-host .embed-responsive,
        .windwisher-skyline-frame-host .embed-responsive-16by9,
        .windwisher-skyline-frame-host .embed-responsive-item {
          position: absolute !important;
          inset: 0 !important;
          width: 100% !important;
          height: 100% !important;
          margin: 0 !important;
          padding: 0 !important;
          background: #000 !important;
        }
      `;
      document.head.appendChild(style);
    }
    var host = document.querySelector('.windwisher-skyline-frame-host');
    if (!host) {
      host = document.createElement('div');
      host.className = 'windwisher-skyline-frame-host';
      document.body.appendChild(host);
    }
    if (webcam.parentElement !== host) {
      host.appendChild(webcam);
    }
    window.dispatchEvent(new Event('resize'));
    if (window.player) {
      if (typeof window.player.resize === 'function') {
        try {
          window.player.resize();
        } catch (e) {}
      }
      if (typeof window.player.mute === 'function') {
        try {
          window.player.mute();
        } catch (e) {}
      }
      if (typeof window.player.play === 'function') {
        try {
          window.player.play();
        } catch (e) {}
      }
    }
    var video = webcam.querySelector('video');
    if (video) {
      video.muted = true;
      video.playsInline = true;
      video.setAttribute('muted', 'muted');
      video.setAttribute('playsinline', 'playsinline');
      video.setAttribute('webkit-playsinline', 'webkit-playsinline');
      video.play().catch(function () {});
    }
  }
  fitWebcamFrame();
  setTimeout(fitWebcamFrame, 250);
  setTimeout(fitWebcamFrame, 700);
  setTimeout(fitWebcamFrame, 1600);
})();
''');
}

String _iframeEmbedHtml(String url) {
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
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: #000;
    }
    iframe {
      position: fixed;
      inset: 0;
      width: 100%;
      height: 100%;
      border: 0;
      background: #000;
    }
  </style>
</head>
<body>
  <iframe
    src="$url"
    frameborder="0"
    scrolling="no"
    marginwidth="0"
    marginheight="0"
    allow="autoplay; fullscreen"
    allowfullscreen=""
    webkitallowfullscreen=""
    mozallowfullscreen=""
    oallowfullscreen=""
    msallowfullscreen=""
  ></iframe>
</body>
</html>
''';
}

Future<void> _configureAndroidWebcamController(
  WebViewController controller,
  String url,
) async {
  if (controller.platform case final AndroidWebViewController android) {
    await android.setMediaPlaybackRequiresUserGesture(false);
    await android.setUseWideViewPort(true);
    await android.setTextZoom(100);
  }
}

void _logWebcamConsoleMessage(JavaScriptConsoleMessage message) {
  if (!kDebugMode) return;
  debugPrint(
    'WebcamWebView console level=${message.level.name} '
    'message="${message.message}"',
  );
}

void _logWebcamResourceError(WebResourceError error) {
  if (!kDebugMode) return;
  debugPrint(
    'WebcamWebView resourceError code=${error.errorCode} '
    'type=${error.errorType} description="${error.description}" '
    'url=${error.url}',
  );
}

void _logWebcamHttpError(HttpResponseError error) {
  if (!kDebugMode) return;
  debugPrint(
    'WebcamWebView httpError status=${error.response?.statusCode} '
    'url=${error.request?.uri}',
  );
}

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
    this.embedAsIframe = false,
    this.focusIframeUrlContains,
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
  final bool embedAsIframe;
  final String? focusIframeUrlContains;

  @override
  State<WebcamPlayerPage> createState() => _WebcamPlayerPageState();
}

class _WebcamPlayerPageState extends State<WebcamPlayerPage> {
  static const _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');
  WebViewController? _controller;
  int _loadingProgress = 0;
  bool _isOpeningRotationFullscreen = false;
  bool _isSkylinePlayerPreparing = false;

  String get _pageUrl =>
      widget.primaryPageUrl ??
      (widget.relatedPages.isNotEmpty ? widget.relatedPages.first.url : '');

  String get _streamManifestUrl => widget.streamManifestUrl ?? '';

  bool get _usesDirectImage => _isDirectImageUrl(_pageUrl);

  bool get _usesRapidDirectImage => _isRapidDirectImageUrl(_pageUrl);

  bool get _usesMjpegStream => _isMjpegStreamUrl(_pageUrl);

  static bool _isDirectImageUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri?.host == 'cams.elcampello.es' &&
        uri?.path.startsWith('/image/') == true) {
      return true;
    }
    final normalized = url.toLowerCase().split('?').first;
    return normalized.endsWith('.jpg') ||
        normalized.endsWith('.jpeg') ||
        normalized.endsWith('.png') ||
        normalized.endsWith('.webp');
  }

  static bool _isRapidDirectImageUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri?.host == 'cams.elcampello.es' &&
        uri?.path == '/image/muchavista';
  }

  static int _directImageRefreshMs(String url) {
    if (_isRapidDirectImageUrl(url)) {
      return 400;
    }
    final uri = Uri.tryParse(url);
    if (uri?.host == 'www.avamet.es' &&
        uri?.path == '/estacions/illaplana/tabarca.jpg') {
      return 180000;
    }
    return 10000;
  }

  String _directImageEmbedHtml(String imageUrl) {
    final refreshMs = _directImageRefreshMs(imageUrl);
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
    img {
      width: 100%;
      height: 100%;
      object-fit: contain;
      background: #000;
    }
  </style>
</head>
<body>
  <img id="webcam-image" src="$imageUrl" alt="Webcam">
  <script>
    const baseUrl = '$imageUrl'.split('?')[0];
    const refreshMs = $refreshMs;
    let currentObjectUrl = null;
    async function refreshImage() {
      try {
        const response = await fetch(baseUrl, { cache: 'no-store' });
        if (!response.ok) throw new Error('HTTP ' + response.status);
        const nextObjectUrl = URL.createObjectURL(await response.blob());
        const image = document.getElementById('webcam-image');
        image.onload = function() {
          if (currentObjectUrl) URL.revokeObjectURL(currentObjectUrl);
          currentObjectUrl = nextObjectUrl;
          setTimeout(refreshImage, refreshMs);
        };
        image.src = nextObjectUrl;
      } catch (_) {
        setTimeout(refreshImage, Math.max(refreshMs, 1000));
      }
    }
    setTimeout(refreshImage, refreshMs);
    window.addEventListener('beforeunload', function() {
      if (currentObjectUrl) URL.revokeObjectURL(currentObjectUrl);
    });
  </script>
</body>
</html>
''';
  }

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
    if (_isFlutterTest || kIsWeb) {
      return;
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage(_logWebcamConsoleMessage)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = 0;
              _isSkylinePlayerPreparing = widget.embedAsIframe;
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
            _fitSkylineWebcamFrame(_controller, _pageUrl);
            _finishSkylinePlayerPreparing();
          },
          onWebResourceError: _logWebcamResourceError,
          onHttpError: _logWebcamHttpError,
          onNavigationRequest: _handleNavigationRequest,
        ),
      );
    _loadPlayer();
  }

  Future<void> _loadPlayer() async {
    final controller = _controller;
    if (controller == null) return;
    if (_usesRapidDirectImage) {
      await controller.clearCache();
    }
    if (mounted) {
      setState(() {
        _isSkylinePlayerPreparing = widget.embedAsIframe;
      });
    }
    await _configureAndroidWebcamController(controller, _pageUrl);
    if (_streamManifestUrl.isNotEmpty) {
      controller.loadHtmlString(_streamEmbedHtml());
      return;
    }
    if (_usesMjpegStream) {
      controller.loadHtmlString(_mjpegEmbedHtml(_pageUrl));
      return;
    }
    if (_usesDirectImage) {
      controller.loadHtmlString(_directImageEmbedHtml(_pageUrl));
      return;
    }
    if (widget.embedAsIframe) {
      controller.loadHtmlString(_iframeEmbedHtml(_pageUrl));
      return;
    }
    if (_pageUrl.isNotEmpty) {
      controller.loadRequest(Uri.parse(_pageUrl));
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    if (_usesRapidDirectImage && controller != null) {
      controller.clearCache().ignore();
    }
    super.dispose();
  }

  Future<void> _finishSkylinePlayerPreparing() async {
    if (!widget.embedAsIframe) return;
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    setState(() {
      _isSkylinePlayerPreparing = false;
    });
  }

  Future<void> _openFullscreen({bool forcePortraitOnClose = false}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _WebcamFullscreenView(
          webcamName: widget.webcamName,
          streamManifestUrl: _streamManifestUrl,
          previewImageUrl: widget.previewImageUrl,
          pageUrl: _pageUrl,
          embedAsIframe: widget.embedAsIframe,
          focusIframeUrlContains: widget.focusIframeUrlContains,
          directImageHtml: _usesMjpegStream
              ? _mjpegEmbedHtml(_pageUrl)
              : _usesDirectImage
              ? _directImageEmbedHtml(_pageUrl)
              : null,
          forcePortraitOnClose: forcePortraitOnClose,
        ),
      ),
    );
    if (!mounted) return;
    _isOpeningRotationFullscreen = false;
    _loadPlayer();
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) {
      return NavigationDecision.navigate;
    }
    if (_shouldOpenExternally(uri)) {
      _openUriExternally(uri);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  bool _shouldOpenExternally(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'intent' || scheme == 'vnd.youtube') {
      return true;
    }
    return scheme.isNotEmpty && scheme != 'http' && scheme != 'https';
  }

  Future<void> _openUriExternally(Uri uri) async {
    if (await _tryLaunchUri(uri)) return;
    final fallbackUri = _externalNavigationFallback(uri);
    if (fallbackUri != null) {
      await _tryLaunchUri(fallbackUri);
    }
  }

  Future<bool> _tryLaunchUri(Uri uri) async {
    for (final mode in const [
      LaunchMode.externalApplication,
      LaunchMode.platformDefault,
    ]) {
      try {
        if (await launchUrl(uri, mode: mode)) {
          return true;
        }
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  Uri? _externalNavigationFallback(Uri uri) {
    if (uri.scheme.toLowerCase() == 'intent') {
      final match = RegExp(
        r'S\.browser_fallback_url=([^;]+)',
      ).firstMatch(uri.toString());
      final fallback = match?.group(1);
      if (fallback != null) {
        return Uri.tryParse(Uri.decodeComponent(fallback));
      }
    }
    if (_isYoutubeUrl(_pageUrl)) {
      return Uri.tryParse(_pageUrl);
    }
    return null;
  }

  bool _isYoutubeUrl(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    return host == 'youtube.com' ||
        host == 'www.youtube.com' ||
        host == 'm.youtube.com' ||
        host == 'youtu.be';
  }

  Widget _buildPlayerSurface({
    BorderRadius? borderRadius,
    bool fill = false,
    bool showFullscreenButton = true,
  }) {
    final player = kIsWeb
        ? ((_streamManifestUrl.isNotEmpty || _pageUrl.isNotEmpty)
              ? WebcamWebEmbed(
                  html: _streamManifestUrl.isNotEmpty
                      ? _streamEmbedHtml()
                      : _usesMjpegStream
                      ? _mjpegEmbedHtml(_pageUrl)
                      : widget.embedAsIframe
                      ? _iframeEmbedHtml(_pageUrl)
                      : _usesDirectImage
                      ? _directImageEmbedHtml(_pageUrl)
                      : null,
                  url:
                      _streamManifestUrl.isEmpty &&
                          !_isSkylineWebcamUrl(_pageUrl) &&
                          !widget.embedAsIframe &&
                          !_usesMjpegStream &&
                          !_usesDirectImage &&
                          _pageUrl.isNotEmpty
                      ? _pageUrl
                      : null,
                )
              : Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: Text(
                      'No hay una webcam publica configurada para esta entrada.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ))
        : _controller == null
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
        if (!kIsWeb && _controller != null && _loadingProgress < 100)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(
              value: _loadingProgress / 100,
              minHeight: 3,
            ),
          ),
        if (_isSkylinePlayerPreparing)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
              ),
            ),
          ),
        if (showFullscreenButton && !kIsWeb)
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

  Widget _buildRotationFullscreenPlaceholder() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white.withValues(alpha: 0.86),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);
    if (!kIsWeb && orientation == Orientation.landscape) {
      if (!_isOpeningRotationFullscreen) {
        _isOpeningRotationFullscreen = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _openFullscreen(forcePortraitOnClose: true);
        });
      }
      return _buildRotationFullscreenPlaceholder();
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
    required this.forcePortraitOnClose,
    required this.embedAsIframe,
    this.focusIframeUrlContains,
    this.directImageHtml,
    this.previewImageUrl,
  });

  final String webcamName;
  final String pageUrl;
  final String streamManifestUrl;
  final bool forcePortraitOnClose;
  final bool embedAsIframe;
  final String? focusIframeUrlContains;
  final String? directImageHtml;
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
      directImageHtml: directImageHtml,
      previewImageUrl: previewImageUrl,
      streamEmbedHtml: _streamEmbedHtml(),
      forcePortraitOnClose: forcePortraitOnClose,
      embedAsIframe: embedAsIframe,
      focusIframeUrlContains: focusIframeUrlContains,
    );
  }
}

class _WebcamFullscreenScaffold extends StatefulWidget {
  const _WebcamFullscreenScaffold({
    required this.webcamName,
    required this.pageUrl,
    required this.streamManifestUrl,
    required this.streamEmbedHtml,
    required this.forcePortraitOnClose,
    required this.embedAsIframe,
    this.focusIframeUrlContains,
    this.directImageHtml,
    this.previewImageUrl,
  });

  final String webcamName;
  final String pageUrl;
  final String streamManifestUrl;
  final String streamEmbedHtml;
  final bool forcePortraitOnClose;
  final bool embedAsIframe;
  final String? focusIframeUrlContains;
  final String? directImageHtml;
  final String? previewImageUrl;

  @override
  State<_WebcamFullscreenScaffold> createState() =>
      _WebcamFullscreenScaffoldState();
}

class _WebcamFullscreenScaffoldState extends State<_WebcamFullscreenScaffold> {
  WebViewController? _controller;
  bool _isSkylinePlayerPreparing = false;

  bool get _usesRapidDirectImage =>
      _WebcamPlayerPageState._isRapidDirectImageUrl(widget.pageUrl);

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setOnConsoleMessage(_logWebcamConsoleMessage)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (!mounted) return;
              setState(() {
                _isSkylinePlayerPreparing = widget.embedAsIframe;
              });
            },
            onPageFinished: (_) {
              _fitSkylineWebcamFrame(_controller, widget.pageUrl);
              _finishSkylinePlayerPreparing();
            },
            onWebResourceError: _logWebcamResourceError,
            onHttpError: _logWebcamHttpError,
            onNavigationRequest: _handleNavigationRequest,
          ),
        );
      _loadFullscreenPlayer();
    }
  }

  Future<void> _loadFullscreenPlayer() async {
    final controller = _controller;
    if (controller == null) return;
    if (_usesRapidDirectImage) {
      await controller.clearCache();
    }
    await _configureAndroidWebcamController(controller, widget.pageUrl);
    if (widget.streamManifestUrl.isNotEmpty) {
      await controller.loadHtmlString(widget.streamEmbedHtml);
    } else if (widget.directImageHtml != null) {
      await controller.loadHtmlString(widget.directImageHtml!);
    } else if (widget.embedAsIframe) {
      await controller.loadHtmlString(_iframeEmbedHtml(widget.pageUrl));
    } else if (widget.pageUrl.isNotEmpty) {
      await controller.loadRequest(Uri.parse(widget.pageUrl));
    }
  }

  Future<void> _finishSkylinePlayerPreparing() async {
    if (!widget.embedAsIframe) return;
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    setState(() {
      _isSkylinePlayerPreparing = false;
    });
  }

  Future<void> _closeFullscreen() async {
    if (!kIsWeb) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await _restoreOrientations();
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    final controller = _controller;
    if (_usesRapidDirectImage && controller != null) {
      controller.clearCache().ignore();
    }
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      _restoreOrientations();
    }
    super.dispose();
  }

  Future<void> _restoreOrientations() {
    if (widget.forcePortraitOnClose) {
      return SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]);
    }
    return SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) {
      return NavigationDecision.navigate;
    }
    if (_shouldOpenExternally(uri)) {
      _openUriExternally(uri);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  bool _shouldOpenExternally(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'intent' || scheme == 'vnd.youtube') {
      return true;
    }
    return scheme.isNotEmpty && scheme != 'http' && scheme != 'https';
  }

  Future<void> _openUriExternally(Uri uri) async {
    if (await _tryLaunchUri(uri)) return;
    final fallbackUri = _externalNavigationFallback(uri);
    if (fallbackUri != null) {
      await _tryLaunchUri(fallbackUri);
    }
  }

  Future<bool> _tryLaunchUri(Uri uri) async {
    for (final mode in const [
      LaunchMode.externalApplication,
      LaunchMode.platformDefault,
    ]) {
      try {
        if (await launchUrl(uri, mode: mode)) {
          return true;
        }
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  Uri? _externalNavigationFallback(Uri uri) {
    if (uri.scheme.toLowerCase() == 'intent') {
      final match = RegExp(
        r'S\.browser_fallback_url=([^;]+)',
      ).firstMatch(uri.toString());
      final fallback = match?.group(1);
      if (fallback != null) {
        return Uri.tryParse(Uri.decodeComponent(fallback));
      }
    }
    if (_isYoutubeUrl(widget.pageUrl)) {
      return Uri.tryParse(widget.pageUrl);
    }
    return null;
  }

  bool _isYoutubeUrl(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    return host == 'youtube.com' ||
        host == 'www.youtube.com' ||
        host == 'm.youtube.com' ||
        host == 'youtu.be';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!kIsWeb) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          _restoreOrientations();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (kIsWeb)
              WebcamWebEmbed(
                html: widget.streamManifestUrl.isNotEmpty
                    ? widget.streamEmbedHtml
                    : widget.embedAsIframe
                    ? _iframeEmbedHtml(widget.pageUrl)
                    : widget.directImageHtml,
                url:
                    widget.streamManifestUrl.isEmpty &&
                        !_isSkylineWebcamUrl(widget.pageUrl) &&
                        !widget.embedAsIframe &&
                        widget.directImageHtml == null &&
                        widget.pageUrl.isNotEmpty
                    ? widget.pageUrl
                    : null,
              )
            else if (_controller != null)
              WebViewWidget(controller: _controller!)
            else
              const ColoredBox(color: Colors.black),
            if (_isSkylinePlayerPreparing)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ),
                  ),
                ),
              ),
            if (!kIsWeb)
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
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
