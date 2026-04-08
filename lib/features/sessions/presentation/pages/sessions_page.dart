import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as app_permissions;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/profile/di/profile_module.dart';
import 'package:windwisher/features/sessions/di/sessions_module.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/domain/entities/session_view_preferences.dart';
import 'package:windwisher/features/sessions/presentation/builders/start_session_recorded_session_builder.dart';
import 'package:windwisher/features/sessions/presentation/logic/start_session_capture_logic.dart';
import 'package:windwisher/features/sessions/presentation/logic/start_session_device_detection_logic.dart';
import 'package:windwisher/features/sessions/presentation/logic/start_session_location_logic.dart';
import 'package:windwisher/features/sessions/presentation/logic/start_session_media_logic.dart';
import 'package:windwisher/features/sessions/presentation/mappers/my_sessions_mapper.dart';
import 'package:windwisher/features/sessions/presentation/mappers/session_gear_mapper.dart';
import 'package:windwisher/features/sessions/presentation/models/my_sessions_models.dart';
import 'package:windwisher/features/sessions/presentation/models/session_gear_models.dart';
import 'package:windwisher/features/sessions/presentation/mappers/start_session_mapper.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';
import 'package:windwisher/features/sessions/presentation/pages/my_sessions_page.dart';
import 'package:windwisher/features/sessions/presentation/pages/session_detail_page.dart';
import 'package:windwisher/features/sessions/presentation/pages/start_session_page.dart';
import 'package:windwisher/features/sessions/presentation/widgets/my_sessions/my_session_card.dart';
import 'package:windwisher/features/sessions/presentation/widgets/shared/session_device_dialog.dart';
import 'package:windwisher/features/sessions/presentation/widgets/shared/session_gear_dialog.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_capture_status_card.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_add_device_dialog.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_device_capabilities_dialog.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_selected_device_card.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_start_panel.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_stop_recording_dialog.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_synced_pending_card.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_upload_dialog.dart';
import 'package:windwisher/features/spots/di/spots_module.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';

typedef _LinkedDevice = LinkedDevice;
typedef _RecordedSession = RecordedSession;

class SessionsPage extends StatefulWidget {
  const SessionsPage({
    super.key,
    this.onStartTabChanged,
    this.useLocalPersistence,
  });

  final ValueChanged<bool>? onStartTabChanged;
  final bool? useLocalPersistence;

  @override
  State<SessionsPage> createState() => SessionsPageState();
}

class SessionsPageState extends State<SessionsPage> {
  static const String _phoneDeviceId = 'phone-1';
  static const double _gpsSampleMaxAccuracyMeters = 25;
  static const double _gpsMaxPlausibleSpeedKnots = 65;
  static const int _minRecordedTrackPoints = 2;
  static const Duration _minRecordedTrackDuration = Duration(minutes: 1);
  static const double _minRecordedTrackDistanceMeters = 20;
  static const double _autoPauseSpeedKnots = 1.5;
  static const double _autoResumeSpeedKnots = 4;
  static const Duration _autoPauseDelay = Duration(minutes: 1);
  static const Duration _autoResumeDelay = Duration(seconds: 6);
  static const double _accelerationEventThresholdG = 1.8;
  static const double _rotationEventThresholdDegPerSec = 320;
  static const double _movingAverageMinSpeedKnots = 4;
  static const Duration _motionEventCooldown = Duration(seconds: 20);
  static const double _jumpMinManeuverG = 1.35;
  static const double _jumpMinManeuverRotationDegPerSec = 220;
  static const double _jumpLandingThresholdG = 1.7;
  static const Duration _jumpMinAirTime = Duration(milliseconds: 800);
  static const Duration _jumpMaxAirTime = Duration(seconds: 8);
  static const Duration _jumpCooldown = Duration(seconds: 8);
  static const String _defaultSessionSummary =
      'Track sincronizado con sensores de velocidad, GPS y eventos.';
  static const Set<String> _templateDeviceIds = {'woo-1', 'watch-1'};
  static const _LinkedDevice _defaultPhoneDevice = _LinkedDevice(
    id: _phoneDeviceId,
    name: 'Telefono del usuario',
    kind: 'Dispositivo Android',
    status: 'Listo',
    lastSync: 'Disponible en este dispositivo',
    family: 'phone',
    placement: 'local',
    physicalSensorKeys: <String>[
      'gps',
      'accelerometer',
      'gyroscope',
      'magnetometer',
    ],
    isSessionEligible: true,
  );
  late final SessionsModule _sessionsModule;
  late final SpotsModule _spotsModule;
  late final ProfileModule _profileModule;
  List<SpotItem> _spotsCatalog = const <SpotItem>[];
  final List<_LinkedDevice> _devices = [];
  final List<SessionDetectedCompatibleDeviceData> _supportedDetectedDevices =
      <SessionDetectedCompatibleDeviceData>[];

  String? _selectedDeviceId;
  _SessionTab _sessionTab = _SessionTab.start;
  String? _lastImportHint;
  final TextEditingController _sessionSearchController =
      TextEditingController();
  String _sessionFilterDevice = 'Todos';
  String _sessionSort = 'Mas recientes';
  String? _lastUsedGearSetupId;
  String _lastUsedUploadSpot = '';
  final List<_RecordedSession> _sessionFeed = [];
  final List<SessionImportedPendingResult> _syncedPendingSessions = [];
  String? _syncedPendingDeviceId;
  _SessionCaptureState _captureState = _SessionCaptureState.ready;
  DateTime? _recordingStartedAt;
  Timer? _recordingTicker;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  final List<SessionCaptureSample> _recordingSamples = <SessionCaptureSample>[];
  final List<double> _recordingTimelineKnots = <double>[];
  double _recordingDistanceMeters = 0;
  double _recordingMaxSpeedKnots = 0;
  double? _lastGpsAccuracyMeters;
  Duration _recordingMovingDuration = Duration.zero;
  Duration _recordingAutoPausedDuration = Duration.zero;
  Duration _recordingLowSpeedCandidateDuration = Duration.zero;
  Duration _recordingResumeCandidateDuration = Duration.zero;
  int _recordingAutoPauseCount = 0;
  int _recordingRawPositionCount = 0;
  int _recordingRejectedAccuracyCount = 0;
  int _recordingRejectedPlausibilityCount = 0;
  int _recordingAccelerationEventCount = 0;
  int _recordingRotationEventCount = 0;
  double _recordingMaxAccelerationG = 0;
  double _recordingMaxRotationDegPerSec = 0;
  final List<double> _recentAccelerationGs = <double>[];
  final List<SessionJumpRecord> _recordingJumpHistory = <SessionJumpRecord>[];
  DateTime? _lastAccelerationEventAt;
  DateTime? _lastRotationEventAt;
  DateTime? _lastJumpRecordedAt;
  SessionPendingJumpCandidate? _pendingJumpCandidate;
  bool _isAutoPaused = false;
  final ImagePicker _imagePicker = ImagePicker();

  static const String _sortMostRecent = 'Mas recientes';
  static const int _accelerationPeakWindowSize = 3;
  static const double _accelerationPeakConfirmationRatio = 0.85;
  static const int _accelerationPeakRequiredMatches = 2;

  @override
  void initState() {
    super.initState();
    final useLocalPersistence =
        widget.useLocalPersistence ?? EnvConfig.sessionsLocalPersistenceEnabled;
    _sessionsModule = useLocalPersistence
        ? SessionsModule.auto(
            encodeInsights: _encodeRecordedSessionInsights,
            decodeInsights: _decodeRecordedSessionInsights,
          )
        : SessionsModule.inMemory();
    _spotsModule = useLocalPersistence
        ? SpotsModule.auto()
        : SpotsModule.inMemory();
    _profileModule = _resolveProfileModule();
    _spotsCatalog = _spotsModule.getSpots();
    _devices.addAll(_sessionsModule.getLinkedDevices());
    _sessionFeed.addAll(_sessionsModule.getRecordedSessions());
    _selectedDeviceId = _sessionsModule.getSelectedDeviceId();
    _pruneTemplateDevices();
    _hydrateSessionViewPreferences();
    _ensurePhoneDeviceAvailable();
    _ensureSelectedDevice();
    _sanitizeSessionViewPreferences();
    unawaited(_hydratePhoneDeviceInfo());
    unawaited(_hydrateDetectedExternalDevices());
    _hydrateRecordedSessions();
    _hydrateSpotsCatalog();
    _hydrateProfileGear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onStartTabChanged?.call(_sessionTab == _SessionTab.start);
    });
  }

  ProfileModule _resolveProfileModule() {
    return EnvConfig.profileLocalPersistenceEnabled
        ? ProfileModule.auto()
        : ProfileModule.inMemory();
  }

  void _saveSelectedDeviceId() {
    _sessionsModule.saveSelectedDeviceId(_selectedDeviceId);
  }

  void _hydrateSessionViewPreferences() {
    final value = _sessionsModule.getSessionViewPreferences();
    _sessionTab = value.selectedTabKey == 'mySessions'
        ? _SessionTab.mySessions
        : _SessionTab.start;
    _sessionFilterDevice = 'Todos';
    _sessionSort = _sortMostRecent;
    _lastUsedGearSetupId = value.lastUsedGearSetupId;
    _lastUsedUploadSpot = value.lastUsedUploadSpot;
  }

  void _sanitizeSessionViewPreferences() {
    final uploadSpotOptions = _availableUploadSpots();
    _sessionFilterDevice = 'Todos';
    _sessionSort = _sortMostRecent;
    if (uploadSpotOptions.isNotEmpty &&
        !uploadSpotOptions.contains(_lastUsedUploadSpot)) {
      _lastUsedUploadSpot = uploadSpotOptions.first;
    }
    _saveSessionViewPreferences();
  }

  void _saveSessionViewPreferences() {
    final value = SessionViewPreferences(
      selectedTabKey: _sessionTab == _SessionTab.mySessions
          ? 'mySessions'
          : 'start',
      filterDeviceName: _sessionFilterDevice,
      sortOrder: _sessionSort,
      lastUsedGearSetupId: _lastUsedGearSetupId,
      lastUsedUploadSpot: _lastUsedUploadSpot,
    );
    _sessionsModule.saveSessionViewPreferences(value);
  }

  Future<void> _hydrateRecordedSessions() async {
    final sessions = await _sessionsModule.getRecordedSessions.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _sessionFeed
        ..clear()
        ..addAll(sessions);
    });
  }

  Future<void> _hydrateSpotsCatalog() async {
    final spots = await _spotsModule.getSpots.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _spotsCatalog = spots;
    });
  }

  Future<void> _hydrateProfileGear() async {
    await _profileModule.gearController.hydrate();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Object? _encodeRecordedSessionInsights(Object value) {
    if (value is SessionInsightData) {
      return value.toJson();
    }
    return value;
  }

  Object _decodeRecordedSessionInsights(Object? value) {
    if (value is Map<String, dynamic>) {
      return SessionInsightData.fromJson(value);
    }
    return value ?? _emptySessionInsights(deviceKind: 'Dispositivo Android');
  }

  SessionInsightData _sessionInsightsForDetail(_RecordedSession session) {
    final insights = session.insights;
    if (insights is SessionInsightData) {
      return insights;
    }
    if (insights is Map<String, dynamic>) {
      return SessionInsightData.fromJson(insights);
    }
    return _emptySessionInsights(
      deviceKind: 'Dispositivo Android',
      events: const <String>[],
    );
  }

  SessionInsightData _emptySessionInsights({
    required String deviceKind,
    List<String> events = const <String>[],
  }) {
    return SessionInsightData.empty(
      deviceKind: deviceKind,
      deviceSensorKeys: SessionInsightData.physicalSensorsForDeviceKind(
        deviceKind,
      ).toList(growable: false),
      events: events,
    );
  }

  @override
  void dispose() {
    _recordingTicker?.cancel();
    _positionSubscription?.cancel();
    _userAccelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _sessionSearchController.dispose();
    super.dispose();
  }

  String _autoDetectedDeviceStatus(_LinkedDevice device) {
    if (device.status == 'Pendiente' || device.status == 'Desconectado') {
      return device.status;
    }

    final isSelected = _selectedDeviceId == device.id;
    if (!isSelected) {
      return 'Conectado';
    }

    switch (_captureState) {
      case _SessionCaptureState.ready:
        return 'Listo';
      case _SessionCaptureState.recording:
        return 'Grabando';
      case _SessionCaptureState.finished:
        return 'Sesión finalizada';
      case _SessionCaptureState.syncing:
        return 'Sincronizando';
      case _SessionCaptureState.synced:
        return 'Sincronizado';
    }
  }

  Color _statusChipColor(String status) {
    switch (status) {
      case 'Listo':
      case 'Conectado':
      case 'Sincronizado':
        return const Color(0xFF2E7D32);
      case 'Grabando':
      case 'Sincronizando':
      case 'Sesion finalizada':
        return const Color(0xFF1565C0);
      case 'Pendiente':
        return const Color(0xFFF9A825);
      case 'Desconectado':
      default:
        return const Color(0xFFC62828);
    }
  }

  IconData _capabilitiesActionIcon(String kind) {
    final normalized = kind.toLowerCase();
    if (normalized.contains('watch') || normalized.contains('smartwatch')) {
      return Icons.watch_rounded;
    }
    if (normalized.contains('android') || normalized.contains('telefono')) {
      return Icons.phone_android_rounded;
    }
    return Icons.memory_rounded;
  }

  String _deviceAvailabilityLabel(_LinkedDevice device) {
    if (device.id == _phoneDeviceId) {
      return 'Disponible en este dispositivo';
    }
    return device.lastSync;
  }

  Future<void> _removeDevice(_LinkedDevice device) async {
    if (device.id == _phoneDeviceId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El teléfono del usuario siempre debe estar disponible.',
          ),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar dispositivo'),
          content: Text('¿Quieres eliminar ${device.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      _devices.removeWhere((d) => d.id == device.id);
      _sessionsModule.deleteLinkedDevice(device.id);
      if (_selectedDeviceId == device.id) {
        _selectedDeviceId = _devices.any((d) => d.id == _phoneDeviceId)
            ? _phoneDeviceId
            : (_devices.isEmpty ? null : _devices.first.id);
      }
      if (_sessionFilterDevice == device.name) {
        _sessionFilterDevice = 'Todos';
      }
      if (_syncedPendingDeviceId == device.id) {
        _syncedPendingDeviceId = null;
        _syncedPendingSessions.clear();
      }
    });
    _saveSelectedDeviceId();
    _saveSessionViewPreferences();
  }

  void _ensurePhoneDeviceAvailable() {
    final exists = _devices.any((device) => device.id == _phoneDeviceId);
    if (exists) {
      return;
    }
    _devices.add(_defaultPhoneDevice);
    _sessionsModule.saveLinkedDevice(_defaultPhoneDevice);
    _saveSelectedDeviceId();
  }

  Future<void> _hydratePhoneDeviceInfo() async {
    final phoneDevice =
        await StartSessionDeviceDetectionLogic.detectCurrentDevice(
          phoneDeviceId: _phoneDeviceId,
          fallbackDevice: _defaultPhoneDevice,
        );
    if (!mounted) {
      return;
    }

    final index = _devices.indexWhere((device) => device.id == _phoneDeviceId);
    final current = index >= 0 ? _devices[index] : null;
    if (current != null &&
        current.name == phoneDevice.name &&
        current.kind == phoneDevice.kind &&
        current.status == phoneDevice.status &&
        current.lastSync == phoneDevice.lastSync) {
      return;
    }

    setState(() {
      if (index >= 0) {
        _devices[index] = phoneDevice;
      } else {
        _devices.insert(0, phoneDevice);
      }
    });
    _sessionsModule.saveLinkedDevice(phoneDevice);
    _saveSelectedDeviceId();
  }

  Future<void> _hydrateDetectedExternalDevices() async {
    final detected =
        await StartSessionDeviceDetectionLogic.detectExternalSessionDevices();
    if (!mounted) {
      return;
    }
    setState(() {
      _supportedDetectedDevices
        ..clear()
        ..addAll(detected);
    });
  }

  void _pruneTemplateDevices() {
    final templateDevices = _devices
        .where((device) => _templateDeviceIds.contains(device.id))
        .toList(growable: false);
    if (templateDevices.isEmpty) {
      return;
    }

    for (final device in templateDevices) {
      _devices.removeWhere((item) => item.id == device.id);
      _sessionsModule.deleteLinkedDevice(device.id);
      if (_selectedDeviceId == device.id) {
        _selectedDeviceId = null;
      }
    }
  }

  List<String> _availableUploadSpots() {
    final names = _spotsCatalog
        .map((spot) => spot.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList(growable: false);
    names.sort();
    return names;
  }

  void _showRealIntegrationPendingMessage(String feature) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          '$feature todavia no esta conectado a datos reales. Hemos quitado la simulación para no inventar sesiones.',
        ),
      ),
    );
  }

  void _ensureSelectedDevice() {
    final eligibleDevices = _devices.where(
      (device) => device.isSessionEligible,
    );
    final exists = eligibleDevices.any(
      (device) => device.id == _selectedDeviceId,
    );
    if (exists) {
      _saveSelectedDeviceId();
      return;
    }
    final displayDevices = _devicesForDisplay();
    _selectedDeviceId = displayDevices.any((d) => d.id == _phoneDeviceId)
        ? _phoneDeviceId
        : (displayDevices.isEmpty ? null : displayDevices.first.id);
    _saveSelectedDeviceId();
  }

  String? _spotNameForSession(_RecordedSession session) {
    final spotName = session.spotName;
    if (spotName != null && spotName.isNotEmpty) {
      return spotName;
    }
    const prefix = 'Sesión en ';
    if (session.title.startsWith(prefix)) {
      final trimmed = session.title.substring(prefix.length).trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  String? _spotBackgroundForSession(_RecordedSession session) {
    final spotName = _spotNameForSession(session);
    if (spotName == null) {
      return null;
    }
    for (final spot in _spotsCatalog) {
      if (spot.name.trim().toLowerCase() == spotName.trim().toLowerCase()) {
        return spot.backgroundImagePath;
      }
    }
    return null;
  }

  List<_LinkedDevice> _devicesForDisplay() {
    final devices = List<_LinkedDevice>.from(
      _devices.where((device) => device.isSessionEligible),
    );
    devices.sort((a, b) {
      if (a.id == _phoneDeviceId) return -1;
      if (b.id == _phoneDeviceId) return 1;
      return 0;
    });
    return devices;
  }

  Future<void> deleteSelectedDeviceFromToolbar() async {
    final selected = _selectedDevice;
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay dispositivo seleccionado.')),
      );
      return;
    }
    await _removeDevice(selected);
  }

  void addDeviceFromToolbar() {
    _showAddDeviceSheet();
  }

  Future<void> _showAddDeviceSheet() async {
    await _showAddDeviceSheetInternal(retryAfterBluetoothActivation: true);
  }

  Future<void> _showAddDeviceSheetInternal({
    required bool retryAfterBluetoothActivation,
  }) async {
    final permissionsReady = await _requestExternalDeviceDiscoveryPermissions();
    if (!mounted) {
      return;
    }
    if (!permissionsReady) {
      await _showExternalDeviceDiscoveryUnavailableDialog(
        SessionExternalDeviceDiscoveryAvailability.unauthorized,
        retryAfterBluetoothActivation: retryAfterBluetoothActivation,
      );
      return;
    }

    final availability =
        await StartSessionDeviceDetectionLogic.externalDeviceDiscoveryAvailability();
    if (!mounted) {
      return;
    }
    if (availability != SessionExternalDeviceDiscoveryAvailability.ready) {
      await _showExternalDeviceDiscoveryUnavailableDialog(
        availability,
        retryAfterBluetoothActivation: retryAfterBluetoothActivation,
      );
      return;
    }

    await _hydrateDetectedExternalDevices();
    if (!mounted) {
      return;
    }

    final availableDevices = _detectedCompatibleDevices();
    final selectedDevice = await SessionAddDeviceDialog.show(
      context,
      availableDevices: availableDevices,
    );

    if (selectedDevice == null || !mounted) {
      return;
    }
    final linked = await _probeDetectedDeviceCapabilities(selectedDevice);
    if (!mounted) {
      return;
    }
    if (!linked.isSessionEligible) {
      final reason = switch (linked.family) {
        'watch' =>
          'Este reloj no tiene barómetro/altímetro y no sirve para grabar sesiones.',
        'board_sensor' =>
          'Este sensor de tabla no expone una fuente vertical válida.',
        _ => 'Este dispositivo detectado no es válido para grabar sesiones.',
      };
      await _showDetectedDeviceNotEligibleDialog(
        reason: reason,
        device: linked,
      );
      return;
    }

    setState(() {
      final linkedDevice = _LinkedDevice(
        id: linked.id,
        name: linked.customName,
        kind: linked.kind,
        status: linked.connectionState.isEmpty
            ? 'Vinculado'
            : linked.connectionState,
        lastSync:
            linked.firmwareVersion == null || linked.firmwareVersion!.isEmpty
            ? 'recién vinculado'
            : 'firmware ${linked.firmwareVersion}',
        family: linked.family,
        placement: linked.placement,
        physicalSensorKeys: linked.physicalSensorKeys,
        isSessionEligible: _LinkedDevice.isSessionEligibleForDetectedDevice(
          family: linked.family,
          physicalSensorKeys: linked.physicalSensorKeys,
        ),
      );
      _devices.insert(0, linkedDevice);
      _sessionsModule.saveLinkedDevice(linkedDevice);
      _selectedDeviceId = linked.id;
    });
    _saveSelectedDeviceId();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${linked.customName} ya esta vinculado y seleccionado para Start Session.',
        ),
      ),
    );
  }

  Future<void> _showDetectedDeviceNotEligibleDialog({
    required String reason,
    required SessionDetectedCompatibleDeviceData device,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Este dispositivo no sirve para grabar sesiones'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.customName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${device.kind} · ${device.connectionState}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(reason),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    device.sensorSummary,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Future<SessionDetectedCompatibleDeviceData> _probeDetectedDeviceCapabilities(
    SessionDetectedCompatibleDeviceData device,
  ) async {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            title: Text('Comprobando sensores'),
            content: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text('Conectando al dispositivo para leer servicios.'),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      return await StartSessionDeviceDetectionLogic.probeExternalSessionDevice(
        device,
      );
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  Future<bool> _requestExternalDeviceDiscoveryPermissions() async {
    if (Platform.isAndroid) {
      final statuses = await <app_permissions.Permission>[
        app_permissions.Permission.bluetoothScan,
        app_permissions.Permission.bluetoothConnect,
      ].request();
      return statuses.values.every(_isPermissionUsable);
    }

    if (Platform.isIOS) {
      final status = await app_permissions.Permission.bluetooth.request();
      return _isPermissionUsable(status);
    }

    return true;
  }

  bool _isPermissionUsable(app_permissions.PermissionStatus status) {
    return status.isGranted || status.isLimited;
  }

  Future<void> _showExternalDeviceDiscoveryUnavailableDialog(
    SessionExternalDeviceDiscoveryAvailability availability, {
    required bool retryAfterBluetoothActivation,
  }) async {
    final isBluetoothOff =
        availability == SessionExternalDeviceDiscoveryAvailability.bluetoothOff;
    final allowSettings =
        availability ==
            SessionExternalDeviceDiscoveryAvailability.unauthorized ||
        availability ==
            SessionExternalDeviceDiscoveryAvailability.locationServicesDisabled;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir dispositivo'),
          content: Text(
            _externalDeviceDiscoveryUnavailableMessage(availability),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
            if (allowSettings)
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Geolocator.openAppSettings();
                },
                child: const Text('Abrir ajustes'),
              ),
            if (isBluetoothOff)
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _requestExternalDeviceBluetoothActivation();
                  if (mounted && retryAfterBluetoothActivation) {
                    await _showAddDeviceSheetInternal(
                      retryAfterBluetoothActivation: false,
                    );
                  }
                },
                child: const Text('Activar Bluetooth'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _requestExternalDeviceBluetoothActivation() async {
    if (Platform.isAndroid) {
      try {
        await const AndroidIntent(
          action: 'android.bluetooth.adapter.action.REQUEST_ENABLE',
        ).launch();
        return;
      } catch (_) {
        await const AndroidIntent(
          action: 'android.settings.BLUETOOTH_SETTINGS',
        ).launch();
        return;
      }
    }

    await app_permissions.openAppSettings();
  }

  String _externalDeviceDiscoveryUnavailableMessage(
    SessionExternalDeviceDiscoveryAvailability availability,
  ) {
    return switch (availability) {
      SessionExternalDeviceDiscoveryAvailability.bluetoothOff =>
        'Para buscar relojes o sensores cercanos, primero activa Bluetooth. Te abriré el aviso del sistema y después volveré a intentar la búsqueda.',
      SessionExternalDeviceDiscoveryAvailability.unauthorized =>
        'WindWisher necesita permiso de Bluetooth para detectar relojes y sensores cercanos. Actívalo en los ajustes de la app y vuelve a intentar añadir el dispositivo.',
      SessionExternalDeviceDiscoveryAvailability.unsupported =>
        'Este dispositivo no permite buscar dispositivos Bluetooth LE desde la app.',
      SessionExternalDeviceDiscoveryAvailability.locationServicesDisabled =>
        'Android necesita los servicios de ubicación activos para algunos escaneos Bluetooth LE. Actívalos y vuelve a intentar añadir el dispositivo.',
      SessionExternalDeviceDiscoveryAvailability.ready =>
        'Bluetooth está listo para detectar dispositivos.',
      SessionExternalDeviceDiscoveryAvailability.unknown =>
        'No se ha podido comprobar el estado de Bluetooth. Revisa que esté activo y vuelve a intentar añadir el dispositivo.',
    };
  }

  List<SessionDetectedCompatibleDeviceData> _detectedCompatibleDevices() {
    final linkedIds = _devices.map((device) => device.id).toSet();
    return _supportedDetectedDevices
        .where((device) => !linkedIds.contains(device.id))
        .toList(growable: false);
  }

  Future<void> _configureSyncedSession(
    SessionImportedPendingResult imported,
  ) async {
    final device = _selectedDevice;
    if (device == null) {
      return;
    }

    final config = await _showUploadSessionDialog();
    if (!mounted || config == null) {
      return;
    }

    final sessionId = _newSessionId();
    final uploadedSessionPhotoPath = await _resolvePersistedSessionPhotoPath(
      sessionId: sessionId,
      candidatePath: config.sessionPhotoLocalPath,
    );
    if (!mounted) {
      return;
    }

    final session = StartSessionRecordedSessionBuilder.buildImportedSession(
      ImportedRecordedSessionBuilderInput(
        id: sessionId,
        deviceName: device.name,
        deviceKind: device.kind,
        imported: imported,
        config: StartSessionSaveConfigData(
          spot: config.spot,
          notes: config.notes,
          sessionMediaLabel: StartSessionMediaLogic.labelForSelection(
            config.mediaSelection,
          ),
          sessionPhotoLocalPath: uploadedSessionPhotoPath,
          gearSetupId: config.gearSetupId,
          gearSetupName: config.gearSetupName,
        ),
      ),
    );
    await _persistSessionIntoFeed(
      session,
      gearSetupId: config.gearSetupId,
      uploadSpot: config.spot,
      importedToRemove: imported,
    );
  }

  Future<void> _removeSyncedPendingSession(
    SessionImportedPendingResult imported,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar sesion sincronizada'),
          content: Text('¿Quieres eliminar ${imported.title}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      _syncedPendingSessions.remove(imported);
      if (_syncedPendingSessions.isEmpty) {
        _syncedPendingDeviceId = null;
      }
      _lastImportHint = _syncedPendingSessions.isEmpty
          ? null
          : 'Quedan ${_syncedPendingSessions.length} sesiones sincronizadas pendientes por configurar.';
    });
  }

  void _importSessionFile() {
    _showRealIntegrationPendingMessage('La importación de sesiones');
  }

  _LinkedDevice? get _selectedDevice {
    for (final device in _devices) {
      if (device.id == _selectedDeviceId) {
        return device;
      }
    }
    return null;
  }

  Set<String> _selectedDeviceCapabilities() {
    final selected = _selectedDevice;
    if (selected == null) {
      return const <String>{};
    }
    if (selected.physicalSensorKeys.isNotEmpty) {
      return selected.physicalSensorKeys.toSet();
    }
    return SessionInsightData.physicalSensorsForDeviceKind(selected.kind);
  }

  ({
    double motionEventMinSpeedKnots,
    double jumpMinTakeoffSpeedKnots,
    double jumpLandingMinSpeedKnots,
    String jumpDetectionMode,
  })
  _captureMeasurementPolicy() {
    return StartSessionCaptureLogic.captureMeasurementPolicyForDeviceKind(
      _selectedDevice?.kind,
    );
  }

  String _selectedDeviceSensorCountLabel() {
    final sensors = _selectedDeviceCapabilities().toList(growable: false)
      ..sort();
    if (sensors.isEmpty) {
      return 'Sensores aun no detectados';
    }

    final labels = sensors.map(_sensorDisplayLabel).toList(growable: false);
    if (labels.length <= 2) {
      return labels.join(' · ');
    }
    return '${labels.take(2).join(' · ')} +${labels.length - 2}';
  }

  String _sensorDisplayLabel(String sensorKey) {
    return switch (sensorKey) {
      'gps' => 'GPS',
      'accelerometer' => 'Acelerometro',
      'gyroscope' => 'Giroscopio',
      'magnetometer' => 'Magnetometro',
      'barometer' => 'Barometro',
      'altimeter' => 'Altimetro',
      'heart_rate' => 'Pulso',
      'temperature' => 'Temperatura',
      'humidity' => 'Humedad',
      _ => sensorKey,
    };
  }

  String _recordingElapsedText() {
    if (_recordingStartedAt == null) {
      return '--:--';
    }
    final elapsed = DateTime.now().difference(_recordingStartedAt!);
    return _formatDuration(elapsed);
  }

  String _recordingActiveText() {
    if (_recordingStartedAt == null) {
      return '--:--';
    }
    final elapsed = DateTime.now().difference(_recordingStartedAt!);
    final active = elapsed - _recordingAutoPausedDuration;
    return _formatDuration(active.isNegative ? Duration.zero : active);
  }

  String _recordingPausedText() {
    return _formatDuration(_recordingAutoPausedDuration);
  }

  String _recordingCurrentSpeedText() {
    if (_recordingSamples.isEmpty) {
      return '--';
    }
    final recentSamples = _recordingSamples.length <= 4
        ? _recordingSamples
        : _recordingSamples.sublist(_recordingSamples.length - 4);
    final smoothedKnots =
        recentSamples
            .map((sample) => sample.speedKnots)
            .reduce((a, b) => a + b) /
        recentSamples.length;
    return '${smoothedKnots.toStringAsFixed(1)} kt';
  }

  String _recordingMaxSpeedText() {
    if (_recordingMaxSpeedKnots <= 0) {
      return '--';
    }
    return '${_recordingMaxSpeedKnots.toStringAsFixed(1)} kt';
  }

  double _currentTrackSpeedKnots() {
    if (_recordingSamples.isEmpty) {
      return 0;
    }
    return _recordingSamples.last.speedKnots;
  }

  bool _isAutoPausePending() {
    if (_captureState != _SessionCaptureState.recording || _isAutoPaused) {
      return false;
    }
    return _recordingLowSpeedCandidateDuration > Duration.zero;
  }

  bool _hasGoodGpsSignal() {
    final accuracy = _lastGpsAccuracyMeters;
    return accuracy != null && accuracy <= 5;
  }

  bool _hasEnoughRecordedTrackForSave() {
    if (_recordingStartedAt == null || _recordingSamples.isEmpty) {
      return false;
    }
    final endedAt = _recordingSamples.last.timestamp;
    final duration = endedAt.difference(_recordingStartedAt!);
    final hasEnoughPoints = _recordingSamples.length >= _minRecordedTrackPoints;
    final hasEnoughDuration = duration >= _minRecordedTrackDuration;
    final hasEnoughDistance =
        _recordingDistanceMeters >= _minRecordedTrackDistanceMeters;
    return hasEnoughPoints && hasEnoughDuration && hasEnoughDistance;
  }

  int _saveReadinessSatisfiedRuleCount() {
    if (_recordingStartedAt == null || _recordingSamples.isEmpty) {
      return 0;
    }
    final endedAt = _recordingSamples.last.timestamp;
    final duration = endedAt.difference(_recordingStartedAt!);
    var count = 0;
    if (_recordingSamples.length >= _minRecordedTrackPoints) {
      count += 1;
    }
    if (duration >= _minRecordedTrackDuration) {
      count += 1;
    }
    if (_recordingDistanceMeters >= _minRecordedTrackDistanceMeters) {
      count += 1;
    }
    return count;
  }

  Future<bool> _confirmStopRealSessionRecording() async {
    final hasEnoughTrack = _hasEnoughRecordedTrackForSave();
    final hasGoodSignal = _hasGoodGpsSignal();
    final result = await SessionStopRecordingDialog.show(
      context,
      data: SessionStopRecordingDialogData(
        title: hasEnoughTrack
            ? 'Detener y revisar sesión'
            : 'Detener sin track suficiente',
        primaryMessage: hasEnoughTrack
            ? 'La sesión dejará de grabarse ahora.'
            : 'Todavia no hemos registrado suficiente track GPS para guardar esta sesión.',
        secondaryMessage: hasEnoughTrack
            ? 'Podrás revisar los datos y decidir si quieres guardarlos.'
            : 'Si detienes ahora, esta sesión se descartará.',
        requirementsMessage: hasEnoughTrack
            ? null
            : 'Necesitamos al menos 2 puntos GPS validos, 1 minuto de duracion y 20 metros de distancia.',
        gpsWarningMessage: hasEnoughTrack && !hasGoodSignal
            ? 'Aunque el GPS no este en OK ahora mismo, la sesión ya tiene track suficiente para revisarse y guardarse.'
            : null,
        lossWarningMessage: hasEnoughTrack
            ? 'Si sales sin guardar, se perderan los datos recogidos.'
            : 'Los datos recogidos hasta ahora se perderan.',
        confirmLabel: hasEnoughTrack
            ? 'Detener y revisar'
            : 'Detener y descartar',
      ),
    );
    return result;
  }

  void _resetRecordingState() {
    setState(() {
      _captureState = _SessionCaptureState.ready;
      _recordingStartedAt = null;
      _lastGpsAccuracyMeters = null;
      _clearRecordingCaptureData();
    });
  }

  void _clearRecordingCaptureData() {
    _recordingSamples.clear();
    _recordingTimelineKnots.clear();
    _recordingDistanceMeters = 0;
    _recordingMaxSpeedKnots = 0;
    _recordingMovingDuration = Duration.zero;
    _recordingAutoPausedDuration = Duration.zero;
    _recordingLowSpeedCandidateDuration = Duration.zero;
    _recordingResumeCandidateDuration = Duration.zero;
    _recordingAutoPauseCount = 0;
    _recordingRawPositionCount = 0;
    _recordingRejectedAccuracyCount = 0;
    _recordingRejectedPlausibilityCount = 0;
    _recordingAccelerationEventCount = 0;
    _recordingRotationEventCount = 0;
    _recordingMaxAccelerationG = 0;
    _recordingMaxRotationDegPerSec = 0;
    _recentAccelerationGs.clear();
    _recordingJumpHistory.clear();
    _lastAccelerationEventAt = null;
    _lastRotationEventAt = null;
    _lastJumpRecordedAt = null;
    _pendingJumpCandidate = null;
    _isAutoPaused = false;
  }

  void _beginRecordingCaptureState(DateTime startedAt) {
    _captureState = _SessionCaptureState.recording;
    _recordingStartedAt = startedAt;
    _lastImportHint = null;
    _lastGpsAccuracyMeters = null;
    _clearRecordingCaptureData();
  }

  Future<void> _cancelCaptureStreams() async {
    _recordingTicker?.cancel();
    _recordingTicker = null;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    await _userAccelerometerSubscription?.cancel();
    _userAccelerometerSubscription = null;
    await _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;
  }

  String _formatSessionDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  Future<void> _showDeviceCapabilitiesDialog() async {
    await SessionDeviceCapabilitiesDialog.show(
      context,
      capabilities: _selectedDeviceCapabilities(),
    );
  }

  Future<void> _onSessionControlPressed() async {
    final decision =
        StartSessionPresentationMapper.resolveCaptureControlDecision(
          phase: switch (_captureState) {
            _SessionCaptureState.ready => SessionCapturePhase.ready,
            _SessionCaptureState.recording => SessionCapturePhase.recording,
            _SessionCaptureState.finished => SessionCapturePhase.finished,
            _SessionCaptureState.syncing => SessionCapturePhase.syncing,
            _SessionCaptureState.synced => SessionCapturePhase.synced,
          },
          hasSelectedDevice: _selectedDevice != null,
          isPhoneDeviceSelected: _selectedDevice?.id == _phoneDeviceId,
        );

    switch (decision.action) {
      case SessionCaptureControlAction.showMessage:
        if (decision.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(decision.message!)));
        }
        return;
      case SessionCaptureControlAction.startRecording:
        await _startRealSessionRecording();
        return;
      case SessionCaptureControlAction.confirmStopRecording:
        final confirm = await _confirmStopRealSessionRecording();
        if (!mounted || !confirm) {
          return;
        }
        await _stopRealSessionRecording();
        return;
      case SessionCaptureControlAction.showSaveDialog:
        await _handleFinishedCaptureSave();
        return;
      case SessionCaptureControlAction.resetToReady:
        _resetRecordingState();
        return;
      case SessionCaptureControlAction.none:
        return;
    }
  }

  Future<void> _startRealSessionRecording() async {
    final locationDecision =
        await StartSessionLocationLogic.resolveLocationAccess();
    if (locationDecision.action == SessionLocationAccessAction.showMessage) {
      if (!mounted || locationDecision.message == null) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(locationDecision.message!)));
      return;
    }

    await _cancelCaptureStreams();
    _activateRecordingCapture();
    _startCaptureTicker();
    _attachCaptureStreams();
  }

  Future<void> _handleFinishedCaptureSave() async {
    final config = await _showUploadSessionDialog();
    if (!mounted || config == null) {
      return;
    }

    _beginCaptureSyncing(config);

    final sessionTiming = _buildCaptureSessionTiming();
    final sessionId = _newSessionId();
    final uploadedSessionPhotoPath = await _resolvePersistedSessionPhotoPath(
      sessionId: sessionId,
      candidatePath: config.sessionPhotoLocalPath,
    );
    if (!mounted) {
      return;
    }

    final session = _buildRecordedSessionFromCapture(
      id: sessionId,
      config: config,
      uploadedSessionPhotoPath: uploadedSessionPhotoPath,
      endedAt: sessionTiming.endedAt,
      duration: sessionTiming.duration,
    );

    await _persistSessionIntoFeed(
      session,
      gearSetupId: config.gearSetupId,
      uploadSpot: config.spot,
      markCaptureAsSynced: true,
    );
  }

  ({DateTime endedAt, Duration duration}) _buildCaptureSessionTiming() {
    final endedAt = _recordingSamples.isNotEmpty
        ? _recordingSamples.last.timestamp
        : DateTime.now();
    final duration = _recordingStartedAt == null
        ? Duration.zero
        : endedAt.difference(_recordingStartedAt!);
    return (endedAt: endedAt, duration: duration);
  }

  void _beginCaptureSyncing(
    ({
      String spot,
      String notes,
      SessionMediaSelection mediaSelection,
      String? sessionPhotoLocalPath,
      String? gearSetupId,
      String? gearSetupName,
    })
    config,
  ) {
    setState(() {
      _captureState = _SessionCaptureState.syncing;
      _lastUsedGearSetupId = config.gearSetupId;
      _lastUsedUploadSpot = config.spot;
    });
    _saveSessionViewPreferences();
  }

  Future<void> _persistSessionIntoFeed(
    _RecordedSession session, {
    required String? gearSetupId,
    required String uploadSpot,
    SessionImportedPendingResult? importedToRemove,
    bool markCaptureAsSynced = false,
  }) async {
    if (!mounted) {
      return;
    }
    setState(() {
      _lastUsedGearSetupId = gearSetupId;
      _lastUsedUploadSpot = uploadSpot;
      _sessionFeed.insert(0, session);
      if (markCaptureAsSynced) {
        _captureState = _SessionCaptureState.synced;
      }
      if (importedToRemove != null) {
        _syncedPendingSessions.remove(importedToRemove);
        if (_syncedPendingSessions.isEmpty) {
          _syncedPendingDeviceId = null;
        }
      }
    });
    _saveSessionViewPreferences();
    await _sessionsModule.saveRecordedSession(session);
  }

  void _activateRecordingCapture() {
    setState(() {
      _beginRecordingCaptureState(DateTime.now());
    });
  }

  void _startCaptureTicker() {
    _recordingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _captureState != _SessionCaptureState.recording) {
        return;
      }
      setState(() {});
    });
  }

  void _attachCaptureStreams() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(_onPositionSample);
    _userAccelerometerSubscription = userAccelerometerEventStream().listen(
      _onUserAccelerometerSample,
    );
    _gyroscopeSubscription = gyroscopeEventStream().listen(_onGyroscopeSample);
  }

  void _onPositionSample(Position position) {
    if (_captureState != _SessionCaptureState.recording) {
      return;
    }

    _recordingRawPositionCount += 1;
    _lastGpsAccuracyMeters = position.accuracy;
    final previous = _recordingSamples.isEmpty ? null : _recordingSamples.last;
    final speedKnots = StartSessionCaptureLogic.resolveSpeedKnots(
      SessionCaptureSpeedResolutionInput(
        rawSpeedMetersPerSecond: position.speed,
        positionLatitude: position.latitude,
        positionLongitude: position.longitude,
        positionTimestamp: position.timestamp,
        previous: previous,
      ),
    );

    final sample = SessionCaptureSample(
      latitude: position.latitude,
      longitude: position.longitude,
      speedKnots: speedKnots,
      timestamp: position.timestamp,
    );
    final trackStep = StartSessionCaptureLogic.evaluateTrackStep(
      SessionCaptureTrackStepEvaluationInput(
        accuracyMeters: position.accuracy,
        maxAccuracyMeters: _gpsSampleMaxAccuracyMeters,
        previous: previous,
        current: sample,
        maxPlausibleSpeedKnots: _gpsMaxPlausibleSpeedKnots,
      ),
    );

    if (!trackStep.isUsablePosition) {
      _handleRejectedTrackSample(isAccuracyRejection: true);
      return;
    }
    if (!trackStep.isPlausibleStep) {
      _handleRejectedTrackSample(isAccuracyRejection: false);
      return;
    }

    _applyAcceptedTrackSample(
      previous: previous,
      sample: sample,
      trackStep: trackStep,
    );
  }

  void _handleRejectedTrackSample({required bool isAccuracyRejection}) {
    if (isAccuracyRejection) {
      _recordingRejectedAccuracyCount += 1;
    } else {
      _recordingRejectedPlausibilityCount += 1;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _applyAcceptedTrackSample({
    required SessionCaptureSample? previous,
    required SessionCaptureSample sample,
    required SessionCaptureTrackStepEvaluationResult trackStep,
  }) {
    if (previous != null) {
      final delta = trackStep.delta ?? Duration.zero;
      if (!delta.isNegative && delta.inSeconds > 0) {
        _updateAutoPauseState(delta: delta, speedKnots: sample.speedKnots);
      }
    }

    final accumulation = StartSessionCaptureLogic.accumulateTrackStep(
      SessionCaptureTrackAccumulationInput(
        legMeters: trackStep.legMeters,
        delta: trackStep.delta,
        speedKnots: sample.speedKnots,
        isAutoPaused: _isAutoPaused,
        currentDistanceMeters: _recordingDistanceMeters,
        currentMovingDuration: _recordingMovingDuration,
        currentMaxSpeedKnots: _recordingMaxSpeedKnots,
        movingMinSpeedKnots: 8,
      ),
    );
    _recordingDistanceMeters = accumulation.distanceMeters;
    _recordingMovingDuration = accumulation.movingDuration;
    _recordingMaxSpeedKnots = accumulation.maxSpeedKnots;

    _recordingSamples.add(sample);
    _recordingTimelineKnots.add(sample.speedKnots);

    if (mounted) {
      setState(() {});
    }
  }

  void _onUserAccelerometerSample(UserAccelerometerEvent event) {
    if (_captureState != _SessionCaptureState.recording) {
      return;
    }
    final now = DateTime.now();
    final evaluation = StartSessionCaptureLogic.evaluateAcceleration(
      SessionAccelerationEvaluationInput(
        x: event.x,
        y: event.y,
        z: event.z,
        recentAccelerationGs: _recentAccelerationGs,
        currentMaxAccelerationG: _recordingMaxAccelerationG,
        accelerationPeakConfirmationRatio: _accelerationPeakConfirmationRatio,
        accelerationPeakRequiredMatches: _accelerationPeakRequiredMatches,
        accelerationEventThresholdG: _accelerationEventThresholdG,
        currentTrackSpeedKnots: _currentTrackSpeedKnots(),
        motionEventMinSpeedKnots:
            _captureMeasurementPolicy().motionEventMinSpeedKnots,
        canRegisterMotionEvent: StartSessionCaptureLogic.canRegisterMotionEvent(
          SessionMotionEventCooldownInput(
            now: now,
            lastEventAt: _lastAccelerationEventAt,
            cooldown: _motionEventCooldown,
          ),
        ),
      ),
    );
    final applied = StartSessionCaptureLogic.applyAccelerationEvaluation(
      SessionApplyAccelerationEvaluationInput(
        evaluation: evaluation,
        accelerationPeakWindowSize: _accelerationPeakWindowSize,
        currentAccelerationEventCount: _recordingAccelerationEventCount,
        now: now,
      ),
    );
    _recentAccelerationGs
      ..clear()
      ..addAll(applied.updatedRecentAccelerationGs);
    _recordingMaxAccelerationG = applied.updatedMaxAccelerationG;
    _recordingAccelerationEventCount = applied.updatedAccelerationEventCount;
    if (applied.updatedLastAccelerationEventAt != null) {
      _lastAccelerationEventAt = applied.updatedLastAccelerationEventAt;
    }
    if (applied.detectedAccelerationG != null) {
      _updateJumpDetectionFromAcceleration(applied.detectedAccelerationG!);
    }
    if (applied.shouldRefreshUi && mounted) {
      setState(() {});
    }
  }

  void _onGyroscopeSample(GyroscopeEvent event) {
    if (_captureState != _SessionCaptureState.recording) {
      return;
    }
    final now = DateTime.now();
    final evaluation = StartSessionCaptureLogic.evaluateRotation(
      SessionRotationEvaluationInput(
        x: event.x,
        y: event.y,
        z: event.z,
        currentMaxRotationDegPerSec: _recordingMaxRotationDegPerSec,
        rotationEventThresholdDegPerSec: _rotationEventThresholdDegPerSec,
        currentTrackSpeedKnots: _currentTrackSpeedKnots(),
        motionEventMinSpeedKnots:
            _captureMeasurementPolicy().motionEventMinSpeedKnots,
        canRegisterMotionEvent: StartSessionCaptureLogic.canRegisterMotionEvent(
          SessionMotionEventCooldownInput(
            now: now,
            lastEventAt: _lastRotationEventAt,
            cooldown: _motionEventCooldown,
          ),
        ),
      ),
    );
    final applied = StartSessionCaptureLogic.applyRotationEvaluation(
      SessionApplyRotationEvaluationInput(
        evaluation: evaluation,
        currentRotationEventCount: _recordingRotationEventCount,
        now: now,
      ),
    );
    _recordingMaxRotationDegPerSec = applied.updatedMaxRotationDegPerSec;
    _recordingRotationEventCount = applied.updatedRotationEventCount;
    if (applied.updatedLastRotationEventAt != null) {
      _lastRotationEventAt = applied.updatedLastRotationEventAt;
    }
    if (applied.detectedRotationDegPerSec != null) {
      _updateJumpDetectionFromRotation(applied.detectedRotationDegPerSec!);
    }
    if (applied.shouldRefreshUi && mounted) {
      setState(() {});
    }
  }

  void _updateJumpDetectionFromAcceleration(double accelerationG) {
    final now = DateTime.now();
    final currentSpeedKnots = _currentTrackSpeedKnots();
    final result = StartSessionCaptureLogic.updateJumpDetectionFromAcceleration(
      SessionJumpDetectionAccelerationInput(
        jumpDetectionMode: _captureMeasurementPolicy().jumpDetectionMode,
        pendingCandidate: _pendingJumpCandidate,
        lastJumpRecordedAt: _lastJumpRecordedAt,
        now: now,
        currentSpeedKnots: currentSpeedKnots,
        accelerationG: accelerationG,
        jumpMinTakeoffSpeedKnots:
            _captureMeasurementPolicy().jumpMinTakeoffSpeedKnots,
        jumpMinManeuverG: _jumpMinManeuverG,
        jumpMinManeuverRotationDegPerSec: _jumpMinManeuverRotationDegPerSec,
        jumpCooldown: _jumpCooldown,
        jumpMinAirTime: _jumpMinAirTime,
        jumpMaxAirTime: _jumpMaxAirTime,
        jumpLandingThresholdG: _jumpLandingThresholdG,
        jumpLandingMinSpeedKnots:
            _captureMeasurementPolicy().jumpLandingMinSpeedKnots,
      ),
    );
    _pendingJumpCandidate = result.pendingCandidate;
    if (result.shouldFinalize &&
        result.landedAt != null &&
        result.landingG != null &&
        result.landingSpeedKnots != null) {
      _finalizeJumpCandidate(
        landedAt: result.landedAt!,
        landingG: result.landingG!,
        landingSpeedKnots: result.landingSpeedKnots!,
      );
    }
  }

  void _updateJumpDetectionFromRotation(double rotationDegPerSec) {
    final now = DateTime.now();
    final currentSpeedKnots = _currentTrackSpeedKnots();
    final result = StartSessionCaptureLogic.updateJumpDetectionFromRotation(
      SessionJumpDetectionRotationInput(
        jumpDetectionMode: _captureMeasurementPolicy().jumpDetectionMode,
        pendingCandidate: _pendingJumpCandidate,
        lastJumpRecordedAt: _lastJumpRecordedAt,
        now: now,
        currentSpeedKnots: currentSpeedKnots,
        rotationDegPerSec: rotationDegPerSec,
        jumpMinTakeoffSpeedKnots:
            _captureMeasurementPolicy().jumpMinTakeoffSpeedKnots,
        jumpMinManeuverG: _jumpMinManeuverG,
        jumpMinManeuverRotationDegPerSec: _jumpMinManeuverRotationDegPerSec,
        jumpCooldown: _jumpCooldown,
        jumpMaxAirTime: _jumpMaxAirTime,
      ),
    );
    _pendingJumpCandidate = result.pendingCandidate;
  }

  void _finalizeJumpCandidate({
    required DateTime landedAt,
    required double landingG,
    required double landingSpeedKnots,
  }) {
    final result = StartSessionCaptureLogic.applyJumpFinalize(
      SessionApplyJumpFinalizeInput(
        pendingCandidate: _pendingJumpCandidate,
        recordingStartedAt: _recordingStartedAt,
        landedAt: landedAt,
        landingG: landingG,
        landingSpeedKnots: landingSpeedKnots,
        nextJumpIndex: _recordingJumpHistory.length + 1,
        jumpMinAirTime: _jumpMinAirTime,
        jumpMinManeuverG: _jumpMinManeuverG,
        jumpMinManeuverRotationDegPerSec: _jumpMinManeuverRotationDegPerSec,
        currentJumpHistory: _recordingJumpHistory,
      ),
    );
    _recordingJumpHistory
      ..clear()
      ..addAll(result.updatedJumpHistory);
    _lastJumpRecordedAt = result.lastJumpRecordedAt;
    _pendingJumpCandidate = result.pendingCandidate;
  }

  void _updateAutoPauseState({
    required Duration delta,
    required double speedKnots,
  }) {
    final evaluation = StartSessionCaptureLogic.evaluateAutoPause(
      SessionAutoPauseEvaluationInput(
        isAutoPaused: _isAutoPaused,
        delta: delta,
        speedKnots: speedKnots,
        hasRecentMotionActivity:
            StartSessionCaptureLogic.hasRecentMotionActivity(
              SessionRecentMotionActivityInput(
                now: DateTime.now(),
                lastAccelerationEventAt: _lastAccelerationEventAt,
                lastRotationEventAt: _lastRotationEventAt,
                window: _autoPauseDelay,
              ),
            ),
        lowSpeedCandidateDuration: _recordingLowSpeedCandidateDuration,
        resumeCandidateDuration: _recordingResumeCandidateDuration,
        autoPausedDuration: _recordingAutoPausedDuration,
        autoPauseCount: _recordingAutoPauseCount,
        autoPauseSpeedKnots: _autoPauseSpeedKnots,
        autoResumeSpeedKnots: _autoResumeSpeedKnots,
        autoPauseDelay: _autoPauseDelay,
        autoResumeDelay: _autoResumeDelay,
      ),
    );
    _isAutoPaused = evaluation.isAutoPaused;
    _recordingLowSpeedCandidateDuration = evaluation.lowSpeedCandidateDuration;
    _recordingResumeCandidateDuration = evaluation.resumeCandidateDuration;
    _recordingAutoPausedDuration = evaluation.autoPausedDuration;
    _recordingAutoPauseCount = evaluation.autoPauseCount;
  }

  Future<void> _stopRealSessionRecording() async {
    await _cancelCaptureStreams();
    final decision = StartSessionPresentationMapper.resolveStopCaptureDecision(
      hasEnoughRecordedTrackForSave: _hasEnoughRecordedTrackForSave(),
    );
    if (!mounted) {
      return;
    }

    switch (decision.action) {
      case SessionStopCaptureAction.discardAndReset:
        _resetRecordingState();
        if (decision.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(decision.message!)));
        }
        return;
      case SessionStopCaptureAction.markFinished:
        setState(() {
          _captureState = _SessionCaptureState.finished;
        });
        return;
    }
  }

  _RecordedSession _buildRecordedSessionFromCapture({
    required String id,
    required ({
      String spot,
      String notes,
      SessionMediaSelection mediaSelection,
      String? sessionPhotoLocalPath,
      String? gearSetupId,
      String? gearSetupName,
    })
    config,
    required String? uploadedSessionPhotoPath,
    required DateTime endedAt,
    required Duration duration,
  }) {
    final title = 'Sesión en ${config.spot}';
    final selectedDevice = _selectedDevice;
    final deviceName = selectedDevice?.name ?? 'Desconocido';
    final deviceKind = selectedDevice?.kind ?? 'Dispositivo Android';
    final deviceSensorKeys =
        selectedDevice?.physicalSensorKeys.isNotEmpty == true
        ? List<String>.from(selectedDevice!.physicalSensorKeys)
        : SessionInsightData.physicalSensorsForDeviceKind(
            deviceKind,
          ).toList(growable: false);
    final jumpDetectionMode = SessionInsightData.jumpDetectionModeForSensors(
      deviceSensorKeys,
    );
    final jumpHistory = List<SessionJumpRecord>.unmodifiable(
      _recordingJumpHistory,
    );
    final metricsSummary =
        StartSessionRecordedSessionBuilder.buildMetricsSummary(
          SessionRecordedMetricsSummaryInput(
            samples: _recordingSamples,
            timelineKnots: _recordingTimelineKnots,
            jumpHistory: jumpHistory,
            duration: duration,
            autoPausedDuration: _recordingAutoPausedDuration,
            movingDuration: _recordingMovingDuration,
            recordingDistanceMeters: _recordingDistanceMeters,
            recordingMaxSpeedKnots: _recordingMaxSpeedKnots,
            rawPositionCount: _recordingRawPositionCount,
            rejectedAccuracyCount: _recordingRejectedAccuracyCount,
            rejectedPlausibilityCount: _recordingRejectedPlausibilityCount,
            lastGpsAccuracyMeters: _lastGpsAccuracyMeters,
            accelerationEventCount: _recordingAccelerationEventCount,
            rotationEventCount: _recordingRotationEventCount,
            autoPauseCount: _recordingAutoPauseCount,
            movingAverageMinSpeedKnots: _movingAverageMinSpeedKnots,
          ),
        );
    return StartSessionRecordedSessionBuilder.build(
      RecordedSessionBuilderInput(
        id: id,
        title: title,
        deviceName: deviceName,
        deviceKind: deviceKind,
        deviceSensorKeys: deviceSensorKeys,
        jumpDetectionMode: jumpDetectionMode,
        endedAt: endedAt,
        duration: duration,
        config: StartSessionSaveConfigData(
          spot: config.spot,
          notes: config.notes,
          sessionMediaLabel: StartSessionMediaLogic.labelForSelection(
            config.mediaSelection,
          ),
          sessionPhotoLocalPath: uploadedSessionPhotoPath,
          gearSetupId: config.gearSetupId,
          gearSetupName: config.gearSetupName,
        ),
        distanceKm: metricsSummary.distanceKm > 0
            ? metricsSummary.distanceKm
            : null,
        maxSpeedKnots: _recordingMaxSpeedKnots > 0
            ? _recordingMaxSpeedKnots
            : null,
        avgSpeedKnots: metricsSummary.avgSpeedKnots > 0
            ? metricsSummary.avgSpeedKnots
            : null,
        movingAvgSpeedKnots: metricsSummary.movingAvgSpeedKnots > 0
            ? metricsSummary.movingAvgSpeedKnots
            : null,
        planingMinutes: metricsSummary.planingMinutes,
        recordedPointCount: _recordingSamples.length,
        autoPauseCount: _recordingAutoPauseCount,
        accelerationEventCount: _recordingAccelerationEventCount,
        rotationEventCount: _recordingRotationEventCount,
        maxRotationDegPerSec: _recordingMaxRotationDegPerSec > 0
            ? _recordingMaxRotationDegPerSec
            : null,
        jumpsCount: metricsSummary.jumpsCount > 0
            ? metricsSummary.jumpsCount
            : null,
        maxJumpHeightMeters: metricsSummary.maxJumpHeightMeters,
        maxHangtimeSeconds: metricsSummary.maxHangtimeSeconds,
        jumpHistory: jumpHistory,
        timelineKnots: List<double>.from(_recordingTimelineKnots),
        routePoints: _recordingSamples
            .map(
              (sample) => SessionTrackPoint(
                latitude: sample.latitude,
                longitude: sample.longitude,
                speedKnots: sample.speedKnots,
                recordedAt: sample.timestamp,
              ),
            )
            .toList(growable: false),
        eventPointCount: _recordingSamples.length,
        eventMaxSpeedKnots: _recordingMaxSpeedKnots,
        measuredValues: metricsSummary.measuredValues,
      ),
    );
  }

  List<_RecordedSession> _filteredSessions() {
    final query = _sessionSearchController.text.trim().toLowerCase();
    return _sessionFeed.where((session) {
      final gearSetupName = session.gearSetupName?.toLowerCase() ?? '';
      final spotName = _spotNameForSession(session)?.toLowerCase() ?? '';
      final byQuery =
          query.isEmpty ||
          session.title.toLowerCase().contains(query) ||
          session.summary.toLowerCase().contains(query) ||
          session.deviceName.toLowerCase().contains(query) ||
          gearSetupName.contains(query) ||
          spotName.contains(query);
      return byQuery;
    }).toList();
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) {
      return '$h:$m:$s';
    }
    return '$m:$s';
  }

  String _formatJumpHeight(double? meters) {
    if (meters == null) {
      return '--';
    }
    return '${meters.toStringAsFixed(1)} m';
  }

  String _formatHangtime(double? seconds) {
    if (seconds == null) {
      return '--';
    }
    return '${seconds.toStringAsFixed(1)} s';
  }

  String _formatSpeedKnots(double? knots) {
    if (knots == null) {
      return '--';
    }
    return '${knots.toStringAsFixed(1)} kt';
  }

  MySessionCardData _buildMySessionCardData(_RecordedSession session) {
    final insights = _sessionInsightsForDetail(session);
    return MySessionsPresentationMapper.buildCardData(
      title: session.title,
      endedAt: session.endedAt,
      summary: session.summary,
      deviceName: session.deviceName,
      insights: insights,
      gearSetupName: session.gearSetupName,
      localPhotoPath: session.sessionPhotoLocalPath,
      defaultSessionSummary: _defaultSessionSummary,
      durationLabel: _formatDuration(session.duration),
      jumpLabel: _optionalLabel(
        _formatJumpHeight(insights.maxJumpHeightMeters),
      ),
      hangtimeLabel: _optionalLabel(
        _formatHangtime(insights.maxHangtimeSeconds),
      ),
      maxSpeedLabel: _optionalLabel(_formatSpeedKnots(insights.maxSpeedKnots)),
    );
  }

  SessionSelectedDeviceCard? _buildSelectedDeviceCard() {
    final selectedDevice = _selectedDevice;
    if (selectedDevice == null) {
      return null;
    }
    final statusLabel = _autoDetectedDeviceStatus(selectedDevice);
    return SessionSelectedDeviceCard(
      data: StartSessionPresentationMapper.buildSelectedDeviceCardData(
        selectedDevice: selectedDevice,
        capabilitiesIcon: _capabilitiesActionIcon(selectedDevice.kind),
        statusLabel: statusLabel,
        statusColor: _statusChipColor(statusLabel),
        availabilityLabel: _deviceAvailabilityLabel(selectedDevice),
        sensorCountLabel: _selectedDeviceSensorCountLabel(),
        isPhoneDeviceSelected: selectedDevice.id == _phoneDeviceId,
      ),
      onCapabilitiesPressed: _showDeviceCapabilitiesDialog,
    );
  }

  SessionSyncedPendingCard? _buildSyncedPendingCard() {
    if (_selectedDeviceId == null ||
        _syncedPendingDeviceId != _selectedDeviceId ||
        _syncedPendingSessions.isEmpty) {
      return null;
    }
    return SessionSyncedPendingCard(
      sessions: _syncedPendingSessions
          .map(
            (session) => SessionSyncedPendingItemData(
              id: '${session.fileName}-${session.endedAt.toIso8601String()}',
              title: session.title,
              subtitle:
                  '${session.duration.inMinutes} min · ${_formatSessionDateTime(session.endedAt)}',
            ),
          )
          .toList(growable: false),
      onConfigure: (sessionId) {
        final session = _syncedPendingSessions
            .where(
              (item) =>
                  '${item.fileName}-${item.endedAt.toIso8601String()}' ==
                  sessionId,
            )
            .firstOrNull;
        if (session == null) {
          return;
        }
        _configureSyncedSession(session);
      },
      onDelete: (sessionId) {
        final session = _syncedPendingSessions
            .where(
              (item) =>
                  '${item.fileName}-${item.endedAt.toIso8601String()}' ==
                  sessionId,
            )
            .firstOrNull;
        if (session == null) {
          return;
        }
        _removeSyncedPendingSession(session);
      },
    );
  }

  SessionCaptureStatusCard _buildSessionCaptureStatusCard(
    BuildContext context,
  ) {
    final captureInput = _buildSessionCapturePresentationInput();
    final data = StartSessionPresentationMapper.buildCaptureStatusCardData(
      input: captureInput,
      colorScheme: Theme.of(context).colorScheme,
    );
    return SessionCaptureStatusCard(
      data: data,
      onActionPressed: _onSessionControlPressed,
    );
  }

  Widget _buildStartSessionSection(BuildContext context, TextTheme textTheme) {
    final captureInput = _buildSessionCapturePresentationInput();
    return StartSessionPage(
      data: StartSessionPresentationMapper.pageData,
      descriptionTextStyle: textTheme.bodyMedium,
      panel: SessionStartPanel(
        data: StartSessionPresentationMapper.buildPanelData(
          captureStatusText:
              StartSessionPresentationMapper.buildCaptureStatusText(
                captureInput,
              ),
          importHintText: _lastImportHint,
        ),
        devices: StartSessionPresentationMapper.buildDeviceSelectorItems(
          devices: _devicesForDisplay(),
        ),
        selectedDeviceId: _selectedDeviceId,
        onDeviceChanged: (value) {
          setState(() {
            _selectedDeviceId = value;
            _lastImportHint = null;
            _syncedPendingSessions.clear();
            _syncedPendingDeviceId = null;
          });
          _saveSelectedDeviceId();
        },
        selectedDeviceCard: _buildSelectedDeviceCard(),
        syncedPendingCard: _buildSyncedPendingCard(),
        captureStatusCard: _buildSessionCaptureStatusCard(context),
        onImportPressed: _importSessionFile,
      ),
    );
  }

  Future<void> _openMySessionDetail(
    BuildContext context,
    _RecordedSession session,
    List<String> gearDetailLines,
  ) async {
    final action = await Navigator.of(context).push<SessionDetailAction>(
      MaterialPageRoute(
        builder: (_) => SessionDetailPage(
          title: session.title,
          deviceName: session.deviceName,
          deviceKind:
              _sessionInsightsForDetail(session).deviceKind ??
              'Dispositivo Android',
          deviceSensorKeys: _sessionInsightsForDetail(session).deviceSensorKeys,
          endedAt: session.endedAt,
          durationLabel: _formatDuration(session.duration),
          summary: session.summary,
          source: SessionDetailSource.mySessions,
          gearSetupName: session.gearSetupName,
          gearSetupDetailLines: gearDetailLines,
          hasSessionPhoto: session.hasSessionPhoto,
          sessionMediaLabel: session.sessionMediaLabel,
          sessionPhotoLocalPath: session.sessionPhotoLocalPath,
          spotBackgroundImagePath: _spotBackgroundForSession(session),
          insights: _sessionInsightsForDetail(session),
        ),
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    if (action.type == SessionDetailActionType.delete) {
      await _confirmAndDeleteSession(session.id);
      return;
    }

    await _openEditSessionDialog(session.id);
  }

  Widget _buildMySessionCard(BuildContext context, _RecordedSession session) {
    final gearSnapshot = _loadProfileGearSnapshot();
    final cardData = _buildMySessionCardData(session);
    final setup = SessionGearMapper.findGearSetup(gearSnapshot, session);
    final gearDetailLines = setup == null
        ? const <String>[]
        : SessionGearMapper.buildGearSetupDetailLines(
            kite: gearSnapshot.kitesById[setup.kiteId],
            board: gearSnapshot.boardsById[setup.boardId],
            bar: setup.barId == null
                ? null
                : gearSnapshot.barsById[setup.barId!],
            harness: setup.harnessId == null
                ? null
                : gearSnapshot.harnessesById[setup.harnessId!],
            wetsuit: setup.wetsuitId == null
                ? null
                : gearSnapshot.wetsuitsById[setup.wetsuitId!],
            helmet: setup.helmetId == null
                ? null
                : gearSnapshot.helmetsById[setup.helmetId!],
            vest: setup.vestId == null
                ? null
                : gearSnapshot.vestsById[setup.vestId!],
          );
    return MySessionCard(
      data: cardData,
      onDevicePressed: () {
        final detailInsights = _sessionInsightsForDetail(session);
        SessionDeviceDialog.show(
          context,
          deviceName: session.deviceName,
          deviceKind: detailInsights.deviceKind ?? 'Dispositivo Android',
          deviceSensorKeys: detailInsights.deviceSensorKeys,
        );
      },
      onGearPressed: () {
        final gearSetupName = session.gearSetupName;
        if (gearSetupName == null || gearSetupName.isEmpty) {
          return;
        }
        SessionGearDialog.show(
          context,
          gearSetupName: gearSetupName,
          gearSetupDetailLines: gearDetailLines,
        );
      },
      onTap: () => _openMySessionDetail(context, session, gearDetailLines),
    );
  }

  Widget _buildMySessionsSection(TextTheme textTheme) {
    final filteredSessions = _filteredSessions();
    final sessionCards = filteredSessions
        .map(
          (session) => Builder(
            builder: (context) => _buildMySessionCard(context, session),
          ),
        )
        .toList(growable: false);
    return MySessionsPage(
      searchController: _sessionSearchController,
      data: MySessionsPresentationMapper.buildPageData(
        hasActiveSearch: _sessionSearchController.text.trim().isNotEmpty,
        hasSessions: filteredSessions.isNotEmpty,
      ),
      onSearchChanged: (_) {
        setState(() {});
      },
      onClearSearchPressed: () {
        _sessionSearchController.clear();
        setState(() {});
      },
      sessionCards: sessionCards,
      emptyStateTextStyle: textTheme.bodyMedium,
    );
  }

  String? _optionalLabel(String label) {
    if (label == '--') {
      return null;
    }
    return label;
  }

  SessionCapturePresentationInput _buildSessionCapturePresentationInput() {
    final remainingAutoPause =
        _autoPauseDelay - _recordingLowSpeedCandidateDuration;
    final autoPauseRemainingSeconds = remainingAutoPause.inSeconds.clamp(
      0,
      _autoPauseDelay.inSeconds,
    );
    final phase = switch (_captureState) {
      _SessionCaptureState.ready => SessionCapturePhase.ready,
      _SessionCaptureState.recording => SessionCapturePhase.recording,
      _SessionCaptureState.finished => SessionCapturePhase.finished,
      _SessionCaptureState.syncing => SessionCapturePhase.syncing,
      _SessionCaptureState.synced => SessionCapturePhase.synced,
    };
    return SessionCapturePresentationInput(
      phase: phase,
      hasSelectedDevice: _selectedDevice != null,
      isPhoneDeviceSelected: _selectedDevice?.id == _phoneDeviceId,
      isAutoPaused: _isAutoPaused,
      isAutoPausePending: _isAutoPausePending(),
      autoPauseRemainingSeconds: autoPauseRemainingSeconds,
      elapsedLabel: _recordingElapsedText(),
      currentSpeedLabel: _recordingCurrentSpeedText(),
      maxSpeedLabel: _recordingMaxSpeedText(),
      activeLabel: _recordingActiveText(),
      pausedLabel: _recordingPausedText(),
      lastGpsAccuracyMeters: _lastGpsAccuracyMeters,
      hasEnoughRecordedTrackForSave: _hasEnoughRecordedTrackForSave(),
      saveReadinessSatisfiedRuleCount: _saveReadinessSatisfiedRuleCount(),
    );
  }

  Future<String?> _pickSessionMedia(SessionMediaSelection selection) async {
    try {
      return await StartSessionMediaLogic.pickAndStoreSessionMedia(
        selection,
        imagePicker: _imagePicker,
      );
    } on MissingPluginException {
      if (!mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selección de imagen no disponible en esta plataforma.',
          ),
        ),
      );
      return null;
    } catch (_) {
      if (!mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo seleccionar la imagen.')),
      );
      return null;
    }
  }

  bool _isRemoteSessionPhotoPath(String? path) {
    if (path == null) {
      return false;
    }
    final normalized = path.trim().toLowerCase();
    return normalized.startsWith('http://') ||
        normalized.startsWith('https://');
  }

  String _sessionPhotoContentType(String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.png')) {
      return 'image/png';
    }
    if (normalized.endsWith('.webp')) {
      return 'image/webp';
    }
    if (normalized.endsWith('.heic')) {
      return 'image/heic';
    }
    if (normalized.endsWith('.heif')) {
      return 'image/heif';
    }
    return 'image/jpeg';
  }

  String _sessionPhotoExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == path.length - 1) {
      return 'jpg';
    }
    return path.substring(dotIndex + 1).toLowerCase();
  }

  Future<String?> _resolvePersistedSessionPhotoPath({
    required String sessionId,
    required String? candidatePath,
    String? previousPath,
  }) async {
    if (candidatePath == null || candidatePath.trim().isEmpty) {
      return null;
    }
    if (_isRemoteSessionPhotoPath(candidatePath)) {
      return candidatePath;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Debes iniciar sesión para subir la foto de la sesión.',
            ),
          ),
        );
      }
      throw StateError(
        'Cannot upload session photo without authenticated user.',
      );
    }

    try {
      final file = File(candidatePath);
      if (!await file.exists()) {
        return previousPath;
      }
      final extension = _sessionPhotoExtension(candidatePath);
      final storagePath =
          '${user.id}/sessions/${sessionId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      await Supabase.instance.client.storage
          .from('session-media')
          .upload(
            storagePath,
            file,
            fileOptions: FileOptions(
              contentType: _sessionPhotoContentType(candidatePath),
              upsert: false,
            ),
          );
      return Supabase.instance.client.storage
          .from('session-media')
          .getPublicUrl(storagePath);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo subir la foto de la sesión: $error'),
          ),
        );
      }
      throw StateError('Session photo upload failed: $error');
    }
  }

  Future<
    ({
      String spot,
      String notes,
      SessionMediaSelection mediaSelection,
      String? sessionPhotoLocalPath,
      String? gearSetupId,
      String? gearSetupName,
    })?
  >
  _showUploadSessionDialog() async {
    await _profileModule.gearController.hydrate();
    final uploadSpotOptions = _availableUploadSpots();
    if (uploadSpotOptions.isEmpty) {
      return null;
    }

    const noGearValue = '__none__';
    String spot = uploadSpotOptions.contains(_lastUsedUploadSpot)
        ? _lastUsedUploadSpot
        : uploadSpotOptions.first;
    String notes = '';
    SessionMediaSelection mediaSelection = SessionMediaSelection.none;
    String? sessionPhotoLocalPath;
    final gearSnapshot = _loadProfileGearSnapshot();
    final gearSetups = gearSnapshot.setups;
    final hasLastUsed =
        _lastUsedGearSetupId != null &&
        gearSetups.any((setup) => setup.id == _lastUsedGearSetupId);
    String selectedGearSetupId = hasLastUsed
        ? _lastUsedGearSetupId!
        : noGearValue;

    if (!mounted) {
      return null;
    }

    final result = await SessionUploadDialog.show(
      context,
      data: SessionUploadDialogData(
        title: 'Configurar sesión',
        submitLabel: 'Subir sesión',
        showSpotField: true,
        spotOptions: uploadSpotOptions,
        initialSpot: spot,
        notesLabel: 'Resumen de sesion (opcional)',
        initialNotes: notes,
        initialMediaSelection: mediaSelection,
        initialSessionPhotoLocalPath: sessionPhotoLocalPath,
        gearSetupOptions: SessionGearMapper.buildGearSetupOptions(gearSnapshot),
        initialGearSetupId: selectedGearSetupId == noGearValue
            ? null
            : selectedGearSetupId,
      ),
      onPickMedia: _pickSessionMedia,
    );

    if (result == null) {
      return null;
    }
    return (
      spot: result.spot,
      notes: result.notes,
      mediaSelection: result.mediaSelection,
      sessionPhotoLocalPath: result.sessionPhotoLocalPath,
      gearSetupId: result.gearSetupId,
      gearSetupName: result.gearSetupName,
    );
  }

  SessionProfileGearSnapshot _loadProfileGearSnapshot() {
    return SessionGearMapper.buildSnapshot(
      gearSetups: _profileModule.gearController.savedGearSetups,
      kites: _profileModule.gearController.savedKites,
      boards: _profileModule.gearController.savedBoards,
      bars: _profileModule.gearController.savedBars,
      harnesses: _profileModule.gearController.savedHarnesses,
      wetsuits: _profileModule.gearController.savedWetsuits,
      helmets: _profileModule.gearController.savedHelmets,
      vests: _profileModule.gearController.savedVests,
    );
  }

  _RecordedSession? _findSessionById(String sessionId) {
    for (final session in _sessionFeed) {
      if (session.id == sessionId) {
        return session;
      }
    }
    return null;
  }

  Future<void> _confirmAndDeleteSession(String sessionId) async {
    final session = _findSessionById(sessionId);
    if (session == null) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar sesión'),
          content: Text('Seguro que quieres eliminar "${session.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) {
      return;
    }

    setState(() {
      _sessionFeed.removeWhere((item) => item.id == sessionId);
    });
    await _sessionsModule.deleteRecordedSession(sessionId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sesión eliminada.')));
  }

  Future<void> _openEditSessionDialog(String sessionId) async {
    final session = _findSessionById(sessionId);
    if (session == null) {
      return;
    }

    final result = await _showEditSessionDialog(session);
    if (result == null || !mounted) {
      return;
    }

    final uploadedSessionPhotoPath = await _resolvePersistedSessionPhotoPath(
      sessionId: session.id,
      candidatePath: result.sessionPhotoLocalPath,
      previousPath: _isRemoteSessionPhotoPath(session.sessionPhotoLocalPath)
          ? session.sessionPhotoLocalPath
          : null,
    );
    if (!mounted) {
      return;
    }

    final updated = StartSessionRecordedSessionBuilder.buildEditedSession(
      EditedRecordedSessionBuilderInput(
        baseSession: session,
        notes: result.notes,
        mediaSelection: result.mediaSelection,
        sessionPhotoLocalPath: uploadedSessionPhotoPath,
        gearSetupId: result.gearSetupId,
        gearSetupName: result.gearSetupName,
        sessionMediaLabel: StartSessionMediaLogic.labelForSelection(
          result.mediaSelection,
        ),
      ),
    );

    setState(() {
      final index = _sessionFeed.indexWhere((item) => item.id == session.id);
      if (index >= 0) {
        _sessionFeed[index] = updated;
      }
      _lastUsedGearSetupId = result.gearSetupId;
    });
    _saveSessionViewPreferences();
    await _sessionsModule.saveRecordedSession(updated);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sesión actualizada.')));
  }

  String _newSessionId() {
    final random = math.Random.secure();
    String section(int bytes) => List<int>.generate(
      bytes,
      (_) => random.nextInt(256),
    ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();

    return '${section(4)}-${section(2)}-${section(2)}-${section(2)}-${section(6)}';
  }

  Future<
    ({
      String notes,
      SessionMediaSelection mediaSelection,
      String? sessionPhotoLocalPath,
      String? gearSetupId,
      String? gearSetupName,
    })?
  >
  _showEditSessionDialog(_RecordedSession session) async {
    await _profileModule.gearController.hydrate();
    if (!mounted) {
      return null;
    }
    final gearSnapshot = _loadProfileGearSnapshot();
    String? selectedGearSetupId;
    if (session.gearSetupName != null) {
      for (final setup in gearSnapshot.setups) {
        if (setup.name == session.gearSetupName) {
          selectedGearSetupId = setup.id;
          break;
        }
      }
    }

    final mediaSelection = StartSessionMediaLogic.selectionForStoredSession(
      sessionMediaLabel: session.sessionMediaLabel,
      sessionPhotoLocalPath: session.sessionPhotoLocalPath,
    );

    final result = await SessionUploadDialog.show(
      context,
      data: SessionUploadDialogData(
        title: 'Editar sesion',
        submitLabel: 'Guardar cambios',
        showSpotField: false,
        spotOptions: const <String>[],
        initialSpot: session.spotName ?? '',
        notesLabel: 'Comentario de sesión',
        initialNotes: session.summary,
        initialMediaSelection: mediaSelection,
        initialSessionPhotoLocalPath: session.sessionPhotoLocalPath,
        gearSetupOptions: SessionGearMapper.buildGearSetupOptions(gearSnapshot),
        initialGearSetupId: selectedGearSetupId,
      ),
      onPickMedia: _pickSessionMedia,
    );

    if (result == null) {
      return null;
    }

    return (
      notes: result.notes,
      mediaSelection: result.mediaSelection,
      sessionPhotoLocalPath: result.sessionPhotoLocalPath,
      gearSetupId: result.gearSetupId,
      gearSetupName: result.gearSetupName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ScrollConfiguration(
      behavior: const _NoStretchScrollBehavior(),
      child: ListView(
        physics: kAppBouncingScrollPhysics,
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SegmentedButton<_SessionTab>(
            segments: const [
              ButtonSegment<_SessionTab>(
                value: _SessionTab.start,
                label: Text('Start Session'),
              ),
              ButtonSegment<_SessionTab>(
                value: _SessionTab.mySessions,
                label: Text('My Sessions'),
              ),
            ],
            selected: {_sessionTab},
            onSelectionChanged: (value) {
              setState(() {
                _sessionTab = value.first;
              });
              _saveSessionViewPreferences();
              widget.onStartTabChanged?.call(_sessionTab == _SessionTab.start);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Session', style: textTheme.headlineSmall),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (_sessionTab == _SessionTab.start) ...[
                    _buildStartSessionSection(context, textTheme),
                  ] else ...[
                    _buildMySessionsSection(textTheme),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SessionCaptureState { ready, recording, finished, syncing, synced }

enum _SessionTab { start, mySessions }

class _NoStretchScrollBehavior extends AppScrollBehavior {
  const _NoStretchScrollBehavior();
}
