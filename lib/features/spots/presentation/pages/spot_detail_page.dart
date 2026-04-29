import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/platform/web_compass.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/profile/di/profile_module.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/spots/application/services/spots_external_data_clients.dart';
import 'package:windwisher/features/spots/application/services/spot_forecast_model_info.dart';
import 'package:windwisher/features/spots/application/services/spot_forecast_model_order.dart';
import 'package:windwisher/features/spots/application/services/spot_forecast_model_recommendations.dart';
import 'package:windwisher/features/spots/application/services/wind_semaforo_scale.dart';
import 'package:windwisher/features/spots/di/spots_module.dart';
import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/domain/entities/spot_social_post.dart';
import 'package:windwisher/features/spots/domain/entities/spot_webcam.dart';
import 'package:windwisher/features/spots/presentation/pages/webcam_player_page.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';
import 'package:windwisher/features/spots/presentation/pages/wind_map_page.dart';
import 'package:windwisher/features/spots/presentation/widgets/meteoblue_forecast_supplement_card.dart';
import 'package:windwisher/features/spots/presentation/widgets/meteostat_day_supplement_card.dart';
import 'package:windwisher/features/spots/presentation/widgets/meteosource_forecast_supplement_card.dart';
import 'package:windwisher/features/spots/presentation/widgets/aemet_forecast_tables.dart';
import 'package:windwisher/features/spots/presentation/widgets/forecast_accuracy_card.dart';
import 'package:windwisher/features/spots/presentation/widgets/windguru_forecast_card.dart';
import 'package:windwisher/features/spots/infrastructure/services/spot_social_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef _SpotWebcam = SpotWebcam;
typedef _SpotForecastEntry = SpotForecastEntry;

class SpotDetailPage extends StatefulWidget {
  const SpotDetailPage({
    super.key,
    required this.name,
    required this.area,
    required this.isCustom,
    this.latitude,
    this.longitude,
    this.aemetMunicipalityCode,
    this.aemetBeachCode,
    this.aemetBeachCodes = const <String>[],
    this.backgroundImagePath,
    this.spotsModule,
    this.aemetBeachForecastClient,
    this.aemetCoastalForecastClient,
    this.aemetObservationClient,
    this.aiguaBlancaMeteoClient,
    this.avametDailyHistoryClient,
    this.avametIntradayHistoryClient,
    this.avametObservationClient,
    this.inforatgeOlivaNovaClient,
    this.meteoblueCurrentDayClient,
    this.meteostatDayClient,
    this.meteosourceCurrentDayClient,
    this.useLocalPersistence = EnvConfig.spotsLocalPersistenceEnabled,
  });

  final String name;
  final String area;
  final bool isCustom;
  final double? latitude;
  final double? longitude;
  final String? aemetMunicipalityCode;
  final String? aemetBeachCode;
  final List<String> aemetBeachCodes;
  final String? backgroundImagePath;
  final SpotsModule? spotsModule;
  final AemetBeachForecastClient? aemetBeachForecastClient;
  final AemetCoastalForecastClient? aemetCoastalForecastClient;
  final AemetObservationClient? aemetObservationClient;
  final AiguaBlancaMeteoClient? aiguaBlancaMeteoClient;
  final AvametDailyHistoryClient? avametDailyHistoryClient;
  final AvametIntradayHistoryClient? avametIntradayHistoryClient;
  final AvametObservationClient? avametObservationClient;
  final InforatgeOlivaNovaClient? inforatgeOlivaNovaClient;
  final MeteoblueCurrentDayClient? meteoblueCurrentDayClient;
  final MeteostatDayClient? meteostatDayClient;
  final MeteosourceCurrentDayClient? meteosourceCurrentDayClient;
  final bool useLocalPersistence;

  SpotItem get spot => SpotItem(
    name: name,
    area: area,
    isCustom: isCustom,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    latitude: latitude,
    longitude: longitude,
    aemetMunicipalityCode: aemetMunicipalityCode,
    aemetBeachCode: aemetBeachCode,
    aemetBeachCodes: aemetBeachCodes,
    backgroundImagePath: backgroundImagePath,
  );

  @override
  State<SpotDetailPage> createState() => _SpotDetailPageState();
}

class _SpotDetailPageState extends State<SpotDetailPage>
    with WidgetsBindingObserver {
  static const Duration _forecastRequestTimeout = Duration(seconds: 15);

  bool _canRenderLocalImage(String? path) {
    return !kIsWeb && path != null && path.isNotEmpty;
  }

  static const bool _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');
  static const double _windguruWidgetHeight = 520;
  static const String _degreeSymbol = '\u00B0';
  static const String _avametOlivaStationId = 'c25m181e07';
  static const String _avametOlivaStationKey = 'avamet:c25m181e07';
  static const String _avametOlivaStationName = 'Club Nautico de Oliva';
  static const double _avametOlivaStationLat = 38.93208;
  static const double _avametOlivaStationLon = -0.09468;
  static const String _avametOlivaPlayaStationId = 'c25m181e20';
  static const String _avametOlivaPlayaStationKey = 'avamet:c25m181e20';
  static const String _avametOlivaPlayaStationName = 'Oliva Playa';
  static const double _avametOlivaPlayaStationLat = 38.9269;
  static const double _avametOlivaPlayaStationLon = -0.0958;
  static const String _meteoclimaticOlivaNovaStationId = 'ESPVA4600000046780B';
  static const String _meteoclimaticOlivaNovaStationKey =
      'meteoclimatic:ESPVA4600000046780B';
  static const String _meteoclimaticOlivaNovaStationName =
      'Oliva Nova Beach & Golf Resort';
  static const double _meteoclimaticOlivaNovaLat = 38.883333;
  static const double _meteoclimaticOlivaNovaLon = -0.05;
  static const String _inforatgePoliesportiuStationId = '46181e01';
  static const String _inforatgePoliesportiuStationKey = 'inforatge:46181e01';
  static const String _inforatgePoliesportiuStationName = 'Oliva Poliesportiu';
  static const double _inforatgePoliesportiuLat = 38.92354;
  static const double _inforatgePoliesportiuLon = -0.11142;
  static const String _aiguaBlancaStationId = 'aiguablanca';
  static const String _aiguaBlancaStationKey = 'aiguablanca:aiguablanca';
  static const String _aiguaBlancaStationName = "Playa Aigua Blanca";
  static const double _aiguaBlancaStationLat = 38.916253794214825;
  static const double _aiguaBlancaStationLon = -0.07699978862569694;
  static const String _windguruWidgetHtml = '''<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body { margin: 0; padding: 0; background: #ffffff; }
  </style>
</head>
<body>
  <script id="wg_fwdg_48858_52_1773264003952">
    (function (window, document) {
      var loader = function () {
        var arg = ["s=48858", "m=52", "mw=84", "uid=wg_fwdg_48858_52_1773264003952", "wj=knots", "tj=c", "waj=m", "tij=cm", "odh=0", "doh=24", "fhours=240", "hrsm=1", "vt=forecasts", "lng=es", "p=WINDSPD,GUST,MWINDSPD,SMER,HTSGW,PERPW,DIRPW,PWEN,SWELL1,SWPER1,SWEN1,SWDIR1,SWELL2,SWEN2,SWPER2,SWDIR2,WVHGT,WVPER,WVEN,WVDIR,TMPE,TMP,WCHILL,CDC,TCDC,APCP1s,RH,RATING"];
        var script = document.createElement("script");
        var tag = document.getElementsByTagName("script")[0];
        script.src = "https://www.windguru.cz/js/widget.php?" + (arg.join("&"));
        tag.parentNode.insertBefore(script, tag);
      };
      window.addEventListener ? window.addEventListener("load", loader, false) : window.attachEvent("onload", loader);
    })(window, document);
  </script>
</body>
</html>
''';
  _SpotDetailSection _section = _SpotDetailSection.prevision;
  String _forecastProvider = 'Open-Meteo';
  late String _forecastModel;
  _ForecastRange _forecastRange = _ForecastRange.d3;
  _ForecastResolution _forecastResolution = _ForecastResolution.h3;
  String _historyForecastProvider = 'Open-Meteo';
  late String _historyForecastModel;
  int _meteoblueSeaVisibleHours = 6;
  _ForecastFullscreenMode _fullscreenMode = _ForecastFullscreenMode.none;
  String _selectedStation = '';
  _WindSpeedUnit _windSpeedUnit = _WindSpeedUnit.knots;
  _CompassOverlayMode _compassOverlayMode = _CompassOverlayMode.off;
  _HistoryRange _historyRange = _HistoryRange.h3;
  _HistoricalBucketOption _historyBucket1d = _HistoricalBucketOption.h1;
  _HistoricalBucketOption _historyBucket3d = _HistoricalBucketOption.h3;
  final ScrollController _historyChartScrollController = ScrollController();
  final ScrollController _historyChartFullscreenScrollController =
      ScrollController();
  final ScrollController _socialFeedScrollController = ScrollController();
  final GlobalKey _socialComposerKey = GlobalKey();
  final GlobalKey _lastSocialMessageKey = GlobalKey();
  final FocusNode _socialPostFocusNode = FocusNode();
  final FocusNode _socialReplyFocusNode = FocusNode();
  String? _historyChartFocusKey;
  String? _historyChartFullscreenFocusKey;
  WebViewController? _windguruController;
  WebViewController? _windguruFullscreenController;
  bool _isLiveRefreshing = false;
  bool _isHistoricalRefreshing = false;
  Timer? _alarmAutoRefreshTimer;
  bool _isAppResumed = true;

  String _alarmStation = '';
  RangeValues _alarmWindRange = const RangeValues(14, 26);
  AlarmRepeatWindow _alarmRepeatWindow = AlarmRepeatWindow.min10;
  int _alarmMaxRepeats = 3;
  int _alarmStartHour = 8;
  int _alarmEndHour = 20;
  int _alarmStartMinute = 0;
  int _alarmEndMinute = 0;
  Set<String> _alarmDirections = <String>{'N', 'NE', 'E'};
  String? _editingAlarmId;

  final TextEditingController _socialPostController = TextEditingController();
  final TextEditingController _socialReplyController = TextEditingController();
  final ImagePicker _socialMediaPicker = ImagePicker();
  String? _replyingPostId;
  String? _replyingReplyId;
  String? _editingPostId;
  String? _editingReplyId;
  String? _editingReplyPostId;
  List<SpotSocialPost> _socialFeed = const <SpotSocialPost>[];
  bool _isSocialLoading = false;
  bool _isSocialSubmitting = false;
  bool _isPickingSocialMedia = false;
  String? _socialErrorMessage;
  bool _canModerateSocialMessages = false;
  StreamSubscription<void>? _socialRealtimeSubscription;
  StreamSubscription<int>? _socialPresenceSubscription;
  StreamSubscription<Set<String>>? _socialTypingSubscription;
  Timer? _socialRealtimeRefreshDebounce;
  Timer? _socialTypingDebounce;
  int _socialOnlineCount = 0;
  Set<String> _socialTypingUsers = const <String>{};
  bool _isSendingTypingState = false;
  List<SpotSocialAttachmentDraft> _pendingSocialPostAttachments =
      const <SpotSocialAttachmentDraft>[];
  List<SpotSocialAttachmentDraft> _pendingSocialReplyAttachments =
      const <SpotSocialAttachmentDraft>[];
  late final SpotSocialClient _spotSocialClient;
  late final ProfileModule _profileModule;
  late final UserProfileData _fallbackSocialProfile;
  UserProfileData _currentSocialProfile = UserProfileData.initial();
  late final SpotsModule _spotsModule;
  late final AemetBeachForecastClient _aemetBeachForecastClient;
  late final AemetCoastalForecastClient _aemetCoastalForecastClient;
  late final AemetObservationClient _aemetObservationClient;
  late final AiguaBlancaMeteoClient _aiguaBlancaMeteoClient;
  late final AvametDailyHistoryClient _avametDailyHistoryClient;
  late final AvametIntradayHistoryClient _avametIntradayHistoryClient;
  late final AvametObservationClient _avametObservationClient;
  late final InforatgeOlivaNovaClient _inforatgeOlivaNovaClient;
  late final MeteoblueCurrentDayClient _meteoblueCurrentDayClient;
  late final MeteostatDayClient _meteostatDayClient;
  late final MeteosourceCurrentDayClient _meteosourceCurrentDayClient;
  late final OpenMeteoWindMapGridClient _openMeteoWindMapGridClient;
  late Future<_ForecastLoadResult> _forecastRowsFuture;
  _ForecastLoadResult? _historyForecastRowsResult;
  bool _historyForecastLoadRequested = false;
  Future<_AemetBeachForecastLoadResult>? _aemetBeachForecastFuture;
  Future<_AemetCoastalForecastLoadResult>? _aemetCoastalForecastFuture;
  Future<_MeteoblueCurrentDayLoadResult>? _meteoblueCurrentDayFuture;
  Future<_MeteostatDayLoadResult>? _meteostatDayFuture;
  Future<_MeteosourceCurrentDayLoadResult>? _meteosourceCurrentDayFuture;
  _LiveStationsLoadResult? _liveStationsLoadResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _spotsModule =
        widget.spotsModule ??
        (widget.useLocalPersistence
            ? SpotsModule.localFile()
            : SpotsModule.inMemory());
    _aemetBeachForecastClient =
        widget.aemetBeachForecastClient ?? AemetBeachForecastClient();
    _aemetCoastalForecastClient =
        widget.aemetCoastalForecastClient ?? AemetCoastalForecastClient();
    _aemetObservationClient =
        widget.aemetObservationClient ?? AemetObservationClient();
    _aiguaBlancaMeteoClient =
        widget.aiguaBlancaMeteoClient ?? AiguaBlancaMeteoClient();
    _avametDailyHistoryClient =
        widget.avametDailyHistoryClient ?? AvametDailyHistoryClient();
    _avametIntradayHistoryClient =
        widget.avametIntradayHistoryClient ?? AvametIntradayHistoryClient();
    _avametObservationClient =
        widget.avametObservationClient ?? AvametObservationClient();
    _inforatgeOlivaNovaClient =
        widget.inforatgeOlivaNovaClient ?? InforatgeOlivaNovaClient();
    _meteoblueCurrentDayClient =
        widget.meteoblueCurrentDayClient ?? MeteoblueCurrentDayClient();
    _meteostatDayClient = widget.meteostatDayClient ?? MeteostatDayClient();
    _meteosourceCurrentDayClient =
        widget.meteosourceCurrentDayClient ?? MeteosourceCurrentDayClient();
    _openMeteoWindMapGridClient = OpenMeteoWindMapGridClient();
    _spotSocialClient = SpotSocialClient.auto();
    _profileModule = ProfileModule.auto();
    _fallbackSocialProfile = UserProfileData.initial().copyWith(
      displayName: 'Rider',
      handle: '@rider',
    );
    _currentSocialProfile = _fallbackSocialProfile;
    _forecastModel =
        getSpotDefaultForecastModel(
          spotName: widget.name,
          spotArea: widget.area,
          spotBeachCode: widget.aemetBeachCode,
          spotBeachCodes: widget.aemetBeachCodes,
          provider: _forecastProvider,
        ) ??
        _modelsForProvider(_forecastProvider).first;
    _historyForecastModel = _historyForecastModelsForProvider(
      _historyForecastProvider,
    ).first;
    _forecastRowsFuture = _loadForecastRows();
    _loadLiveStations();
    unawaited(_hydrateAlarmCatalog());
    _loadSocialIdentity();
    unawaited(_loadSocialModerationPermissions());
    _loadSocialFeed();
    _syncAlarmMonitoring();
  }

  List<String> _modelsForProvider(String provider) {
    return getSpotForecastModels(
      spotName: widget.name,
      spotArea: widget.area,
      spotBeachCode: widget.aemetBeachCode,
      spotBeachCodes: widget.aemetBeachCodes,
      provider: provider,
    );
  }

  List<String> _historyForecastProviders() {
    return const <String>[
      'Open-Meteo',
      'Meteoblue',
      'Meteosource',
      'Meteostat',
    ];
  }

  List<String> _historyForecastModelsForProvider(String provider) {
    final models = _modelsForProvider(provider);
    switch (provider) {
      case 'Open-Meteo':
        return models;
      case 'Meteoblue':
        return models
            .where((model) => model == 'Basic' || model == 'Sea')
            .toList(growable: false);
      case 'Meteosource':
        return models
            .where((model) => model == 'Hourly')
            .toList(growable: false);
      case 'Meteostat':
        return models
            .where((model) => model == 'Hourly')
            .toList(growable: false);
      default:
        return const <String>[];
    }
  }

  void _ensureHistoryForecastRowsLoaded() {
    if (_historyForecastLoadRequested) {
      return;
    }
    _historyForecastLoadRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadHistoryForecastRows();
    });
  }

  bool _providerUsesModelForFetch(String provider, [String? model]) {
    if (provider == 'AEMET') {
      return (model ?? _forecastModel) == kAemetPortusAtmosphereForecastModel;
    }
    return provider != 'Windguru';
  }

  bool _usesAemetBeachForecastModel([String? model]) {
    return _forecastProvider == 'AEMET' &&
        isAemetBeachForecastModelLabel(model ?? _forecastModel);
  }

  bool _usesAemetCoastalForecastModel([String? model]) {
    return _forecastProvider == 'AEMET' &&
        (model ?? _forecastModel) == kAemetCoastalForecastModel;
  }

  bool _usesAemetPortusForecastModel([String? model]) {
    return _forecastProvider == 'AEMET' &&
        (model ?? _forecastModel) == kAemetPortusAtmosphereForecastModel;
  }

  bool _usesMeteoblueProvider() {
    return _forecastProvider == 'Meteoblue';
  }

  bool _usesMeteoblueCurrentModel() {
    return _usesMeteoblueProvider() && _forecastModel == 'Current';
  }

  bool _usesMeteoblueDayModel() {
    return _usesMeteoblueProvider() && _forecastModel == 'Day';
  }

  bool _usesMeteoblueSeaModel() {
    return _usesMeteoblueProvider() && _forecastModel == 'Sea';
  }

  bool _usesMeteosourceProvider() {
    return _forecastProvider == 'Meteosource';
  }

  bool _usesMeteosourceCurrentModel() {
    return _usesMeteosourceProvider() && _forecastModel == 'Current';
  }

  bool _usesMeteosourceDayModel() {
    return _usesMeteosourceProvider() && _forecastModel == 'Day';
  }

  bool _usesMeteostatProvider() {
    return _forecastProvider == 'Meteostat';
  }

  bool _usesMeteostatDayModel() {
    return _usesMeteostatProvider() && _forecastModel == 'Day';
  }

  bool _usesWindguruProvider() {
    return _forecastProvider == 'Windguru';
  }

  String _compactTechnicalError(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 140) {
      return normalized;
    }
    return '${normalized.substring(0, 140)}...';
  }

  Future<_ForecastLoadResult> _loadForecastRows() async {
    final requestedProvider = _forecastProvider;
    final requestedModel = _forecastModel;
    try {
      final entries = await _runForecastRequest(
        () => _spotsModule.getSpotForecast(
          spot: widget.spot,
          provider: requestedProvider,
          model: requestedModel,
        ),
      );
      if (entries.isEmpty) {
        final fallbackMessage =
            requestedProvider == 'AEMET' &&
                requestedModel != kAemetPortusAtmosphereForecastModel &&
                !EnvConfig.aemetAccessConfigured
            ? 'AEMET sin API key cargada.'
            : requestedProvider == 'Meteoblue' &&
                  !EnvConfig.meteoblueAccessConfigured
            ? 'Meteoblue sin API key cargada.'
            : requestedProvider == 'Meteosource' &&
                  !EnvConfig.meteosourceAccessConfigured
            ? 'Meteosource sin API key cargada.'
            : requestedProvider == 'Meteostat' &&
                  !EnvConfig.meteostatAccessConfigured
            ? 'Meteostat sin RapidAPI key cargada.'
            : '$requestedProvider no devolvio datos reales.';
        final result = _ForecastLoadResult(
          rows: const <_ForecastRow>[],
          source: _ForecastDataSource.fallback,
          message: fallbackMessage,
        );
        return result;
      }
      final rows = _mapForecastEntriesToRows(entries);
      return _ForecastLoadResult(rows: rows, source: _ForecastDataSource.live);
    } catch (error) {
      final rawError = '$error';
      final fallbackMessage =
          requestedProvider == 'AEMET' && rawError.contains('429')
          ? 'AEMET ha limitado temporalmente las peticiones.'
          : 'Error cargando $requestedProvider.';
      final result = _ForecastLoadResult(
        rows: const <_ForecastRow>[],
        source: _ForecastDataSource.fallback,
        message: fallbackMessage,
        technicalError: rawError,
      );
      return result;
    }
  }

  Future<_ForecastLoadResult> _loadHistoryForecastRows() async {
    final requestedProvider = _historyForecastProvider;
    final requestedModel = _historyForecastModel;
    try {
      final entries = await _runForecastRequest(
        () => _spotsModule.getSpotForecast(
          spot: widget.spot,
          provider: requestedProvider,
          model: requestedModel,
        ),
      );
      final result = entries.isEmpty
          ? _ForecastLoadResult(
              rows: const <_ForecastRow>[],
              source: _ForecastDataSource.fallback,
              message: '$requestedProvider no devolvio datos reales.',
            )
          : _ForecastLoadResult(
              rows: _mapForecastEntriesToRows(entries),
              source: _ForecastDataSource.live,
            );
      if (mounted &&
          _historyForecastProvider == requestedProvider &&
          _historyForecastModel == requestedModel) {
        setState(() {
          _historyForecastRowsResult = result;
        });
      }
      return result;
    } catch (error) {
      final result = _ForecastLoadResult(
        rows: const <_ForecastRow>[],
        source: _ForecastDataSource.fallback,
        message: 'Error cargando $requestedProvider.',
        technicalError: '$error',
      );
      if (mounted &&
          _historyForecastProvider == requestedProvider &&
          _historyForecastModel == requestedModel) {
        setState(() {
          _historyForecastRowsResult = result;
        });
      }
      return result;
    }
  }

  void _refreshForecastRows() {
    setState(() {
      _forecastRowsFuture = _loadForecastRows();
      if (_usesMeteoblueProvider()) {
        _meteoblueCurrentDayFuture = _loadMeteoblueCurrentDay();
      }
      if (_usesMeteosourceProvider()) {
        _meteosourceCurrentDayFuture = _loadMeteosourceCurrentDay();
      }
      if (_usesMeteostatDayModel()) {
        _meteostatDayFuture = _loadMeteostatDay();
      }
    });
  }

  void _refreshHistoryForecastRows() {
    setState(() {
      _historyForecastRowsResult = null;
      _historyForecastLoadRequested = true;
    });
    _loadHistoryForecastRows();
  }

  Future<bool> _refreshSelectedStationHistoricalData() async {
    final station = _findStationByKey(_selectedStation);
    final current = _liveStationsLoadResult;
    if (station == null || current == null) {
      return false;
    }

    try {
      List<_HistoricalWindPoint>? refreshedHistory;
      if (station.provider == 'AVAMET') {
        if (station.stationId == null) {
          return false;
        }
        final intradayHistory = await _avametIntradayHistoryClient
            .fetchIntradayWindHistory(stationId: station.stationId!);
        refreshedHistory = intradayHistory
            .map(
              (point) => _HistoricalWindPoint(
                time: point.time,
                windKnots: point.windKnots,
                windDirectionDeg: point.windDirectionDeg,
                directionKind: point.windDirectionDeg == null
                    ? null
                    : _HistoricalDirectionKind.exact,
              ),
            )
            .toList(growable: false);

        if (refreshedHistory.isEmpty) {
          final dailyHistory = await _avametDailyHistoryClient
              .fetchDailyWindHistory(stationId: station.stationId!);
          refreshedHistory = dailyHistory
              .map(
                (point) => _HistoricalWindPoint(
                  time: point.time,
                  windKnots: point.windKnots,
                ),
              )
              .toList(growable: false);
        }
      } else if (station.provider == 'INFORATGE') {
        final feed = await _inforatgeOlivaNovaClient.fetchFeed(
          stationCode: station.stationId == _inforatgePoliesportiuStationId
              ? '01'
              : '02',
          liveUrl: station.stationId == _inforatgePoliesportiuStationId
              ? InforatgeOlivaNovaClient.livePoliesportiuUrl
              : InforatgeOlivaNovaClient.liveOlivaNovaUrl,
        );
        refreshedHistory = feed.points
            .map(
              (point) => _HistoricalWindPoint(
                time: point.time,
                windKnots: point.windKnots,
                windDirectionDeg: point.windDirectionDeg,
                directionKind: point.windDirectionDeg == null
                    ? null
                    : _HistoricalDirectionKind.exact,
              ),
            )
            .toList(growable: false);
      } else if (station.provider == 'AIGUABLANCA') {
        final feed = await _aiguaBlancaMeteoClient.fetchFeed();
        refreshedHistory = feed.points
            .map(
              (point) => _HistoricalWindPoint(
                time: point.time,
                windKnots: point.windKnots,
                gustKnots: point.gustKnots,
                windDirectionDeg: point.windDirectionDeg,
                directionKind: point.windDirectionDeg == null
                    ? null
                    : _HistoricalDirectionKind.exact,
              ),
            )
            .toList(growable: false);
      } else if (station.provider == 'AEMET' && station.stationId != null) {
        final observationSeries = await _aemetObservationClient
            .fetchStationObservations(
              stationId: station.stationId!,
              referenceLatitude: station.latitude,
              referenceLongitude: station.longitude,
            );
        refreshedHistory = observationSeries
            .where((snapshot) => snapshot.observedAt != null)
            .map(
              (snapshot) => _HistoricalWindPoint(
                time: snapshot.observedAt!,
                windKnots: snapshot.windKnots ?? 0,
                gustKnots: snapshot.gustKnots,
                windDirectionDeg: snapshot.windDirectionDeg,
                directionKind: snapshot.windDirectionDeg == null
                    ? null
                    : _HistoricalDirectionKind.exact,
              ),
            )
            .toList(growable: false);
      }

      if (!mounted || refreshedHistory == null) {
        return false;
      }

      setState(() {
        final updatedHistory = Map<String, List<_HistoricalWindPoint>>.from(
          current.historicalSeriesByStation,
        );
        updatedHistory[station.stationKey] = refreshedHistory!;
        _liveStationsLoadResult = _LiveStationsLoadResult(
          stations: current.stations,
          liveDataByStation: current.liveDataByStation,
          historicalSeriesByStation: updatedHistory,
          source: current.source,
          message: current.message,
          technicalError: current.technicalError,
        );
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _refreshHistoricalChartData() async {
    if (_isHistoricalRefreshing) {
      return;
    }
    setState(() {
      _isHistoricalRefreshing = true;
    });
    try {
      await _refreshSelectedStationLiveData();
      final historyUpdated = await _refreshSelectedStationHistoricalData();
      _refreshHistoryForecastRows();
      if (!historyUpdated && mounted) {
        _showLiveRefreshFeedback(
          'No se pudo actualizar el historico de ${_stationDisplayName(_selectedStation)}.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isHistoricalRefreshing = false;
        });
      }
    }
  }

  Future<_MeteoblueCurrentDayLoadResult> _loadMeteoblueCurrentDay() async {
    try {
      final snapshot = await _runForecastRequest(
        () => _meteoblueCurrentDayClient.fetchSnapshot(spot: widget.spot),
      );
      return _MeteoblueCurrentDayLoadResult(
        snapshot: snapshot,
        source: _ForecastDataSource.live,
      );
    } catch (error) {
      return _MeteoblueCurrentDayLoadResult(
        snapshot: const MeteoblueCurrentDaySnapshot(
          current: null,
          sea: <MeteoblueSeaData>[],
          days: <MeteoblueDayData>[],
        ),
        source: _ForecastDataSource.fallback,
        message: !EnvConfig.meteoblueAccessConfigured
            ? 'Meteoblue sin API key cargada.'
            : 'Current/Day de Meteoblue no disponible.',
        technicalError: '$error',
      );
    }
  }

  Future<_MeteoblueCurrentDayLoadResult> _ensureMeteoblueCurrentDayFuture() {
    return _meteoblueCurrentDayFuture ??= _loadMeteoblueCurrentDay();
  }

  Future<_MeteosourceCurrentDayLoadResult> _loadMeteosourceCurrentDay() async {
    try {
      final snapshot = await _runForecastRequest(
        () => _meteosourceCurrentDayClient.fetchSnapshot(spot: widget.spot),
      );
      return _MeteosourceCurrentDayLoadResult(
        snapshot: snapshot,
        source: _ForecastDataSource.live,
      );
    } catch (error) {
      return _MeteosourceCurrentDayLoadResult(
        snapshot: const MeteosourceCurrentDaySnapshot(
          current: null,
          days: <MeteosourceDayData>[],
        ),
        source: _ForecastDataSource.fallback,
        message: !EnvConfig.meteosourceAccessConfigured
            ? 'Meteosource sin API key cargada.'
            : 'Current/Day de Meteosource no disponible.',
        technicalError: '$error',
      );
    }
  }

  Future<_MeteosourceCurrentDayLoadResult>
  _ensureMeteosourceCurrentDayFuture() {
    return _meteosourceCurrentDayFuture ??= _loadMeteosourceCurrentDay();
  }

  Future<_MeteostatDayLoadResult> _loadMeteostatDay() async {
    try {
      final snapshot = await _runForecastRequest(
        () => _meteostatDayClient.fetchSnapshot(spot: widget.spot),
      );
      return _MeteostatDayLoadResult(
        snapshot: snapshot,
        source: _ForecastDataSource.live,
      );
    } catch (error) {
      return _MeteostatDayLoadResult(
        snapshot: const MeteostatDaySnapshot(days: <MeteostatDayData>[]),
        source: _ForecastDataSource.fallback,
        message: !EnvConfig.meteostatAccessConfigured
            ? 'Meteostat sin RapidAPI key cargada.'
            : 'Day de Meteostat no disponible.',
        technicalError: '$error',
      );
    }
  }

  Future<_MeteostatDayLoadResult> _ensureMeteostatDayFuture() {
    return _meteostatDayFuture ??= _loadMeteostatDay();
  }

  Future<T> _runForecastRequest<T>(Future<T> Function() action) {
    return action().timeout(_forecastRequestTimeout);
  }

  bool get _isFullscreenActive =>
      _fullscreenMode != _ForecastFullscreenMode.none;

  MeteoblueCurrentDaySnapshot get _emptyMeteoblueSnapshot =>
      const MeteoblueCurrentDaySnapshot(
        current: null,
        sea: <MeteoblueSeaData>[],
        days: <MeteoblueDayData>[],
      );

  Widget _buildSelectedMeteoblueSupplement(
    _MeteoblueCurrentDayLoadResult result,
  ) {
    return MeteoblueForecastSupplementCard(
      snapshot: result.snapshot,
      message: result.message,
      showCurrent: _usesMeteoblueCurrentModel(),
      showSea: _usesMeteoblueSeaModel(),
      showDay: _usesMeteoblueDayModel(),
      seaVisibleHours: _meteoblueSeaVisibleHours,
      onSeaVisibleHoursChanged: (hours) {
        setState(() {
          _meteoblueSeaVisibleHours = hours;
        });
      },
      showFullscreenButton: _usesMeteoblueSeaModel(),
      onOpenFullscreen: _usesMeteoblueSeaModel()
          ? () {
              setState(() {
                _fullscreenMode = _ForecastFullscreenMode.meteoblueSea;
              });
            }
          : null,
    );
  }

  Widget _buildSelectedMeteosourceSupplement(
    _MeteosourceCurrentDayLoadResult result,
  ) {
    return MeteosourceForecastSupplementCard(
      snapshot: result.snapshot,
      message: result.message,
      showCurrent: _usesMeteosourceCurrentModel(),
      showDay: _usesMeteosourceDayModel(),
    );
  }

  Widget _buildSelectedMeteostatDaySupplement(_MeteostatDayLoadResult result) {
    return MeteostatDaySupplementCard(
      snapshot: result.snapshot,
      message: result.message,
    );
  }

  Widget _buildExpandedMeteoblueSeaOverlay(
    _MeteoblueCurrentDayLoadResult result,
  ) {
    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;

    return Positioned.fill(
      child: Stack(
        children: [
          ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final seaCard = MeteoblueForecastSupplementCard(
                  snapshot: result.snapshot,
                  message: result.message,
                  showCurrent: false,
                  showSea: true,
                  showDay: false,
                  seaVisibleHours: _meteoblueSeaVisibleHours,
                  showSeaHeader: false,
                  showSeaControls: false,
                  showFullscreenButton: false,
                  expandToFill: true,
                );
                final content = isLandscape
                    ? SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: seaCard,
                      )
                    : SizedBox(
                        width: constraints.maxHeight,
                        height: constraints.maxWidth,
                        child: RotatedBox(quarterTurns: 1, child: seaCard),
                      );

                return ClipRect(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: content,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            right: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: SafeArea(
              child: SizedBox(
                width: 34,
                height: 34,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: 'meteoblueSeaFullscreenClose',
                  tooltip: 'Salir de fullscreen',
                  elevation: 0,
                  highlightElevation: 0,
                  backgroundColor: Colors.black.withValues(alpha: 0.22),
                  foregroundColor: Colors.white.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  onPressed: () {
                    setState(() {
                      _fullscreenMode = _ForecastFullscreenMode.none;
                    });
                  },
                  child: const Icon(Icons.close_rounded, size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<_AemetBeachForecastLoadResult> _loadAemetBeachForecast() async {
    try {
      final selectedBeachCode = extractAemetBeachCodeFromModel(
        model: _forecastModel,
        spot: widget.spot,
      );
      final data = await _runForecastRequest(
        () => _aemetBeachForecastClient.fetchForecasts(
          spot: widget.spot,
          beachCodes: selectedBeachCode == null ? null : [selectedBeachCode],
        ),
      );
      return _AemetBeachForecastLoadResult(
        data: data,
        source: _ForecastDataSource.live,
      );
    } catch (error) {
      return _AemetBeachForecastLoadResult(
        data: const <AemetBeachForecastData>[],
        source: _ForecastDataSource.fallback,
        message: !EnvConfig.aemetAccessConfigured
            ? 'AEMET playa sin API key cargada.'
            : 'AEMET playa no disponible.',
        technicalError: '$error',
      );
    }
  }

  void _refreshAemetBeachForecast() {
    setState(() {
      _aemetBeachForecastFuture = _loadAemetBeachForecast();
    });
  }

  Future<_AemetBeachForecastLoadResult> _ensureAemetBeachForecastFuture() {
    return _aemetBeachForecastFuture ??= _loadAemetBeachForecast();
  }

  Future<_AemetCoastalForecastLoadResult> _loadAemetCoastalForecast() async {
    try {
      final data = await _runForecastRequest(
        () => _aemetCoastalForecastClient.fetchForecast(spot: widget.spot),
      );
      return _AemetCoastalForecastLoadResult(
        data: data,
        source: _ForecastDataSource.live,
      );
    } catch (error) {
      return _AemetCoastalForecastLoadResult(
        data: null,
        source: _ForecastDataSource.fallback,
        message: !EnvConfig.aemetAccessConfigured
            ? 'AEMET maritima sin API key cargada.'
            : 'AEMET maritima costera no disponible.',
        technicalError: '$error',
      );
    }
  }

  void _refreshAemetCoastalForecast() {
    setState(() {
      _aemetCoastalForecastFuture = _loadAemetCoastalForecast();
    });
  }

  Future<_AemetCoastalForecastLoadResult> _ensureAemetCoastalForecastFuture() {
    return _aemetCoastalForecastFuture ??= _loadAemetCoastalForecast();
  }

  List<_ForecastRow> _mapForecastEntriesToRows(
    List<_SpotForecastEntry> entries,
  ) {
    return entries
        .map(
          (entry) => _ForecastRow(
            slotTime: entry.time,
            hour: _formatForecastSlot(entry.time),
            windKnots: entry.windKnots,
            gustKnots: entry.gustKnots,
            windDeg: entry.windDeg,
            tempC: entry.airTempC,
            waterTempC: entry.waterTempC,
            pressureHpa: entry.pressureHpa,
            cloudCoverPct: entry.cloudCoverPct,
            waveM: entry.waveM == null
                ? null
                : double.parse(entry.waveM!.toStringAsFixed(1)),
            rainMm: entry.rainMm == null
                ? null
                : double.parse(entry.rainMm!.toStringAsFixed(1)),
          ),
        )
        .toList(growable: false);
  }

  Widget _buildForecastDataStatusBanner(_ForecastLoadResult result) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, color, text) = switch (result.source) {
      _ForecastDataSource.live => (
        Icons.cloud_done_rounded,
        const Color(0xFF2E7D32),
        'Datos reales cargados desde $_forecastProvider.',
      ),
      _ForecastDataSource.mock => (
        Icons.developer_mode_rounded,
        colorScheme.primary,
        'Modo demo local para este proveedor.',
      ),
      _ForecastDataSource.fallback => (
        Icons.warning_amber_rounded,
        const Color(0xFFF9A825),
        result.message ?? 'Datos no disponibles.',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAemetBeachStatusBanner(_AemetBeachForecastLoadResult result) {
    final bannerResult = _ForecastLoadResult(
      rows: const <_ForecastRow>[],
      source: result.source,
      message: result.message,
      technicalError: result.technicalError,
    );
    return _buildForecastDataStatusBanner(bannerResult);
  }

  Widget _buildAemetCoastalStatusBanner(
    _AemetCoastalForecastLoadResult result,
  ) {
    final bannerResult = _ForecastLoadResult(
      rows: const <_ForecastRow>[],
      source: result.source,
      message: result.message,
      technicalError: result.technicalError,
    );
    return _buildForecastDataStatusBanner(bannerResult);
  }

  Widget _buildUnavailableForecastState({
    String? message,
    String? technicalError,
    VoidCallback? onRetry,
  }) {
    final diagnosticMessage = technicalError == null
        ? null
        : _compactTechnicalError(technicalError);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 28,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sin datos disponibles',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            message ?? 'Prueba de nuevo mas tarde o cambia de proveedor.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (diagnosticMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              diagnosticMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildForecastLoadingState({bool includeBottomSpacing = false}) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: LinearProgressIndicator(),
        ),
        if (includeBottomSpacing) const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  void _openForecastTableFullscreen() {
    setState(() {
      _fullscreenMode = _ForecastFullscreenMode.forecastTable;
    });
  }

  void _updateForecastRange(_ForecastRange range) {
    setState(() {
      _forecastRange = range;
      _syncForecastResolutionWithRange();
    });
  }

  void _updateForecastResolution(_ForecastResolution resolution) {
    setState(() {
      _forecastResolution = resolution;
    });
  }

  Widget _buildForecastTableContent(_ForecastLoadResult result) {
    if (result.source == _ForecastDataSource.fallback) {
      return _buildUnavailableForecastState(
        message:
            result.message ??
            'Prueba de nuevo mas tarde o cambia de proveedor.',
        technicalError: result.technicalError,
        onRetry: _refreshForecastRows,
      );
    }

    return Column(
      children: [
        Row(children: [Expanded(child: _buildForecastTableTitle())]),
        const SizedBox(height: AppSpacing.xs),
        _buildForecastDataStatusBanner(result),
        const SizedBox(height: AppSpacing.sm),
        _buildWindguruStyleTable(
          rowsOverride: _resampleForecastRows(
            _clipForecastRows(
              result.rows,
              provider: _forecastProvider,
              range: _forecastRange,
            ),
            _forecastResolution,
          ),
          onOpenFullscreen: _openForecastTableFullscreen,
          selectedRange: _forecastRange,
          fullscreenResolution: _forecastResolution,
          showResolutionSelector: true,
          onRangeChanged: _updateForecastRange,
          onResolutionChanged: _updateForecastResolution,
        ),
      ],
    );
  }

  void _openWindguruFullscreen() {
    setState(() {
      if (!_isFlutterTest && !kIsWeb) {
        _windguruFullscreenController ??= _createWindguruController();
      }
      _fullscreenMode = _ForecastFullscreenMode.windguru;
    });
  }

  WebViewController? _createWindguruController() {
    if (WebViewPlatform.instance == null) {
      return null;
    }
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(_windguruWidgetHtml, baseUrl: 'https://www.windguru.cz');
  }

  Widget _buildWindguruForecastSection() {
    final controller = _isFlutterTest || kIsWeb
        ? _windguruController
        : (_windguruController ??= _createWindguruController());
    if (_isFlutterTest || (!kIsWeb && controller == null)) {
      final message = _isFlutterTest
          ? 'Windguru no disponible en esta plataforma de prueba.'
          : 'No se ha podido iniciar el widget de Windguru.';
      return _buildUnavailableForecastState(message: message);
    }
    const windguruStatus = _ForecastLoadResult(
      rows: <_ForecastRow>[],
      source: _ForecastDataSource.live,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildForecastDataStatusBanner(windguruStatus),
        const SizedBox(height: AppSpacing.sm),
        WindguruForecastCard(
          title: _buildForecastTableTitle(),
          subtitle: 'Widget Windguru · Oliva Canal',
          height: _windguruWidgetHeight,
          controller: controller,
          webEmbedHtml: kIsWeb ? _windguruWidgetHtml : null,
          isFullscreenActive:
              _fullscreenMode == _ForecastFullscreenMode.windguru,
          onOpenFullscreen: _openWindguruFullscreen,
        ),
      ],
    );
  }

  Widget _buildMeteoblueSupplement() {
    return FutureBuilder<_MeteoblueCurrentDayLoadResult>(
      future: _ensureMeteoblueCurrentDayFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildForecastLoadingState();
        }
        final currentDay =
            snapshot.data ??
            _MeteoblueCurrentDayLoadResult(
              snapshot: _emptyMeteoblueSnapshot,
              source: _ForecastDataSource.fallback,
              message: 'Meteoblue no disponible.',
            );

        return _buildSelectedMeteoblueSupplement(currentDay);
      },
    );
  }

  Widget _buildMeteosourceSupplement() {
    return FutureBuilder<_MeteosourceCurrentDayLoadResult>(
      future: _ensureMeteosourceCurrentDayFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildForecastLoadingState();
        }
        final currentDay =
            snapshot.data ??
            const _MeteosourceCurrentDayLoadResult(
              snapshot: MeteosourceCurrentDaySnapshot(
                current: null,
                days: <MeteosourceDayData>[],
              ),
              source: _ForecastDataSource.fallback,
              message: 'Meteosource no disponible.',
            );

        return _buildSelectedMeteosourceSupplement(currentDay);
      },
    );
  }

  Widget _buildMeteostatDaySupplement() {
    return FutureBuilder<_MeteostatDayLoadResult>(
      future: _ensureMeteostatDayFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildForecastLoadingState();
        }
        final dayResult =
            snapshot.data ??
            const _MeteostatDayLoadResult(
              snapshot: MeteostatDaySnapshot(days: <MeteostatDayData>[]),
              source: _ForecastDataSource.fallback,
              message: 'Meteostat Day no disponible.',
            );

        return _buildSelectedMeteostatDaySupplement(dayResult);
      },
    );
  }

  Widget _buildForecastSupplementOrTable(_ForecastLoadResult result) {
    if (_usesMeteoblueCurrentModel() ||
        _usesMeteoblueDayModel() ||
        _usesMeteoblueSeaModel()) {
      return _buildMeteoblueSupplement();
    }
    if (_usesMeteosourceCurrentModel() || _usesMeteosourceDayModel()) {
      return _buildMeteosourceSupplement();
    }
    if (_usesMeteostatDayModel()) {
      return _buildMeteostatDaySupplement();
    }
    return _buildForecastTableContent(result);
  }

  Widget _buildAemetBeachForecastSection() {
    return FutureBuilder<_AemetBeachForecastLoadResult>(
      future: _ensureAemetBeachForecastFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildForecastLoadingState(includeBottomSpacing: true);
        }

        final result =
            snapshot.data ??
            _AemetBeachForecastLoadResult(
              data: const <AemetBeachForecastData>[],
              source: _ForecastDataSource.fallback,
              message: 'AEMET playa no disponible.',
            );
        if (result.source == _ForecastDataSource.fallback ||
            result.data.isEmpty) {
          return _buildUnavailableForecastState(
            message:
                result.message ??
                'Prueba de nuevo mas tarde o cambia de proveedor.',
            technicalError: result.technicalError,
            onRetry: _refreshAemetBeachForecast,
          );
        }
        return Column(
          children: [
            Row(children: [Expanded(child: _buildForecastTableTitle())]),
            const SizedBox(height: AppSpacing.xs),
            _buildAemetBeachStatusBanner(result),
            const SizedBox(height: AppSpacing.sm),
            ...result.data.map(
              (beachData) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AemetBeachForecastTable(data: beachData),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAemetCoastalForecastSection() {
    return FutureBuilder<_AemetCoastalForecastLoadResult>(
      future: _ensureAemetCoastalForecastFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildForecastLoadingState(includeBottomSpacing: true);
        }

        final result =
            snapshot.data ??
            _AemetCoastalForecastLoadResult(
              data: null,
              source: _ForecastDataSource.fallback,
              message: 'AEMET maritima costera no disponible.',
            );
        if (result.source == _ForecastDataSource.fallback ||
            result.data == null) {
          return _buildUnavailableForecastState(
            message:
                result.message ??
                'Prueba de nuevo mas tarde o cambia de proveedor.',
            technicalError: result.technicalError,
            onRetry: _refreshAemetCoastalForecast,
          );
        }
        return Column(
          children: [
            Row(children: [Expanded(child: _buildForecastTableTitle())]),
            const SizedBox(height: AppSpacing.xs),
            _buildAemetCoastalStatusBanner(result),
            const SizedBox(height: AppSpacing.sm),
            AemetCoastalForecastTable(data: result.data!),
          ],
        );
      },
    );
  }

  void _handleForecastProviderChanged(String value) {
    setState(() {
      _forecastProvider = value;
      final models = _modelsForProvider(value);
      if (!models.contains(_forecastModel) && models.isNotEmpty) {
        _forecastModel =
            getSpotDefaultForecastModel(
              spotName: widget.name,
              spotArea: widget.area,
              spotBeachCode: widget.aemetBeachCode,
              spotBeachCodes: widget.aemetBeachCodes,
              provider: value,
            ) ??
            models.first;
      }
      _syncForecastRangeWithProvider();
    });
    if (_usesWindguruProvider()) {
      return;
    }
    if (_usesAemetBeachForecastModel()) {
      _refreshAemetBeachForecast();
    } else if (_usesAemetCoastalForecastModel()) {
      _refreshAemetCoastalForecast();
    } else {
      _refreshForecastRows();
    }
  }

  void _handleForecastModelChanged(String value) {
    final shouldRefresh = _providerUsesModelForFetch(_forecastProvider, value);
    setState(() {
      _forecastModel = value;
    });
    if (_usesAemetBeachForecastModel(value)) {
      _refreshAemetBeachForecast();
    } else if (_usesAemetCoastalForecastModel(value)) {
      _refreshAemetCoastalForecast();
    } else if (shouldRefresh) {
      _refreshForecastRows();
    }
  }

  void _handleHistoryForecastProviderChanged(String value) {
    final models = _historyForecastModelsForProvider(value);
    setState(() {
      _historyForecastProvider = value;
      _historyForecastModel = models.isNotEmpty ? models.first : '';
      _historyForecastRowsResult = null;
      _historyForecastLoadRequested = true;
    });
    _loadHistoryForecastRows();
  }

  void _handleHistoryForecastModelChanged(String value) {
    setState(() {
      _historyForecastModel = value;
      _historyForecastRowsResult = null;
      _historyForecastLoadRequested = true;
    });
    _loadHistoryForecastRows();
  }

  Future<void> _openWindMap() async {
    final result = await _forecastRowsFuture;
    if (!mounted) {
      return;
    }
    if (!_canBuildWindMapFromForecastResult(result)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este forecast no tiene datos reutilizables para el mapa de viento.',
          ),
        ),
      );
      return;
    }
    final center = LatLng(
      widget.latitude ?? _avametOlivaStationLat,
      widget.longitude ?? _avametOlivaStationLon,
    );
    final baseRows = _clipForecastRows(
      result.rows,
      provider: _forecastProvider,
      range: _forecastRange,
    );
    final mapResolution = switch (_forecastRange) {
      _ForecastRange.d15 => _ForecastResolution.h6,
      _ => _ForecastResolution.h3,
    };
    final forecastRows = _resampleForecastRows(baseRows, mapResolution);
    final samples = forecastRows
        .map(
          (row) => WindMapSample(
            time: row.slotTime,
            windKnots: row.windKnots,
            windDeg: row.windDeg,
            gustKnots: row.gustKnots,
            waveM: row.waveM,
          ),
        )
        .toList(growable: false);
    var gridSnapshots = const <OpenMeteoWindMapGridSnapshot>[];
    if (_forecastProvider == 'Open-Meteo') {
      try {
        gridSnapshots = await _openMeteoWindMapGridClient.fetchGrid(
          centerLat: center.latitude,
          centerLon: center.longitude,
          model: _forecastModel,
        );
      } catch (_) {
        gridSnapshots = const <OpenMeteoWindMapGridSnapshot>[];
      }
    }

    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WindMapPage(
          spotName: widget.name,
          center: center,
          samples: samples,
          providerLabel: _forecastProvider,
          modelLabel: _forecastModel,
          gridSnapshots: gridSnapshots,
        ),
      ),
    );
  }

  Widget _buildForecastProviderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _forecastProvider,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Proveedor meteo',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'Open-Meteo', child: Text('Open-Meteo')),
        DropdownMenuItem(value: 'AEMET', child: Text('AEMET')),
        DropdownMenuItem(value: 'Windguru', child: Text('Windguru')),
        DropdownMenuItem(value: 'Meteoblue', child: Text('Meteoblue')),
        DropdownMenuItem(value: 'Meteosource', child: Text('Meteosource')),
        DropdownMenuItem<String>(value: 'Meteostat', child: Text('Meteostat')),
      ],
      onChanged: (value) {
        if (value == null) {
          return;
        }
        _handleForecastProviderChanged(value);
      },
    );
  }

  Widget _buildForecastModelControls() {
    if (_usesWindguruProvider()) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final modelDropdown = DropdownButtonFormField<String>(
          initialValue:
              _modelsForProvider(_forecastProvider).contains(_forecastModel)
              ? _forecastModel
              : _modelsForProvider(_forecastProvider).first,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Modelo de prevision',
            border: OutlineInputBorder(),
          ),
          selectedItemBuilder: (context) {
            return _modelsForProvider(_forecastProvider).map((model) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  model,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
          items: _modelsForProvider(_forecastProvider).map((model) {
            final recommendation = getSpotForecastModelRecommendation(
              spotName: widget.name,
              provider: _forecastProvider,
              model: model,
            );
            return DropdownMenuItem<String>(
              value: model,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      model,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (recommendation != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Chip(
                      label: Text(recommendation.badgeLabel),
                      labelStyle: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      side: BorderSide.none,
                      backgroundColor: recommendation.badgeLabel == 'Top'
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.tertiaryContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            _handleForecastModelChanged(value);
          },
        );

        final infoButton = IconButton(
          tooltip: 'Info del modelo',
          onPressed: _showForecastModelInfoDialog,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.info_outline_rounded),
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: modelDropdown),
            const SizedBox(width: AppSpacing.xs),
            infoButton,
          ],
        );
      },
    );
  }

  Widget _buildWindMapButton() {
    if (!_supportsWindMapForCurrentForecastSelection()) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<_ForecastLoadResult>(
      future: _forecastRowsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final result = snapshot.data;
        if (result == null || !_canBuildWindMapFromForecastResult(result)) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openWindMap,
            icon: const Icon(Icons.air_outlined),
            label: const Text('Mapa de viento'),
          ),
        );
      },
    );
  }

  Widget _buildWindMapButtonBlock() {
    if (!_supportsWindMapForCurrentForecastSelection()) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        _buildWindMapButton(),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildForecastSectionBody() {
    if (_usesWindguruProvider()) {
      return _buildWindguruForecastSection();
    }
    if (_usesAemetBeachForecastModel()) {
      return _buildAemetBeachForecastSection();
    }
    if (_usesAemetCoastalForecastModel()) {
      return _buildAemetCoastalForecastSection();
    }
    return FutureBuilder<_ForecastLoadResult>(
      future: _forecastRowsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildForecastLoadingState(includeBottomSpacing: true);
        }

        final result =
            snapshot.data ??
            _ForecastLoadResult(
              rows: const <_ForecastRow>[],
              source: _ForecastDataSource.fallback,
              message: 'No se han podido cargar datos.',
            );
        return _buildForecastSupplementOrTable(result);
      },
    );
  }

  Widget _buildForecastSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildForecastProviderDropdown(),
          const SizedBox(height: AppSpacing.sm),
          if (!_usesWindguruProvider()) ...[_buildForecastModelControls()],
          _buildWindMapButtonBlock(),
          _buildForecastSectionBody(),
        ],
      ),
    );
  }

  bool _supportsWindMapForCurrentForecastSelection() {
    if (_usesWindguruProvider()) {
      return false;
    }
    if (_usesAemetBeachForecastModel()) {
      return false;
    }
    if (_usesAemetCoastalForecastModel()) {
      return false;
    }
    return true;
  }

  bool _canBuildWindMapFromForecastResult(_ForecastLoadResult result) {
    if (!_supportsWindMapForCurrentForecastSelection()) {
      return false;
    }
    if (result.rows.isEmpty) {
      return false;
    }
    return result.rows.any((row) => row.windKnots > 0);
  }

  void _handleLiveStationChanged(String value) {
    final station = _findStationByKey(value);
    setState(() {
      _selectedStation = value;
      _applyHistoricalDefaultsForStation(station);
    });
    _refreshSelectedStationLiveData();
    _refreshSelectedStationHistoricalData();
  }

  String _stationKey(_NearbyStation station) {
    return station.stationKey;
  }

  _NearbyStation? _findStationByKey(String key) {
    for (final station in _resolvedNearbyStations()) {
      if (_stationKey(station) == key) {
        return station;
      }
    }
    return null;
  }

  String _stationDisplayName(String key) {
    final station = _findStationByKey(key);
    return station?.name ?? key;
  }

  String _stationLabel(_NearbyStation station) {
    final stationLocationLabel =
        station.proximityLabel ?? '${station.distanceKm.toStringAsFixed(1)} km';
    final directionLabel = _stationDirectionLabel(station);
    if (directionLabel == null) {
      return '${station.name} · $stationLocationLabel';
    }
    return '${station.name} · $stationLocationLabel · $directionLabel';
  }

  String? _stationDirectionLabel(_NearbyStation station) {
    final latitude = widget.latitude;
    final longitude = widget.longitude;
    if (latitude == null || longitude == null) {
      return null;
    }
    final bearing = _bearingDegrees(
      latitudeA: latitude,
      longitudeA: longitude,
      latitudeB: station.latitude,
      longitudeB: station.longitude,
    );
    return _degreesToCardinal(bearing);
  }

  String _stationLabelForKey(String key) {
    final station = _findStationByKey(key);
    if (station == null) {
      return key;
    }
    return _stationLabel(station);
  }

  String _currentSpotAlarmKey() => '${widget.name}::${widget.area}';

  List<SpotAlarmRecord> _savedAlarmsForCurrentSpot() {
    return SpotAlarmCatalog.instance.alarmsForSpot(_currentSpotAlarmKey());
  }

  String _selectedStationName() {
    return _stationDisplayName(_selectedStation);
  }

  bool _isOlivaAemetOfficialStation(_NearbyStation? station) {
    return station?.provider == 'AEMET' && station?.stationId == '8058X';
  }

  bool _isOlivaNovaInforatgeStation(_NearbyStation? station) {
    return station?.provider == 'INFORATGE' &&
        station?.stationId == _meteoclimaticOlivaNovaStationId;
  }

  bool _isAiguaBlancaStation(_NearbyStation? station) {
    return station?.provider == 'AIGUABLANCA' &&
        station?.stationId == _aiguaBlancaStationId;
  }

  void _applyHistoricalDefaultsForStation(_NearbyStation? station) {
    if (_isOlivaNovaInforatgeStation(station) ||
        _isAiguaBlancaStation(station)) {
      _historyBucket1d = _HistoricalBucketOption.min20;
      return;
    }
    if (_historyBucket1d == _HistoricalBucketOption.min20) {
      _historyBucket1d = _HistoricalBucketOption.h1;
    }
  }

  void _handleHistoryRangeChanged(_HistoryRange value) {
    setState(() {
      _historyRange = value;
    });
  }

  void _handleHistoricalBucketOptionChanged(_HistoricalBucketOption value) {
    setState(() {
      _setSelectedBucketOption(value);
    });
  }

  void _handleWindSpeedUnitChanged(_WindSpeedUnit value) {
    setState(() {
      _windSpeedUnit = value;
    });
  }

  Future<void> _toggleRealtimeCompass() async {
    if (_compassOverlayMode == _CompassOverlayMode.realtime) {
      if (!mounted) return;
      setState(() {
        _compassOverlayMode = _CompassOverlayMode.off;
      });
      return;
    }
    if (kIsWeb) {
      final granted = await ensureWebCompassPermission();
      if (!mounted) return;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brujula no disponible. Revisa permisos/sensor.'),
          ),
        );
        return;
      }
    }
    if (!mounted) return;
    setState(() {
      _compassOverlayMode = _CompassOverlayMode.realtime;
    });
  }

  Widget _buildLiveStationDropdown() {
    final stations = _resolvedNearbyStations();
    final stationKeys = stations.map(_stationKey).toList(growable: false);
    final effectiveKey = stationKeys.contains(_selectedStation)
        ? _selectedStation
        : (stationKeys.isNotEmpty ? stationKeys.first : _selectedStation);
    return DropdownButtonFormField<String>(
      initialValue: effectiveKey,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Estacion meteorologica cercana',
        border: OutlineInputBorder(),
      ),
      items: stations.map((station) {
        return DropdownMenuItem<String>(
          value: _stationKey(station),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _stationLabel(station),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
      selectedItemBuilder: (context) {
        return stations
            .map(
              (station) => Text(
                _stationLabel(station),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
            .toList();
      },
      onChanged: (value) {
        if (value == null) {
          return;
        }
        _handleLiveStationChanged(value);
      },
    );
  }

  Widget _buildLiveProviderLabel() {
    final observedAt = _selectedLiveData().observedAt;
    if (observedAt == null) {
      return const SizedBox.shrink();
    }
    return Text(
      'Actualizado: ${_formatObservedAt(observedAt)}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildLiveWindUnitSelector() {
    return SegmentedButton<_WindSpeedUnit>(
      segments: const [
        ButtonSegment(value: _WindSpeedUnit.knots, label: Text('kt')),
        ButtonSegment(value: _WindSpeedUnit.kmh, label: Text('km/h')),
        ButtonSegment(value: _WindSpeedUnit.mph, label: Text('mph')),
        ButtonSegment(value: _WindSpeedUnit.beaufort, label: Text('Bft')),
      ],
      selected: {_windSpeedUnit},
      onSelectionChanged: (value) {
        _handleWindSpeedUnitChanged(value.first);
      },
    );
  }

  Widget _buildLiveCompassSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final liveData = _selectedLiveData();
        final hasWindData =
            liveData.windKnots != null && liveData.windDeg != null;
        final compassCard = Stack(
          children: [
            _buildWindRoseWithCompassOverlay(liveData),
            Positioned(
              top: AppSpacing.xs,
              left: AppSpacing.xs,
              child: IconButton.filledTonal(
                tooltip: _compassOverlayMode == _CompassOverlayMode.realtime
                    ? 'Desactivar brujula'
                    : 'Activar brujula',
                onPressed: hasWindData ? _toggleRealtimeCompass : null,
                icon: Icon(
                  _compassOverlayMode == _CompassOverlayMode.realtime
                      ? Icons.explore_off_rounded
                      : Icons.explore_rounded,
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: IconButton.filledTonal(
                tooltip: 'Refrescar estacion',
                onPressed: _isLiveRefreshing
                    ? null
                    : _refreshSelectedStationLiveData,
                icon: _isLiveRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
            ),
          ],
        );
        return compassCard;
      },
    );
  }

  Widget _buildLiveMetricsGrid() {
    final liveData = _selectedLiveData();
    final station = _findStationByKey(_selectedStation);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.2,
      children: [
        _liveMetric('Viento', _formatWind(liveData.windKnots)),
        _liveMetric(
          station?.provider == 'INFORATGE' ? 'Racha max.' : 'Racha',
          _formatWind(liveData.gustKnots),
        ),
        _liveMetric('Temperatura', _formatOptionalDouble(liveData.tempC, ' C')),
        _liveMetric(
          'Presion',
          _formatOptionalInt(liveData.pressureHpa, ' hPa'),
        ),
        _liveMetric('Humedad', _formatOptionalInt(liveData.humidityPct, '%')),
        _liveMetric('Lluvia', _formatOptionalDouble(liveData.rainMm, ' mm')),
      ],
    );
  }

  Future<void> _showWindSemaforoLegendDialog() {
    return showDialog<void>(
      context: context,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.traffic_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Leyenda del semaforo de viento'),
                    const SizedBox(height: 2),
                    Text(
                      'Guia rapida para interpretar viento y tamano orientativo de cometa.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWindSemaforoLegendCard(textTheme),
                const SizedBox(height: AppSpacing.sm),
                _buildKiteSizeGuideCard(textTheme),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWindSemaforoLegendCard(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.45),
            Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Escala de viento', style: textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(8),
            title: _formatWindRangeLabel(upperExclusiveKnots: 10),
            description: 'No navegable',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(12),
            title: _formatWindRangeLabel(
              lowerInclusiveKnots: 10,
              upperInclusiveKnots: 14,
            ),
            description: 'Viento muy flojo',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(16),
            title: _formatWindRangeLabel(
              lowerInclusiveKnots: 14,
              upperInclusiveKnots: 18,
            ),
            description: 'Viento flojo',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(22),
            title: _formatWindRangeLabel(
              lowerInclusiveKnots: 18,
              upperInclusiveKnots: 26,
            ),
            description: 'Viento optimo',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(29),
            title: _formatWindRangeLabel(
              lowerInclusiveKnots: 26,
              upperInclusiveKnots: 32,
            ),
            description: 'Viento fuerte',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(36),
            title: _formatWindRangeLabel(
              lowerInclusiveKnots: 32,
              upperInclusiveKnots: 40,
            ),
            description: 'Viento muy fuerte',
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildWindSemaforoLegendRow(
            color: _windSemaforoColor(45),
            title: _formatWindRangeLabel(lowerExclusiveKnots: 40),
            description: 'Viento super fuerte',
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildWindSemaforoLegendRow({
    required Color color,
    required String title,
    required String description,
    required TextTheme textTheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Wrap(
            children: [
              Text(
                '$title: ',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(description, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKiteSizeGuideCard(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.air_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Tamano orientativo de cometa', style: textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildKiteSizeGuideRow(
            windRange: _formatWindRangeLabel(
              lowerInclusiveKnots: 10,
              upperInclusiveKnots: 14,
            ),
            kiteSize: '14 m o +',
            textTheme: textTheme,
          ),
          _buildKiteSizeGuideRow(
            windRange: _formatWindRangeLabel(
              lowerInclusiveKnots: 14,
              upperInclusiveKnots: 18,
            ),
            kiteSize: '12-14 m',
            textTheme: textTheme,
          ),
          _buildKiteSizeGuideRow(
            windRange: _formatWindRangeLabel(
              lowerInclusiveKnots: 18,
              upperInclusiveKnots: 22,
            ),
            kiteSize: '9-12 m',
            textTheme: textTheme,
          ),
          _buildKiteSizeGuideRow(
            windRange: _formatWindRangeLabel(
              lowerInclusiveKnots: 22,
              upperInclusiveKnots: 26,
            ),
            kiteSize: '7-9 m',
            textTheme: textTheme,
          ),
          _buildKiteSizeGuideRow(
            windRange: _formatWindRangeLabel(
              lowerInclusiveKnots: 26,
              upperInclusiveKnots: 32,
            ),
            kiteSize: '5-7 m',
            textTheme: textTheme,
          ),
          _buildKiteSizeGuideRow(
            windRange: _formatWindRangeLabel(lowerExclusiveKnots: 32),
            kiteSize: '4-5 m',
            textTheme: textTheme,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildKiteSizeGuideRow({
    required String windRange,
    required String kiteSize,
    required TextTheme textTheme,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: isLast ? 0 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.18),
                ),
              ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              windRange,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            kiteSize,
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStationMapLink(_NearbyStation station) {
    return TextButton.icon(
      onPressed: () => _showLiveStationMapDialog(station),
      icon: const Icon(Icons.map_outlined),
      label: const Text('Ver estacion en el mapa'),
    );
  }

  Widget _buildLiveActionsRow(_NearbyStation station) {
    return _buildLiveStationMapLink(station);
  }

  Future<void> _showLiveStationMapDialog(_NearbyStation station) async {
    final latLng = LatLng(station.latitude, station.longitude);
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = math.min(screenSize.width * 0.94, 720.0);
    final mapHeight = math.min(screenSize.height * 0.55, 460.0);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: SizedBox(
            width: dialogWidth,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estacion · ${station.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: mapHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: latLng,
                            initialZoom: 12,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.windwisher.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: latLng,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${station.latitude.toStringAsFixed(4)}, ${station.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveSection() {
    final loadResult = _liveStationsLoadResult;
    if (loadResult == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: _buildForecastLoadingState(includeBottomSpacing: true),
        ),
      );
    }
    if (loadResult.source == _LiveStationsDataSource.unavailable ||
        loadResult.stations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: _buildUnavailableForecastState(
            message:
                loadResult.message ??
                'No hay observaciones reales disponibles para este spot.',
            technicalError: loadResult.technicalError,
            onRetry: _isLiveRefreshing ? null : _loadLiveStations,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLiveStationDropdown(),
            _buildLiveActionsRow(
              _findStationByKey(_selectedStation) ??
                  _resolvedNearbyStations().first,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildLiveProviderLabel(),
            const SizedBox(height: AppSpacing.sm),
            _buildLiveWindUnitSelector(),
            const SizedBox(height: AppSpacing.sm),
            _buildLiveCompassSection(),
            const SizedBox(height: AppSpacing.sm),
            _buildLiveMetricsGrid(),
            const SizedBox(height: AppSpacing.sm),
            _buildHistoricalChart(),
            const SizedBox(height: AppSpacing.sm),
            _buildCustomAlarmsSection(),
          ],
        ),
      ),
    );
  }

  Future<void> _loadLiveStations() async {
    if (_isLiveRefreshing) {
      return;
    }
    setState(() {
      _isLiveRefreshing = true;
    });
    try {
      final result = await _resolveLiveStations();
      if (!mounted) {
        return;
      }
      setState(() {
        _liveStationsLoadResult = result;
        final stationKeys = result.stations.map(_stationKey).toSet();
        if (result.stations.isNotEmpty &&
            !stationKeys.contains(_selectedStation)) {
          final preferredStation = _findPreferredLiveStation(
            result.stations,
            result.historicalSeriesByStation,
          );
          final resolvedStation = preferredStation ?? result.stations.first;
          _selectedStation = _stationKey(resolvedStation);
          _applyHistoricalDefaultsForStation(resolvedStation);
        }
        if (result.stations.isNotEmpty &&
            !stationKeys.contains(_alarmStation)) {
          _alarmStation = _stationKey(result.stations.first);
        }
      });
      await _refreshSelectedStationLiveData();
      await _refreshAlarmStationsLiveData(_savedAlarmsForCurrentSpot());
      _syncAlarmMonitoring();
    } finally {
      if (mounted) {
        setState(() {
          _isLiveRefreshing = false;
        });
      }
    }
  }

  Future<void> _hydrateAlarmCatalog() async {
    await SpotAlarmCatalog.instance.hydrateFromRemote();
    if (!mounted) {
      return;
    }
    setState(() {
      _syncAlarmMonitoring();
    });
  }

  void _syncAlarmMonitoring() {
    final savedAlarms = _savedAlarmsForCurrentSpot();
    final hasSavedAlarms = savedAlarms.isNotEmpty;
    final catalog = SpotAlarmCatalog.instance;
    final shouldMonitor =
        _isAppResumed &&
        hasSavedAlarms &&
        catalog.globalEnabled &&
        catalog.isSpotEnabled(_currentSpotAlarmKey());
    if (!shouldMonitor) {
      _alarmAutoRefreshTimer?.cancel();
      _alarmAutoRefreshTimer = null;
      return;
    }
    final monitoringInterval = _alarmMonitoringInterval(savedAlarms);
    _alarmAutoRefreshTimer?.cancel();
    _alarmAutoRefreshTimer = Timer.periodic(monitoringInterval, (_) {
      if (!mounted || !_isAppResumed) {
        return;
      }
      unawaited(_loadLiveStations());
    });
  }

  Duration _alarmMonitoringInterval(List<SpotAlarmRecord> alarms) {
    if (alarms.any((alarm) => alarm.repeatWindow == AlarmRepeatWindow.min1)) {
      return const Duration(minutes: 1);
    }
    return const Duration(minutes: 5);
  }

  Future<void> _refreshSelectedStationLiveData() async {
    final station = _findStationByKey(_selectedStation);
    if (station == null) {
      return;
    }
    final ownsRefreshState = !_isLiveRefreshing;
    if (ownsRefreshState && mounted) {
      setState(() {
        _isLiveRefreshing = true;
      });
    }
    try {
      final refreshed = await _fetchLiveDataForStation(station);
      if (!mounted || refreshed == null) {
        if (ownsRefreshState && mounted) {
          _showLiveRefreshFeedback(
            'No se pudo actualizar ${_stationDisplayName(_selectedStation)}.',
          );
        }
        return;
      }
      final liveData = refreshed;
      setState(() {
        final current = _liveStationsLoadResult;
        if (current == null) {
          return;
        }
        final updatedLiveData = Map<String, _StationLiveData>.from(
          current.liveDataByStation,
        );
        updatedLiveData[_selectedStation] = liveData;
        _liveStationsLoadResult = _LiveStationsLoadResult(
          stations: current.stations,
          liveDataByStation: updatedLiveData,
          historicalSeriesByStation: current.historicalSeriesByStation,
          source: current.source,
          message: current.message,
          technicalError: current.technicalError,
        );
      });
    } catch (_) {
      if (ownsRefreshState && mounted) {
        _showLiveRefreshFeedback(
          'No se pudo actualizar ${_stationDisplayName(_selectedStation)}.',
        );
      }
    } finally {
      if (ownsRefreshState && mounted) {
        setState(() {
          _isLiveRefreshing = false;
        });
      }
    }
  }

  void _showLiveRefreshFeedback(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _refreshAlarmStationsLiveData(
    List<SpotAlarmRecord> alarms,
  ) async {
    final stationKeys = alarms.map((alarm) => alarm.stationKey).toSet();
    if (stationKeys.isEmpty) {
      return;
    }
    final current = _liveStationsLoadResult;
    if (current == null) {
      return;
    }
    final updatedLiveData = Map<String, _StationLiveData>.from(
      current.liveDataByStation,
    );
    var changed = false;
    for (final stationKey in stationKeys) {
      if (stationKey == _selectedStation) {
        continue;
      }
      final station = _findStationByKey(stationKey);
      if (station == null) {
        continue;
      }
      try {
        final refreshed = await _fetchLiveDataForStation(station);
        if (refreshed == null) {
          continue;
        }
        updatedLiveData[stationKey] = refreshed;
        changed = true;
      } catch (_) {
        continue;
      }
    }
    if (!mounted || !changed) {
      return;
    }
    setState(() {
      final currentResult = _liveStationsLoadResult;
      if (currentResult == null) {
        return;
      }
      _liveStationsLoadResult = _LiveStationsLoadResult(
        stations: currentResult.stations,
        liveDataByStation: updatedLiveData,
        historicalSeriesByStation: currentResult.historicalSeriesByStation,
        source: currentResult.source,
        message: currentResult.message,
        technicalError: currentResult.technicalError,
      );
    });
  }

  Future<_StationLiveData?> _fetchLiveDataForStation(
    _NearbyStation station,
  ) async {
    if (station.provider == 'AVAMET') {
      final snapshot = await _avametObservationClient.fetchStationObservation(
        stationId: station.stationId!,
      );
      if (snapshot == null) {
        return null;
      }
      return _StationLiveData(
        windKnots: snapshot.windKnots?.toDouble(),
        windDeg: snapshot.windDirectionDeg,
        gustKnots: snapshot.gustKnots?.toDouble(),
        tempC: snapshot.tempC,
        pressureHpa: snapshot.pressureHpa?.round(),
        humidityPct: snapshot.humidityPct,
        rainMm: snapshot.rainMm,
        observedAt: snapshot.observedAt,
      );
    }
    if (station.provider == 'INFORATGE') {
      final feed = await _inforatgeOlivaNovaClient.fetchFeed(
        stationCode: station.stationId == _inforatgePoliesportiuStationId
            ? '01'
            : '02',
        liveUrl: station.stationId == _inforatgePoliesportiuStationId
            ? InforatgeOlivaNovaClient.livePoliesportiuUrl
            : InforatgeOlivaNovaClient.liveOlivaNovaUrl,
      );
      final snapshot = feed.latestSnapshot;
      if (snapshot == null) {
        return null;
      }
      return _StationLiveData(
        windKnots: snapshot.windKnots?.toDouble(),
        windDeg: snapshot.windDirectionDeg,
        gustKnots: snapshot.gustKnots?.toDouble(),
        tempC: snapshot.tempC,
        pressureHpa: snapshot.pressureHpa,
        humidityPct: snapshot.humidityPct,
        rainMm: snapshot.rainMm,
        observedAt: snapshot.observedAt,
      );
    }
    if (station.provider == 'AIGUABLANCA') {
      final feed = await _aiguaBlancaMeteoClient.fetchFeed();
      final snapshot = feed.latestSnapshot;
      if (snapshot == null) {
        return null;
      }
      return _StationLiveData(
        windKnots: snapshot.windKnots?.toDouble(),
        windDeg: snapshot.windDirectionDeg,
        gustKnots: snapshot.gustKnots?.toDouble(),
        tempC: snapshot.tempC,
        pressureHpa: snapshot.pressureHpa,
        humidityPct: snapshot.humidityPct,
        rainMm: snapshot.rainMm,
        observedAt: snapshot.observedAt,
      );
    }
    if (station.stationId == null) {
      return null;
    }
    final snapshot = await _aemetObservationClient.fetchStationObservation(
      stationId: station.stationId!,
      referenceLatitude: station.latitude,
      referenceLongitude: station.longitude,
    );
    if (snapshot == null) {
      return null;
    }
    return _StationLiveData(
      windKnots: snapshot.windKnots,
      windDeg: snapshot.windDirectionDeg,
      gustKnots: snapshot.gustKnots,
      tempC: snapshot.tempC,
      pressureHpa: snapshot.pressureHpa?.round(),
      humidityPct: snapshot.humidityPct,
      rainMm: snapshot.rainMm,
      observedAt: snapshot.observedAt,
    );
  }

  _NearbyStation? _findPreferredLiveStation(
    List<_NearbyStation> stations,
    Map<String, List<_HistoricalWindPoint>> historicalSeriesByStation,
  ) {
    if (stations.isEmpty) {
      return null;
    }
    return stations.first;
  }

  Future<_LiveStationsLoadResult> _resolveLiveStations() async {
    final latitude = widget.latitude;
    final longitude = widget.longitude;
    if (latitude == null || longitude == null) {
      return const _LiveStationsLoadResult(
        stations: <_NearbyStation>[],
        liveDataByStation: <String, _StationLiveData>{},
        historicalSeriesByStation: <String, List<_HistoricalWindPoint>>{},
        source: _LiveStationsDataSource.unavailable,
        message:
            'Este spot no tiene coordenadas para buscar estaciones reales cercanas.',
      );
    }

    try {
      final isOlivaSpot = widget.name.trim().toLowerCase().contains('oliva');
      final stations = <_NearbyStation>[];
      final liveDataByStation = <String, _StationLiveData>{};
      final historyByStation = <String, List<_HistoricalWindPoint>>{};
      final seenKeys = <String>{};
      String? errorMessage;
      String? technicalError;

      List<AemetObservationStationSnapshot> snapshots =
          const <AemetObservationStationSnapshot>[];
      try {
        snapshots = await _aemetObservationClient.fetchNearestStations(
          latitude: latitude,
          longitude: longitude,
          limit: 20,
          maxDistanceKm: isOlivaSpot ? 5 : 5,
          preferredStationId: _preferredLiveStationId(),
        );
      } catch (error) {
        errorMessage = !EnvConfig.aemetAccessConfigured
            ? 'AEMET sin API key cargada para observaciones reales.'
            : 'No se han podido cargar observaciones reales de AEMET.';
        technicalError = '$error';
      }

      for (final snapshot in snapshots) {
        final normalizedName = snapshot.stationName.toLowerCase();
        final isOlivaClubNautico =
            normalizedName.contains('club nautico') &&
            normalizedName.contains('oliva');
        final stationName = snapshot.stationId == '8058X'
            ? 'AEMET Oliva'
            : (isOlivaClubNautico
                  ? 'Club Nautico de Oliva'
                  : snapshot.stationName);
        final proximityLabel = null;
        final stationKey = snapshot.stationId;
        if (seenKeys.contains(stationKey)) {
          continue;
        }
        seenKeys.add(stationKey);
        stations.add(
          _NearbyStation(
            name: stationName,
            distanceKm: snapshot.distanceKm,
            provider: 'AEMET',
            sourceKind: _StationSourceKind.observation,
            stationId: snapshot.stationId,
            proximityLabel: proximityLabel,
            stationKey: stationKey,
            latitude: snapshot.latitude,
            longitude: snapshot.longitude,
          ),
        );
        liveDataByStation[stationKey] = _StationLiveData(
          windKnots: snapshot.windKnots,
          windDeg: snapshot.windDirectionDeg,
          gustKnots: snapshot.gustKnots,
          tempC: snapshot.tempC,
          pressureHpa: snapshot.pressureHpa?.round(),
          humidityPct: snapshot.humidityPct,
          rainMm: snapshot.rainMm,
          observedAt: snapshot.observedAt,
        );
      }
      if (isOlivaSpot) {
        try {
          final aemetOlivaHistory = await _aemetObservationClient
              .fetchStationObservations(
                stationId: '8058X',
                referenceLatitude: latitude,
                referenceLongitude: longitude,
              );
          historyByStation['8058X'] = aemetOlivaHistory
              .where((snapshot) => snapshot.observedAt != null)
              .map(
                (snapshot) => _HistoricalWindPoint(
                  time: snapshot.observedAt!,
                  windKnots: snapshot.windKnots ?? 0,
                  gustKnots: snapshot.gustKnots,
                  windDirectionDeg: snapshot.windDirectionDeg,
                  directionKind: snapshot.windDirectionDeg == null
                      ? null
                      : _HistoricalDirectionKind.exact,
                ),
              )
              .toList(growable: false);
        } catch (error) {
          technicalError ??= '$error';
        }
      }
      if (isOlivaSpot) {
        InforatgeOlivaNovaFeed inforatgePoliesportiuFeed =
            const InforatgeOlivaNovaFeed(
              points: <InforatgeOlivaNovaPoint>[],
              latestSnapshot: null,
            );
        try {
          inforatgePoliesportiuFeed = await _inforatgeOlivaNovaClient.fetchFeed(
            stationCode: '01',
            liveUrl: InforatgeOlivaNovaClient.livePoliesportiuUrl,
          );
        } catch (error) {
          technicalError ??= '$error';
        }
        InforatgeOlivaNovaFeed inforatgeFeed = const InforatgeOlivaNovaFeed(
          points: <InforatgeOlivaNovaPoint>[],
          latestSnapshot: null,
        );
        try {
          inforatgeFeed = await _inforatgeOlivaNovaClient.fetchFeed(
            stationCode: '02',
            liveUrl: InforatgeOlivaNovaClient.liveOlivaNovaUrl,
          );
        } catch (error) {
          technicalError ??= '$error';
        }
        AiguaBlancaMeteoFeed aiguaBlancaFeed = const AiguaBlancaMeteoFeed(
          points: <AiguaBlancaMeteoPoint>[],
          latestSnapshot: null,
        );
        try {
          aiguaBlancaFeed = await _aiguaBlancaMeteoClient.fetchFeed();
        } catch (error) {
          technicalError ??= '$error';
        }
        AvametObservationSnapshot? avametSnapshot;
        try {
          avametSnapshot = await _avametObservationClient
              .fetchStationObservation(stationId: _avametOlivaStationId);
        } catch (error) {
          technicalError ??= '$error';
        }
        AvametObservationSnapshot? avametOlivaPlayaSnapshot;
        try {
          avametOlivaPlayaSnapshot = await _avametObservationClient
              .fetchStationObservation(stationId: _avametOlivaPlayaStationId);
        } catch (error) {
          technicalError ??= '$error';
        }
        List<_HistoricalWindPoint> avametHistory =
            const <_HistoricalWindPoint>[];
        try {
          final intradayHistory = await _avametIntradayHistoryClient
              .fetchIntradayWindHistory(stationId: _avametOlivaStationId);
          avametHistory = intradayHistory
              .map(
                (point) => _HistoricalWindPoint(
                  time: point.time,
                  windKnots: point.windKnots,
                  windDirectionDeg: point.windDirectionDeg,
                  directionKind: point.windDirectionDeg == null
                      ? null
                      : _HistoricalDirectionKind.exact,
                ),
              )
              .toList(growable: false);
        } catch (error) {
          technicalError ??= '$error';
        }
        if (avametHistory.isEmpty) {
          try {
            final dailyHistory = await _avametDailyHistoryClient
                .fetchDailyWindHistory(stationId: _avametOlivaStationId);
            avametHistory = dailyHistory
                .map(
                  (point) => _HistoricalWindPoint(
                    time: point.time,
                    windKnots: point.windKnots,
                  ),
                )
                .toList(growable: false);
          } catch (error) {
            technicalError ??= '$error';
          }
        }
        List<_HistoricalWindPoint> avametOlivaPlayaHistory =
            const <_HistoricalWindPoint>[];
        try {
          final intradayHistory = await _avametIntradayHistoryClient
              .fetchIntradayWindHistory(stationId: _avametOlivaPlayaStationId);
          avametOlivaPlayaHistory = intradayHistory
              .map(
                (point) => _HistoricalWindPoint(
                  time: point.time,
                  windKnots: point.windKnots,
                  windDirectionDeg: point.windDirectionDeg,
                  directionKind: point.windDirectionDeg == null
                      ? null
                      : _HistoricalDirectionKind.exact,
                ),
              )
              .toList(growable: false);
        } catch (error) {
          technicalError ??= '$error';
        }
        if (avametOlivaPlayaHistory.isEmpty) {
          try {
            final dailyHistory = await _avametDailyHistoryClient
                .fetchDailyWindHistory(stationId: _avametOlivaPlayaStationId);
            avametOlivaPlayaHistory = dailyHistory
                .map(
                  (point) => _HistoricalWindPoint(
                    time: point.time,
                    windKnots: point.windKnots,
                  ),
                )
                .toList(growable: false);
          } catch (error) {
            technicalError ??= '$error';
          }
        }
        final poliesportiuStationKey = _inforatgePoliesportiuStationKey;
        if (!seenKeys.contains(poliesportiuStationKey)) {
          seenKeys.add(poliesportiuStationKey);
          stations.add(
            _NearbyStation(
              name: _inforatgePoliesportiuStationName,
              distanceKm: _distanceKm(
                latitudeA: latitude,
                longitudeA: longitude,
                latitudeB: _inforatgePoliesportiuLat,
                longitudeB: _inforatgePoliesportiuLon,
              ),
              provider: 'INFORATGE',
              sourceKind: _StationSourceKind.observation,
              stationId: _inforatgePoliesportiuStationId,
              proximityLabel: null,
              stationKey: poliesportiuStationKey,
              latitude: _inforatgePoliesportiuLat,
              longitude: _inforatgePoliesportiuLon,
            ),
          );
          final snapshot = inforatgePoliesportiuFeed.latestSnapshot;
          liveDataByStation[poliesportiuStationKey] = _StationLiveData(
            windKnots: snapshot?.windKnots?.toDouble(),
            windDeg: snapshot?.windDirectionDeg,
            gustKnots: snapshot?.gustKnots?.toDouble(),
            tempC: snapshot?.tempC,
            pressureHpa: snapshot?.pressureHpa,
            humidityPct: snapshot?.humidityPct,
            rainMm: snapshot?.rainMm,
            observedAt: snapshot?.observedAt,
          );
          historyByStation[poliesportiuStationKey] = inforatgePoliesportiuFeed
              .points
              .map(
                (point) => _HistoricalWindPoint(
                  time: point.time,
                  windKnots: point.windKnots,
                  windDirectionDeg: point.windDirectionDeg,
                  directionKind: point.windDirectionDeg == null
                      ? null
                      : _HistoricalDirectionKind.exact,
                ),
              )
              .toList(growable: false);
        }
        final inforatgeStationKey = _meteoclimaticOlivaNovaStationKey;
        if (!seenKeys.contains(inforatgeStationKey)) {
          seenKeys.add(inforatgeStationKey);
          stations.add(
            _NearbyStation(
              name: _meteoclimaticOlivaNovaStationName,
              distanceKm: _distanceKm(
                latitudeA: latitude,
                longitudeA: longitude,
                latitudeB: _meteoclimaticOlivaNovaLat,
                longitudeB: _meteoclimaticOlivaNovaLon,
              ),
              provider: 'INFORATGE',
              sourceKind: _StationSourceKind.observation,
              stationId: _meteoclimaticOlivaNovaStationId,
              proximityLabel: null,
              stationKey: inforatgeStationKey,
              latitude: _meteoclimaticOlivaNovaLat,
              longitude: _meteoclimaticOlivaNovaLon,
            ),
          );
          final snapshot = inforatgeFeed.latestSnapshot;
          liveDataByStation[inforatgeStationKey] = _StationLiveData(
            windKnots: snapshot?.windKnots?.toDouble(),
            windDeg: snapshot?.windDirectionDeg,
            gustKnots: snapshot?.gustKnots?.toDouble(),
            tempC: snapshot?.tempC,
            pressureHpa: snapshot?.pressureHpa,
            humidityPct: snapshot?.humidityPct,
            rainMm: snapshot?.rainMm,
            observedAt: snapshot?.observedAt,
          );
          historyByStation[inforatgeStationKey] = inforatgeFeed.points
              .map(
                (point) => _HistoricalWindPoint(
                  time: point.time,
                  windKnots: point.windKnots,
                  windDirectionDeg: point.windDirectionDeg,
                  directionKind: point.windDirectionDeg == null
                      ? null
                      : _HistoricalDirectionKind.exact,
                ),
              )
              .toList(growable: false);
        }
        final aiguaBlancaStationKey = _aiguaBlancaStationKey;
        if (!seenKeys.contains(aiguaBlancaStationKey)) {
          seenKeys.add(aiguaBlancaStationKey);
          stations.add(
            _NearbyStation(
              name: _aiguaBlancaStationName,
              distanceKm: _distanceKm(
                latitudeA: latitude,
                longitudeA: longitude,
                latitudeB: _aiguaBlancaStationLat,
                longitudeB: _aiguaBlancaStationLon,
              ),
              provider: 'AIGUABLANCA',
              sourceKind: _StationSourceKind.observation,
              stationId: _aiguaBlancaStationId,
              proximityLabel: null,
              stationKey: aiguaBlancaStationKey,
              latitude: _aiguaBlancaStationLat,
              longitude: _aiguaBlancaStationLon,
            ),
          );
          final snapshot = aiguaBlancaFeed.latestSnapshot;
          liveDataByStation[aiguaBlancaStationKey] = _StationLiveData(
            windKnots: snapshot?.windKnots?.toDouble(),
            windDeg: snapshot?.windDirectionDeg,
            gustKnots: snapshot?.gustKnots?.toDouble(),
            tempC: snapshot?.tempC,
            pressureHpa: snapshot?.pressureHpa,
            humidityPct: snapshot?.humidityPct,
            rainMm: snapshot?.rainMm,
            observedAt: snapshot?.observedAt,
          );
          historyByStation[aiguaBlancaStationKey] = aiguaBlancaFeed.points
              .map(
                (point) => _HistoricalWindPoint(
                  time: point.time,
                  windKnots: point.windKnots,
                  gustKnots: point.gustKnots,
                  windDirectionDeg: point.windDirectionDeg,
                  directionKind: point.windDirectionDeg == null
                      ? null
                      : _HistoricalDirectionKind.exact,
                ),
              )
              .toList(growable: false);
        }
        final stationKey = _avametOlivaStationKey;
        if (!seenKeys.contains(stationKey)) {
          seenKeys.add(stationKey);
          stations.add(
            _NearbyStation(
              name: _avametOlivaStationName,
              distanceKm: _distanceKm(
                latitudeA: latitude,
                longitudeA: longitude,
                latitudeB: _avametOlivaStationLat,
                longitudeB: _avametOlivaStationLon,
              ),
              provider: 'AVAMET',
              sourceKind: _StationSourceKind.observation,
              stationId: _avametOlivaStationId,
              proximityLabel: null,
              stationKey: stationKey,
              latitude: _avametOlivaStationLat,
              longitude: _avametOlivaStationLon,
            ),
          );
          liveDataByStation[stationKey] = _StationLiveData(
            windKnots: avametSnapshot?.windKnots,
            windDeg: avametSnapshot?.windDirectionDeg,
            gustKnots: avametSnapshot?.gustKnots,
            tempC: avametSnapshot?.tempC,
            pressureHpa: avametSnapshot?.pressureHpa?.round(),
            humidityPct: avametSnapshot?.humidityPct,
            rainMm: avametSnapshot?.rainMm,
            observedAt: avametSnapshot?.observedAt,
          );
          historyByStation[stationKey] = avametHistory;
        }
        final avametOlivaPlayaStationKey = _avametOlivaPlayaStationKey;
        final avametOlivaPlayaHasWindData =
            avametOlivaPlayaSnapshot?.windKnots != null ||
            avametOlivaPlayaSnapshot?.windDirectionDeg != null ||
            avametOlivaPlayaSnapshot?.gustKnots != null ||
            avametOlivaPlayaHistory.isNotEmpty;
        if (avametOlivaPlayaHasWindData &&
            !seenKeys.contains(avametOlivaPlayaStationKey)) {
          seenKeys.add(avametOlivaPlayaStationKey);
          stations.add(
            _NearbyStation(
              name: _avametOlivaPlayaStationName,
              distanceKm: _distanceKm(
                latitudeA: latitude,
                longitudeA: longitude,
                latitudeB: _avametOlivaPlayaStationLat,
                longitudeB: _avametOlivaPlayaStationLon,
              ),
              provider: 'AVAMET',
              sourceKind: _StationSourceKind.observation,
              stationId: _avametOlivaPlayaStationId,
              proximityLabel: null,
              stationKey: avametOlivaPlayaStationKey,
              latitude: _avametOlivaPlayaStationLat,
              longitude: _avametOlivaPlayaStationLon,
            ),
          );
          liveDataByStation[avametOlivaPlayaStationKey] = _StationLiveData(
            windKnots: avametOlivaPlayaSnapshot?.windKnots,
            windDeg: avametOlivaPlayaSnapshot?.windDirectionDeg,
            gustKnots: avametOlivaPlayaSnapshot?.gustKnots,
            tempC: avametOlivaPlayaSnapshot?.tempC,
            pressureHpa: avametOlivaPlayaSnapshot?.pressureHpa?.round(),
            humidityPct: avametOlivaPlayaSnapshot?.humidityPct,
            rainMm: avametOlivaPlayaSnapshot?.rainMm,
            observedAt: avametOlivaPlayaSnapshot?.observedAt,
          );
          historyByStation[avametOlivaPlayaStationKey] =
              avametOlivaPlayaHistory;
        }
      }
      stations.sort((a, b) {
        final distanceCompare = a.distanceKm.compareTo(b.distanceKm);
        if (distanceCompare != 0) {
          return distanceCompare;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      if (stations.isEmpty) {
        return _LiveStationsLoadResult(
          stations: const <_NearbyStation>[],
          liveDataByStation: const <String, _StationLiveData>{},
          historicalSeriesByStation:
              const <String, List<_HistoricalWindPoint>>{},
          source: _LiveStationsDataSource.unavailable,
          message:
              errorMessage ??
              'No se han podido cargar estaciones de observacion reales.',
          technicalError: technicalError,
        );
      }
      return _LiveStationsLoadResult(
        stations: stations,
        liveDataByStation: liveDataByStation,
        historicalSeriesByStation: historyByStation,
        source: _LiveStationsDataSource.real,
      );
    } catch (error) {
      return _LiveStationsLoadResult(
        stations: const <_NearbyStation>[],
        liveDataByStation: const <String, _StationLiveData>{},
        historicalSeriesByStation: const <String, List<_HistoricalWindPoint>>{},
        source: _LiveStationsDataSource.unavailable,
        message: !EnvConfig.aemetAccessConfigured
            ? 'AEMET sin API key cargada para observaciones reales.'
            : 'No se han podido cargar observaciones reales de AEMET.',
        technicalError: '$error',
      );
    }
  }

  String? _preferredLiveStationId() {
    final normalized = widget.name.trim().toLowerCase();
    if (normalized.contains('oliva')) {
      return '8058X';
    }
    return null;
  }

  String _formatObservedAt(DateTime value) {
    String two(int input) => input.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)} ${two(value.hour)}:${two(value.minute)}';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppResumed = state == AppLifecycleState.resumed;
    if (_isAppResumed) {
      _syncAlarmMonitoring();
      unawaited(_loadLiveStations());
      if (_section == _SpotDetailSection.social) {
        if (_socialRealtimeSubscription == null) {
          _bindSocialRealtime();
          _bindSocialPresence();
          _bindSocialTyping();
        }
        unawaited(_loadSocialFeed());
        _scheduleFocusSocialSection();
      }
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _alarmAutoRefreshTimer?.cancel();
      _alarmAutoRefreshTimer = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _alarmAutoRefreshTimer?.cancel();
    _socialRealtimeRefreshDebounce?.cancel();
    _socialTypingDebounce?.cancel();
    unawaited(_broadcastTypingState(isTyping: false));
    _unbindSocialRealtime();
    _unbindSocialPresence();
    _unbindSocialTyping();
    _historyChartScrollController.dispose();
    _historyChartFullscreenScrollController.dispose();
    _socialFeedScrollController.dispose();
    _socialPostFocusNode.dispose();
    _socialReplyFocusNode.dispose();
    _socialPostController.dispose();
    _socialReplyController.dispose();
    super.dispose();
  }

  void _bindSocialRealtime() {
    _socialRealtimeSubscription?.cancel();
    _socialRealtimeSubscription = _spotSocialClient
        .watchSpotFeed(spotName: widget.name, spotArea: widget.area)
        .listen((_) {
          if (!mounted) {
            return;
          }
          _socialRealtimeRefreshDebounce?.cancel();
          _socialRealtimeRefreshDebounce = Timer(
            const Duration(milliseconds: 280),
            () {
              if (!mounted) {
                return;
              }
              unawaited(_loadSocialFeed());
            },
          );
        });
  }

  void _unbindSocialRealtime() {
    _socialRealtimeRefreshDebounce?.cancel();
    _socialRealtimeRefreshDebounce = null;
    _socialRealtimeSubscription?.cancel();
    _socialRealtimeSubscription = null;
  }

  void _bindSocialPresence() {
    _socialPresenceSubscription?.cancel();
    _socialPresenceSubscription = _spotSocialClient
        .watchSpotPresence(spotName: widget.name, spotArea: widget.area)
        .listen((count) {
          if (!mounted) {
            return;
          }
          setState(() {
            _socialOnlineCount = count;
          });
        });
  }

  void _unbindSocialPresence() {
    _socialPresenceSubscription?.cancel();
    _socialPresenceSubscription = null;
    _socialOnlineCount = 0;
  }

  void _bindSocialTyping() {
    _socialTypingSubscription?.cancel();
    _socialTypingSubscription = _spotSocialClient
        .watchSpotTyping(spotName: widget.name, spotArea: widget.area)
        .listen((typingUsers) {
          if (!mounted) {
            return;
          }
          setState(() {
            _socialTypingUsers = typingUsers;
          });
        });
  }

  void _unbindSocialTyping() {
    _socialTypingDebounce?.cancel();
    _socialTypingDebounce = null;
    _socialTypingSubscription?.cancel();
    _socialTypingSubscription = null;
    _isSendingTypingState = false;
    _socialTypingUsers = const <String>{};
  }

  Future<void> _broadcastTypingState({required bool isTyping}) async {
    if (_isSendingTypingState == isTyping) {
      return;
    }
    _isSendingTypingState = isTyping;
    await _spotSocialClient.sendTypingState(
      spotName: widget.name,
      spotArea: widget.area,
      displayName: _socialDisplayName(),
      isTyping: isTyping,
    );
  }

  void _handleSocialComposerChanged(String value, {required bool forReply}) {
    setState(() {});
    if (_section != _SpotDetailSection.social) {
      return;
    }
    final hasText = value.trim().isNotEmpty;
    _socialTypingDebounce?.cancel();
    if (hasText) {
      unawaited(_broadcastTypingState(isTyping: true));
      _socialTypingDebounce = Timer(const Duration(milliseconds: 1400), () {
        unawaited(_broadcastTypingState(isTyping: false));
      });
    } else {
      unawaited(_broadcastTypingState(isTyping: false));
    }
  }

  void _restoreSocialChatViewport() {
    if (!mounted || _section != _SpotDetailSection.social) {
      return;
    }
    FocusScope.of(context).unfocus();
    _scheduleFocusSocialSection();
  }

  List<_ForecastRow> _rowsForProvider(String provider) {
    switch (provider) {
      case 'AEMET':
        return _generateForecastRows(
          days: 3,
          baseWindKnots: 14,
          baseWindDeg: 74,
          baseAirTempC: 22,
          baseWaterTempC: 18,
          basePressureHpa: 1016,
          baseWaveM: 0.9,
          providerBias: 0,
        );
      case 'Meteoblue':
        return _generateForecastRows(
          days: 7,
          baseWindKnots: 15,
          baseWindDeg: 82,
          baseAirTempC: 21,
          baseWaterTempC: 18,
          basePressureHpa: 1015,
          baseWaveM: 0.9,
          providerBias: 1,
        );
      case 'Meteosource':
        return _generateForecastRows(
          days: 1,
          baseWindKnots: 14,
          baseWindDeg: 88,
          baseAirTempC: 21,
          baseWaterTempC: 18,
          basePressureHpa: 1014,
          baseWaveM: 0.8,
          providerBias: 1,
        );
      case 'Meteostat':
        return _generateForecastRows(
          days: 7,
          baseWindKnots: 13,
          baseWindDeg: 86,
          baseAirTempC: 20,
          baseWaterTempC: 18,
          basePressureHpa: 1015,
          baseWaveM: 0.8,
          providerBias: 0,
        );
      default:
        return _generateForecastRows(
          days: 15,
          baseWindKnots: 13,
          baseWindDeg: 78,
          baseAirTempC: 21,
          baseWaterTempC: 18,
          basePressureHpa: 1017,
          baseWaveM: 0.8,
          providerBias: -1,
        );
    }
  }

  List<_ForecastRow> _generateForecastRows({
    required int days,
    required int baseWindKnots,
    required int baseWindDeg,
    required int baseAirTempC,
    required int baseWaterTempC,
    required int basePressureHpa,
    required double baseWaveM,
    required int providerBias,
  }) {
    final rows = <_ForecastRow>[];
    final now = DateTime.now();
    final startHour = ((now.hour ~/ 3) * 3) + 3;
    final start = DateTime(now.year, now.month, now.day, startHour);
    final totalSlots = (days * 8) + 1;

    for (var i = 0; i < totalSlots; i++) {
      final slot = start.add(Duration(hours: i * 3));
      final dayPhase = math.sin(((slot.hour - 8) / 24) * math.pi * 2);
      final synopticPhase = math.sin(i / 3.2);
      final windKnots = math.max(
        6,
        baseWindKnots +
            providerBias +
            (dayPhase * 4).round() +
            (synopticPhase * 2).round(),
      );
      final gustKnots = windKnots + 5 + (math.cos(i / 2.4) * 2).round();
      final windDeg = _normalizeDegrees(
        baseWindDeg + (math.sin(i / 4) * 18).roundToDouble(),
      ).round();
      final tempC = baseAirTempC + (dayPhase * 3).round() + (i ~/ 16);
      final waterTempC = baseWaterTempC + (i ~/ 24);
      final pressureHpa =
          basePressureHpa + (math.cos(i / 5) * 3).round() - (i ~/ 20);
      final cloudCoverPct = (28 + (math.sin(i / 2.1) * 24) + (i % 5) * 6)
          .round()
          .clamp(4, 100);
      final waveM = (baseWaveM + (windKnots / 25) + (math.cos(i / 3.4) * 0.18))
          .clamp(0.4, 2.8);
      final rainMm = cloudCoverPct > 72 && i % 4 == 1
          ? ((cloudCoverPct - 68) / 20).clamp(0.1, 2.2)
          : 0.0;

      rows.add(
        _ForecastRow(
          slotTime: slot,
          hour: _formatForecastSlot(slot),
          windKnots: windKnots,
          gustKnots: gustKnots,
          windDeg: windDeg,
          tempC: tempC,
          waterTempC: waterTempC,
          pressureHpa: pressureHpa,
          cloudCoverPct: cloudCoverPct,
          waveM: double.parse(waveM.toStringAsFixed(1)),
          rainMm: double.parse(rainMm.toStringAsFixed(1)),
        ),
      );
    }

    return rows;
  }

  String _formatForecastSlot(DateTime value, {int stepMinutes = 180}) {
    const weekdays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    final weekday = weekdays[value.weekday - 1];
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final timeLabel = stepMinutes >= 60 ? '$hour h' : '$hour:$minute';
    return '$weekday\n$timeLabel';
  }

  List<_ForecastResolution> _allowedForecastResolutions(_ForecastRange range) {
    if (_forecastProvider == 'Meteoblue') {
      switch (range) {
        case _ForecastRange.d15:
          return const [_ForecastResolution.h1];
        case _ForecastRange.d7:
          return const [_ForecastResolution.h1];
        case _ForecastRange.d3:
          return const [_ForecastResolution.h1, _ForecastResolution.m15];
        case _ForecastRange.d1:
          return const [_ForecastResolution.h1, _ForecastResolution.m15];
      }
    }

    if (_forecastProvider == 'Meteosource') {
      return const [_ForecastResolution.h1];
    }

    if (_forecastProvider == 'Meteostat') {
      return const [_ForecastResolution.h1];
    }

    if (_usesAemetPortusForecastModel()) {
      return const [_ForecastResolution.h1];
    }

    switch (range) {
      case _ForecastRange.d15:
        return const [_ForecastResolution.h6];
      case _ForecastRange.d7:
        return const [_ForecastResolution.h6, _ForecastResolution.h3];
      case _ForecastRange.d3:
        return const [_ForecastResolution.h3, _ForecastResolution.h1];
      case _ForecastRange.d1:
        return const [
          _ForecastResolution.h3,
          _ForecastResolution.h1,
          _ForecastResolution.m20,
        ];
    }
  }

  _ForecastResolution _preferredForecastResolution(_ForecastRange range) {
    if (_forecastProvider == 'Meteoblue') {
      switch (range) {
        case _ForecastRange.d15:
        case _ForecastRange.d7:
          return _ForecastResolution.h1;
        case _ForecastRange.d3:
        case _ForecastRange.d1:
          return _ForecastResolution.m15;
      }
    }

    if (_forecastProvider == 'Meteosource') {
      return _ForecastResolution.h1;
    }

    if (_forecastProvider == 'Meteostat') {
      return _ForecastResolution.h1;
    }

    if (_usesAemetPortusForecastModel()) {
      return _ForecastResolution.h1;
    }

    switch (range) {
      case _ForecastRange.d15:
        return _ForecastResolution.h6;
      case _ForecastRange.d7:
        return _ForecastResolution.h3;
      case _ForecastRange.d3:
        return _ForecastResolution.h3;
      case _ForecastRange.d1:
        return _ForecastResolution.h3;
    }
  }

  double _lerpAngle(double startDeg, double endDeg, double t) {
    final diff = (((endDeg - startDeg) + 540) % 360) - 180;
    return _normalizeDegrees(startDeg + diff * t);
  }

  List<_ForecastRow> _resampleForecastRows(
    List<_ForecastRow> baseRows,
    _ForecastResolution resolution,
  ) {
    if (_forecastProvider == 'Meteoblue') {
      return _selectNativeMeteoblueRows(baseRows, resolution);
    }

    if (resolution == _ForecastResolution.h6) {
      final rows = <_ForecastRow>[];
      for (var i = 0; i < baseRows.length; i += 2) {
        final row = baseRows[i];
        rows.add(
          _ForecastRow(
            slotTime: row.slotTime,
            hour: _formatForecastSlot(row.slotTime, stepMinutes: 360),
            windKnots: row.windKnots,
            gustKnots: row.gustKnots,
            windDeg: row.windDeg,
            tempC: row.tempC,
            waterTempC: row.waterTempC,
            pressureHpa: row.pressureHpa,
            cloudCoverPct: row.cloudCoverPct,
            waveM: row.waveM,
            rainMm: row.rainMm,
          ),
        );
      }
      return rows;
    }

    if (resolution == _ForecastResolution.h3 || baseRows.length < 2) {
      return baseRows;
    }

    final rows = <_ForecastRow>[];
    final stepMinutes = resolution.minutes;

    for (var i = 0; i < baseRows.length - 1; i++) {
      final current = baseRows[i];
      final next = baseRows[i + 1];
      final totalMinutes = next.slotTime.difference(current.slotTime).inMinutes;
      final steps = totalMinutes ~/ stepMinutes;

      for (var step = 0; step < steps; step++) {
        final t = step / steps;
        final slotTime = current.slotTime.add(
          Duration(minutes: step * stepMinutes),
        );
        rows.add(
          _ForecastRow(
            slotTime: slotTime,
            hour: _formatForecastSlot(slotTime, stepMinutes: stepMinutes),
            windKnots:
                (current.windKnots + (next.windKnots - current.windKnots) * t)
                    .round(),
            gustKnots: _lerpNullableInt(current.gustKnots, next.gustKnots, t),
            windDeg: _lerpAngle(
              current.windDeg.toDouble(),
              next.windDeg.toDouble(),
              t,
            ).round(),
            tempC: _lerpNullableInt(current.tempC, next.tempC, t),
            waterTempC: _lerpNullableInt(
              current.waterTempC,
              next.waterTempC,
              t,
            ),
            pressureHpa: _lerpNullableInt(
              current.pressureHpa,
              next.pressureHpa,
              t,
            ),
            cloudCoverPct: _lerpNullableInt(
              current.cloudCoverPct,
              next.cloudCoverPct,
              t,
            ),
            waveM: _lerpNullableDouble(current.waveM, next.waveM, t),
            rainMm: _lerpNullableDouble(current.rainMm, next.rainMm, t),
          ),
        );
      }
    }

    final last = baseRows.last;
    rows.add(
      _ForecastRow(
        slotTime: last.slotTime,
        hour: _formatForecastSlot(last.slotTime, stepMinutes: stepMinutes),
        windKnots: last.windKnots,
        gustKnots: last.gustKnots,
        windDeg: last.windDeg,
        tempC: last.tempC,
        waterTempC: last.waterTempC,
        pressureHpa: last.pressureHpa,
        cloudCoverPct: last.cloudCoverPct,
        waveM: last.waveM,
        rainMm: last.rainMm,
      ),
    );

    return rows;
  }

  List<_ForecastRow> _selectNativeMeteoblueRows(
    List<_ForecastRow> baseRows,
    _ForecastResolution resolution,
  ) {
    final nativeRows = baseRows
        .map(
          (row) => _ForecastRow(
            slotTime: row.slotTime,
            hour: _formatForecastSlot(
              row.slotTime,
              stepMinutes: resolution.minutes,
            ),
            windKnots: row.windKnots,
            gustKnots: row.gustKnots,
            windDeg: row.windDeg,
            tempC: row.tempC,
            waterTempC: row.waterTempC,
            pressureHpa: row.pressureHpa,
            cloudCoverPct: row.cloudCoverPct,
            waveM: row.waveM,
            rainMm: row.rainMm,
          ),
        )
        .toList(growable: false);

    if (resolution == _ForecastResolution.m15) {
      return nativeRows;
    }
    if (resolution == _ForecastResolution.h1) {
      return nativeRows.where((row) => row.slotTime.minute == 0).toList();
    }
    return nativeRows;
  }

  int? _lerpNullableInt(int? current, int? next, double t) {
    if (current == null || next == null) {
      return null;
    }
    return (current + (next - current) * t).round();
  }

  double? _lerpNullableDouble(double? current, double? next, double t) {
    if (current == null || next == null) {
      return null;
    }
    return double.parse((current + (next - current) * t).toStringAsFixed(1));
  }

  String _nullableMetricText(String? value) {
    return value == null || value.isEmpty ? '-' : value;
  }

  Widget _buildForecastTableTitle() {
    final modelLabel = _usesWindguruProvider() ? 'Windguru' : _forecastModel;
    return Text(
      'Tabla Forecast ($modelLabel)',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  List<_ForecastRow> _rowsForSelectedForecastRange(String provider) {
    return _rowsForForecastRange(provider, _forecastRange);
  }

  List<_ForecastRow> _rowsForForecastRange(
    String provider,
    _ForecastRange range,
  ) {
    final rows = _rowsForProvider(provider);
    return _clipForecastRows(rows, provider: provider, range: range);
  }

  List<_ForecastRow> _clipForecastRows(
    List<_ForecastRow> rows, {
    required String provider,
    required _ForecastRange range,
  }) {
    if (rows.isEmpty) {
      return const <_ForecastRow>[];
    }

    final end = rows.first.slotTime.add(Duration(days: range.days));

    if (provider == 'Meteoblue') {
      return rows.where((row) => row.slotTime.isBefore(end)).toList();
    }

    return rows.where((row) => row.slotTime.isBefore(end)).toList();
  }

  List<_ForecastRange> _availableForecastRanges(String provider) {
    if (provider == 'Meteoblue') {
      final rows = _rowsForProvider(provider);
      if (rows.isEmpty) {
        return const [_ForecastRange.d1];
      }
      final totalHours =
          rows.last.slotTime.difference(rows.first.slotTime).inHours + 1;
      return _ForecastRange.values
          .where((range) => totalHours >= range.days * 24)
          .toList();
    }
    if (provider == 'Meteosource') {
      return const [_ForecastRange.d1];
    }
    if (provider == 'Windguru') {
      return const [_ForecastRange.d1];
    }
    if (provider == 'Meteostat') {
      final rows = _rowsForProvider(provider);
      if (rows.isEmpty) {
        return const [_ForecastRange.d1];
      }
      final totalHours =
          rows.last.slotTime.difference(rows.first.slotTime).inHours + 1;
      return _ForecastRange.values
          .where((range) => totalHours >= range.days * 24)
          .toList();
    }
    final availableDays = (_rowsForProvider(provider).length / 8).floor();
    return _ForecastRange.values
        .where((range) => range.days <= availableDays)
        .toList();
  }

  void _syncForecastRangeWithProvider() {
    final ranges = _availableForecastRanges(_forecastProvider);
    if (!ranges.contains(_forecastRange) && ranges.isNotEmpty) {
      _forecastRange = ranges.last;
    }
    _syncForecastResolutionWithRange();
  }

  void _syncForecastResolutionWithRange() {
    final allowed = _allowedForecastResolutions(_forecastRange);
    if (!allowed.contains(_forecastResolution)) {
      _forecastResolution = _preferredForecastResolution(_forecastRange);
    }
  }

  double _forecastColumnWidth(_ForecastResolution? resolution) {
    switch (resolution) {
      case _ForecastResolution.h6:
        return 86;
      case _ForecastResolution.h1:
        return 72;
      case _ForecastResolution.m15:
        return 74;
      case _ForecastResolution.m20:
        return 64;
      case _ForecastResolution.h3:
      case null:
        return 76;
    }
  }

  Widget _buildExpandedForecastOverlay(_ForecastLoadResult result) {
    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;
    final baseRows = _clipForecastRows(
      result.rows,
      provider: _forecastProvider,
      range: _forecastRange,
    );
    final forecastRows = _resampleForecastRows(baseRows, _forecastResolution);

    return Positioned.fill(
      child: Stack(
        children: [
          ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final usableMainAxis = isLandscape
                    ? constraints.maxHeight
                    : constraints.maxWidth;
                final fullscreenRowHeight = math.max(24.0, usableMainAxis / 10);
                final forecastTable = _buildWindguruStyleTable(
                  rowsOverride: forecastRows,
                  selectedRange: _forecastRange,
                  showRangeSelector: false,
                  showResolutionSelector: false,
                  showFullscreenButton: false,
                  expandToFill: true,
                  fullscreenRowHeight: fullscreenRowHeight,
                  fullscreenResolution: _forecastResolution,
                );
                final content = isLandscape
                    ? SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: forecastTable,
                      )
                    : SizedBox(
                        width: constraints.maxHeight,
                        height: constraints.maxWidth,
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: forecastTable,
                        ),
                      );

                return ClipRect(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: content,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            right: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: SafeArea(
              child: SizedBox(
                width: 34,
                height: 34,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: 'forecastFullscreenClose',
                  tooltip: 'Salir de fullscreen',
                  elevation: 0,
                  highlightElevation: 0,
                  backgroundColor: Colors.black.withValues(alpha: 0.22),
                  foregroundColor: Colors.white.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  onPressed: () {
                    setState(() {
                      _fullscreenMode = _ForecastFullscreenMode.none;
                    });
                  },
                  child: const Icon(Icons.close_rounded, size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedWindguruOverlay() {
    final isSupported = !_isFlutterTest;
    return WindguruFullscreenOverlay(
      controller: _windguruFullscreenController,
      webEmbedHtml: kIsWeb ? _windguruWidgetHtml : null,
      isSupported: isSupported,
      unsupportedMessage: 'Windguru no disponible en este dispositivo.',
      onClose: () {
        setState(() {
          _fullscreenMode = _ForecastFullscreenMode.none;
        });
      },
    );
  }

  List<_NearbyStation> _resolvedNearbyStations() {
    return _liveStationsLoadResult?.stations ?? const <_NearbyStation>[];
  }

  Map<String, _StationLiveData> _resolvedLiveDataByStation() {
    return _liveStationsLoadResult?.liveDataByStation ??
        const <String, _StationLiveData>{};
  }

  _StationLiveData _selectedLiveData() {
    return _resolvedLiveDataByStation()[_selectedStation] ??
        const _StationLiveData(
          windKnots: null,
          windDeg: null,
          gustKnots: null,
          tempC: null,
          pressureHpa: null,
          humidityPct: null,
          rainMm: null,
          observedAt: null,
        );
  }

  List<_SpotWebcam> _webcamsForSpot() {
    final webcams = _spotsModule.getSpotWebcams(
      spotName: widget.name,
      isCustom: widget.isCustom,
    );
    final spotLat = widget.latitude;
    final spotLon = widget.longitude;
    if (spotLat == null || spotLon == null) {
      return webcams;
    }
    final sorted = List<_SpotWebcam>.from(webcams);
    sorted.sort((a, b) {
      final aDistance = _webcamDistanceKm(a, spotLat, spotLon);
      final bDistance = _webcamDistanceKm(b, spotLat, spotLon);
      if (aDistance == null && bDistance == null) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      if (aDistance == null) return 1;
      if (bDistance == null) return -1;
      final distanceCompare = aDistance.compareTo(bDistance);
      if (distanceCompare != 0) {
        return distanceCompare;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return sorted;
  }

  double? _webcamDistanceKm(
    _SpotWebcam webcam,
    double spotLat,
    double spotLon,
  ) {
    final webcamLat = webcam.latitude;
    final webcamLon = webcam.longitude;
    if (webcamLat == null || webcamLon == null) {
      return null;
    }
    return _distanceKm(
      latitudeA: spotLat,
      longitudeA: spotLon,
      latitudeB: webcamLat,
      longitudeB: webcamLon,
    );
  }

  void _openWebcam(_SpotWebcam webcam) {
    final relatedPages = _spotsModule.getWebcamReferencePages(webcam.name);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebcamPlayerPage(
          webcamName: webcam.name,
          source: webcam.source,
          status: webcam.status,
          resolution: webcam.resolution,
          primaryPageUrl: webcam.primaryPageUrl,
          summary: webcam.summary,
          streamManifestUrl: webcam.streamManifestUrl,
          previewImageUrl: webcam.previewImageUrl,
          relatedPages: relatedPages,
        ),
      ),
    );
  }

  String _formatWind(double? knots) {
    if (knots == null) {
      return '-';
    }
    switch (_windSpeedUnit) {
      case _WindSpeedUnit.knots:
        return '${knots.round()} kt';
      case _WindSpeedUnit.kmh:
        return '${(knots * 1.852).toStringAsFixed(1)} km/h';
      case _WindSpeedUnit.mph:
        return '${(knots * 1.15078).toStringAsFixed(1)} mph';
      case _WindSpeedUnit.beaufort:
        return 'FUERZA ${_beaufortFromKnots(knots.round())}';
    }
  }

  String _formatWindRoseValue(double? knots) {
    return _formatWind(knots);
  }

  String _formatWindUnitValue(double knots) {
    switch (_windSpeedUnit) {
      case _WindSpeedUnit.knots:
        return knots.round().toString();
      case _WindSpeedUnit.kmh:
        return (knots * 1.852).round().toString();
      case _WindSpeedUnit.mph:
        return (knots * 1.15078).round().toString();
      case _WindSpeedUnit.beaufort:
        return _beaufortFromKnots(knots.round()).toString();
    }
  }

  String _windUnitSuffix() {
    switch (_windSpeedUnit) {
      case _WindSpeedUnit.knots:
        return 'kt';
      case _WindSpeedUnit.kmh:
        return 'km/h';
      case _WindSpeedUnit.mph:
        return 'mph';
      case _WindSpeedUnit.beaufort:
        return '';
    }
  }

  String _formatWindRangeLabel({
    int? lowerInclusiveKnots,
    int? upperInclusiveKnots,
    int? upperExclusiveKnots,
    int? lowerExclusiveKnots,
  }) {
    if (_windSpeedUnit == _WindSpeedUnit.beaufort) {
      if (upperExclusiveKnots != null) {
        return '< FUERZA ${_beaufortFromKnots(upperExclusiveKnots)}';
      }
      if (lowerExclusiveKnots != null) {
        return '> FUERZA ${_beaufortFromKnots(lowerExclusiveKnots)}';
      }
      if (lowerInclusiveKnots != null && upperInclusiveKnots != null) {
        return 'FUERZA ${_beaufortFromKnots(lowerInclusiveKnots)}-${_beaufortFromKnots(upperInclusiveKnots)}';
      }
    }
    final suffix = _windUnitSuffix();
    if (upperExclusiveKnots != null) {
      return '< ${_formatWindUnitValue(upperExclusiveKnots.toDouble())} $suffix';
    }
    if (lowerExclusiveKnots != null) {
      return '> ${_formatWindUnitValue(lowerExclusiveKnots.toDouble())} $suffix';
    }
    if (lowerInclusiveKnots != null && upperInclusiveKnots != null) {
      return '${_formatWindUnitValue(lowerInclusiveKnots.toDouble())}-${_formatWindUnitValue(upperInclusiveKnots.toDouble())} $suffix';
    }
    return '-';
  }

  String _formatAlarmWindValue(num knots) {
    switch (_windSpeedUnit) {
      case _WindSpeedUnit.knots:
        return '${knots.round()} kt';
      case _WindSpeedUnit.kmh:
        return '${(knots * 1.852).round()} km/h';
      case _WindSpeedUnit.mph:
        return '${(knots * 1.15078).round()} mph';
      case _WindSpeedUnit.beaufort:
        return 'FUERZA ${_beaufortFromKnots(knots.round())}';
    }
  }

  String _formatAlarmWindRange(RangeValues range) {
    if (_windSpeedUnit == _WindSpeedUnit.beaufort) {
      return 'FUERZA ${_beaufortFromKnots(range.start.round())}-${_beaufortFromKnots(range.end.round())}';
    }
    final start = _formatAlarmWindValue(range.start);
    final end = _formatAlarmWindValue(range.end);
    final suffix = _windUnitSuffix();
    final startValue = start.replaceAll(' $suffix', '');
    final endValue = end.replaceAll(' $suffix', '');
    return '$startValue-$endValue $suffix';
  }

  String _formatOptionalInt(int? value, String suffix) {
    if (value == null) {
      return '-';
    }
    return '$value$suffix';
  }

  String _formatOptionalDouble(double? value, String suffix) {
    if (value == null) {
      return '-';
    }
    return '${value.toStringAsFixed(1)}$suffix';
  }

  Widget _liveMetric(String label, String value) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildTraditionalCompassRoseFace() {
    final colorScheme = Theme.of(context).colorScheme;
    const contrastFillColor = Color(0xFFF9A825);
    final needleTint = colorScheme.primary.withValues(alpha: 0.14);
    TextStyle? labelStyle(String text) {
      final isCardinal = text.length == 1;
      final isNorth = text == 'N';
      return Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: isCardinal ? FontWeight.w800 : FontWeight.w700,
        fontSize: isCardinal ? 11 : 10,
        color: isNorth
            ? const Color(0xFFD32F2F)
            : colorScheme.onSurface.withValues(alpha: isCardinal ? 0.92 : 0.8),
      );
    }

    Widget roseLabel(String text, double angleDeg) {
      const ringRadius = 80.0;
      final angle = angleDeg * math.pi / 180;
      final dx = math.cos(angle) * ringRadius;
      final dy = math.sin(angle) * ringRadius;

      return Transform.translate(
        offset: Offset(dx, dy),
        child: Text(text, style: labelStyle(text)),
      );
    }

    return SizedBox(
      width: 252,
      height: 252,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(220, 220),
            painter: _TraditionalCompassRosePainter(
              ringColor: colorScheme.outline,
              majorColor: colorScheme.onSurface.withValues(alpha: 0.88),
              minorColor: colorScheme.onSurface.withValues(alpha: 0.45),
              lightPetalColor: Color.alphaBlend(
                needleTint,
                colorScheme.surfaceContainerHighest,
              ),
              darkPetalColor: Color.alphaBlend(
                needleTint,
                colorScheme.surfaceContainer,
              ),
              accentPetalColor: colorScheme.primary.withValues(alpha: 0.4),
              centerGlowColor: colorScheme.primary.withValues(alpha: 0.26),
              contrastFillColor: contrastFillColor,
            ),
          ),
          roseLabel('N', -90),
          roseLabel('NE', -45),
          roseLabel('E', 0),
          roseLabel('SE', 45),
          roseLabel('S', 90),
          roseLabel('SW', 135),
          roseLabel('W', 180),
          roseLabel('NW', 225),
        ],
      ),
    );
  }

  Widget _buildWindRose(
    _StationLiveData data, {
    double? compassHeadingDeg,
    bool headingAvailable = true,
  }) {
    final windKnots = data.windKnots;
    final windDeg = data.windDeg;
    if (windKnots == null) {
      return _buildLiveEmptyWindCard();
    }
    final windKnotsValue = windKnots;
    final navigability = switch (windKnotsValue) {
      < 10 => (
        label: 'No navegable',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.block,
      ),
      >= 10 && < 14 => (
        label: 'Viento muy flojo',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.warning_amber_rounded,
      ),
      >= 14 && < 18 => (
        label: 'Viento flojo',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.check_circle,
      ),
      >= 18 && <= 26 => (
        label: 'Viento optimo',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.check_circle,
      ),
      > 26 && <= 32 => (
        label: 'Viento fuerte',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.warning_amber_rounded,
      ),
      > 32 && <= 40 => (
        label: 'Viento muy fuerte',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.warning_amber_rounded,
      ),
      _ => (
        label: 'Viento super fuerte',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.block,
      ),
    };

    final windDirection = windDeg == null
        ? null
        : _normalizeDegrees(windDeg.toDouble());
    final normalizedHeading = compassHeadingDeg == null
        ? null
        : _normalizeDegrees(compassHeadingDeg);
    final headingDelta = normalizedHeading == null || windDirection == null
        ? null
        : _headingDelta(windDirection, normalizedHeading);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            ActionChip(
              avatar: Icon(navigability.icon, color: Colors.white, size: 18),
              label: Text(
                navigability.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              tooltip: 'Leyenda del semaforo',
              onPressed: _showWindSemaforoLegendDialog,
              backgroundColor: navigability.color,
              side: BorderSide.none,
              shape: const StadiumBorder(),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: 252,
              height: 252,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildTraditionalCompassRoseFace(),
                  if (windDirection != null)
                    _buildWindClockHand(
                      directionDeg: windDirection,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  if (normalizedHeading != null)
                    _buildCompassNeedle(
                      directionDeg: normalizedHeading,
                      northColor: const Color(0xFFD32F2F),
                      southColor: const Color(0xFF263238),
                      showPoleLabels: true,
                    ),
                  if (normalizedHeading != null)
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _formatWindRoseValue(windKnotsValue),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (windDirection == null) ...[
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  'Direccion del viento no disponible.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            if (_compassOverlayMode != _CompassOverlayMode.off) ...[
              const SizedBox(height: AppSpacing.xs),
              if (!headingAvailable)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(
                    'Brujula no disponible. Revisa permisos/sensor.',
                    textAlign: TextAlign.center,
                  ),
                )
              else if (normalizedHeading != null &&
                  headingDelta != null &&
                  windDirection != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Brujula: ${normalizedHeading.toStringAsFixed(0)}$_degreeSymbol',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Viento: ${windDirection.toStringAsFixed(0)}$_degreeSymbol ${_degreesToCardinal(windDirection)}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWindRoseWithCompassOverlay(_StationLiveData data) {
    switch (_compassOverlayMode) {
      case _CompassOverlayMode.off:
        return _buildWindRose(data);
      case _CompassOverlayMode.realtime:
        if (kIsWeb) {
          return StreamBuilder<double?>(
            stream: webCompassHeadingStream,
            builder: (context, snapshot) {
              final heading = snapshot.data;
              if (heading == null) {
                return _buildWindRose(data, headingAvailable: false);
              }
              return _buildWindRose(data, compassHeadingDeg: heading);
            },
          );
        }
        return StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            final heading = snapshot.data?.heading;
            if (heading == null) {
              return _buildWindRose(data, headingAvailable: false);
            }
            return _buildWindRose(data, compassHeadingDeg: heading);
          },
        );
    }
  }

  Widget _buildLiveEmptyWindCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(
              Icons.air_rounded,
              size: 32,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Viento no disponible',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'La estacion seleccionada no reporta viento ahora mismo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  double _normalizeDegrees(double degrees) {
    final normalized = degrees % 360;
    if (normalized < 0) {
      return normalized + 360;
    }
    return normalized;
  }

  double _bearingDegrees({
    required double latitudeA,
    required double longitudeA,
    required double latitudeB,
    required double longitudeB,
  }) {
    final lat1 = _toRadians(latitudeA);
    final lat2 = _toRadians(latitudeB);
    final deltaLon = _toRadians(longitudeB - longitudeA);
    final y = math.sin(deltaLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);
    final bearing = math.atan2(y, x) * (180 / math.pi);
    return _normalizeDegrees(bearing);
  }

  double _distanceKm({
    required double latitudeA,
    required double longitudeA,
    required double latitudeB,
    required double longitudeB,
  }) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(latitudeB - latitudeA);
    final dLon = _toRadians(longitudeB - longitudeA);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitudeA)) *
            math.cos(_toRadians(latitudeB)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double value) => value * (math.pi / 180);

  double _headingDelta(double a, double b) {
    final diff = (_normalizeDegrees(a) - _normalizeDegrees(b)).abs();
    return diff > 180 ? 360 - diff : diff;
  }

  String _degreesToCardinal(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final normalized = _normalizeDegrees(degrees);
    final index = ((normalized + 22.5) ~/ 45) % directions.length;
    return directions[index];
  }

  Widget _buildCompassNeedle({
    required double directionDeg,
    required Color northColor,
    required Color southColor,
    double needleLength = 74,
    double needleWidth = 3,
    bool showPoleLabels = false,
  }) {
    return Transform.rotate(
      angle: (directionDeg * math.pi) / 180,
      child: SizedBox(
        width: math.max(needleWidth + 4, 30),
        height: needleLength * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(needleWidth * 4.2, needleLength * 2),
              painter: _CompassDiamondNeedlePainter(
                northColor: northColor,
                southColor: southColor,
              ),
            ),
            if (showPoleLabels) ...[
              Positioned(
                top: 53,
                child: Text(
                  'N',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 53,
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWindClockHand({
    required double directionDeg,
    required Color color,
  }) {
    return Transform.rotate(
      angle: ((_normalizeDegrees(directionDeg) + 180) * math.pi) / 180,
      child: SizedBox(
        width: 22,
        height: 220,
        child: CustomPaint(painter: _WindClockHandPainter(color: color)),
      ),
    );
  }

  List<_HistoricalWindPoint> _selectedHistoricalWindPoints() {
    final station = _findStationByKey(_selectedStation);
    if (station == null) {
      return const <_HistoricalWindPoint>[];
    }
    return _historicalWindPointsForStation(station);
  }

  List<_HistoricalWindPoint> _historicalWindPointsForStation(
    _NearbyStation station,
  ) {
    return _liveStationsLoadResult?.historicalSeriesByStation[station
            .stationKey] ??
        const <_HistoricalWindPoint>[];
  }

  bool _hasRealHistoricalSeries() => _selectedHistoricalWindPoints().isNotEmpty;

  bool _supportsThreeDayHistoryForSelectedStation() {
    final station = _findStationByKey(_selectedStation);
    if (station == null) {
      return false;
    }
    if (station.provider == 'INFORATGE') {
      return false;
    }
    if (station.provider == 'AIGUABLANCA') {
      return false;
    }
    if (station.provider == 'AEMET' && station.stationId == '8058X') {
      return false;
    }
    return true;
  }

  bool _usesFixedAemetOlivaHistoryWindow() {
    final station = _findStationByKey(_selectedStation);
    return _isOlivaAemetOfficialStation(station);
  }

  String _historicalSeriesDisplayLabel() {
    final station = _findStationByKey(_selectedStation);
    switch (station?.provider) {
      case 'AEMET':
        return 'AEMET';
      case 'AVAMET':
        return 'AVAMET';
      case 'INFORATGE':
        return 'Inforatge';
      default:
        return 'Historico';
    }
  }

  String _historicalCoverageLabel(List<_HistoricalWindPoint> points) {
    if (points.isEmpty) {
      return 'Sin historico disponible';
    }
    if (points.length == 1) {
      return 'Ultima hora disponible';
    }
    Duration smallestStep = points.last.time.difference(points.first.time);
    for (var i = 1; i < points.length; i++) {
      final delta = points[i].time.difference(points[i - 1].time);
      if (delta.inMinutes <= 0) {
        continue;
      }
      if (delta < smallestStep) {
        smallestStep = delta;
      }
    }
    final coveredDuration =
        points.last.time.difference(points.first.time) + smallestStep;
    if (coveredDuration.inHours >= 24) {
      return 'Ultimas 24 h disponibles';
    }
    if (coveredDuration.inHours >= 1) {
      return 'Ultimas ${coveredDuration.inHours} h disponibles';
    }
    return 'Ultimos ${coveredDuration.inMinutes} min disponibles';
  }

  String _historyRangeLabel(_HistoryRange range) {
    switch (range) {
      case _HistoryRange.h1:
        return '1d';
      case _HistoryRange.h3:
        return '3d';
    }
  }

  Future<void> _showForecastModelInfoDialog() {
    final info = getSpotForecastModelInfo(
      provider: _forecastProvider,
      model: _forecastModel,
    );
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(info.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(info.description),
              const SizedBox(height: AppSpacing.sm),
              Text('Tipo: ${info.scope}'),
              const SizedBox(height: 4),
              Text('Resolucion: ${info.resolution}'),
              const SizedBox(height: 4),
              Text('Horizonte: ${info.horizon}'),
              if (getSpotForecastModelRecommendation(
                    spotName: widget.name,
                    provider: _forecastProvider,
                    model: _forecastModel,
                  )
                  case final recommendation?) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Para ${widget.name}: ${recommendation.badgeLabel}. ${recommendation.message}',
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Duration _durationForRange(_HistoryRange range) {
    switch (range) {
      case _HistoryRange.h1:
        return const Duration(days: 1);
      case _HistoryRange.h3:
        return const Duration(days: 3);
    }
  }

  bool _isIntradayHistoricalSeries(List<_HistoricalWindPoint> points) {
    if (points.length < 2) {
      return false;
    }
    for (var i = 1; i < points.length; i++) {
      final delta = points[i].time.difference(points[i - 1].time);
      if (delta.inHours < 12) {
        return true;
      }
    }
    return false;
  }

  List<_HistoricalWindPoint> _windowHistoricalPoints(
    List<_HistoricalWindPoint> points, {
    Duration? intradayBucket,
  }) {
    if (points.isEmpty) {
      return const <_HistoricalWindPoint>[];
    }
    if (intradayBucket != null) {
      final endExclusive = _alignBucketStart(
        points.last.time,
        intradayBucket,
      ).add(intradayBucket);
      final startInclusive = endExclusive.subtract(
        _durationForRange(_historyRange),
      );
      return points
          .where(
            (point) =>
                !point.time.isBefore(startInclusive) &&
                point.time.isBefore(endExclusive),
          )
          .toList(growable: false);
    }
    final lastPointTime = points.last.time;
    final cutoff = lastPointTime.subtract(_durationForRange(_historyRange));
    return points
        .where((point) => !point.time.isBefore(cutoff))
        .toList(growable: false);
  }

  String _formatHistoricalLabel(
    _HistoricalWindPoint point, {
    required bool intraday,
  }) {
    String two(int input) => input.toString().padLeft(2, '0');
    if (!intraday) {
      return '${two(point.time.day)}/${two(point.time.month)}';
    }
    return '${two(point.time.hour)}:${two(point.time.minute)}';
  }

  List<_HistoricalBucketOption> _availableBucketOptions(_HistoryRange range) {
    switch (range) {
      case _HistoryRange.h1:
        if (_usesFixedAemetOlivaHistoryWindow()) {
          return const <_HistoricalBucketOption>[
            _HistoricalBucketOption.h1,
            _HistoricalBucketOption.h3,
          ];
        }
        return const <_HistoricalBucketOption>[
          _HistoricalBucketOption.min20,
          _HistoricalBucketOption.h1,
          _HistoricalBucketOption.h3,
        ];
      case _HistoryRange.h3:
        return const <_HistoricalBucketOption>[
          _HistoricalBucketOption.h3,
          _HistoricalBucketOption.h6,
          _HistoricalBucketOption.h12,
        ];
    }
  }

  _HistoricalBucketOption _selectedBucketOption(_HistoryRange range) {
    if (_usesFixedAemetOlivaHistoryWindow()) {
      return _HistoricalBucketOption.h1;
    }
    switch (range) {
      case _HistoryRange.h1:
        return _historyBucket1d;
      case _HistoryRange.h3:
        return _historyBucket3d;
    }
  }

  void _setSelectedBucketOption(_HistoricalBucketOption option) {
    if (_usesFixedAemetOlivaHistoryWindow()) {
      _historyBucket1d = _HistoricalBucketOption.h1;
      return;
    }
    switch (_historyRange) {
      case _HistoryRange.h1:
        _historyBucket1d = option;
      case _HistoryRange.h3:
        _historyBucket3d = option;
    }
  }

  Duration _bucketDurationForOption(_HistoricalBucketOption option) {
    switch (option) {
      case _HistoricalBucketOption.min20:
        return const Duration(minutes: 20);
      case _HistoricalBucketOption.h1:
        return const Duration(hours: 1);
      case _HistoricalBucketOption.h3:
        return const Duration(hours: 3);
      case _HistoricalBucketOption.h6:
        return const Duration(hours: 6);
      case _HistoricalBucketOption.h12:
        return const Duration(hours: 12);
    }
  }

  DateTime _alignBucketStart(DateTime time, Duration bucket) {
    final minutes = bucket.inMinutes;
    final dayStart = DateTime(time.year, time.month, time.day);
    final elapsedMinutes = time.difference(dayStart).inMinutes;
    final bucketIndex = elapsedMinutes ~/ minutes;
    return dayStart.add(Duration(minutes: bucketIndex * minutes));
  }

  List<_HistoricalWindPoint> _bucketHistoricalPoints(
    List<_HistoricalWindPoint> points, {
    required Duration bucket,
    bool representativeWhenMultiple = true,
  }) {
    if (points.isEmpty) {
      return const <_HistoricalWindPoint>[];
    }

    final buckets = <DateTime, List<_HistoricalWindPoint>>{};
    for (final point in points) {
      final bucketStart = _alignBucketStart(point.time, bucket);
      buckets
          .putIfAbsent(bucketStart, () => <_HistoricalWindPoint>[])
          .add(point);
    }

    final entries = buckets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final result = <_HistoricalWindPoint>[];
    for (final entry in entries) {
      final bucketPoints = entry.value;
      final avgWind =
          bucketPoints.fold<double>(0, (acc, point) => acc + point.windKnots) /
          bucketPoints.length;
      final gustValues = bucketPoints
          .map((point) => point.gustKnots)
          .whereType<double>()
          .toList(growable: false);
      _HistoricalWindPoint? directionPoint;
      for (final point in bucketPoints.reversed) {
        if (point.windDirectionDeg != null) {
          directionPoint = point;
          break;
        }
      }
      final lastDirection = directionPoint?.windDirectionDeg;
      final directionKind = lastDirection == null
          ? null
          : (!representativeWhenMultiple || bucketPoints.length == 1)
          ? directionPoint?.directionKind ?? _HistoricalDirectionKind.exact
          : _HistoricalDirectionKind.representative;
      result.add(
        _HistoricalWindPoint(
          time: entry.key,
          windKnots: avgWind,
          gustKnots: gustValues.isEmpty
              ? null
              : gustValues.reduce((a, b) => a > b ? a : b),
          windDirectionDeg: lastDirection,
          directionKind: directionKind,
        ),
      );
    }
    return result;
  }

  String _formatBucketLabel(Duration bucket) {
    if (bucket.inMinutes == 20) {
      return '20 min';
    }
    if (bucket.inHours == 1) {
      return '1 h';
    }
    return '${bucket.inHours} h';
  }

  String _historicalBucketOptionLabel(_HistoricalBucketOption option) {
    return _formatBucketLabel(_bucketDurationForOption(option));
  }

  void _scheduleHistoryChartFocus({
    required ScrollController controller,
    required bool fullscreen,
    required double chartWidth,
    required double viewportWidth,
    required List<double> xFractions,
  }) {
    final lastFraction = xFractions.isEmpty ? 1.0 : xFractions.last;
    final focusKey =
        '${chartWidth.toStringAsFixed(1)}|${viewportWidth.toStringAsFixed(1)}|${lastFraction.toStringAsFixed(4)}|$fullscreen';
    final currentKey = fullscreen
        ? _historyChartFullscreenFocusKey
        : _historyChartFocusKey;
    if (currentKey == focusKey) {
      return;
    }
    if (fullscreen) {
      _historyChartFullscreenFocusKey = focusKey;
    } else {
      _historyChartFocusKey = focusKey;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!controller.hasClients) return;
      const rightPad = 12.0;
      final plotWidth = math.max(
        0.0,
        chartWidth - _liveChartLeftPad - rightPad,
      );
      final currentPointX = _liveChartLeftPad + (plotWidth * lastFraction);
      final visibleWidth = math.max(0.0, viewportWidth - _liveChartLeftPad);
      final targetX = math.max(
        _liveChartLeftPad + 24,
        _liveChartLeftPad + visibleWidth - 72,
      );
      final targetOffset = (currentPointX - targetX).clamp(
        0.0,
        controller.position.maxScrollExtent,
      );
      controller.jumpTo(targetOffset);
    });
  }

  Duration _gridDurationForHistorySelection(
    _HistoryRange range,
    _HistoricalBucketOption option,
  ) {
    switch (range) {
      case _HistoryRange.h3:
        switch (option) {
          case _HistoricalBucketOption.h12:
            return const Duration(hours: 12);
          case _HistoricalBucketOption.h6:
            return const Duration(hours: 6);
          case _HistoricalBucketOption.h3:
            return const Duration(hours: 3);
          case _HistoricalBucketOption.min20:
          case _HistoricalBucketOption.h1:
            return const Duration(hours: 3);
        }
      case _HistoryRange.h1:
        switch (option) {
          case _HistoricalBucketOption.h3:
            return const Duration(hours: 3);
          case _HistoricalBucketOption.h1:
            return const Duration(hours: 1);
          case _HistoricalBucketOption.min20:
            return const Duration(minutes: 20);
          case _HistoricalBucketOption.h6:
          case _HistoricalBucketOption.h12:
            return const Duration(hours: 1);
        }
    }
  }

  Duration _arrowDurationForHistorySelection(
    _HistoryRange range,
    _HistoricalBucketOption option,
  ) {
    switch (range) {
      case _HistoryRange.h3:
        switch (option) {
          case _HistoricalBucketOption.h12:
            return const Duration(hours: 6);
          case _HistoricalBucketOption.h6:
            return const Duration(hours: 3);
          case _HistoricalBucketOption.h3:
            return const Duration(hours: 3);
          case _HistoricalBucketOption.min20:
          case _HistoricalBucketOption.h1:
            return const Duration(hours: 1);
        }
      case _HistoryRange.h1:
        switch (option) {
          case _HistoricalBucketOption.h3:
            return const Duration(hours: 1);
          case _HistoricalBucketOption.h1:
            return const Duration(minutes: 30);
          case _HistoricalBucketOption.min20:
            return const Duration(minutes: 5);
          case _HistoricalBucketOption.h6:
          case _HistoricalBucketOption.h12:
            return const Duration(hours: 1);
        }
    }
  }

  int _maxBucketCountForHistorySelection(
    _HistoryRange range,
    Duration arrowDuration,
  ) {
    final totalMinutes = _durationForRange(range).inMinutes;
    final bucketMinutes = math.max(1, arrowDuration.inMinutes);
    return (totalMinutes / bucketMinutes).ceil();
  }

  ({DateTime startInclusive, DateTime endExclusive})
  _alignedIntradayWindowBounds(
    List<_HistoricalWindPoint> points,
    Duration bucket,
  ) {
    final endExclusive = _alignBucketStart(
      points.last.time,
      bucket,
    ).add(bucket);
    return (
      startInclusive: endExclusive.subtract(_durationForRange(_historyRange)),
      endExclusive: endExclusive,
    );
  }

  double _timeFraction(
    DateTime time, {
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) {
    final totalMs = endExclusive.difference(startInclusive).inMilliseconds;
    if (totalMs <= 0) {
      return 0;
    }
    final elapsedMs = time.difference(startInclusive).inMilliseconds;
    return (elapsedMs / totalMs).clamp(0.0, 1.0);
  }

  List<double> _timeFractionsForPoints(
    List<_HistoricalWindPoint> points, {
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) {
    return points
        .map(
          (point) => _timeFraction(
            point.time,
            startInclusive: startInclusive,
            endExclusive: endExclusive,
          ),
        )
        .toList(growable: false);
  }

  List<_ChartTimeGuide> _gridTimeGuides({
    required DateTime startInclusive,
    required DateTime endExclusive,
    required Duration gridStep,
  }) {
    final guides = <_ChartTimeGuide>[];
    var cursor = _alignBucketStart(startInclusive, gridStep);
    if (cursor.isBefore(startInclusive)) {
      cursor = cursor.add(gridStep);
    }
    for (; !cursor.isAfter(endExclusive); cursor = cursor.add(gridStep)) {
      final isHour = cursor.minute == 0;
      final isMajor = gridStep.inMinutes >= 60 ? true : isHour;
      final showsEveryTwentyMinutes = gridStep.inMinutes == 20;
      guides.add(
        _ChartTimeGuide(
          xFraction: _timeFraction(
            cursor,
            startInclusive: startInclusive,
            endExclusive: endExclusive,
          ),
          isMajor: isMajor,
          label: showsEveryTwentyMinutes
              ? '${cursor.hour.toString().padLeft(2, '0')}:${cursor.minute.toString().padLeft(2, '0')}'
              : isMajor
              ? '${cursor.hour.toString().padLeft(2, '0')}h'
              : null,
        ),
      );
    }
    return guides;
  }

  ({
    List<double> points,
    List<double?>? gust,
    List<String> labels,
    List<double> xFractions,
    List<int?> directions,
    List<_HistoricalDirectionKind?> directionKinds,
    List<_ChartArrowMarker> overlayMarkers,
    List<_ChartTimeGuide> timeGuides,
    List<int> dayStartIndexes,
    List<String> dayStartLabels,
    List<double?>? forecast,
    bool intraday,
    String intervalLabel,
    String? diagnosticLabel,
  })
  _historySeriesWindowed() {
    final prepared = _prepareHistorySeriesWindow();
    final intraday = prepared.intraday;
    final selectedBucketOption = prepared.selectedBucketOption;
    final gridDuration = prepared.gridDuration;
    final arrowDuration = prepared.arrowDuration;
    final intradayBounds = prepared.intradayBounds;
    final boundedTrimmed = prepared.points;
    final points = boundedTrimmed
        .map((point) => point.windKnots)
        .toList(growable: false);
    final gust = boundedTrimmed
        .map((point) => point.gustKnots)
        .toList(growable: false);
    final labels = boundedTrimmed
        .map((point) => _formatHistoricalLabel(point, intraday: intraday))
        .toList(growable: false);
    final xFractions = intraday && intradayBounds != null
        ? _timeFractionsForPoints(
            boundedTrimmed,
            startInclusive: intradayBounds.startInclusive,
            endExclusive: intradayBounds.endExclusive,
          )
        : List<double>.generate(
            boundedTrimmed.length,
            (index) => boundedTrimmed.length <= 1
                ? 0
                : index / (boundedTrimmed.length - 1),
            growable: false,
          );
    final directions = boundedTrimmed
        .map((point) => point.windDirectionDeg)
        .toList(growable: false);
    final directionKinds = boundedTrimmed
        .map((point) => point.directionKind)
        .toList(growable: false);
    final overlayMarkers = const <_ChartArrowMarker>[];
    final timeGuides = intraday && intradayBounds != null
        ? _gridTimeGuides(
            startInclusive: intradayBounds.startInclusive,
            endExclusive: intradayBounds.endExclusive,
            gridStep: gridDuration,
          )
        : const <_ChartTimeGuide>[];
    final dayStartIndexes = <int>[];
    final dayStartLabels = <String>[];
    final diagnosticLabel = null;
    final forecast = _forecastSeriesForHistoricalPoints(
      boundedTrimmed,
      bucketDuration: arrowDuration,
    );
    DateTime? previous;
    for (var i = 0; i < boundedTrimmed.length; i++) {
      final current = boundedTrimmed[i].time;
      final isNewDay =
          previous == null ||
          previous.year != current.year ||
          previous.month != current.month ||
          previous.day != current.day;
      if (isNewDay) {
        dayStartIndexes.add(i);
        dayStartLabels.add(
          '${current.day.toString().padLeft(2, '0')}/${current.month.toString().padLeft(2, '0')}',
        );
      }
      previous = current;
    }
    return (
      points: points,
      gust: gust.any((value) => value != null) ? gust : null,
      labels: labels,
      xFractions: xFractions,
      directions: directions,
      directionKinds: directionKinds,
      overlayMarkers: overlayMarkers,
      timeGuides: timeGuides,
      dayStartIndexes: dayStartIndexes,
      dayStartLabels: dayStartLabels,
      forecast: forecast,
      intraday: intraday,
      intervalLabel: intraday
          ? _historicalBucketOptionLabel(selectedBucketOption!)
          : '1 d',
      diagnosticLabel: diagnosticLabel,
    );
  }

  ({
    List<_HistoricalWindPoint> realHistory,
    bool intraday,
    _HistoricalBucketOption? selectedBucketOption,
    Duration gridDuration,
    Duration arrowDuration,
    ({DateTime startInclusive, DateTime endExclusive})? intradayBounds,
    List<_HistoricalWindPoint> points,
  })
  _prepareHistorySeriesWindow() {
    final realHistory = _selectedHistoricalWindPoints();
    final intraday = _isIntradayHistoricalSeries(realHistory);
    final selectedBucketOption = intraday
        ? _selectedBucketOption(_historyRange)
        : null;
    final gridDuration = intraday
        ? _gridDurationForHistorySelection(_historyRange, selectedBucketOption!)
        : const Duration(days: 1);
    final arrowDuration = intraday
        ? _arrowDurationForHistorySelection(
            _historyRange,
            selectedBucketOption!,
          )
        : const Duration(days: 1);
    final alignmentDuration =
        intraday && arrowDuration.inMinutes < gridDuration.inMinutes
        ? arrowDuration
        : gridDuration;
    final intradayBounds = intraday
        ? _alignedIntradayWindowBounds(realHistory, alignmentDuration)
        : null;
    final windowed = _windowHistoricalPoints(
      realHistory,
      intradayBucket: intraday ? alignmentDuration : null,
    );
    final trimmed = intraday
        ? _bucketHistoricalPoints(
            windowed,
            bucket: arrowDuration,
            representativeWhenMultiple: false,
          )
        : windowed;
    final boundedTrimmed = intraday
        ? trimmed.length >
                  _maxBucketCountForHistorySelection(
                    _historyRange,
                    arrowDuration,
                  )
              ? trimmed.sublist(
                  trimmed.length -
                      _maxBucketCountForHistorySelection(
                        _historyRange,
                        arrowDuration,
                      ),
                )
              : trimmed
        : trimmed;
    return (
      realHistory: realHistory,
      intraday: intraday,
      selectedBucketOption: selectedBucketOption,
      gridDuration: gridDuration,
      arrowDuration: arrowDuration,
      intradayBounds: intradayBounds,
      points: boundedTrimmed,
    );
  }

  bool _supportsHistoricalForecastOverlay({
    required String provider,
    required String model,
  }) {
    return _historyForecastModelsForProvider(provider).contains(model);
  }

  List<_ForecastRow> _historicalForecastOverlayRows() {
    final latestResult = _historyForecastRowsResult;
    if (latestResult == null ||
        latestResult.source != _ForecastDataSource.live ||
        latestResult.rows.isEmpty ||
        !_supportsHistoricalForecastOverlay(
          provider: _historyForecastProvider,
          model: _historyForecastModel,
        )) {
      return const <_ForecastRow>[];
    }
    final rows = List<_ForecastRow>.from(latestResult.rows)
      ..sort((a, b) => a.slotTime.compareTo(b.slotTime));
    return rows;
  }

  List<double?>? _forecastSeriesForHistoricalPoints(
    List<_HistoricalWindPoint> points, {
    required Duration bucketDuration,
  }) {
    if (points.isEmpty) {
      return null;
    }
    if (_usesFixedAemetOlivaHistoryWindow()) {
      // AEMET Oliva exposes a past-looking hourly history window, while the
      // forecast rows are future-looking from "now". Overlaying both only
      // paints a tiny edge segment and suggests a false 24h comparison.
      return null;
    }
    final rows = _historicalForecastOverlayRows();
    if (rows.isEmpty) {
      return null;
    }
    final values = points
        .map(
          (point) => _forecastWindForTime(
            point.time,
            rows,
            bucketDuration: bucketDuration,
          ),
        )
        .toList(growable: false);
    if (!values.any((value) => value != null)) {
      return null;
    }
    return values;
  }

  _HistoricalForecastAccuracySummary? _historicalForecastAccuracySummary({
    required List<_HistoricalWindPoint> points,
    required Duration bucketDuration,
  }) {
    if (points.isEmpty || _usesFixedAemetOlivaHistoryWindow()) {
      return null;
    }
    final rows = _historicalForecastOverlayRows();
    if (rows.isEmpty) {
      return null;
    }

    var speedMatched = 0;
    var speedComparable = 0;
    var directionMatched = 0;
    var directionComparable = 0;
    var combinedMatched = 0;
    var combinedComparable = 0;
    var absoluteErrorSum = 0.0;

    for (final point in points) {
      final forecastWind = _forecastWindForTime(
        point.time,
        rows,
        bucketDuration: bucketDuration,
      );
      final forecastDirection = _forecastDirectionForTime(
        point.time,
        rows,
        bucketDuration: bucketDuration,
      );

      final hasSpeed = forecastWind != null;
      final hasDirection =
          forecastDirection != null && point.windDirectionDeg != null;

      var speedHit = false;
      var directionHit = false;

      if (hasSpeed) {
        final error = (forecastWind - point.windKnots).abs();
        absoluteErrorSum += error;
        speedComparable += 1;
        speedHit = error <= 2.0;
        if (speedHit) {
          speedMatched += 1;
        }
      }

      if (hasDirection) {
        final error = _angularDifferenceDegrees(
          forecastDirection,
          point.windDirectionDeg!,
        );
        directionComparable += 1;
        directionHit = error <= 30;
        if (directionHit) {
          directionMatched += 1;
        }
      }

      if (hasSpeed && hasDirection) {
        combinedComparable += 1;
        if (speedHit && directionHit) {
          combinedMatched += 1;
        }
      }
    }

    if (speedComparable == 0 && directionComparable == 0) {
      return null;
    }

    return _HistoricalForecastAccuracySummary(
      totalPercentage: (speedComparable + directionComparable) == 0
          ? null
          : (((speedMatched + directionMatched) /
                        (speedComparable + directionComparable)) *
                    100)
                .round(),
      windPercentage: speedComparable == 0
          ? null
          : ((speedMatched / speedComparable) * 100).round(),
      windMatchedPoints: speedMatched,
      windComparablePoints: speedComparable,
      directionPercentage: directionComparable == 0
          ? null
          : ((directionMatched / directionComparable) * 100).round(),
      directionMatchedPoints: directionMatched,
      directionComparablePoints: directionComparable,
      combinedPercentage: combinedComparable == 0
          ? null
          : ((combinedMatched / combinedComparable) * 100).round(),
      combinedMatchedPoints: combinedMatched,
      combinedComparablePoints: combinedComparable,
      meanAbsoluteErrorKnots: speedComparable == 0
          ? null
          : absoluteErrorSum / speedComparable,
    );
  }

  double? _forecastWindForTime(
    DateTime target,
    List<_ForecastRow> rows, {
    required Duration bucketDuration,
  }) {
    if (rows.isEmpty) {
      return null;
    }
    final edgeTolerance = Duration(
      minutes: math.max(bucketDuration.inMinutes, 60),
    );
    if (rows.length == 1) {
      final diff = rows.first.slotTime.difference(target).abs();
      return diff <= edgeTolerance ? rows.first.windKnots.toDouble() : null;
    }

    if (target.isBefore(rows.first.slotTime)) {
      final diff = rows.first.slotTime.difference(target);
      return diff <= edgeTolerance ? rows.first.windKnots.toDouble() : null;
    }

    for (var i = 1; i < rows.length; i++) {
      final previous = rows[i - 1];
      final current = rows[i];
      if (target.isAtSameMomentAs(previous.slotTime)) {
        return previous.windKnots.toDouble();
      }
      if (target.isAtSameMomentAs(current.slotTime)) {
        return current.windKnots.toDouble();
      }
      if (target.isBefore(current.slotTime)) {
        final totalMillis = current.slotTime
            .difference(previous.slotTime)
            .inMilliseconds;
        if (totalMillis <= 0) {
          return current.windKnots.toDouble();
        }
        final elapsedMillis = target
            .difference(previous.slotTime)
            .inMilliseconds;
        final ratio = (elapsedMillis / totalMillis).clamp(0.0, 1.0);
        return previous.windKnots +
            ((current.windKnots - previous.windKnots) * ratio);
      }
    }

    final trailingDiff = target.difference(rows.last.slotTime);
    return trailingDiff <= edgeTolerance
        ? rows.last.windKnots.toDouble()
        : null;
  }

  int? _forecastDirectionForTime(
    DateTime target,
    List<_ForecastRow> rows, {
    required Duration bucketDuration,
  }) {
    if (rows.isEmpty) {
      return null;
    }
    final edgeTolerance = Duration(
      minutes: math.max(bucketDuration.inMinutes, 60),
    );
    _ForecastRow? nearest;
    var nearestDiff = Duration(days: 365);
    for (final row in rows) {
      final diff = row.slotTime.difference(target).abs();
      if (diff < nearestDiff) {
        nearest = row;
        nearestDiff = diff;
      }
    }
    if (nearest == null || nearestDiff > edgeTolerance) {
      return null;
    }
    return nearest.windDeg;
  }

  int _angularDifferenceDegrees(int a, int b) {
    final diff = (a - b).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }

  Widget _buildInteractiveHistoryChart({
    required List<double> points,
    required List<double?>? gustPoints,
    required List<String> labels,
    required List<double> xFractions,
    required List<int?> directionDegs,
    required List<_HistoricalDirectionKind?> directionKinds,
    required List<_ChartArrowMarker> overlayMarkers,
    required List<_ChartTimeGuide> timeGuides,
    required List<int> dayStartIndexes,
    required List<String> dayStartLabels,
    required List<double?>? forecastPoints,
    required ScrollController scrollController,
    required bool fullscreen,
    double? fixedHeight,
  }) {
    const yAxisWidth = _liveChartLeftPad;
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = math.max(
          constraints.maxWidth,
          (math.max(points.length, timeGuides.length) * 20.0) + 90,
        );
        final chartHeight = fixedHeight ?? constraints.maxHeight;

        final realLineColor = const Color(0xFF1F1F8F);
        final gustLineColor = const Color(0xFFC2185B);
        final forecastLineColor = const Color(0xFFD84315);
        final gridMajorColor = Theme.of(
          context,
        ).colorScheme.outline.withValues(alpha: 0.35);
        final gridMinorColor = Theme.of(
          context,
        ).colorScheme.outline.withValues(alpha: 0.16);
        final textColor = Theme.of(context).colorScheme.onSurface;
        final surfaceColor = Theme.of(context).colorScheme.surface;

        _scheduleHistoryChartFocus(
          controller: scrollController,
          fullscreen: fullscreen,
          chartWidth: chartWidth,
          viewportWidth: constraints.maxWidth,
          xFractions: xFractions,
        );

        return Stack(
          children: [
            ClipRect(
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: chartWidth,
                  height: chartHeight,
                  child: CustomPaint(
                    painter: _LiveWindChartPainter(
                      points: points,
                      gustPoints: gustPoints,
                      timeLabels: labels,
                      pointXFractions: xFractions,
                      markerDirectionsDeg: directionDegs,
                      markerDirectionKinds: directionKinds,
                      overlayMarkers: overlayMarkers,
                      timeGuides: timeGuides,
                      dayStartIndexes: dayStartIndexes,
                      dayStartLabels: dayStartLabels,
                      forecastPoints: forecastPoints,
                      realLineColor: realLineColor,
                      gustLineColor: gustLineColor,
                      forecastLineColor: forecastLineColor,
                      gridMajorColor: gridMajorColor,
                      gridMinorColor: gridMinorColor,
                      textColor: textColor,
                      windSpeedUnit: _windSpeedUnit,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: yAxisWidth,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _LiveWindYAxisPainter(
                    points: points,
                    gustPoints: gustPoints,
                    forecastPoints: forecastPoints,
                    gridMajorColor: gridMajorColor,
                    gridMinorColor: gridMinorColor,
                    textColor: textColor,
                    backgroundColor: surfaceColor,
                    windSpeedUnit: _windSpeedUnit,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openHistoricalChartFullscreen() async {
    final series = _historySeriesWindowed();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text('Historico · ${_selectedStationName()}')),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HistoricalChartLegend(
                  showGust: series.gust != null,
                  showForecast: series.forecast != null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: _buildInteractiveHistoryChart(
                    points: series.points,
                    gustPoints: series.gust,
                    labels: series.labels,
                    xFractions: series.xFractions,
                    directionDegs: series.directions,
                    directionKinds: series.directionKinds,
                    overlayMarkers: series.overlayMarkers,
                    timeGuides: series.timeGuides,
                    dayStartIndexes: series.dayStartIndexes,
                    dayStartLabels: series.dayStartLabels,
                    forecastPoints: series.forecast,
                    scrollController: _historyChartFullscreenScrollController,
                    fullscreen: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoricalChart() {
    if (!_hasRealHistoricalSeries()) {
      final sourceLabel = _historicalSeriesDisplayLabel();
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historico $sourceLabel no disponible · ${_selectedStationName()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Este bloque solo se muestra cuando hay historico real cargado para la estacion seleccionada.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    _ensureHistoryForecastRowsLoaded();
    final series = _historySeriesWindowed();
    final preparedHistory = _prepareHistorySeriesWindow();
    final intraday = series.intraday;
    final diagnosticLabel = series.diagnosticLabel;
    final historyProviderLabel = _historicalSeriesDisplayLabel();
    final usesFixedAemetOlivaWindow = _usesFixedAemetOlivaHistoryWindow();
    final showsHistoricalForecastSelectors = series.forecast != null;
    final historicalCoverageLabel = _historicalCoverageLabel(
      _selectedHistoricalWindPoints(),
    );
    final forecastAccuracy = _historicalForecastAccuracySummary(
      points: preparedHistory.points,
      bucketDuration: preparedHistory.arrowDuration,
    );
    final availableRanges = _supportsThreeDayHistoryForSelectedStation()
        ? const <_HistoryRange>[_HistoryRange.h1, _HistoryRange.h3]
        : const <_HistoryRange>[_HistoryRange.h1];
    if (!availableRanges.contains(_historyRange)) {
      _historyRange = _HistoryRange.h1;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${intraday ? 'Historico intradia $historyProviderLabel' : 'Historico diario $historyProviderLabel'} · ${_selectedStationName()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (diagnosticLabel != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                diagnosticLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            if (usesFixedAemetOlivaWindow)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  historicalCoverageLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<_HistoryRange>(
                  segments: availableRanges
                      .map(
                        (range) => ButtonSegment<_HistoryRange>(
                          value: range,
                          label: Text(_historyRangeLabel(range)),
                        ),
                      )
                      .toList(growable: false),
                  selected: {_historyRange},
                  onSelectionChanged: (value) =>
                      _handleHistoryRangeChanged(value.first),
                ),
              ),
            if (intraday && !usesFixedAemetOlivaWindow) ...[
              const SizedBox(height: AppSpacing.xs),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<_HistoricalBucketOption>(
                  segments: _availableBucketOptions(_historyRange)
                      .map(
                        (option) => ButtonSegment<_HistoricalBucketOption>(
                          value: option,
                          label: Text(_historicalBucketOptionLabel(option)),
                        ),
                      )
                      .toList(growable: false),
                  selected: {_selectedBucketOption(_historyRange)},
                  onSelectionChanged: (value) =>
                      _handleHistoricalBucketOptionChanged(value.first),
                ),
              ),
            ],
            if (showsHistoricalForecastSelectors) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 170,
                    child: DropdownButtonFormField<String>(
                      initialValue: _historyForecastProvider,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Proveedor forecast',
                        isDense: true,
                      ),
                      items: _historyForecastProviders()
                          .map(
                            (provider) => DropdownMenuItem<String>(
                              value: provider,
                              child: Text(provider),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null ||
                            value == _historyForecastProvider) {
                          return;
                        }
                        _handleHistoryForecastProviderChanged(value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    child: DropdownButtonFormField<String>(
                      initialValue: _historyForecastModel,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Modelo forecast',
                        isDense: true,
                      ),
                      items:
                          _historyForecastModelsForProvider(
                                _historyForecastProvider,
                              )
                              .map((model) {
                                return DropdownMenuItem<String>(
                                  value: model,
                                  child: Text(model),
                                );
                              })
                              .toList(growable: false),
                      onChanged: (value) {
                        if (value == null || value == _historyForecastModel) {
                          return;
                        }
                        _handleHistoryForecastModelChanged(value);
                      },
                    ),
                  ),
                ],
              ),
            ],
            if (forecastAccuracy != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ForecastAccuracyCard(
                totalPercentage: forecastAccuracy.totalPercentage,
                windPercentage: forecastAccuracy.windPercentage,
                directionPercentage: forecastAccuracy.directionPercentage,
                meanAbsoluteErrorKnots: forecastAccuracy.meanAbsoluteErrorKnots,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            _HistoricalChartLegend(
              showGust: series.gust != null,
              showForecast: series.forecast != null,
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 420,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildInteractiveHistoryChart(
                      points: series.points,
                      gustPoints: series.gust,
                      labels: series.labels,
                      xFractions: series.xFractions,
                      directionDegs: series.directions,
                      directionKinds: series.directionKinds,
                      overlayMarkers: series.overlayMarkers,
                      timeGuides: series.timeGuides,
                      dayStartIndexes: series.dayStartIndexes,
                      dayStartLabels: series.dayStartLabels,
                      forecastPoints: series.forecast,
                      scrollController: _historyChartScrollController,
                      fullscreen: false,
                      fixedHeight: 420,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      elevation: 2,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Refrescar grafica',
                        onPressed: _isHistoricalRefreshing
                            ? null
                            : _refreshHistoricalChartData,
                        icon: _isHistoricalRefreshing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      elevation: 2,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Pantalla completa',
                        onPressed: _openHistoricalChartFullscreen,
                        icon: const Icon(Icons.fullscreen_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAlarmsSection() {
    final catalog = SpotAlarmCatalog.instance;
    final spotKey = _currentSpotAlarmKey();
    final alarmStations = _resolvedNearbyStations().map(_stationKey).toList();
    if (!alarmStations.contains(_alarmStation) && alarmStations.isNotEmpty) {
      _alarmStation = alarmStations.first;
    }
    final savedAlarms = _savedAlarmsForCurrentSpot();
    final spotEnabled = catalog.isSpotEnabled(spotKey);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.9),
                    colorScheme.secondaryContainer.withValues(alpha: 0.75),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.72),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alarmas personalizadas',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          spotEnabled
                              ? 'Spot activo para alertas'
                              : 'Spot desactivado para alertas',
                          style: textTheme.bodySmall?.copyWith(
                            color: spotEnabled
                                ? const Color(0xFF2E7D32)
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: spotEnabled,
                    onChanged: (value) async {
                      await catalog.setSpotEnabled(spotKey, value);
                      if (!mounted) {
                        return;
                      }
                      setState(() {});
                      if (catalog.lastSyncError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'No se pudo sincronizar el estado de alarmas: ${catalog.lastSyncError}',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.42,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.55),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Nueva alarma',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: _alarmStation,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Estacion meteorologica',
                      border: OutlineInputBorder(),
                    ),
                    items: alarmStations
                        .map(
                          (station) => DropdownMenuItem(
                            value: station,
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                _stationLabelForKey(station),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (context) {
                      return alarmStations
                          .map(
                            (station) => Text(
                              _stationLabelForKey(station),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                          .toList();
                    },
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _alarmStation = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickAlarmTime(isStart: true),
                          icon: const Icon(Icons.schedule_rounded),
                          label: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Desde'),
                              Text(
                                _formatAlarmTime(
                                  _alarmStartHour,
                                  _alarmStartMinute,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickAlarmTime(isStart: false),
                          icon: const Icon(Icons.schedule_rounded),
                          label: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hasta'),
                              Text(
                                _formatAlarmTime(
                                  _alarmEndHour,
                                  _alarmEndMinute,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.55,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Rango de viento · ${_formatAlarmWindRange(_alarmWindRange)}',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  RangeSlider(
                    min: 4,
                    max: 40,
                    divisions: 36,
                    values: _alarmWindRange,
                    labels: RangeLabels(
                      _formatAlarmWindValue(_alarmWindRange.start),
                      _formatAlarmWindValue(_alarmWindRange.end),
                    ),
                    onChanged: (values) {
                      setState(() {
                        _alarmWindRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Direcciones activas',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      FilterChip(
                        label: const Text('Todas'),
                        selected:
                            _alarmDirections.length ==
                            _alarmDirectionOptions.length,
                        showCheckmark: false,
                        onSelected: (_) {
                          setState(() {
                            final allSelected =
                                _alarmDirections.length ==
                                _alarmDirectionOptions.length;
                            _alarmDirections = allSelected
                                ? <String>{}
                                : _alarmDirectionOptions.toSet();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final rows = <List<String>>[
                        _alarmDirectionOptions.sublist(0, 4),
                        _alarmDirectionOptions.sublist(4, 8),
                      ];
                      return Column(
                        children: rows
                            .map((row) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: row == rows.last ? 0 : AppSpacing.xs,
                                ),
                                child: Row(
                                  children: row
                                      .map((direction) {
                                        final selected = _alarmDirections
                                            .contains(direction);
                                        return Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              right: direction == row.last
                                                  ? 0
                                                  : AppSpacing.xs,
                                            ),
                                            child: FilterChip(
                                              showCheckmark: false,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              labelPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                  ),
                                              label: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Transform.rotate(
                                                      angle:
                                                          _alarmDirectionRotation(
                                                            direction,
                                                          ),
                                                      child: Icon(
                                                        Icons
                                                            .navigation_rounded,
                                                        size: 14,
                                                        color: selected
                                                            ? colorScheme
                                                                  .onSecondaryContainer
                                                            : colorScheme
                                                                  .onSurfaceVariant,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      direction,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              selected: selected,
                                              onSelected: (value) {
                                                setState(() {
                                                  if (value) {
                                                    _alarmDirections = <String>{
                                                      ..._alarmDirections,
                                                      direction,
                                                    };
                                                  } else {
                                                    _alarmDirections =
                                                        _alarmDirections
                                                            .where(
                                                              (entry) =>
                                                                  entry !=
                                                                  direction,
                                                            )
                                                            .toSet();
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      })
                                      .toList(growable: false),
                                ),
                              );
                            })
                            .toList(growable: false),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<AlarmRepeatWindow>(
                    initialValue: _alarmRepeatWindow,
                    decoration: const InputDecoration(
                      labelText: 'Repetir cada',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: AlarmRepeatWindow.min1,
                        child: Text('1 min'),
                      ),
                      DropdownMenuItem(
                        value: AlarmRepeatWindow.min5,
                        child: Text('5 min'),
                      ),
                      DropdownMenuItem(
                        value: AlarmRepeatWindow.min10,
                        child: Text('10 min'),
                      ),
                      DropdownMenuItem(
                        value: AlarmRepeatWindow.min15,
                        child: Text('15 min'),
                      ),
                      DropdownMenuItem(
                        value: AlarmRepeatWindow.min30,
                        child: Text('30 min'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _alarmRepeatWindow = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<int>(
                    initialValue: _alarmMaxRepeats,
                    decoration: const InputDecoration(
                      labelText: 'Maximo de avisos seguidos',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(6, (index) {
                      final value = index + 1;
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value aviso${value == 1 ? '' : 's'}'),
                      );
                    }),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _alarmMaxRepeats = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final wasEditing = _editingAlarmId != null;
                        if (_alarmDirections.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Selecciona al menos una direccion para la alarma.',
                              ),
                            ),
                          );
                          return;
                        }
                        final stationName = _stationDisplayName(_alarmStation);
                        final stationProvider =
                            _findStationByKey(_alarmStation)?.provider ?? '';
                        final alarm = SpotAlarmRecord(
                          id:
                              _editingAlarmId ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          spotKey: spotKey,
                          spotName: widget.name,
                          spotArea: widget.area,
                          stationProvider: stationProvider,
                          stationKey: _alarmStation,
                          stationName: stationName,
                          windRange: _alarmWindRange,
                          startHour: _alarmStartHour,
                          endHour: _alarmEndHour,
                          startMinute: _alarmStartMinute,
                          endMinute: _alarmEndMinute,
                          directions: _alarmDirections,
                          repeatWindow: _alarmRepeatWindow,
                          maxRepeats: _alarmMaxRepeats,
                        );
                        final duplicateExists = catalog.hasEquivalentAlarm(
                          alarm,
                          excludingId: _editingAlarmId,
                        );
                        if (duplicateExists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Ya existe una alarma identica para esta estacion.',
                              ),
                            ),
                          );
                          return;
                        }
                        final saved = await catalog.saveAlarm(alarm);
                        if (!mounted) {
                          return;
                        }
                        setState(() {
                          _editingAlarmId = null;
                          _syncAlarmMonitoring();
                        });
                        if (!wasEditing) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nueva alarma creada.'),
                            ),
                          );
                        }
                        if (!saved) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'La alarma se guardo localmente, pero no se pudo sincronizar: ${catalog.lastSyncError ?? 'error desconocido'}',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.alarm_add_rounded),
                      label: Text(
                        _editingAlarmId == null
                            ? 'Guardar alarma'
                            : 'Guardar cambios',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.alarm_add_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Alarmas guardadas',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (savedAlarms.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Todavia no hay alarmas guardadas para este spot.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(savedAlarms.length, (index) {
                final alarm = savedAlarms[index];
                final evaluation = _evaluateAlarm(alarm);
                final evaluationColor = _alarmEvaluationColor(
                  context,
                  evaluation,
                );
                final statusBackground = evaluationColor.withValues(
                  alpha: 0.12,
                );
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    bottom: index == savedAlarms.length - 1 ? 0 : AppSpacing.sm,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alarm.stationName,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBackground,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        switch (evaluation.state) {
                                          _AlarmEvaluationState.active =>
                                            Icons.notifications_active_rounded,
                                          _AlarmEvaluationState.partial =>
                                            Icons.timelapse_rounded,
                                          _AlarmEvaluationState.idle =>
                                            Icons.notifications_paused_rounded,
                                          _AlarmEvaluationState.noData =>
                                            Icons.error_outline_rounded,
                                          _AlarmEvaluationState.disabled =>
                                            Icons.notifications_off_rounded,
                                        },
                                        size: 16,
                                        color: evaluationColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          evaluation.label,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: evaluationColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Column(
                            children: [
                              IconButton(
                                tooltip: 'Editar',
                                onPressed: () {
                                  setState(() {
                                    _editingAlarmId = alarm.id;
                                    _alarmStation = alarm.stationKey;
                                    _alarmWindRange = alarm.windRange;
                                    _alarmRepeatWindow = alarm.repeatWindow;
                                    _alarmMaxRepeats = alarm.maxRepeats;
                                    _alarmStartHour = alarm.startHour;
                                    _alarmEndHour = alarm.endHour;
                                    _alarmStartMinute = alarm.startMinute;
                                    _alarmEndMinute = alarm.endMinute;
                                    _alarmDirections = alarm.directions;
                                  });
                                },
                                icon: const Icon(Icons.edit_rounded),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                onPressed: () async {
                                  final confirmed = await _confirmDeleteAlarm(
                                    alarm,
                                  );
                                  if (!confirmed || !mounted) {
                                    return;
                                  }
                                  setState(() {
                                    catalog.deleteAlarm(alarm.id);
                                    if (_editingAlarmId == alarm.id) {
                                      _editingAlarmId = null;
                                    }
                                    _syncAlarmMonitoring();
                                  });
                                },
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _alarmTriggerSummary(alarm),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _AlarmMetaChip(
                            icon: Icons.air_rounded,
                            label: _formatAlarmWindRange(alarm.windRange),
                          ),
                          _AlarmMetaChip(
                            icon: Icons.schedule_rounded,
                            label:
                                '${_formatAlarmTime(alarm.startHour, alarm.startMinute)}-${_formatAlarmTime(alarm.endHour, alarm.endMinute)}',
                          ),
                          _AlarmMetaChip(
                            icon: Icons.navigation_rounded,
                            label: alarm.directions.join('/'),
                          ),
                          _AlarmMetaChip(
                            icon: Icons.repeat_rounded,
                            label: _alarmRepeatWindowLabel(alarm.repeatWindow),
                          ),
                          _AlarmMetaChip(
                            icon: Icons.filter_3_rounded,
                            label: '${alarm.maxRepeats} avisos',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  static const List<String> _alarmDirectionOptions = <String>[
    'N',
    'NE',
    'E',
    'SE',
    'S',
    'SW',
    'W',
    'NW',
  ];

  String _alarmRepeatWindowLabel(AlarmRepeatWindow window) {
    switch (window) {
      case AlarmRepeatWindow.min1:
        return '1 min';
      case AlarmRepeatWindow.min5:
        return '5 min';
      case AlarmRepeatWindow.min10:
        return '10 min';
      case AlarmRepeatWindow.min15:
        return '15 min';
      case AlarmRepeatWindow.min30:
        return '30 min';
    }
  }

  String _formatAlarmTime(int hour, int minute) {
    final safeHour = _sanitizeAlarmHour(hour);
    final safeMinute = _sanitizeAlarmMinute(minute);
    return '${safeHour.toString().padLeft(2, '0')}:${safeMinute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickAlarmTime({required bool isStart}) async {
    final initialTime = TimeOfDay(
      hour: _sanitizeAlarmHour(isStart ? _alarmStartHour : _alarmEndHour),
      minute: _sanitizeAlarmMinute(
        isStart ? _alarmStartMinute : _alarmEndMinute,
      ),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      if (isStart) {
        _alarmStartHour = picked.hour;
        _alarmStartMinute = picked.minute;
      } else {
        _alarmEndHour = picked.hour;
        _alarmEndMinute = picked.minute;
      }
    });
  }

  int _sanitizeAlarmHour(int hour) => hour.clamp(0, 23);

  int _sanitizeAlarmMinute(int minute) => minute.clamp(0, 59);

  bool _isTimeInAlarmRange({
    required int totalMinutes,
    required int startHour,
    required int endHour,
    required int startMinute,
    required int endMinute,
  }) {
    final startTotal = (startHour * 60) + startMinute;
    final endTotal = (endHour * 60) + endMinute;
    if (startTotal == endTotal) {
      return true;
    }
    if (startTotal < endTotal) {
      return totalMinutes >= startTotal && totalMinutes < endTotal;
    }
    return totalMinutes >= startTotal || totalMinutes < endTotal;
  }

  String? _directionBucketLabel(int? directionDeg) {
    if (directionDeg == null) {
      return null;
    }
    final normalized = ((directionDeg % 360) + 360) % 360;
    if (normalized < 23 || normalized >= 338) return 'N';
    if (normalized < 68) return 'NE';
    if (normalized < 113) return 'E';
    if (normalized < 158) return 'SE';
    if (normalized < 203) return 'S';
    if (normalized < 248) return 'SW';
    if (normalized < 293) return 'W';
    return 'NW';
  }

  double _alarmDirectionRotation(String direction) {
    switch (direction) {
      case 'N':
        return 0;
      case 'NE':
        return math.pi / 4;
      case 'E':
        return math.pi / 2;
      case 'SE':
        return (3 * math.pi) / 4;
      case 'S':
        return math.pi;
      case 'SW':
        return (5 * math.pi) / 4;
      case 'W':
        return (3 * math.pi) / 2;
      case 'NW':
        return (7 * math.pi) / 4;
    }
    return 0;
  }

  _AlarmEvaluation _evaluateAlarm(SpotAlarmRecord alarm) {
    final catalog = SpotAlarmCatalog.instance;
    if (!catalog.globalEnabled) {
      return const _AlarmEvaluation(
        state: _AlarmEvaluationState.disabled,
        label: 'Alarmas globales desactivadas',
      );
    }
    if (!catalog.isSpotEnabled(alarm.spotKey)) {
      return const _AlarmEvaluation(
        state: _AlarmEvaluationState.disabled,
        label: 'Alarmas de este spot desactivadas',
      );
    }

    final liveData = _resolvedLiveDataByStation()[alarm.stationKey];
    final currentWind = liveData?.windKnots?.toDouble();
    final currentDirection = _directionBucketLabel(liveData?.windDeg);
    final observedAt = liveData?.observedAt;

    if (liveData == null || observedAt == null || currentWind == null) {
      return const _AlarmEvaluation(
        state: _AlarmEvaluationState.noData,
        label: 'Sin datos live suficientes',
      );
    }

    final timeMatches = _isTimeInAlarmRange(
      totalMinutes: (observedAt.hour * 60) + observedAt.minute,
      startHour: alarm.startHour,
      endHour: alarm.endHour,
      startMinute: alarm.startMinute,
      endMinute: alarm.endMinute,
    );
    final windMatches =
        currentWind >= alarm.windRange.start &&
        currentWind <= alarm.windRange.end;
    final directionMatches =
        currentDirection != null && alarm.directions.contains(currentDirection);

    if (timeMatches && windMatches && directionMatches) {
      return _AlarmEvaluation(
        state: _AlarmEvaluationState.active,
        label:
            'Lista para disparar · repetir ${_alarmRepeatWindowLabel(alarm.repeatWindow)} · ${alarm.triggerCount}/${alarm.maxRepeats}',
      );
    }

    if (windMatches && (timeMatches || directionMatches)) {
      return _AlarmEvaluation(
        state: _AlarmEvaluationState.partial,
        label:
            'Coincidencia parcial · hora ${timeMatches ? "ok" : "no"} · direccion ${directionMatches ? "ok" : "no"}',
      );
    }

    return _AlarmEvaluation(
      state: _AlarmEvaluationState.idle,
      label:
          'No activa ahora · ${_formatAlarmWindValue(currentWind)} · ${currentDirection ?? "sin direccion"}',
    );
  }

  Color _alarmEvaluationColor(
    BuildContext context,
    _AlarmEvaluation evaluation,
  ) {
    switch (evaluation.state) {
      case _AlarmEvaluationState.active:
        return const Color(0xFF2E7D32);
      case _AlarmEvaluationState.partial:
        return const Color(0xFFEF6C00);
      case _AlarmEvaluationState.idle:
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case _AlarmEvaluationState.noData:
        return Theme.of(context).colorScheme.error;
      case _AlarmEvaluationState.disabled:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Future<bool> _confirmDeleteAlarm(SpotAlarmRecord alarm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar alarma'),
          content: Text(
            'Se eliminara la alarma de ${alarm.stationName} para ${widget.name}. Esta accion no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  Future<void> _loadSocialIdentity() async {
    try {
      final profile = await _profileModule.profileController.loadProfile();
      if (!mounted) {
        return;
      }
      setState(() {
        _currentSocialProfile = profile;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _currentSocialProfile = _fallbackSocialProfile;
      });
    }
  }

  Future<void> _loadSocialModerationPermissions() async {
    try {
      final client = Supabase.instance.client;
      if (client.auth.currentUser == null) {
        if (!mounted) {
          return;
        }
        setState(() {
          _canModerateSocialMessages = false;
        });
        return;
      }
      final spotKey = SpotSocialClient.buildSpotKey(
        spotName: widget.name,
        spotArea: widget.area,
      );
      final result = await client.rpc(
        'can_moderate_spot',
        params: <String, dynamic>{'target_spot_key': spotKey},
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _canModerateSocialMessages = result == true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _canModerateSocialMessages = false;
      });
    }
  }

  Future<void> _loadSocialFeed() async {
    if (mounted) {
      setState(() {
        _isSocialLoading = true;
        _socialErrorMessage = null;
      });
    }
    try {
      final posts = await _spotSocialClient.loadPosts(
        spotName: widget.name,
        spotArea: widget.area,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _socialFeed = posts;
      });
      _scheduleScrollSocialFeedToBottom();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _socialErrorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSocialLoading = false;
        });
        if (_section == _SpotDetailSection.social && _socialFeed.isNotEmpty) {
          unawaited(_scrollSocialFeedToBottomAfterLayout());
        }
      }
    }
  }

  Future<void> _scrollSocialFeedToBottomAfterLayout({
    bool animated = false,
  }) async {
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (!_socialFeedScrollController.hasClients) {
        return;
      }
      final targetOffset = _socialFeedScrollController.position.maxScrollExtent;
      if (animated) {
        unawaited(
          _socialFeedScrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
          ),
        );
      } else {
        _socialFeedScrollController.jumpTo(targetOffset);
      }
    });
  }

  void _scheduleEnsureSocialComposerVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final currentContext = _socialComposerKey.currentContext;
      if (currentContext == null) {
        return;
      }
      Scrollable.ensureVisible(
        currentContext,
        alignment: 0.72,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  void _scheduleFocusSocialComposerInput({required bool forReply}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final focusNode = forReply ? _socialReplyFocusNode : _socialPostFocusNode;
      if (!focusNode.canRequestFocus) {
        return;
      }
      focusNode.requestFocus();
    });
  }

  void _scheduleFocusSocialSection() {
    _scheduleScrollSocialFeedToBottom(animated: true);
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (!mounted || _section != _SpotDetailSection.social) {
        return;
      }
      _scheduleEnsureSocialComposerVisible();
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        if (!mounted || _section != _SpotDetailSection.social) {
          return;
        }
        _scheduleScrollSocialFeedToBottom();
      });
    });
  }

  void _scheduleScrollSocialFeedToBottom({bool animated = false}) {
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (!mounted || _section != _SpotDetailSection.social) {
        return;
      }
      unawaited(_scrollSocialFeedToBottomAfterLayout(animated: animated));
    });
  }

  void _setSection(_SpotDetailSection section) {
    if (_section == section) {
      if (section == _SpotDetailSection.social) {
        if (_socialRealtimeSubscription == null) {
          _bindSocialRealtime();
          _bindSocialPresence();
          _bindSocialTyping();
          unawaited(_loadSocialFeed());
        } else {
          _scheduleFocusSocialSection();
        }
      }
      return;
    }
    final previousSection = _section;
    setState(() {
      _section = section;
    });
    if (previousSection == _SpotDetailSection.social &&
        section != _SpotDetailSection.social) {
      _unbindSocialRealtime();
      _unbindSocialPresence();
      unawaited(_broadcastTypingState(isTyping: false));
      _unbindSocialTyping();
    }
    if (section == _SpotDetailSection.social) {
      _bindSocialRealtime();
      _bindSocialPresence();
      _bindSocialTyping();
      unawaited(_loadSocialFeed());
      _scheduleFocusSocialSection();
    }
  }

  String _normalizedSocialUsername() {
    final handle = _currentSocialProfile.handle.trim().replaceFirst('@', '');
    if (handle.isNotEmpty) {
      return handle;
    }
    final displayName = _currentSocialProfile.displayName.trim();
    if (displayName.isNotEmpty) {
      return displayName
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
    }
    return 'rider';
  }

  String _socialDisplayName() {
    final displayName = _currentSocialProfile.displayName.trim();
    if (displayName.isNotEmpty) {
      return displayName;
    }
    final username = _normalizedSocialUsername();
    if (username.isEmpty) {
      return 'Rider';
    }
    return username
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  bool get _canPublishSocial => _spotSocialClient.canWrite;

  bool get _canSendSocialPost =>
      !_isSocialSubmitting &&
      (_socialPostController.text.trim().isNotEmpty ||
          _pendingSocialPostAttachments.isNotEmpty);

  bool get _canSendSocialReply =>
      !_isSocialSubmitting &&
      (_socialReplyController.text.trim().isNotEmpty ||
          _pendingSocialReplyAttachments.isNotEmpty);

  Future<void> _showSocialAttachmentOptions({required bool forReply}) async {
    if (_isPickingSocialMedia || _isSocialSubmitting || !_canPublishSocial) {
      return;
    }
    final selection = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add_a_photo_rounded),
                title: const Text('Tomar foto o video'),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.perm_media_rounded),
                title: const Text('Adjuntar foto o video desde la galeria'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
    if (selection == null) {
      _restoreSocialChatViewport();
      return;
    }
    if (selection == ImageSource.gallery) {
      await _pickSocialMediaFromGallery(forReply: forReply);
      return;
    }
    final captureSelection = await _showSocialCameraCaptureTypeOptions();
    if (captureSelection == null) {
      _restoreSocialChatViewport();
      return;
    }
    await _pickSocialAttachment(
      forReply: forReply,
      isVideo: captureSelection.isVideo,
      source: captureSelection.source,
    );
  }

  Future<_SocialAttachmentSelection?> _showSocialCameraCaptureTypeOptions() {
    return showModalBottomSheet<_SocialAttachmentSelection>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_back_rounded),
                title: const Text('Foto'),
                onTap: () => Navigator.of(sheetContext).pop(
                  const _SocialAttachmentSelection(
                    isVideo: false,
                    source: ImageSource.camera,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.video_call_rounded),
                title: const Text('Video'),
                onTap: () => Navigator.of(sheetContext).pop(
                  const _SocialAttachmentSelection(
                    isVideo: true,
                    source: ImageSource.camera,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickSocialMediaFromGallery({required bool forReply}) async {
    if (_isPickingSocialMedia) {
      return;
    }
    setState(() {
      _isPickingSocialMedia = true;
    });
    try {
      final XFile? picked = await _socialMediaPicker.pickMedia();
      if (picked == null || !mounted) {
        _restoreSocialChatViewport();
        return;
      }
      final fileName = _socialAttachmentFileName(picked);
      final isVideo = _isVideoFileName(fileName);
      final bytes = await picked.readAsBytes();
      final draft = SpotSocialAttachmentDraft(
        type: isVideo
            ? SpotSocialAttachmentType.video
            : SpotSocialAttachmentType.image,
        fileName: fileName,
        bytes: bytes,
        mimeType: _socialAttachmentMimeType(
          isVideo: isVideo,
          fileName: fileName,
        ),
      );
      setState(() {
        final current = List<SpotSocialAttachmentDraft>.from(
          forReply
              ? _pendingSocialReplyAttachments
              : _pendingSocialPostAttachments,
        )..add(draft);
        if (forReply) {
          _pendingSocialReplyAttachments = current;
        } else {
          _pendingSocialPostAttachments = current;
        }
      });
    } catch (_) {
      _showSocialSnackBar('No se pudo adjuntar el archivo seleccionado.');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingSocialMedia = false;
        });
        _restoreSocialChatViewport();
      }
    }
  }

  Future<void> _pickSocialAttachment({
    required bool forReply,
    required bool isVideo,
    required ImageSource source,
  }) async {
    if (_isPickingSocialMedia) {
      return;
    }
    setState(() {
      _isPickingSocialMedia = true;
    });
    try {
      final XFile? picked = isVideo
          ? await _socialMediaPicker.pickVideo(source: source)
          : await _socialMediaPicker.pickImage(source: source);
      if (picked == null || !mounted) {
        _restoreSocialChatViewport();
        return;
      }
      final bytes = await picked.readAsBytes();
      final draft = SpotSocialAttachmentDraft(
        type: isVideo
            ? SpotSocialAttachmentType.video
            : SpotSocialAttachmentType.image,
        fileName: _socialAttachmentFileName(picked),
        bytes: bytes,
        mimeType: _socialAttachmentMimeType(
          isVideo: isVideo,
          fileName: picked.name,
        ),
      );
      setState(() {
        final current = List<SpotSocialAttachmentDraft>.from(
          forReply
              ? _pendingSocialReplyAttachments
              : _pendingSocialPostAttachments,
        )..add(draft);
        if (forReply) {
          _pendingSocialReplyAttachments = current;
        } else {
          _pendingSocialPostAttachments = current;
        }
      });
    } catch (_) {
      _showSocialSnackBar('No se pudo adjuntar el archivo seleccionado.');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingSocialMedia = false;
        });
        _restoreSocialChatViewport();
      }
    }
  }

  String _socialAttachmentFileName(XFile file) {
    final name = file.name.trim();
    if (name.isNotEmpty) {
      return name;
    }
    final path = file.path;
    if (path.isEmpty) {
      return 'adjunto';
    }
    return path.split(RegExp(r'[\\/]')).last;
  }

  String _socialAttachmentMimeType({
    required bool isVideo,
    required String fileName,
  }) {
    final lower = fileName.toLowerCase();
    if (isVideo) {
      if (lower.endsWith('.mov')) return 'video/quicktime';
      if (lower.endsWith('.webm')) return 'video/webm';
      return 'video/mp4';
    }
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  bool _isVideoFileName(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv');
  }

  void _removePendingSocialAttachment({
    required bool forReply,
    required int index,
  }) {
    setState(() {
      final current = List<SpotSocialAttachmentDraft>.from(
        forReply
            ? _pendingSocialReplyAttachments
            : _pendingSocialPostAttachments,
      );
      if (index >= 0 && index < current.length) {
        current.removeAt(index);
      }
      if (forReply) {
        _pendingSocialReplyAttachments = current;
      } else {
        _pendingSocialPostAttachments = current;
      }
    });
  }

  List<SpotSocialAttachment> _optimisticSocialAttachments(
    List<SpotSocialAttachmentDraft> drafts,
  ) {
    return drafts
        .map(
          (draft) => SpotSocialAttachment(
            id: 'local-${DateTime.now().microsecondsSinceEpoch}-${draft.fileName}',
            type: draft.type,
            url: '',
            storagePath: draft.fileName,
            fileName: draft.fileName,
            mimeType: draft.mimeType,
            sizeBytes: draft.bytes.length,
          ),
        )
        .toList(growable: false);
  }

  void _insertOptimisticSocialPost({
    required String tempId,
    required String message,
    required List<SpotSocialAttachmentDraft> attachments,
  }) {
    final optimisticPost = SpotSocialPost(
      id: tempId,
      spotName: widget.name,
      spotArea: widget.area,
      authorUsername: _normalizedSocialUsername(),
      authorDisplayName: _socialDisplayName(),
      message: message,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isMine: true,
      attachments: _optimisticSocialAttachments(attachments),
      replies: const <SpotSocialReply>[],
    );
    setState(() {
      _socialFeed = <SpotSocialPost>[optimisticPost, ..._socialFeed];
    });
    _scheduleFocusSocialSection();
  }

  void _insertOptimisticSocialReply({
    required String tempId,
    required String postId,
    required String? parentReplyId,
    required String message,
    required List<SpotSocialAttachmentDraft> attachments,
  }) {
    final optimisticReply = SpotSocialReply(
      id: tempId,
      postId: postId,
      parentReplyId: parentReplyId,
      authorUsername: _normalizedSocialUsername(),
      authorDisplayName: _socialDisplayName(),
      message: message,
      createdAt: DateTime.now(),
      isMine: true,
      attachments: _optimisticSocialAttachments(attachments),
      replies: const <SpotSocialReply>[],
    );
    setState(() {
      _socialFeed = _socialFeed
          .map((post) {
            if (post.id != postId) {
              return post;
            }
            final nextReplies = List<SpotSocialReply>.from(post.replies);
            if (parentReplyId == null || parentReplyId.isEmpty) {
              nextReplies.add(optimisticReply);
            } else {
              _appendOptimisticNestedReply(
                nextReplies,
                parentReplyId,
                optimisticReply,
              );
            }
            return post.copyWith(replies: nextReplies);
          })
          .toList(growable: false);
    });
    _scheduleFocusSocialSection();
  }

  bool _appendOptimisticNestedReply(
    List<SpotSocialReply> replies,
    String parentReplyId,
    SpotSocialReply optimisticReply,
  ) {
    for (var index = 0; index < replies.length; index += 1) {
      final current = replies[index];
      if (current.id == parentReplyId) {
        final children = List<SpotSocialReply>.from(current.replies)
          ..add(optimisticReply);
        replies[index] = current.copyWith(replies: children);
        return true;
      }
      final children = List<SpotSocialReply>.from(current.replies);
      if (_appendOptimisticNestedReply(
        children,
        parentReplyId,
        optimisticReply,
      )) {
        replies[index] = current.copyWith(replies: children);
        return true;
      }
    }
    return false;
  }

  Future<void> _publishSocialPost() async {
    final text = _socialPostController.text.trim();
    if ((text.isEmpty && _pendingSocialPostAttachments.isEmpty) ||
        _isSocialSubmitting) {
      return;
    }
    if (!_canPublishSocial) {
      _showSocialSnackBar('Inicia sesion para escribir en el chat del spot.');
      return;
    }

    final optimisticAttachments = List<SpotSocialAttachmentDraft>.from(
      _pendingSocialPostAttachments,
    );
    final optimisticTempId =
        'local-post-${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      _isSocialSubmitting = true;
    });
    try {
      if (_editingPostId == null) {
        _insertOptimisticSocialPost(
          tempId: optimisticTempId,
          message: text,
          attachments: optimisticAttachments,
        );
        await _spotSocialClient.addPost(
          spotName: widget.name,
          spotArea: widget.area,
          authorUsername: _normalizedSocialUsername(),
          authorDisplayName: _socialDisplayName(),
          message: text,
          attachments: optimisticAttachments,
        );
      } else {
        await _spotSocialClient.updatePost(
          postId: _editingPostId!,
          message: text,
        );
      }
      _socialPostController.clear();
      _pendingSocialPostAttachments = const <SpotSocialAttachmentDraft>[];
      _editingPostId = null;
      _replyingPostId = null;
      _replyingReplyId = null;
      _socialReplyController.clear();
      _pendingSocialReplyAttachments = const <SpotSocialAttachmentDraft>[];
      await _broadcastTypingState(isTyping: false);
      await _loadSocialFeed();
    } catch (error) {
      await _loadSocialFeed();
      _showSocialSnackBar(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSocialSubmitting = false;
        });
      }
    }
  }

  void _startEditPost(SpotSocialPost post) {
    setState(() {
      _editingPostId = post.id;
      _editingReplyId = null;
      _editingReplyPostId = null;
      _replyingPostId = null;
      _replyingReplyId = null;
      _socialPostController.text = post.message;
      _pendingSocialPostAttachments = const <SpotSocialAttachmentDraft>[];
    });
  }

  void _startEditReply({
    required String postId,
    required SpotSocialReply reply,
  }) {
    setState(() {
      _editingPostId = null;
      _editingReplyId = reply.id;
      _editingReplyPostId = postId;
      _replyingPostId = null;
      _replyingReplyId = null;
      _socialReplyController.text = reply.message;
      _pendingSocialReplyAttachments = const <SpotSocialAttachmentDraft>[];
    });
    _scheduleEnsureSocialComposerVisible();
    _scheduleFocusSocialComposerInput(forReply: true);
  }

  Future<void> _deletePost(SpotSocialPost post) async {
    try {
      await _spotSocialClient.deletePost(postId: post.id);
      if (!mounted) {
        return;
      }
      setState(() {
        if (_editingPostId == post.id) {
          _editingPostId = null;
          _socialPostController.clear();
          _pendingSocialPostAttachments = const <SpotSocialAttachmentDraft>[];
        }
        if (_replyingPostId == post.id) {
          _replyingPostId = null;
          _replyingReplyId = null;
          _socialReplyController.clear();
          _pendingSocialReplyAttachments = const <SpotSocialAttachmentDraft>[];
        }
      });
      await _loadSocialFeed();
    } catch (error) {
      _showSocialSnackBar(error.toString());
    }
  }

  Future<void> _deleteReply({
    required String postId,
    required SpotSocialReply reply,
  }) async {
    try {
      await _spotSocialClient.deleteReply(replyId: reply.id);
      if (!mounted) {
        return;
      }
      setState(() {
        if (_editingReplyId == reply.id) {
          _editingReplyId = null;
          _editingReplyPostId = null;
          _socialReplyController.clear();
          _pendingSocialReplyAttachments = const <SpotSocialAttachmentDraft>[];
        }
        if (_replyingReplyId == reply.id) {
          _replyingReplyId = null;
          _replyingPostId = null;
          _socialReplyController.clear();
          _pendingSocialReplyAttachments = const <SpotSocialAttachmentDraft>[];
        } else if (_replyingPostId == postId && _replyingReplyId == null) {
          _replyingPostId = null;
          _socialReplyController.clear();
          _pendingSocialReplyAttachments = const <SpotSocialAttachmentDraft>[];
        }
      });
      await _loadSocialFeed();
    } catch (error) {
      _showSocialSnackBar(error.toString());
    }
  }

  SpotSocialPost? _findSocialPostById(String postId) {
    for (final post in _socialFeed) {
      if (post.id == postId) {
        return post;
      }
    }
    return null;
  }

  SpotSocialReply? _findSocialReplyById(String replyId) {
    SpotSocialReply? search(List<SpotSocialReply> replies) {
      for (final reply in replies) {
        if (reply.id == replyId) {
          return reply;
        }
        final nested = search(reply.replies);
        if (nested != null) {
          return nested;
        }
      }
      return null;
    }

    for (final post in _socialFeed) {
      final found = search(post.replies);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  bool _canManageSocialEntry(_SpotChatEntry entry) {
    return entry.isMine || _canModerateSocialMessages;
  }

  Future<void> _showSocialMessageActions(_SpotChatEntry entry) async {
    if (!_canManageSocialEntry(entry)) {
      return;
    }
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Editar mensaje'),
                onTap: () => Navigator.of(sheetContext).pop('edit'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Eliminar mensaje'),
                onTap: () => Navigator.of(sheetContext).pop('delete'),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || action == null) {
      return;
    }
    if (entry.isReply) {
      final reply = _findSocialReplyById(entry.id);
      if (reply == null) {
        return;
      }
      if (action == 'edit') {
        _startEditReply(postId: entry.postId, reply: reply);
      } else if (action == 'delete') {
        await _deleteReply(postId: entry.postId, reply: reply);
      }
      return;
    }
    final post = _findSocialPostById(entry.id);
    if (post == null) {
      return;
    }
    if (action == 'edit') {
      _startEditPost(post);
    } else if (action == 'delete') {
      await _deletePost(post);
    }
  }

  int _countRepliesCascade(List<SpotSocialReply> replies) {
    var count = 0;
    for (final reply in replies) {
      count += 1;
      count += _countRepliesCascade(reply.replies);
    }
    return count;
  }

  List<_SpotChatEntry> _buildChatEntries() {
    final entries = <_SpotChatEntry>[];
    for (final post in _socialFeed) {
      entries.add(
        _SpotChatEntry.post(
          id: post.id,
          authorUsername: post.authorUsername,
          authorDisplayName: post.authorDisplayName,
          message: post.message,
          createdAt: post.createdAt,
          isMine: post.isMine,
          attachments: post.attachments,
          replyCount: _countRepliesCascade(post.replies),
        ),
      );
      _appendReplyEntries(
        target: entries,
        postId: post.id,
        replies: post.replies,
        parentAuthor: post.authorDisplayName,
        parentMessage: post.message,
      );
    }
    entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return entries;
  }

  void _appendReplyEntries({
    required List<_SpotChatEntry> target,
    required String postId,
    required List<SpotSocialReply> replies,
    required String parentAuthor,
    required String parentMessage,
  }) {
    for (final reply in replies) {
      target.add(
        _SpotChatEntry.reply(
          id: reply.id,
          postId: postId,
          authorUsername: reply.authorUsername,
          authorDisplayName: reply.authorDisplayName,
          message: reply.message,
          createdAt: reply.createdAt,
          isMine: reply.isMine,
          attachments: reply.attachments,
          replyCount: _countRepliesCascade(reply.replies),
          parentAuthor: parentAuthor,
          parentMessage: parentMessage,
        ),
      );
      _appendReplyEntries(
        target: target,
        postId: postId,
        replies: reply.replies,
        parentAuthor: reply.authorDisplayName,
        parentMessage: reply.message,
      );
    }
  }

  void _openReplyComposerForPost(String postId) {
    setState(() {
      _editingReplyId = null;
      _editingReplyPostId = null;
      _replyingPostId = postId;
      _replyingReplyId = null;
      _socialReplyController.clear();
      _pendingSocialReplyAttachments = const <SpotSocialAttachmentDraft>[];
    });
    _scheduleEnsureSocialComposerVisible();
    _scheduleFocusSocialComposerInput(forReply: true);
  }

  void _openReplyComposerForReply(String postId, String replyId) {
    setState(() {
      _editingReplyId = null;
      _editingReplyPostId = null;
      _replyingPostId = postId;
      _replyingReplyId = replyId;
      _socialReplyController.clear();
      _pendingSocialReplyAttachments = const <SpotSocialAttachmentDraft>[];
    });
    _scheduleEnsureSocialComposerVisible();
    _scheduleFocusSocialComposerInput(forReply: true);
  }

  void _cancelReplyComposer() {
    setState(() {
      _editingReplyId = null;
      _editingReplyPostId = null;
      _replyingPostId = null;
      _replyingReplyId = null;
      _socialReplyController.clear();
      _pendingSocialReplyAttachments = const <SpotSocialAttachmentDraft>[];
    });
    unawaited(_broadcastTypingState(isTyping: false));
  }

  Future<void> _publishReply() async {
    final text = _socialReplyController.text.trim();
    final editingReplyId = _editingReplyId;
    final postId = editingReplyId != null
        ? _editingReplyPostId
        : _replyingPostId;
    if ((text.isEmpty && _pendingSocialReplyAttachments.isEmpty) ||
        postId == null ||
        _isSocialSubmitting) {
      return;
    }
    if (!_canPublishSocial) {
      _showSocialSnackBar('Inicia sesion para responder en el chat del spot.');
      return;
    }
    final optimisticAttachments = List<SpotSocialAttachmentDraft>.from(
      _pendingSocialReplyAttachments,
    );
    final optimisticTempId =
        'local-reply-${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      _isSocialSubmitting = true;
    });
    try {
      if (editingReplyId == null) {
        _insertOptimisticSocialReply(
          tempId: optimisticTempId,
          postId: postId,
          parentReplyId: _replyingReplyId,
          message: text,
          attachments: optimisticAttachments,
        );
        await _spotSocialClient.addReply(
          postId: postId,
          parentReplyId: _replyingReplyId,
          authorUsername: _normalizedSocialUsername(),
          authorDisplayName: _socialDisplayName(),
          message: text,
          attachments: optimisticAttachments,
        );
      } else {
        await _spotSocialClient.updateReply(
          replyId: editingReplyId,
          message: text,
        );
      }
      _socialReplyController.clear();
      _editingReplyId = null;
      _editingReplyPostId = null;
      _replyingPostId = null;
      _replyingReplyId = null;
      _pendingSocialReplyAttachments = const <SpotSocialAttachmentDraft>[];
      await _broadcastTypingState(isTyping: false);
      await _loadSocialFeed();
    } catch (error) {
      await _loadSocialFeed();
      _showSocialSnackBar(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSocialSubmitting = false;
        });
      }
    }
  }

  Widget _buildPendingSocialAttachments({
    required List<SpotSocialAttachmentDraft> attachments,
    required bool forReply,
  }) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (var index = 0; index < attachments.length; index += 1)
            _PendingSocialAttachmentCard(
              attachment: attachments[index],
              onRemove: () => _removePendingSocialAttachment(
                forReply: forReply,
                index: index,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialAttachments(
    List<SpotSocialAttachment> attachments, {
    required bool compact,
  }) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: attachments
            .map(
              (attachment) => _SpotSocialAttachmentCard(
                attachment: attachment,
                compact: compact,
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  _SpotChatEntry? _activeReplyEntry() {
    final postId = _replyingPostId;
    if (postId == null) {
      return null;
    }
    final replyId = _replyingReplyId;
    for (final entry in _buildChatEntries()) {
      if (replyId != null) {
        if (entry.id == replyId) {
          return entry;
        }
      } else if (entry.id == postId && !entry.isReply) {
        return entry;
      }
    }
    return null;
  }

  String _socialAvatarInitials(String displayName) {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'R';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Color _socialAvatarColor(String seed) {
    final hash = seed.runes.fold<int>(0, (value, rune) => value * 31 + rune);
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.42, 0.58).toColor();
  }

  Widget _buildSocialMiniAvatar(_SpotChatEntry entry) {
    final localAvatarPath = entry.isMine && !kIsWeb
        ? _currentSocialProfile.avatarLocalPath
        : null;
    final hasLocalAvatar =
        localAvatarPath != null && localAvatarPath.trim().isNotEmpty;
    return CircleAvatar(
      radius: 14,
      backgroundColor: _socialAvatarColor(entry.authorUsername),
      backgroundImage: hasLocalAvatar ? FileImage(File(localAvatarPath)) : null,
      child: hasLocalAvatar
          ? null
          : Text(
              _socialAvatarInitials(entry.authorDisplayName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  Widget _buildSocialComposer(TextTheme textTheme, ColorScheme colorScheme) {
    final isEditingReply = _editingReplyId != null;
    final isReplying = !isEditingReply && _replyingPostId != null;
    final usesReplyComposer = isReplying || isEditingReply;
    final controller = usesReplyComposer
        ? _socialReplyController
        : _socialPostController;
    final pendingAttachments = usesReplyComposer
        ? _pendingSocialReplyAttachments
        : _pendingSocialPostAttachments;
    final canSend = usesReplyComposer
        ? _canSendSocialReply
        : _canSendSocialPost;
    final replyEntry = isReplying ? _activeReplyEntry() : null;
    final focusNode = usesReplyComposer
        ? _socialReplyFocusNode
        : _socialPostFocusNode;
    final title = isReplying
        ? 'Respondiendo'
        : isEditingReply
        ? 'Editando respuesta'
        : (_editingPostId == null ? null : 'Editando mensaje');
    final hintText = !_canPublishSocial
        ? (usesReplyComposer
              ? 'Inicia sesion para responder...'
              : 'Inicia sesion para escribir en este spot.')
        : (usesReplyComposer
              ? 'Escribe tu respuesta...'
              : 'Escribe al chat del spot...');
    final onAttach =
        _canPublishSocial &&
            !_isSocialSubmitting &&
            (_editingPostId == null || isReplying) &&
            !isEditingReply
        ? () => _showSocialAttachmentOptions(forReply: usesReplyComposer)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) Text(title, style: textTheme.titleSmall),
        if (replyEntry != null) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(color: colorScheme.primary, width: 3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        replyEntry.authorDisplayName,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        replyEntry.message.isNotEmpty
                            ? replyEntry.message
                            : (replyEntry.attachments.isNotEmpty
                                  ? 'Adjunto'
                                  : ''),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Cancelar respuesta',
                  onPressed: _cancelReplyComposer,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
        ],
        _buildPendingSocialAttachments(
          attachments: pendingAttachments,
          forReply: usesReplyComposer,
        ),
        TextField(
          controller: controller,
          focusNode: focusNode,
          minLines: 1,
          maxLines: usesReplyComposer ? 3 : 5,
          onChanged: (value) =>
              _handleSocialComposerChanged(value, forReply: usesReplyComposer),
          enabled: _canPublishSocial && !_isSocialSubmitting,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              tooltip: 'Adjuntar foto o video',
              onPressed: onAttach,
              icon: _isPickingSocialMedia
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_rounded),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (usesReplyComposer)
                  TextButton(
                    onPressed: _cancelReplyComposer,
                    child: const Text('Cancelar'),
                  )
                else if (_editingPostId != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _editingPostId = null;
                        _socialPostController.clear();
                        _pendingSocialPostAttachments =
                            const <SpotSocialAttachmentDraft>[];
                      });
                      unawaited(_broadcastTypingState(isTyping: false));
                    },
                    child: const Text('Cancelar'),
                  ),
                const SizedBox(width: AppSpacing.xs),
                FilledButton.icon(
                  onPressed: _canPublishSocial && canSend
                      ? (usesReplyComposer ? _publishReply : _publishSocialPost)
                      : null,
                  icon: const Icon(Icons.send_rounded),
                  label: Text(
                    usesReplyComposer
                        ? (isEditingReply ? 'Guardar' : 'Responder')
                        : (_editingPostId == null ? 'Enviar' : 'Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialSection(TextTheme textTheme) {
    final colorScheme = Theme.of(context).colorScheme;
    final chatMaxHeight = math.min(
      520.0,
      math.max(280.0, MediaQuery.of(context).size.height * 0.46),
    );
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.chat_bubble_rounded,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chat del spot', style: textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.name} · ${widget.area}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (_socialOnlineCount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          _socialOnlineCount == 1
                              ? '1 persona dentro del chat'
                              : '$_socialOnlineCount personas dentro del chat',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (_socialTypingUsers.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _socialTypingUsers.length == 1
                              ? '${_socialTypingUsers.first} esta escribiendo...'
                              : 'Varias personas estan escribiendo...',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              0,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: chatMaxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Builder(
                    builder: (context) {
                      if (_isSocialLoading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (_socialFeed.isEmpty && _socialErrorMessage == null) {
                        return Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            'Aun no hay mensajes en este spot.',
                            style: textTheme.bodyMedium,
                          ),
                        );
                      }
                      if (_socialFeed.isEmpty && _socialErrorMessage != null) {
                        return Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            _socialErrorMessage!,
                            style: textTheme.bodyMedium,
                          ),
                        );
                      }
                      final chatEntries = _buildChatEntries();
                      return Scrollbar(
                        controller: _socialFeedScrollController,
                        thumbVisibility: true,
                        child: ListView(
                          controller: _socialFeedScrollController,
                          primary: false,
                          children: [
                            for (
                              var index = 0;
                              index < chatEntries.length;
                              index += 1
                            )
                              Padding(
                                key: index == chatEntries.length - 1
                                    ? _lastSocialMessageKey
                                    : null,
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    final entry = chatEntries[index];
                                    return Row(
                                      mainAxisAlignment: entry.isMine
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (!entry.isMine) ...[
                                          _buildSocialMiniAvatar(entry),
                                          const SizedBox(width: AppSpacing.xs),
                                        ],
                                        Flexible(
                                          child: Align(
                                            alignment: entry.isMine
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 420,
                                              ),
                                              child: Builder(
                                                builder: (context) {
                                                  final bubbleColor =
                                                      entry.isMine
                                                      ? colorScheme
                                                            .primaryContainer
                                                      : colorScheme
                                                            .surfaceContainerHighest;
                                                  final bubbleTextColor =
                                                      entry.isMine
                                                      ? colorScheme
                                                            .onPrimaryContainer
                                                      : colorScheme.onSurface;
                                                  return _SwipeReplyMessageWrapper(
                                                    accentColor: entry.isMine
                                                        ? colorScheme
                                                              .onPrimaryContainer
                                                        : colorScheme.primary,
                                                    manageColor:
                                                        colorScheme.error,
                                                    onReplyTriggered: () =>
                                                        entry.isReply
                                                        ? _openReplyComposerForReply(
                                                            entry.postId,
                                                            entry.id,
                                                          )
                                                        : _openReplyComposerForPost(
                                                            entry.id,
                                                          ),
                                                    onManageTriggered:
                                                        _canManageSocialEntry(
                                                          entry,
                                                        )
                                                        ? () =>
                                                              _showSocialMessageActions(
                                                                entry,
                                                              )
                                                        : null,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(
                                                            AppSpacing.sm,
                                                            AppSpacing.xs,
                                                            AppSpacing.sm,
                                                            AppSpacing.xs,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: bubbleColor,
                                                        borderRadius: BorderRadius.only(
                                                          topLeft:
                                                              const Radius.circular(
                                                                20,
                                                              ),
                                                          topRight:
                                                              const Radius.circular(
                                                                20,
                                                              ),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                entry.isMine
                                                                    ? 20
                                                                    : 6,
                                                              ),
                                                          bottomRight:
                                                              Radius.circular(
                                                                entry.isMine
                                                                    ? 6
                                                                    : 20,
                                                              ),
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withValues(
                                                                  alpha: 0.04,
                                                                ),
                                                            blurRadius: 10,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  4,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  '${entry.authorDisplayName} · ${_relativeTimeLabel(entry.createdAt)}',
                                                                  style: textTheme
                                                                      .bodySmall
                                                                      ?.copyWith(
                                                                        color:
                                                                            entry.isMine
                                                                            ? colorScheme.onPrimaryContainer.withValues(
                                                                                alpha: 0.72,
                                                                              )
                                                                            : colorScheme.onSurfaceVariant,
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          if (entry
                                                                  .parentMessage
                                                                  ?.trim()
                                                                  .isNotEmpty ??
                                                              false) ...[
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Container(
                                                              width: double
                                                                  .infinity,
                                                              margin:
                                                                  const EdgeInsets.only(
                                                                    bottom:
                                                                        AppSpacing
                                                                            .xs,
                                                                  ),
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    AppSpacing
                                                                        .xs,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: colorScheme
                                                                    .surfaceContainerHighest,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                                border: Border(
                                                                  left: BorderSide(
                                                                    color: colorScheme
                                                                        .primary,
                                                                    width: 3,
                                                                  ),
                                                                ),
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    entry.parentAuthor ??
                                                                        '',
                                                                    style: textTheme.labelSmall?.copyWith(
                                                                      color: colorScheme
                                                                          .primary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    entry
                                                                        .parentMessage!,
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: textTheme
                                                                        .bodySmall
                                                                        ?.copyWith(
                                                                          color:
                                                                              colorScheme.onSurfaceVariant,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                          if (entry
                                                              .message
                                                              .isNotEmpty) ...[
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              entry.message,
                                                              style: textTheme
                                                                  .bodyMedium
                                                                  ?.copyWith(
                                                                    color:
                                                                        bubbleTextColor,
                                                                  ),
                                                            ),
                                                          ],
                                                          _buildSocialAttachments(
                                                            entry.attachments,
                                                            compact:
                                                                entry.isReply,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (entry.isMine) ...[
                                          const SizedBox(width: AppSpacing.xs),
                                          _buildSocialMiniAvatar(entry),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            key: _socialComposerKey,
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              0,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildSocialComposer(textTheme, colorScheme)],
            ),
          ),
        ],
      ),
    );
  }

  void _showSocialSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _relativeTimeLabel(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'ahora';
    }
    if (difference.inHours < 1) {
      return 'hace ${difference.inMinutes} min';
    }
    if (difference.inDays < 1) {
      return 'hace ${difference.inHours} h';
    }
    return 'hace ${difference.inDays} d';
  }

  String _alarmTriggerSummary(SpotAlarmRecord alarm) {
    final lastTriggeredAt = alarm.lastTriggeredAt;
    if (lastTriggeredAt == null) {
      return 'Aun no ha disparado';
    }
    return 'Ultimo aviso ${_relativeTimeLabel(lastTriggeredAt)} · ${alarm.triggerCount}/${alarm.maxRepeats}';
  }

  Color _windColor(int knots) {
    if (knots < 10) {
      return Colors.transparent;
    }
    return _windSemaforoColor(knots.toDouble());
  }

  Color _rainColor(double mm) {
    if (mm <= 0) {
      return const Color(0xFFE0E0E0);
    }
    if (mm < 0.5) {
      return const Color(0xFFB3E5FC);
    }
    if (mm < 1.5) {
      return const Color(0xFF81D4FA);
    }
    return const Color(0xFF4FC3F7);
  }

  Color _airTempColor(int tempC) {
    if (tempC <= 16) {
      return const Color(0xFFB3E5FC);
    }
    if (tempC <= 20) {
      return const Color(0xFF81D4FA);
    }
    if (tempC <= 24) {
      return const Color(0xFFFFF59D);
    }
    if (tempC <= 28) {
      return const Color(0xFFFFCC80);
    }
    return const Color(0xFFFFAB91);
  }

  Color _waterTempColor(int tempC) {
    if (tempC <= 16) {
      return const Color(0xFF90CAF9);
    }
    if (tempC <= 18) {
      return const Color(0xFF81D4FA);
    }
    if (tempC <= 20) {
      return const Color(0xFF80DEEA);
    }
    if (tempC <= 22) {
      return const Color(0xFFA5D6A7);
    }
    return const Color(0xFFC5E1A5);
  }

  Widget _compactLabelCell(String text, {double? minHeight}) {
    return Container(
      alignment: Alignment.centerLeft,
      constraints: minHeight == null
          ? null
          : BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: minHeight == null ? 8 : 4,
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  bool _isForecastDayStart(List<_ForecastRow> rows, int index) {
    if (index == 0) {
      return true;
    }
    final current = rows[index].slotTime;
    final previous = rows[index - 1].slotTime;
    return current.year != previous.year ||
        current.month != previous.month ||
        current.day != previous.day;
  }

  Widget _forecastHourCell(
    List<_ForecastRow> rows,
    int index, {
    double? minHeight,
  }) {
    final isDayStart = _isForecastDayStart(rows, index);

    return _forecastColumnCell(
      isDayStart: isDayStart,
      child: _compactValueCell(
        rows[index].hour,
        bold: true,
        minHeight: minHeight,
      ),
    );
  }

  Widget _forecastColumnCell({
    required bool isDayStart,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isDayStart ? colorScheme.primary : Colors.transparent,
            width: isDayStart ? 4 : 0,
          ),
        ),
      ),
      child: child,
    );
  }

  Widget _compactValueCell(
    String text, {
    Color? color,
    bool bold = false,
    Color? textColor,
    double? minHeight,
  }) {
    return Container(
      alignment: Alignment.center,
      constraints: minHeight == null
          ? null
          : BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.symmetric(
        horizontal: 6,
        vertical: minHeight == null ? 8 : 4,
      ),
      color: color,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _compactDirectionCell(int degrees, {double? minHeight}) {
    final normalizedDegrees = _normalizeDegrees(degrees.toDouble());
    return Container(
      alignment: Alignment.center,
      constraints: minHeight == null
          ? null
          : BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.symmetric(
        horizontal: 4,
        vertical: minHeight == null ? 6 : 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.rotate(
            angle: ((normalizedDegrees - 45 + 180) * math.pi) / 180,
            child: const Icon(Icons.near_me_rounded, size: 18),
          ),
          const SizedBox(height: 2),
          Text(
            _degreesToCardinal(normalizedDegrees),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastRangeSelector({
    _ForecastRange? selectedRange,
    ValueChanged<_ForecastRange>? onRangeChanged,
  }) {
    final effectiveRange = selectedRange ?? _forecastRange;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<_ForecastRange>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.35),
          ),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          foregroundColor: Theme.of(context).colorScheme.primary,
          selectedForegroundColor: Colors.white,
          selectedBackgroundColor: Theme.of(context).colorScheme.primary,
        ),
        segments: _availableForecastRanges(_forecastProvider)
            .map(
              (range) => ButtonSegment<_ForecastRange>(
                value: range,
                label: Text(range.label),
              ),
            )
            .toList(),
        selected: {effectiveRange},
        onSelectionChanged: (value) {
          if (onRangeChanged != null) {
            onRangeChanged(value.first);
          } else {
            setState(() {
              _forecastRange = value.first;
            });
          }
        },
      ),
    );
  }

  Widget _buildWindguruStyleTable({
    List<_ForecastRow>? rowsOverride,
    _ForecastRange? selectedRange,
    bool showRangeSelector = true,
    bool showResolutionSelector = false,
    bool showFullscreenButton = true,
    bool expandToFill = false,
    double? fullscreenRowHeight,
    _ForecastResolution? fullscreenResolution,
    ValueChanged<_ForecastRange>? onRangeChanged,
    ValueChanged<_ForecastResolution>? onResolutionChanged,
    VoidCallback? onOpenFullscreen,
  }) {
    final rows =
        rowsOverride ?? _rowsForSelectedForecastRange(_forecastProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final columnWidth = _forecastColumnWidth(fullscreenResolution);

    final tableScroll = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Table(
        defaultColumnWidth: FixedColumnWidth(columnWidth),
        border: TableBorder(
          horizontalInside: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            width: 0.6,
          ),
          verticalInside: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            width: 0.5,
          ),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
            ),
            children: [
              _compactLabelCell('Hora', minHeight: fullscreenRowHeight),
              ...rows.asMap().entries.map(
                (entry) => _forecastHourCell(
                  rows,
                  entry.key,
                  minHeight: fullscreenRowHeight,
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              _compactLabelCell('Viento', minHeight: fullscreenRowHeight),
              ...rows.asMap().entries.map(
                (entry) => _forecastColumnCell(
                  isDayStart: _isForecastDayStart(rows, entry.key),
                  child: _compactValueCell(
                    '${entry.value.windKnots}',
                    color: _windColor(entry.value.windKnots),
                    bold: true,
                    minHeight: fullscreenRowHeight,
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              _compactLabelCell('Racha', minHeight: fullscreenRowHeight),
              ...rows.asMap().entries.map(
                (entry) => _forecastColumnCell(
                  isDayStart: _isForecastDayStart(rows, entry.key),
                  child: _compactValueCell(
                    _nullableMetricText(entry.value.gustKnots?.toString()),
                    color: entry.value.gustKnots == null
                        ? null
                        : _windColor(entry.value.gustKnots!),
                    minHeight: fullscreenRowHeight,
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              _compactLabelCell('Dir', minHeight: fullscreenRowHeight),
              ...rows.asMap().entries.map(
                (entry) => _forecastColumnCell(
                  isDayStart: _isForecastDayStart(rows, entry.key),
                  child: _compactDirectionCell(
                    entry.value.windDeg,
                    minHeight: fullscreenRowHeight,
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              _compactLabelCell('Olas', minHeight: fullscreenRowHeight),
              ...rows.asMap().entries.map(
                (entry) => _forecastColumnCell(
                  isDayStart: _isForecastDayStart(rows, entry.key),
                  child: _compactValueCell(
                    _nullableMetricText(entry.value.waveM?.toStringAsFixed(1)),
                    color: entry.value.waveM == null
                        ? null
                        : const Color(0xFFB3E5FC).withValues(alpha: 0.75),
                    minHeight: fullscreenRowHeight,
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              _compactLabelCell('Presion', minHeight: fullscreenRowHeight),
              ...rows.asMap().entries.map(
                (entry) => _forecastColumnCell(
                  isDayStart: _isForecastDayStart(rows, entry.key),
                  child: _compactValueCell(
                    _nullableMetricText(entry.value.pressureHpa?.toString()),
                    textColor: entry.value.pressureHpa == null
                        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.55)
                        : colorScheme.onSurfaceVariant,
                    minHeight: fullscreenRowHeight,
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              _compactLabelCell('Agua', minHeight: fullscreenRowHeight),
              ...rows.asMap().entries.map(
                (entry) => _forecastColumnCell(
                  isDayStart: _isForecastDayStart(rows, entry.key),
                  child: _compactValueCell(
                    _nullableMetricText(
                      entry.value.waterTempC == null
                          ? null
                          : '${entry.value.waterTempC}$_degreeSymbol',
                    ),
                    color: entry.value.waterTempC == null
                        ? null
                        : _waterTempColor(entry.value.waterTempC!),
                    minHeight: fullscreenRowHeight,
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              _compactLabelCell('Aire', minHeight: fullscreenRowHeight),
              ...rows.asMap().entries.map(
                (entry) => _forecastColumnCell(
                  isDayStart: _isForecastDayStart(rows, entry.key),
                  child: _compactValueCell(
                    _nullableMetricText(
                      entry.value.tempC == null
                          ? null
                          : '${entry.value.tempC}$_degreeSymbol',
                    ),
                    color: entry.value.tempC == null
                        ? null
                        : _airTempColor(entry.value.tempC!),
                    minHeight: fullscreenRowHeight,
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              _compactLabelCell('Nubes', minHeight: fullscreenRowHeight),
              ...rows.asMap().entries.map(
                (entry) => _forecastColumnCell(
                  isDayStart: _isForecastDayStart(rows, entry.key),
                  child: _compactValueCell(
                    _nullableMetricText(
                      entry.value.cloudCoverPct == null
                          ? null
                          : '${entry.value.cloudCoverPct}%',
                    ),
                    color: entry.value.cloudCoverPct == null
                        ? null
                        : colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.24,
                          ),
                    minHeight: fullscreenRowHeight,
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              _compactLabelCell('Lluvia', minHeight: fullscreenRowHeight),
              ...rows.asMap().entries.map(
                (entry) => _forecastColumnCell(
                  isDayStart: _isForecastDayStart(rows, entry.key),
                  child: _compactValueCell(
                    entry.value.rainMm == null
                        ? '-'
                        : entry.value.rainMm! > 0
                        ? entry.value.rainMm!.toStringAsFixed(1)
                        : '-',
                    color: entry.value.rainMm == null
                        ? null
                        : _rainColor(
                            entry.value.rainMm!,
                          ).withValues(alpha: 0.8),
                    minHeight: fullscreenRowHeight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Stack(
      fit: expandToFill ? StackFit.expand : StackFit.loose,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(expandToFill ? 0 : 16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: expandToFill ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showRangeSelector)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: _buildForecastRangeSelector(
                    selectedRange: selectedRange,
                    onRangeChanged: onRangeChanged,
                  ),
                ),
              if (showResolutionSelector)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<_ForecastResolution>(
                      showSelectedIcon: false,
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.35),
                        ),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        selectedForegroundColor: Colors.white,
                        selectedBackgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary,
                      ),
                      segments:
                          _allowedForecastResolutions(
                            selectedRange ?? _forecastRange,
                          ).map((resolution) {
                            return ButtonSegment<_ForecastResolution>(
                              value: resolution,
                              label: Text(resolution.label),
                            );
                          }).toList(),
                      selected: {
                        fullscreenResolution ??
                            _preferredForecastResolution(
                              selectedRange ?? _forecastRange,
                            ),
                      },
                      onSelectionChanged: (value) {
                        onResolutionChanged?.call(value.first);
                      },
                    ),
                  ),
                ),
              if (showRangeSelector) const Divider(height: 1),
              if (expandToFill) Expanded(child: tableScroll) else tableScroll,
            ],
          ),
        ),
        if (showFullscreenButton)
          Positioned(
            right: 8,
            bottom: 8,
            child: IconButton(
              onPressed: onOpenFullscreen,
              tooltip: 'Ampliar tabla',
              icon: const Icon(Icons.fullscreen_rounded),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_isFullscreenActive,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isFullscreenActive) {
          setState(() {
            _fullscreenMode = _ForecastFullscreenMode.none;
          });
        }
      },
      child: Scaffold(
        appBar: _isFullscreenActive
            ? null
            : AppBar(title: const Text('Spot seleccionado')),
        body: Stack(
          children: [
            ScrollConfiguration(
              behavior: const _NoStretchScrollBehavior(),
              child: ListView(
                physics: kAppBouncingScrollPhysics,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Builder(
                    builder: (context) {
                      final hasBackground = _canRenderLocalImage(
                        widget.backgroundImagePath,
                      );
                      final header = Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: textTheme.headlineSmall?.copyWith(
                                color: hasBackground ? Colors.white : null,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              widget.area,
                              style: textTheme.bodyMedium?.copyWith(
                                color: hasBackground ? Colors.white : null,
                              ),
                            ),
                            if (widget.isCustom) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Chip(
                                backgroundColor: hasBackground
                                    ? Colors.black.withValues(alpha: 0.4)
                                    : null,
                                label: Text(
                                  'Custom',
                                  style: hasBackground
                                      ? const TextStyle(color: Colors.white)
                                      : null,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );

                      if (!hasBackground) {
                        return Card(child: header);
                      }

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.file(
                                File(widget.backgroundImagePath!),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.45),
                                      Colors.black.withValues(alpha: 0.2),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            header,
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<_SpotDetailSection>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: _SpotDetailSection.prevision,
                        label: Text('Forecast'),
                      ),
                      ButtonSegment(
                        value: _SpotDetailSection.live,
                        label: Text('Live'),
                      ),
                      ButtonSegment(
                        value: _SpotDetailSection.webcam,
                        label: Text('Webcam'),
                      ),
                      ButtonSegment(
                        value: _SpotDetailSection.social,
                        label: Text('Chat'),
                      ),
                    ],
                    selected: {_section},
                    onSelectionChanged: (value) {
                      _setSection(value.first);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  switch (_section) {
                    _SpotDetailSection.prevision => _buildForecastSection(),
                    _SpotDetailSection.live => _buildLiveSection(),
                    _SpotDetailSection.webcam => Builder(
                      builder: (context) {
                        final webcams = _webcamsForSpot();
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  webcams.length == 1
                                      ? 'Webcam principal'
                                      : 'Webcams disponibles',
                                  style: textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${widget.name} · ${widget.area}',
                                  style: textTheme.bodySmall,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                if (webcams.isEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'No hay webcams disponibles para este spot por ahora.',
                                      style: textTheme.bodyMedium,
                                    ),
                                  )
                                else
                                  ...webcams.map(
                                    (webcam) => Card(
                                      margin: const EdgeInsets.only(
                                        bottom: AppSpacing.sm,
                                      ),
                                      child: ListTile(
                                        title: Text(webcam.name),
                                        subtitle: Text(() {
                                          final distanceKm =
                                              widget.latitude != null &&
                                                  widget.longitude != null
                                              ? _webcamDistanceKm(
                                                  webcam,
                                                  widget.latitude!,
                                                  widget.longitude!,
                                                )
                                              : null;
                                          final parts = <String>[
                                            if (webcam.locationLabel != null &&
                                                webcam
                                                    .locationLabel!
                                                    .isNotEmpty)
                                              webcam.locationLabel!,
                                            if (distanceKm != null)
                                              '${distanceKm.toStringAsFixed(1)} km',
                                            webcam.source,
                                          ];
                                          if (parts.isNotEmpty) {
                                            return parts.join(' · ');
                                          }
                                          return webcam.summary ??
                                              '${webcam.source} · ${webcam.resolution} · ${webcam.status}';
                                        }()),
                                        trailing: FilledButton.icon(
                                          onPressed: () => _openWebcam(webcam),
                                          icon: const Icon(
                                            Icons.play_arrow_rounded,
                                          ),
                                          label: const Text('Abrir'),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    _SpotDetailSection.social => _buildSocialSection(textTheme),
                  },
                ],
              ),
            ),
            if (_fullscreenMode == _ForecastFullscreenMode.forecastTable)
              FutureBuilder<_ForecastLoadResult>(
                future: _forecastRowsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Positioned.fill(
                      child: Material(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  final result =
                      snapshot.data ??
                      _ForecastLoadResult(
                        rows: const <_ForecastRow>[],
                        source: _ForecastDataSource.fallback,
                        message: 'No se han podido cargar datos.',
                      );
                  return _buildExpandedForecastOverlay(result);
                },
              ),
            if (_fullscreenMode == _ForecastFullscreenMode.meteoblueSea)
              FutureBuilder<_MeteoblueCurrentDayLoadResult>(
                future: _ensureMeteoblueCurrentDayFuture(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Positioned.fill(
                      child: Material(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  final result =
                      snapshot.data ??
                      _MeteoblueCurrentDayLoadResult(
                        snapshot: _emptyMeteoblueSnapshot,
                        source: _ForecastDataSource.fallback,
                        message: 'Meteoblue Sea no disponible.',
                      );
                  return _buildExpandedMeteoblueSeaOverlay(result);
                },
              ),
            if (_fullscreenMode == _ForecastFullscreenMode.windguru)
              _buildExpandedWindguruOverlay(),
          ],
        ),
      ),
    );
  }
}

class _ForecastRow {
  const _ForecastRow({
    required this.slotTime,
    required this.hour,
    required this.windKnots,
    this.gustKnots,
    required this.windDeg,
    this.tempC,
    this.waterTempC,
    this.pressureHpa,
    this.cloudCoverPct,
    this.waveM,
    this.rainMm,
  });

  final DateTime slotTime;
  final String hour;
  final int windKnots;
  final int? gustKnots;
  final int windDeg;
  final int? tempC;
  final int? waterTempC;
  final int? pressureHpa;
  final int? cloudCoverPct;
  final double? waveM;
  final double? rainMm;
}

class _NearbyStation {
  const _NearbyStation({
    required this.name,
    required this.distanceKm,
    required this.provider,
    required this.sourceKind,
    required this.stationKey,
    required this.latitude,
    required this.longitude,
    this.stationId,
    this.proximityLabel,
  });

  final String name;
  final double distanceKm;
  final String provider;
  final _StationSourceKind sourceKind;
  final String stationKey;
  final double latitude;
  final double longitude;
  final String? stationId;
  final String? proximityLabel;
}

enum _StationSourceKind {
  observation('Observacion'),
  forecast('Forecast');

  const _StationSourceKind(this.label);

  final String label;
}

class _StationLiveData {
  const _StationLiveData({
    required this.windKnots,
    required this.windDeg,
    required this.gustKnots,
    required this.tempC,
    required this.pressureHpa,
    required this.humidityPct,
    required this.rainMm,
    required this.observedAt,
  });

  final double? windKnots;
  final int? windDeg;
  final double? gustKnots;
  final double? tempC;
  final int? pressureHpa;
  final int? humidityPct;
  final double? rainMm;
  final DateTime? observedAt;
}

class _HistoricalWindPoint {
  const _HistoricalWindPoint({
    required this.time,
    required this.windKnots,
    this.gustKnots,
    this.windDirectionDeg,
    this.directionKind,
  });

  final DateTime time;
  final double windKnots;
  final double? gustKnots;
  final int? windDirectionDeg;
  final _HistoricalDirectionKind? directionKind;
}

class _HistoricalForecastAccuracySummary {
  const _HistoricalForecastAccuracySummary({
    required this.totalPercentage,
    required this.windPercentage,
    required this.windMatchedPoints,
    required this.windComparablePoints,
    required this.directionPercentage,
    required this.directionMatchedPoints,
    required this.directionComparablePoints,
    required this.combinedPercentage,
    required this.combinedMatchedPoints,
    required this.combinedComparablePoints,
    required this.meanAbsoluteErrorKnots,
  });

  final int? totalPercentage;
  final int? windPercentage;
  final int windMatchedPoints;
  final int windComparablePoints;
  final int? directionPercentage;
  final int directionMatchedPoints;
  final int directionComparablePoints;
  final int? combinedPercentage;
  final int combinedMatchedPoints;
  final int combinedComparablePoints;
  final double? meanAbsoluteErrorKnots;
}

enum _HistoryRange { h1, h3 }

enum _HistoricalBucketOption { min20, h1, h3, h6, h12 }

enum _HistoricalDirectionKind { exact, representative }

class _ChartArrowMarker {
  const _ChartArrowMarker({
    required this.xFraction,
    required this.windKnots,
    required this.directionDeg,
    required this.kind,
  });

  final double xFraction;
  final double windKnots;
  final int directionDeg;
  final _HistoricalDirectionKind kind;
}

class _ChartTimeGuide {
  const _ChartTimeGuide({
    required this.xFraction,
    required this.isMajor,
    this.label,
  });

  final double xFraction;
  final bool isMajor;
  final String? label;
}

class _HistoricalChartLegend extends StatelessWidget {
  const _HistoricalChartLegend({
    required this.showGust,
    required this.showForecast,
  });

  final bool showGust;
  final bool showForecast;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        const _HistoricalLegendChip(
          label: 'Viento real',
          color: Color(0xFF1F1F8F),
          style: _LegendStrokeStyle.solid,
        ),
        if (showGust)
          const _HistoricalLegendChip(
            label: 'Racha',
            color: Color(0xFFC2185B),
            style: _LegendStrokeStyle.solid,
          ),
        if (showForecast)
          const _HistoricalLegendChip(
            label: 'Forecast',
            color: Color(0xFFD84315),
            style: _LegendStrokeStyle.dashed,
          ),
      ],
    );
  }
}

enum _LegendStrokeStyle { solid, dashed }

class _HistoricalLegendChip extends StatelessWidget {
  const _HistoricalLegendChip({
    required this.label,
    required this.color,
    required this.style,
  });

  final String label;
  final Color color;
  final _LegendStrokeStyle style;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 10,
            child: CustomPaint(
              painter: _LegendStrokePainter(color: color, style: style),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendStrokePainter extends CustomPainter {
  const _LegendStrokePainter({required this.color, required this.style});

  final Color color;
  final _LegendStrokeStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    if (style == _LegendStrokeStyle.solid) {
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }
    const dash = 4.0;
    const gap = 3.0;
    var x = 0.0;
    while (x < size.width) {
      final end = math.min(size.width, x + dash);
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(end, size.height / 2),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _LegendStrokePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.style != style;
  }
}

enum _AlarmEvaluationState { active, partial, idle, noData, disabled }

class _AlarmEvaluation {
  const _AlarmEvaluation({required this.state, required this.label});

  final _AlarmEvaluationState state;
  final String label;
}

class _AlarmMetaChip extends StatelessWidget {
  const _AlarmMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _LiveWindChartPainter extends CustomPainter {
  const _LiveWindChartPainter({
    required this.points,
    required this.gustPoints,
    required this.timeLabels,
    required this.pointXFractions,
    required this.forecastPoints,
    required this.markerDirectionsDeg,
    required this.markerDirectionKinds,
    required this.overlayMarkers,
    required this.timeGuides,
    required this.dayStartIndexes,
    required this.dayStartLabels,
    required this.realLineColor,
    required this.gustLineColor,
    required this.forecastLineColor,
    required this.gridMajorColor,
    required this.gridMinorColor,
    required this.textColor,
    required this.windSpeedUnit,
  });

  final List<double> points;
  final List<double?>? gustPoints;
  final List<String> timeLabels;
  final List<double> pointXFractions;
  final List<double?>? forecastPoints;
  final List<int?> markerDirectionsDeg;
  final List<_HistoricalDirectionKind?> markerDirectionKinds;
  final List<_ChartArrowMarker> overlayMarkers;
  final List<_ChartTimeGuide> timeGuides;
  final List<int> dayStartIndexes;
  final List<String> dayStartLabels;
  final Color realLineColor;
  final Color gustLineColor;
  final Color forecastLineColor;
  final Color gridMajorColor;
  final Color gridMinorColor;
  final Color textColor;
  final _WindSpeedUnit windSpeedUnit;

  static const _yMin = 0.0;

  double _normalizeDirectionDeg(double degrees) {
    final normalized = degrees % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.width <= 0 || size.height <= 0) return;

    double computedMax = 0;
    for (final v in points) {
      final display = _displayWindValue(v, windSpeedUnit);
      if (display > computedMax) computedMax = display;
    }
    if (gustPoints != null) {
      for (final v in gustPoints!) {
        if (v == null) continue;
        final display = _displayWindValue(v, windSpeedUnit);
        if (display > computedMax) computedMax = display;
      }
    }
    if (forecastPoints != null) {
      for (final v in forecastPoints!) {
        if (v == null) continue;
        final display = _displayWindValue(v, windSpeedUnit);
        if (display > computedMax) computedMax = display;
      }
    }
    final minChartMax = _historicalMinChartMax(windSpeedUnit);
    final minorStep = _historicalMinorStep(windSpeedUnit);
    final majorStep = _historicalMajorStep(windSpeedUnit);
    final yMax = math.max(
      minChartMax,
      (computedMax / minorStep).ceil() * minorStep + minorStep,
    );

    final leftPad = _liveChartLeftPad;
    final rightPad = 12.0;
    final topPad = 12.0;
    final bottomPad = 32.0;
    final plot = Rect.fromLTWH(
      leftPad,
      topPad,
      size.width - leftPad - rightPad,
      size.height - topPad - bottomPad,
    );
    if (plot.width <= 0 || plot.height <= 0) return;

    final plotBackground = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gridMajorColor.withValues(alpha: 0.05), Colors.transparent],
      ).createShader(plot);
    canvas.drawRRect(
      RRect.fromRectAndRadius(plot, const Radius.circular(10)),
      plotBackground,
    );

    final majorGrid = Paint()
      ..color = gridMajorColor
      ..strokeWidth = 0.8;
    final minorGrid = Paint()
      ..color = gridMinorColor
      ..strokeWidth = 0.6;

    for (var k = _yMin; k <= yMax; k += minorStep) {
      final t = (k - _yMin) / (yMax - _yMin);
      final y = plot.bottom - (t * plot.height);
      final isMajor =
          ((k / majorStep).roundToDouble() - (k / majorStep)).abs() < 0.001;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        isMajor ? majorGrid : minorGrid,
      );
      if (!isMajor) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: _formatHistoricalAxisValue(k, windSpeedUnit),
          style: TextStyle(
            fontSize: 10,
            color: textColor.withValues(alpha: 0.8),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(plot.left - tp.width - 4, y - (tp.height / 2)));
    }

    if (timeGuides.isNotEmpty) {
      for (final guide in timeGuides) {
        final x = plot.left + (plot.width * guide.xFraction);
        canvas.drawLine(
          Offset(x, plot.top),
          Offset(x, plot.bottom),
          guide.isMajor
              ? (Paint()
                  ..color = gridMajorColor.withValues(alpha: 0.9)
                  ..strokeWidth = 1.0)
              : (Paint()
                  ..color = gridMinorColor.withValues(alpha: 0.75)
                  ..strokeWidth = 0.6),
        );
        if (guide.label == null) continue;
        final tp = TextPainter(
          text: TextSpan(
            text: guide.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.9),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - (tp.width / 2), plot.bottom + 6));
      }
    } else {
      final labelStep = points.length > 96
          ? 12
          : points.length > 48
          ? 6
          : 3;
      for (var i = 0; i < points.length; i++) {
        if (i % labelStep != 0) continue;
        final x = pointXFractions.length == points.length
            ? plot.left + (plot.width * pointXFractions[i])
            : points.length == 1
            ? plot.left
            : plot.left + (plot.width * i / (points.length - 1));
        canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), majorGrid);
        if (i < timeLabels.length) {
          final tp = TextPainter(
            text: TextSpan(
              text: timeLabels[i],
              style: TextStyle(
                fontSize: 10,
                color: textColor.withValues(alpha: 0.86),
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(x - (tp.width / 2), plot.bottom + 6));
        }
      }
    }

    for (var i = 0; i < dayStartIndexes.length; i++) {
      final index = dayStartIndexes[i];
      if (index < 0 || index >= points.length) continue;
      final x = pointXFractions.length == points.length
          ? plot.left + (plot.width * pointXFractions[index])
          : points.length == 1
          ? plot.left
          : plot.left + (plot.width * index / (points.length - 1));
      canvas.drawLine(
        Offset(x, plot.top),
        Offset(x, plot.bottom),
        Paint()
          ..color = realLineColor.withValues(alpha: 0.28)
          ..strokeWidth = 1.4,
      );
      if (i >= dayStartLabels.length) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: dayStartLabels[i],
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textColor.withValues(alpha: 0.92),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final dx = (x + 4).clamp(plot.left, plot.right - tp.width);
      tp.paint(canvas, Offset(dx, plot.top - 2));
    }

    Offset toOffset(int i, double v) {
      final x = pointXFractions.length == points.length
          ? plot.left + (plot.width * pointXFractions[i])
          : points.length == 1
          ? plot.left
          : plot.left + (plot.width * i / (points.length - 1));
      final displayValue = _displayWindValue(v, windSpeedUnit);
      final clamped = displayValue.clamp(_yMin, yMax);
      final y =
          plot.bottom - ((clamped - _yMin) / (yMax - _yMin)) * plot.height;
      return Offset(x, y);
    }

    Path buildPath(List<double> values) {
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final p = toOffset(i, values[i]);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      return path;
    }

    Path buildStepPath(List<double> values) {
      final path = Path();
      if (values.isEmpty) {
        return path;
      }
      final first = toOffset(0, values[0]);
      path.moveTo(first.dx, first.dy);
      for (var i = 1; i < values.length; i++) {
        final previous = toOffset(i - 1, values[i - 1]);
        final current = toOffset(i, values[i]);
        path.lineTo(current.dx, previous.dy);
        path.lineTo(current.dx, current.dy);
      }
      return path;
    }

    Path buildSmoothPath(List<double> values) {
      if (values.length < 3) {
        return buildPath(values);
      }
      final path = Path();
      var previous = toOffset(0, values[0]);
      path.moveTo(previous.dx, previous.dy);
      for (var i = 1; i < values.length; i++) {
        final current = toOffset(i, values[i]);
        final mid = Offset(
          (previous.dx + current.dx) / 2,
          (previous.dy + current.dy) / 2,
        );
        path.quadraticBezierTo(previous.dx, previous.dy, mid.dx, mid.dy);
        previous = current;
      }
      path.lineTo(previous.dx, previous.dy);
      return path;
    }

    final useSteppedWindScale = windSpeedUnit == _WindSpeedUnit.beaufort;
    final realSeriesPath = useSteppedWindScale
        ? buildStepPath(points)
        : buildSmoothPath(points);
    final realFill = Path.from(realSeriesPath)
      ..lineTo(plot.right, plot.bottom)
      ..lineTo(plot.left, plot.bottom)
      ..close();
    canvas.drawPath(
      realFill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            realLineColor.withValues(alpha: 0.22),
            realLineColor.withValues(alpha: 0.02),
          ],
        ).createShader(plot),
    );

    canvas.drawPath(
      realSeriesPath,
      Paint()
        ..color = realLineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );

    if (gustPoints != null && gustPoints!.any((value) => value != null)) {
      final gustPath = _buildPathForIndexedValues(
        List<int>.generate(
          gustPoints!.length,
          (index) => index,
          growable: false,
        ),
        gustPoints!.map((value) => value ?? double.nan).toList(growable: false),
        toOffset,
        useSteppedWindScale,
        skipNaN: true,
      );
      canvas.drawPath(
        gustPath,
        Paint()
          ..color = gustLineColor.withValues(alpha: 0.92)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
      );
    }

    if (forecastPoints != null &&
        forecastPoints!.any((value) => value != null)) {
      _drawDashedNullableSeries(
        canvas,
        forecastPoints!,
        toOffset,
        Paint()
          ..color = forecastLineColor.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
        useSteppedWindScale,
      );
    }

    Color semaforoColor(double knots) => _windSemaforoColor(knots);

    final arrowBase = Path()
      ..moveTo(0, -11.5)
      ..lineTo(8.5, 8.5)
      ..lineTo(0, 4.4)
      ..lineTo(-8.5, 8.5)
      ..close();

    void drawArrowMarker({
      required double xFraction,
      required double windKnots,
      required int directionDeg,
      required _HistoricalDirectionKind directionKind,
    }) {
      final displayValue = _displayWindValue(windKnots, windSpeedUnit);
      final p = Offset(
        plot.left + (plot.width * xFraction),
        plot.bottom -
            (((displayValue.clamp(_yMin, yMax) - _yMin) / (yMax - _yMin)) *
                plot.height),
      );
      final markerColor = semaforoColor(windKnots);
      final flowDirectionDeg =
          (_normalizeDirectionDeg(directionDeg.toDouble()) + 180) % 360;
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate((flowDirectionDeg * math.pi) / 180);
      canvas.drawPath(
        arrowBase,
        Paint()
          ..color = markerColor.withValues(alpha: 1)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        arrowBase,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      canvas.drawShadow(
        arrowBase,
        Colors.black.withValues(alpha: 0.22),
        2.8,
        true,
      );
      canvas.drawPath(
        arrowBase,
        Paint()
          ..color = markerColor
          ..style = PaintingStyle.fill,
      );
      canvas.restore();
    }

    for (final marker in overlayMarkers) {
      drawArrowMarker(
        xFraction: marker.xFraction,
        windKnots: marker.windKnots,
        directionDeg: marker.directionDeg,
        directionKind: marker.kind,
      );
    }

    for (var i = 0; i < points.length; i++) {
      final directionDeg = i < markerDirectionsDeg.length
          ? markerDirectionsDeg[i]
          : null;
      final directionKind = i < markerDirectionKinds.length
          ? markerDirectionKinds[i]
          : null;
      if (directionDeg == null || directionKind == null) continue;
      final xFraction = pointXFractions.length == points.length
          ? pointXFractions[i]
          : points.length <= 1
          ? 0.0
          : i / (points.length - 1);
      drawArrowMarker(
        xFraction: xFraction,
        windKnots: points[i],
        directionDeg: directionDeg,
        directionKind: directionKind,
      );
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = math.min(metric.length, dist + dash);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist += dash + gap;
      }
    }
  }

  void _drawDashedNullableSeries(
    Canvas canvas,
    List<double?> values,
    Offset Function(int index, double value) toOffset,
    Paint paint,
    bool stepped,
  ) {
    final activeIndexes = <int>[];
    final activeValues = <double>[];

    void flush() {
      if (activeIndexes.isEmpty) {
        return;
      }
      if (activeIndexes.length == 1) {
        final point = toOffset(activeIndexes.first, activeValues.first);
        canvas.drawLine(
          Offset(point.dx - 4, point.dy),
          Offset(point.dx + 4, point.dy),
          paint,
        );
      } else {
        _drawDashedPath(
          canvas,
          _buildPathForIndexedValues(
            activeIndexes,
            activeValues,
            toOffset,
            stepped,
          ),
          paint,
        );
      }
      activeIndexes.clear();
      activeValues.clear();
    }

    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value == null) {
        flush();
        continue;
      }
      activeIndexes.add(i);
      activeValues.add(value);
    }
    flush();
  }

  Path _buildPathForIndexedValues(
    List<int> indexes,
    List<double> values,
    Offset Function(int index, double value) toOffset,
    bool stepped, {
    bool skipNaN = false,
  }) {
    if (indexes.length != values.length || indexes.isEmpty) {
      return Path();
    }
    if (skipNaN) {
      final filteredIndexes = <int>[];
      final filteredValues = <double>[];
      for (var i = 0; i < values.length; i++) {
        final value = values[i];
        if (value.isNaN) {
          continue;
        }
        filteredIndexes.add(indexes[i]);
        filteredValues.add(value);
      }
      if (filteredIndexes.isEmpty) {
        return Path();
      }
      return _buildPathForIndexedValues(
        filteredIndexes,
        filteredValues,
        toOffset,
        stepped,
      );
    }
    if (stepped) {
      final path = Path();
      final first = toOffset(indexes[0], values[0]);
      path.moveTo(first.dx, first.dy);
      for (var i = 1; i < indexes.length; i++) {
        final previous = toOffset(indexes[i - 1], values[i - 1]);
        final current = toOffset(indexes[i], values[i]);
        path.lineTo(current.dx, previous.dy);
        path.lineTo(current.dx, current.dy);
      }
      return path;
    }
    if (indexes.length < 3) {
      final path = Path();
      for (var i = 0; i < indexes.length; i++) {
        final point = toOffset(indexes[i], values[i]);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      return path;
    }
    final path = Path();
    var previous = toOffset(indexes[0], values[0]);
    path.moveTo(previous.dx, previous.dy);
    for (var i = 1; i < indexes.length; i++) {
      final current = toOffset(indexes[i], values[i]);
      final mid = Offset(
        (previous.dx + current.dx) / 2,
        (previous.dy + current.dy) / 2,
      );
      path.quadraticBezierTo(previous.dx, previous.dy, mid.dx, mid.dy);
      previous = current;
    }
    path.lineTo(previous.dx, previous.dy);
    return path;
  }

  @override
  bool shouldRepaint(covariant _LiveWindChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.gustPoints != gustPoints ||
        oldDelegate.timeLabels != timeLabels ||
        oldDelegate.pointXFractions != pointXFractions ||
        oldDelegate.forecastPoints != forecastPoints ||
        oldDelegate.markerDirectionsDeg != markerDirectionsDeg ||
        oldDelegate.markerDirectionKinds != markerDirectionKinds ||
        oldDelegate.overlayMarkers != overlayMarkers ||
        oldDelegate.timeGuides != timeGuides ||
        oldDelegate.dayStartIndexes != dayStartIndexes ||
        oldDelegate.dayStartLabels != dayStartLabels ||
        oldDelegate.realLineColor != realLineColor ||
        oldDelegate.gustLineColor != gustLineColor ||
        oldDelegate.forecastLineColor != forecastLineColor ||
        oldDelegate.gridMajorColor != gridMajorColor ||
        oldDelegate.gridMinorColor != gridMinorColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.windSpeedUnit != windSpeedUnit;
  }
}

class _LiveWindYAxisPainter extends CustomPainter {
  const _LiveWindYAxisPainter({
    required this.points,
    required this.gustPoints,
    required this.forecastPoints,
    required this.gridMajorColor,
    required this.gridMinorColor,
    required this.textColor,
    required this.backgroundColor,
    required this.windSpeedUnit,
  });

  final List<double> points;
  final List<double?>? gustPoints;
  final List<double?>? forecastPoints;
  final Color gridMajorColor;
  final Color gridMinorColor;
  final Color textColor;
  final Color backgroundColor;
  final _WindSpeedUnit windSpeedUnit;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    double computedMax = 0;
    for (final v in points) {
      final display = _displayWindValue(v, windSpeedUnit);
      if (display > computedMax) computedMax = display;
    }
    if (gustPoints != null) {
      for (final v in gustPoints!) {
        if (v == null) continue;
        final display = _displayWindValue(v, windSpeedUnit);
        if (display > computedMax) computedMax = display;
      }
    }
    if (forecastPoints != null) {
      for (final v in forecastPoints!) {
        if (v == null) continue;
        final display = _displayWindValue(v, windSpeedUnit);
        if (display > computedMax) computedMax = display;
      }
    }
    final minChartMax = _historicalMinChartMax(windSpeedUnit);
    final minorStep = _historicalMinorStep(windSpeedUnit);
    final majorStep = _historicalMajorStep(windSpeedUnit);
    final yMax = math.max(
      minChartMax,
      (computedMax / minorStep).ceil() * minorStep + minorStep,
    );

    const topPad = 12.0;
    const bottomPad = 32.0;
    final plot = Rect.fromLTWH(
      0,
      topPad,
      size.width,
      size.height - topPad - bottomPad,
    );
    if (plot.height <= 0) {
      return;
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    final majorGrid = Paint()
      ..color = gridMajorColor
      ..strokeWidth = 0.8;
    final minorGrid = Paint()
      ..color = gridMinorColor
      ..strokeWidth = 0.6;

    for (var k = _LiveWindChartPainter._yMin; k <= yMax; k += minorStep) {
      final t =
          (k - _LiveWindChartPainter._yMin) /
          (yMax - _LiveWindChartPainter._yMin);
      final y = plot.bottom - (t * plot.height);
      final isMajor =
          ((k / majorStep).roundToDouble() - (k / majorStep)).abs() < 0.001;
      canvas.drawLine(
        Offset(size.width - 4, y),
        Offset(size.width, y),
        isMajor ? majorGrid : minorGrid,
      );
      if (!isMajor) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: _formatHistoricalAxisValue(k, windSpeedUnit),
          style: TextStyle(
            fontSize: 10,
            color: textColor.withValues(alpha: 0.8),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width - 6, y - (tp.height / 2)));
    }

    canvas.drawLine(
      Offset(size.width - 0.5, plot.top),
      Offset(size.width - 0.5, plot.bottom),
      Paint()
        ..color = gridMajorColor.withValues(alpha: 0.9)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _LiveWindYAxisPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.gustPoints != gustPoints ||
        oldDelegate.forecastPoints != forecastPoints ||
        oldDelegate.gridMajorColor != gridMajorColor ||
        oldDelegate.gridMinorColor != gridMinorColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.windSpeedUnit != windSpeedUnit;
  }
}

const double _liveChartLeftPad = 38.0;

Color _windSemaforoColor(double knots) => windSemaforoColor(knots);

int _beaufortFromKnots(int knots) {
  if (knots < 1) return 0;
  if (knots < 4) return 1;
  if (knots < 7) return 2;
  if (knots < 11) return 3;
  if (knots < 17) return 4;
  if (knots < 22) return 5;
  if (knots < 28) return 6;
  if (knots < 34) return 7;
  if (knots < 41) return 8;
  if (knots < 48) return 9;
  if (knots < 56) return 10;
  if (knots < 64) return 11;
  return 12;
}

double _displayWindValue(double knots, _WindSpeedUnit unit) {
  switch (unit) {
    case _WindSpeedUnit.knots:
      return knots;
    case _WindSpeedUnit.kmh:
      return knots * 1.852;
    case _WindSpeedUnit.mph:
      return knots * 1.15078;
    case _WindSpeedUnit.beaufort:
      return _beaufortFromKnots(knots.round()).toDouble();
  }
}

double _historicalMinorStep(_WindSpeedUnit unit) {
  switch (unit) {
    case _WindSpeedUnit.knots:
      return 2;
    case _WindSpeedUnit.kmh:
      return 4;
    case _WindSpeedUnit.mph:
      return 2;
    case _WindSpeedUnit.beaufort:
      return 1;
  }
}

double _historicalMajorStep(_WindSpeedUnit unit) {
  switch (unit) {
    case _WindSpeedUnit.knots:
      return 2;
    case _WindSpeedUnit.kmh:
      return 4;
    case _WindSpeedUnit.mph:
      return 2;
    case _WindSpeedUnit.beaufort:
      return 1;
  }
}

double _historicalMinChartMax(_WindSpeedUnit unit) {
  switch (unit) {
    case _WindSpeedUnit.knots:
      return 12;
    case _WindSpeedUnit.kmh:
      return 24;
    case _WindSpeedUnit.mph:
      return 14;
    case _WindSpeedUnit.beaufort:
      return 6;
  }
}

String _formatHistoricalAxisValue(double value, _WindSpeedUnit unit) {
  switch (unit) {
    case _WindSpeedUnit.knots:
    case _WindSpeedUnit.beaufort:
      return value.toStringAsFixed(0);
    case _WindSpeedUnit.kmh:
    case _WindSpeedUnit.mph:
      return value.toStringAsFixed(0);
  }
}

class _CompassDiamondNeedlePainter extends CustomPainter {
  const _CompassDiamondNeedlePainter({
    required this.northColor,
    required this.southColor,
  });

  final Color northColor;
  final Color southColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final northPath = Path()
      ..moveTo(center.dx, 0)
      ..lineTo(size.width, center.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(0, center.dy)
      ..close();

    final southPath = Path()
      ..moveTo(0, center.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(size.width, center.dy)
      ..lineTo(center.dx, size.height)
      ..close();

    canvas.drawPath(northPath, Paint()..color = northColor);
    canvas.drawPath(southPath, Paint()..color = southColor);
  }

  @override
  bool shouldRepaint(covariant _CompassDiamondNeedlePainter oldDelegate) {
    return oldDelegate.northColor != northColor ||
        oldDelegate.southColor != southColor;
  }
}

class _WindClockHandPainter extends CustomPainter {
  const _WindClockHandPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final headTipY = 2.0;
    final headBaseY = 20.0;
    final tailY = size.height - 2;

    canvas.drawLine(
      Offset(centerX, tailY + 1),
      Offset(centerX, headBaseY + 1),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round,
    );

    final shaftPaint = Paint()
      ..color = color.withValues(alpha: 0.92)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, tailY),
      Offset(centerX, headBaseY),
      shaftPaint,
    );

    final headPath = Path()
      ..moveTo(centerX, headTipY)
      ..lineTo(centerX + 7, headBaseY)
      ..lineTo(centerX - 7, headBaseY)
      ..close();
    canvas.drawPath(
      headPath.shift(const Offset(0, 1)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawPath(headPath, Paint()..color = color);

    canvas.drawLine(
      Offset(centerX, headTipY + 3),
      Offset(centerX, headBaseY - 2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..strokeWidth = 0.9
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset(centerX, centerY),
      2.8,
      Paint()..color = color.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _WindClockHandPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _TraditionalCompassRosePainter extends CustomPainter {
  const _TraditionalCompassRosePainter({
    required this.ringColor,
    required this.majorColor,
    required this.minorColor,
    required this.lightPetalColor,
    required this.darkPetalColor,
    required this.accentPetalColor,
    required this.centerGlowColor,
    required this.contrastFillColor,
  });

  final Color ringColor;
  final Color majorColor;
  final Color minorColor;
  final Color lightPetalColor;
  final Color darkPetalColor;
  final Color accentPetalColor;
  final Color centerGlowColor;
  final Color contrastFillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final outerRadius = radius - 4;
    final starRadius = radius * 0.66;

    final radialFill = Paint()
      ..color = contrastFillColor.withValues(alpha: 0.36);
    canvas.drawCircle(center, outerRadius, radialFill);

    final outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = ringColor;
    canvas.drawCircle(center, outerRadius, outerRingPaint);
    canvas.drawCircle(center, outerRadius * 0.68, outerRingPaint);
    canvas.drawCircle(
      center,
      outerRadius * 0.9,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = minorColor,
    );

    for (var i = 0; i < 32; i++) {
      final angle = (i * 360 / 32) * math.pi / 180;
      final isMajor = i % 4 == 0;
      final start = Offset(
        center.dx + math.cos(angle) * (outerRadius - (isMajor ? 16 : 8)),
        center.dy + math.sin(angle) * (outerRadius - (isMajor ? 16 : 8)),
      );
      final end = Offset(
        center.dx + math.cos(angle) * outerRadius,
        center.dy + math.sin(angle) * outerRadius,
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = isMajor ? majorColor : minorColor
          ..strokeWidth = isMajor ? 1.4 : 1,
      );
    }

    for (var i = 0; i < 8; i++) {
      final angle = (i * 45 - 90) * math.pi / 180;
      final nextAngle = ((i + 1) * 45 - 90) * math.pi / 180;
      final prevAngle = ((i - 1) * 45 - 90) * math.pi / 180;
      final tip = Offset(
        center.dx + math.cos(angle) * starRadius,
        center.dy + math.sin(angle) * starRadius,
      );
      final left = Offset(
        center.dx + math.cos(prevAngle) * (starRadius * 0.35),
        center.dy + math.sin(prevAngle) * (starRadius * 0.35),
      );
      final right = Offset(
        center.dx + math.cos(nextAngle) * (starRadius * 0.35),
        center.dy + math.sin(nextAngle) * (starRadius * 0.35),
      );
      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(center.dx, center.dy)
        ..lineTo(right.dx, right.dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = i.isEven ? darkPetalColor : lightPetalColor,
      );

      final innerTip = Offset(
        center.dx + math.cos(angle) * (starRadius * 0.38),
        center.dy + math.sin(angle) * (starRadius * 0.38),
      );
      final innerLeft = Offset(
        center.dx + math.cos(prevAngle) * (starRadius * 0.16),
        center.dy + math.sin(prevAngle) * (starRadius * 0.16),
      );
      final innerRight = Offset(
        center.dx + math.cos(nextAngle) * (starRadius * 0.16),
        center.dy + math.sin(nextAngle) * (starRadius * 0.16),
      );
      final innerPath = Path()
        ..moveTo(innerTip.dx, innerTip.dy)
        ..lineTo(innerLeft.dx, innerLeft.dy)
        ..lineTo(center.dx, center.dy)
        ..lineTo(innerRight.dx, innerRight.dy)
        ..close();
      canvas.drawPath(
        innerPath,
        Paint()
          ..style = PaintingStyle.fill
          ..color = i.isEven ? accentPetalColor : Colors.transparent,
      );
    }

    canvas.drawCircle(
      center,
      radius * 0.08,
      Paint()..color = ringColor.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      center,
      radius * 0.04,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _TraditionalCompassRosePainter oldDelegate) {
    return oldDelegate.ringColor != ringColor ||
        oldDelegate.majorColor != majorColor ||
        oldDelegate.minorColor != minorColor ||
        oldDelegate.lightPetalColor != lightPetalColor ||
        oldDelegate.darkPetalColor != darkPetalColor ||
        oldDelegate.accentPetalColor != accentPetalColor ||
        oldDelegate.centerGlowColor != centerGlowColor;
  }
}

enum _WindSpeedUnit { knots, kmh, mph, beaufort }

enum _ForecastRange {
  d1(1, '1 dia'),
  d3(3, '3 dias'),
  d7(7, '7 dias'),
  d15(15, '15 dias');

  const _ForecastRange(this.days, this.label);

  final int days;
  final String label;
}

enum _ForecastResolution {
  h6(360, '6h'),
  h3(180, '3h'),
  h1(60, '1h'),
  m15(15, '15m'),
  m20(20, '20m');

  const _ForecastResolution(this.minutes, this.label);

  final int minutes;
  final String label;
}

enum _ForecastDataSource { live, mock, fallback }

enum _ForecastFullscreenMode { none, forecastTable, meteoblueSea, windguru }

enum _CompassOverlayMode { off, realtime }

class _NoStretchScrollBehavior extends AppScrollBehavior {
  const _NoStretchScrollBehavior();
}

class _PendingSocialAttachmentCard extends StatelessWidget {
  const _PendingSocialAttachmentCard({
    required this.attachment,
    required this.onRemove,
  });

  final SpotSocialAttachmentDraft attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isImage = attachment.type == SpotSocialAttachmentType.image;
    return Stack(
      children: [
        Container(
          width: isImage ? 120 : 180,
          padding: EdgeInsets.all(isImage ? 0 : AppSpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: isImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    attachment.bytes,
                    width: 120,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 120,
                      height: 100,
                      child: Center(child: Text('Imagen no disponible')),
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_circle_fill_rounded),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        attachment.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton.filledTonal(
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            icon: const Icon(Icons.close_rounded),
          ),
        ),
      ],
    );
  }
}

class _SpotSocialAttachmentCard extends StatelessWidget {
  const _SpotSocialAttachmentCard({
    required this.attachment,
    required this.compact,
  });

  final SpotSocialAttachment attachment;
  final bool compact;

  Future<void> _openAttachment(BuildContext context) async {
    if (attachment.type == SpotSocialAttachmentType.image &&
        attachment.url.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog.fullscreen(
            child: Stack(
              children: [
                Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: InteractiveViewer(
                    child: Image.network(
                      attachment.url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          'No se pudo cargar la imagen.',
                          style: Theme.of(
                            dialogContext,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: IconButton.filled(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ],
            ),
          );
        },
      );
      return;
    }

    if (attachment.url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el adjunto.')),
      );
      return;
    }

    if (attachment.type == SpotSocialAttachmentType.video) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return _SpotSocialVideoViewerDialog(
            videoUrl: attachment.url,
            fileName: attachment.fileName,
          );
        },
      );
      return;
    }

    final uri = Uri.tryParse(attachment.url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el adjunto.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = compact ? 132.0 : 176.0;
    final height = compact ? 96.0 : 132.0;
    if (attachment.type == SpotSocialAttachmentType.image &&
        attachment.url.isNotEmpty) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openAttachment(context),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Image.network(
            attachment.url,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _SpotSocialAttachmentFallback(
              label: attachment.fileName,
              icon: Icons.broken_image_outlined,
              width: width,
            ),
          ),
        ),
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openAttachment(context),
      child: _SpotSocialAttachmentFallback(
        label: attachment.fileName,
        icon: attachment.type == SpotSocialAttachmentType.video
            ? Icons.play_circle_fill_rounded
            : Icons.image_rounded,
        width: width,
      ),
    );
  }
}

class _SpotSocialVideoViewerDialog extends StatefulWidget {
  const _SpotSocialVideoViewerDialog({
    required this.videoUrl,
    required this.fileName,
  });

  final String videoUrl;
  final String fileName;

  @override
  State<_SpotSocialVideoViewerDialog> createState() =>
      _SpotSocialVideoViewerDialogState();
}

class _SpotSocialVideoViewerDialogState
    extends State<_SpotSocialVideoViewerDialog> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;
  Object? _loadError;

  String _formatVideoDuration(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null) {
      _loadError = 'URL de video no valida.';
      return;
    }
    final controller = VideoPlayerController.networkUrl(uri);
    _controller = controller;
    _initializeFuture = controller
        .initialize()
        .then((_) {
          controller.play();
          controller.setLooping(true);
        })
        .catchError((error) {
          _loadError = error;
        });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: _loadError != null
                    ? Text(
                        'No se pudo reproducir el video.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                      )
                    : FutureBuilder<void>(
                        future: _initializeFuture,
                        builder: (context, snapshot) {
                          final controller = _controller;
                          if (snapshot.connectionState !=
                                  ConnectionState.done ||
                              controller == null ||
                              !controller.value.isInitialized) {
                            return const CircularProgressIndicator();
                          }
                          return AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: ValueListenableBuilder<VideoPlayerValue>(
                              valueListenable: controller,
                              builder: (context, value, _) {
                                return GestureDetector(
                                  onTap: () {
                                    if (value.isPlaying) {
                                      controller.pause();
                                    } else {
                                      controller.play();
                                    }
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      VideoPlayer(controller),
                                      if (!value.isPlaying)
                                        const Icon(
                                          Icons.play_circle_fill_rounded,
                                          color: Colors.white,
                                          size: 72,
                                        ),
                                      Positioned(
                                        left: AppSpacing.md,
                                        right: AppSpacing.md,
                                        bottom: AppSpacing.md,
                                        child: Container(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.sm,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.52,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              VideoProgressIndicator(
                                                controller,
                                                allowScrubbing: true,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: AppSpacing.xs,
                                                    ),
                                                colors: VideoProgressColors(
                                                  playedColor: Colors.white,
                                                  bufferedColor: Colors.white24,
                                                  backgroundColor:
                                                      Colors.white12,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: AppSpacing.xs,
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      if (value.isPlaying) {
                                                        controller.pause();
                                                      } else {
                                                        controller.play();
                                                      }
                                                    },
                                                    icon: Icon(
                                                      value.isPlaying
                                                          ? Icons.pause_rounded
                                                          : Icons
                                                                .play_arrow_rounded,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      '${_formatVideoDuration(value.position)} / ${_formatVideoDuration(value.duration)}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: IconButton.filled(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: IgnorePointer(
                  child: Text(
                    widget.fileName,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotSocialAttachmentFallback extends StatelessWidget {
  const _SpotSocialAttachmentFallback({
    required this.label,
    required this.icon,
    required this.width,
  });

  final String label;
  final IconData icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _SocialAttachmentSelection {
  const _SocialAttachmentSelection({
    required this.isVideo,
    required this.source,
  });

  final bool isVideo;
  final ImageSource source;
}

class _SpotChatEntry {
  const _SpotChatEntry._({
    required this.id,
    required this.postId,
    required this.authorUsername,
    required this.authorDisplayName,
    required this.message,
    required this.createdAt,
    required this.isMine,
    required this.attachments,
    required this.replyCount,
    required this.isReply,
    this.parentAuthor,
    this.parentMessage,
  });

  factory _SpotChatEntry.post({
    required String id,
    required String authorUsername,
    required String authorDisplayName,
    required String message,
    required DateTime createdAt,
    required bool isMine,
    required List<SpotSocialAttachment> attachments,
    required int replyCount,
  }) {
    return _SpotChatEntry._(
      id: id,
      postId: id,
      authorUsername: authorUsername,
      authorDisplayName: authorDisplayName,
      message: message,
      createdAt: createdAt,
      isMine: isMine,
      attachments: attachments,
      replyCount: replyCount,
      isReply: false,
    );
  }

  factory _SpotChatEntry.reply({
    required String id,
    required String postId,
    required String authorUsername,
    required String authorDisplayName,
    required String message,
    required DateTime createdAt,
    required bool isMine,
    required List<SpotSocialAttachment> attachments,
    required int replyCount,
    required String parentAuthor,
    required String parentMessage,
  }) {
    return _SpotChatEntry._(
      id: id,
      postId: postId,
      authorUsername: authorUsername,
      authorDisplayName: authorDisplayName,
      message: message,
      createdAt: createdAt,
      isMine: isMine,
      attachments: attachments,
      replyCount: replyCount,
      isReply: true,
      parentAuthor: parentAuthor,
      parentMessage: parentMessage,
    );
  }

  final String id;
  final String postId;
  final String authorUsername;
  final String authorDisplayName;
  final String message;
  final DateTime createdAt;
  final bool isMine;
  final List<SpotSocialAttachment> attachments;
  final int replyCount;
  final bool isReply;
  final String? parentAuthor;
  final String? parentMessage;
}

class _SwipeReplyMessageWrapper extends StatefulWidget {
  const _SwipeReplyMessageWrapper({
    required this.child,
    required this.onReplyTriggered,
    required this.accentColor,
    required this.manageColor,
    this.onManageTriggered,
  });

  final Widget child;
  final VoidCallback onReplyTriggered;
  final Color accentColor;
  final Color manageColor;
  final VoidCallback? onManageTriggered;

  @override
  State<_SwipeReplyMessageWrapper> createState() =>
      _SwipeReplyMessageWrapperState();
}

class _SwipeReplyMessageWrapperState extends State<_SwipeReplyMessageWrapper> {
  static const double _maxReveal = 72;
  static const double _triggerThreshold = 44;

  double _dragOffset = 0;
  _SwipeMessageAction? _triggeredAction;
  _SwipeMessageAction? _crossedThresholdAction;

  @override
  Widget build(BuildContext context) {
    final leftRevealProgress = (-_dragOffset / _maxReveal).clamp(0.0, 1.0);
    final rightRevealProgress = (_dragOffset / _maxReveal).clamp(0.0, 1.0);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) {
        _triggeredAction = null;
        _crossedThresholdAction = null;
      },
      onHorizontalDragUpdate: (details) {
        final minOffset = widget.onManageTriggered == null
            ? -_maxReveal
            : -_maxReveal;
        final maxOffset = widget.onManageTriggered == null ? 0.0 : _maxReveal;
        final nextOffset = (_dragOffset + details.delta.dx).clamp(
          minOffset,
          maxOffset,
        );
        if (nextOffset == _dragOffset) {
          return;
        }
        final crossedThresholdAction = nextOffset <= -_triggerThreshold
            ? _SwipeMessageAction.reply
            : (nextOffset >= _triggerThreshold &&
                  widget.onManageTriggered != null)
            ? _SwipeMessageAction.manage
            : null;
        if (crossedThresholdAction != null &&
            crossedThresholdAction != _crossedThresholdAction) {
          _crossedThresholdAction = crossedThresholdAction;
          HapticFeedback.selectionClick();
        } else if (crossedThresholdAction == null &&
            _crossedThresholdAction != null) {
          _crossedThresholdAction = null;
        }
        setState(() {
          _dragOffset = nextOffset;
        });
      },
      onHorizontalDragEnd: (_) {
        if (_triggeredAction == null && _dragOffset <= -_triggerThreshold) {
          _triggeredAction = _SwipeMessageAction.reply;
          widget.onReplyTriggered();
        } else if (_triggeredAction == null &&
            _dragOffset >= _triggerThreshold &&
            widget.onManageTriggered != null) {
          _triggeredAction = _SwipeMessageAction.manage;
          widget.onManageTriggered!.call();
        }
        setState(() {
          _dragOffset = 0;
        });
        _crossedThresholdAction = null;
      },
      onHorizontalDragCancel: () {
        setState(() {
          _dragOffset = 0;
        });
        _crossedThresholdAction = null;
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.onManageTriggered != null)
            Positioned(
              left: AppSpacing.sm,
              child: Opacity(
                opacity: rightRevealProgress,
                child: Transform.scale(
                  scale: 0.8 + (rightRevealProgress * 0.28),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: widget.manageColor.withValues(alpha: 0.88),
                  ),
                ),
              ),
            ),
          Positioned(
            right: AppSpacing.sm,
            child: Opacity(
              opacity: leftRevealProgress,
              child: Transform.scale(
                scale: 0.8 + (leftRevealProgress * 0.28),
                child: Icon(
                  Icons.reply_rounded,
                  color: widget.accentColor.withValues(alpha: 0.88),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

enum _SwipeMessageAction { reply, manage }

enum _SpotDetailSection { prevision, live, webcam, social }

class _ForecastLoadResult {
  const _ForecastLoadResult({
    required this.rows,
    required this.source,
    this.message,
    this.technicalError,
  });

  final List<_ForecastRow> rows;
  final _ForecastDataSource source;
  final String? message;
  final String? technicalError;
}

class _AemetBeachForecastLoadResult {
  const _AemetBeachForecastLoadResult({
    required this.data,
    required this.source,
    this.message,
    this.technicalError,
  });

  final List<AemetBeachForecastData> data;
  final _ForecastDataSource source;
  final String? message;
  final String? technicalError;
}

class _AemetCoastalForecastLoadResult {
  const _AemetCoastalForecastLoadResult({
    required this.data,
    required this.source,
    this.message,
    this.technicalError,
  });

  final AemetCoastalForecastData? data;
  final _ForecastDataSource source;
  final String? message;
  final String? technicalError;
}

class _MeteoblueCurrentDayLoadResult {
  const _MeteoblueCurrentDayLoadResult({
    required this.snapshot,
    required this.source,
    this.message,
    this.technicalError,
  });

  final MeteoblueCurrentDaySnapshot snapshot;
  final _ForecastDataSource source;
  final String? message;
  final String? technicalError;
}

class _MeteosourceCurrentDayLoadResult {
  const _MeteosourceCurrentDayLoadResult({
    required this.snapshot,
    required this.source,
    this.message,
    this.technicalError,
  });

  final MeteosourceCurrentDaySnapshot snapshot;
  final _ForecastDataSource source;
  final String? message;
  final String? technicalError;
}

class _MeteostatDayLoadResult {
  const _MeteostatDayLoadResult({
    required this.snapshot,
    required this.source,
    this.message,
    this.technicalError,
  });

  final MeteostatDaySnapshot snapshot;
  final _ForecastDataSource source;
  final String? message;
  final String? technicalError;
}

class _LiveStationsLoadResult {
  const _LiveStationsLoadResult({
    required this.stations,
    required this.liveDataByStation,
    required this.historicalSeriesByStation,
    required this.source,
    this.message,
    this.technicalError,
  });

  final List<_NearbyStation> stations;
  final Map<String, _StationLiveData> liveDataByStation;
  final Map<String, List<_HistoricalWindPoint>> historicalSeriesByStation;
  final _LiveStationsDataSource source;
  final String? message;
  final String? technicalError;
}

enum _LiveStationsDataSource { real, unavailable }
