import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/notifications/local_notifications_service.dart';
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
import 'package:windwisher/features/spots/infrastructure/data/spot_capabilities_catalog.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';
import 'package:windwisher/features/spots/presentation/pages/wind_map_page.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/chat/widgets/spot_chat_widgets.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/forecast/widgets/forecast_accuracy_card.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/forecast/widgets/tables/aemet/aemet_forecast_tables.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/forecast/widgets/tables/meteoblue/meteoblue_forecast_supplement_card.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/forecast/widgets/tables/meteosource/meteosource_forecast_supplement_card.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/forecast/widgets/tables/meteostat/meteostat_day_supplement_card.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/forecast/widgets/tables/windguru/windguru_forecast_card.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/webcam/webcam_player_page.dart';
import 'package:windwisher/features/spots/infrastructure/services/spot_social_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'tabs/forecast/models/forecast_models.dart';
part 'tabs/forecast/models/windguru_embed_config.dart';
part 'tabs/forecast/forecast_actions_controller.dart';
part 'tabs/forecast/forecast_data_controller.dart';
part 'tabs/forecast/forecast_fullscreen_section.dart';
part 'tabs/forecast/forecast_rows_controller.dart';
part 'tabs/forecast/forecast_section.dart';
part 'tabs/forecast/forecast_status_widgets.dart';
part 'tabs/forecast/forecast_supplement_loaders.dart';
part 'tabs/forecast/forecast_supplements_section.dart';
part 'tabs/forecast/forecast_table_section.dart';
part 'tabs/forecast/widgets/tables/shared/forecast_table_selectors.dart';
part 'tabs/live/models/live_history_models.dart';
part 'tabs/live/models/live_station_models.dart';
part 'tabs/live/models/live_station_registry.dart';
part 'tabs/live/live_actions_controller.dart';
part 'tabs/live/live_alarms_controller.dart';
part 'tabs/live/live_alarms_section.dart';
part 'tabs/live/live_compass_section.dart';
part 'tabs/live/live_formatters.dart';
part 'tabs/live/live_history_controller.dart';
part 'tabs/live/live_history_data_loader.dart';
part 'tabs/live/live_history_forecast_overlay.dart';
part 'tabs/live/live_history_helpers.dart';
part 'tabs/live/live_history_section.dart';
part 'tabs/live/live_history_series_controller.dart';
part 'tabs/live/live_section.dart';
part 'tabs/live/live_station_actions.dart';
part 'tabs/live/live_station_data_loader.dart';
part 'tabs/live/live_station_metadata_loader.dart';
part 'tabs/live/live_station_payload_loader.dart';
part 'tabs/live/live_station_selection.dart';
part 'tabs/live/live_stations_controller.dart';
part 'tabs/live/live_wind_legend_dialog.dart';
part 'tabs/live/widgets/live_alarm_widgets.dart';
part 'tabs/live/widgets/live_compass_painters.dart';
part 'tabs/live/widgets/live_history_chart_legend.dart';
part 'tabs/live/widgets/live_history_chart_painters.dart';
part 'tabs/live/widgets/live_history_chart_shell.dart';
part 'tabs/live/widgets/live_history_comparison_controls.dart';
part 'tabs/live/widgets/live_history_header.dart';
part 'tabs/live/widgets/live_history_load_card.dart';
part 'tabs/live/widgets/live_history_range_controls.dart';
part 'tabs/live/widgets/live_metrics_grid.dart';
part 'tabs/live/widgets/live_provider_label.dart';
part 'tabs/live/widgets/live_station_actions_row.dart';
part 'tabs/live/widgets/live_station_dropdown.dart';
part 'tabs/live/widgets/live_wind_unit_selector.dart';
part 'tabs/live/widgets/live_wind_units.dart';
part 'tabs/live/widgets/live_wind_loading_card.dart';
part 'tabs/webcam/webcam_section.dart';
part 'tabs/chat/social_chat_actions.dart';
part 'tabs/chat/social_chat_attachments.dart';
part 'tabs/chat/social_chat_lifecycle.dart';
part 'tabs/chat/social_chat_section.dart';

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
    this.capabilities = SpotCapabilities.empty,
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
    this.portusRealtimeWindClient,
    this.useLocalPersistence = EnvConfig.spotsLocalPersistenceEnabled,
    this.openChatInitially = false,
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
  final SpotCapabilities capabilities;
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
  final PortusRealtimeWindClient? portusRealtimeWindClient;
  final bool useLocalPersistence;
  final bool openChatInitially;

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
    capabilities: capabilities,
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
  static const String _degreeSymbol = '\u00B0';
  late _SpotDetailSection _section;
  String _forecastProvider = 'Open-Meteo';
  late String _forecastModel;
  _ForecastRange _forecastRange = _ForecastRange.d3;
  _ForecastResolution _forecastResolution = _ForecastResolution.h3;
  String? _historyForecastProvider;
  String? _historyForecastModel;
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
  String? _historyChartFocusKey;
  String? _historyChartFullscreenFocusKey;
  WebViewController? _windguruController;
  WebViewController? _windguruFullscreenController;
  bool _isLiveRefreshing = false;
  bool _isHistoricalRefreshing = false;
  bool _isHistoricalLoading = false;
  bool _liveSectionLoadRequested = false;
  bool _alarmCatalogHydrationRequested = false;
  bool _socialHydrationRequested = false;

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

  // Social chat state lives in pages/spot_detail/tabs/chat.
  final ScrollController _socialFeedScrollController = ScrollController();
  final GlobalKey _socialComposerKey = GlobalKey();
  final GlobalKey _lastSocialMessageKey = GlobalKey();
  final FocusNode _socialPostFocusNode = FocusNode();
  final FocusNode _socialReplyFocusNode = FocusNode();
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
  int _socialOnlineCount = 0;
  Set<String> _socialTypingUsers = const <String>{};
  List<SpotSocialAttachmentDraft> _pendingSocialPostAttachments =
      const <SpotSocialAttachmentDraft>[];
  List<SpotSocialAttachmentDraft> _pendingSocialReplyAttachments =
      const <SpotSocialAttachmentDraft>[];
  late final SpotSocialClient _spotSocialClient;
  late final SpotChatRealtimeController _spotChatRealtimeController;
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
  late final PortusRealtimeWindClient _portusRealtimeWindClient;
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
    _section = widget.openChatInitially
        ? _SpotDetailSection.social
        : _SpotDetailSection.prevision;
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
    _portusRealtimeWindClient =
        widget.portusRealtimeWindClient ?? PortusRealtimeWindClient();
    _openMeteoWindMapGridClient = OpenMeteoWindMapGridClient();
    _initializeSocialChat();
    _forecastProvider =
        widget.capabilities.defaultForecastProvider ?? _forecastProvider;
    _forecastModel =
        _defaultForecastModelFromCapabilities(_forecastProvider) ??
        getSpotDefaultForecastModel(
          spotName: widget.name,
          spotArea: widget.area,
          spotBeachCode: widget.aemetBeachCode,
          spotBeachCodes: widget.aemetBeachCodes,
          provider: _forecastProvider,
        ) ??
        _modelsForProvider(_forecastProvider).first;
    _forecastRowsFuture = _loadForecastRows();
    if (_section == _SpotDetailSection.social) {
      final didStartSocialHydration = _ensureSocialSectionHydrated();
      _enterSocialChatSection(loadFeed: !didStartSocialHydration);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_liveSectionLoadRequested) {
        unawaited(_loadLiveStations());
      }
      _resumeSocialChatIfVisible();
      return;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeSocialChat();
    _historyChartScrollController.dispose();
    _historyChartFullscreenScrollController.dispose();
    super.dispose();
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

  void _setSection(_SpotDetailSection section) {
    if (_section == section) {
      if (section == _SpotDetailSection.live) {
        _ensureLiveSectionLoaded();
      }
      if (section == _SpotDetailSection.social) {
        final didStartSocialHydration = _ensureSocialSectionHydrated();
        if (!didStartSocialHydration) {
          _focusOrStartSocialChat();
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
      _leaveSocialChatSection();
    }
    if (section == _SpotDetailSection.live) {
      _ensureLiveSectionLoaded();
    }
    if (section == _SpotDetailSection.social) {
      final didStartSocialHydration = _ensureSocialSectionHydrated();
      _enterSocialChatSection(loadFeed: !didStartSocialHydration);
    }
  }

  void _ensureLiveSectionLoaded() {
    if (!_alarmCatalogHydrationRequested) {
      _alarmCatalogHydrationRequested = true;
      unawaited(_hydrateAlarmCatalog());
    }
    if (_liveSectionLoadRequested) {
      return;
    }
    _liveSectionLoadRequested = true;
    unawaited(_loadLiveStations());
  }

  bool _ensureSocialSectionHydrated() {
    if (_socialHydrationRequested) {
      return false;
    }
    _socialHydrationRequested = true;
    _hydrateSocialChat();
    return true;
  }

  void _showSocialSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                    _SpotDetailSection.webcam => _buildWebcamSection(textTheme),
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

enum _CompassOverlayMode { off, realtime }

class _NoStretchScrollBehavior extends AppScrollBehavior {
  const _NoStretchScrollBehavior();
}

enum _SpotDetailSection { prevision, live, webcam, social }
