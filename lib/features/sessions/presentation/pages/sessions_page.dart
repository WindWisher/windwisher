import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/profile/di/profile_module.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/sessions/di/sessions_module.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/domain/entities/session_view_preferences.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';
import 'package:windwisher/features/sessions/presentation/pages/session_detail_page.dart';
import 'package:windwisher/features/sessions/presentation/widgets/my_sessions/my_session_card.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_capture_status_card.dart';
import 'package:windwisher/features/spots/di/spots_module.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:path_provider/path_provider.dart';

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
  static const double _motionEventMinSpeedKnots = 6;
  static const double _movingAverageMinSpeedKnots = 4;
  static const Duration _motionEventCooldown = Duration(seconds: 20);
  static const double _jumpMinTakeoffSpeedKnots = 10;
  static const double _jumpMinManeuverG = 1.35;
  static const double _jumpMinManeuverRotationDegPerSec = 220;
  static const double _jumpLandingThresholdG = 1.7;
  static const double _jumpLandingMinSpeedKnots = 6;
  static const Duration _jumpMinAirTime = Duration(milliseconds: 800);
  static const Duration _jumpMaxAirTime = Duration(seconds: 8);
  static const Duration _jumpCooldown = Duration(seconds: 8);
  static const String _defaultSessionSummary =
      'Track sincronizado con sensores de velocidad, GPS y eventos.';
  static const Set<String> _templateDeviceIds = {'woo-1', 'watch-1'};
  static const List<_DetectedCompatibleDevice> _supportedDetectedDevices =
      <_DetectedCompatibleDevice>[];
  static const _LinkedDevice _defaultPhoneDevice = _LinkedDevice(
    id: _phoneDeviceId,
    name: 'Telefono del usuario',
    kind: 'Dispositivo Android',
    status: 'Listo',
    lastSync: 'Disponible en este dispositivo',
  );
  static const List<String> _deviceSensorOrder = [
    'gps',
    'accelerometer',
    'gyroscope',
    'magnetometer',
    'orientation',
    'heart_rate',
    'barometer',
  ];
  static const Map<String, String> _deviceSensorLabels = {
    'gps': 'GPS',
    'accelerometer': 'Acelerometro',
    'gyroscope': 'Giroscopio',
    'magnetometer': 'Magnetometro',
    'orientation': 'Orientacion',
    'heart_rate': 'Ritmo cardiaco',
    'barometer': 'Barometro',
  };

  late final SessionsModule _sessionsModule;
  late final SpotsModule _spotsModule;
  late final ProfileModule _profileModule;
  List<SpotItem> _spotsCatalog = const <SpotItem>[];
  final List<_LinkedDevice> _devices = [];

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
  final List<_ImportedSessionResult> _syncedPendingSessions = [];
  String? _syncedPendingDeviceId;
  _SessionCaptureState _captureState = _SessionCaptureState.ready;
  DateTime? _recordingStartedAt;
  Timer? _recordingTicker;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  final List<_SessionLocationSample> _recordingSamples =
      <_SessionLocationSample>[];
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
  _PendingJumpCandidate? _pendingJumpCandidate;
  bool _isAutoPaused = false;
  final ImagePicker _imagePicker = ImagePicker();

  static const String _sortMostRecent = 'Mas recientes';
  static const String _sortOldest = 'Mas antiguas';
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
    _sessionFilterDevice = value.filterDeviceName;
    _sessionSort = value.sortOrder;
    _lastUsedGearSetupId = value.lastUsedGearSetupId;
    _lastUsedUploadSpot = value.lastUsedUploadSpot;
  }

  void _sanitizeSessionViewPreferences() {
    final uploadSpotOptions = _availableUploadSpots();
    final hasDeviceFilter =
        _sessionFilterDevice == 'Todos' ||
        _devices.any((device) => device.name == _sessionFilterDevice);
    if (!hasDeviceFilter) {
      _sessionFilterDevice = 'Todos';
    }
    if (_sessionSort != _sortMostRecent && _sessionSort != _sortOldest) {
      _sessionSort = _sortMostRecent;
    }
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
      deviceSensorKeys: _physicalSensorsForDeviceKind(
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
        return 'Sesion finalizada';
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

  Widget _buildDeviceMetaPill({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
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
            'El telefono del usuario siempre debe estar disponible.',
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
    final phoneDevice = await _detectPhoneDevice();
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

  Future<_LinkedDevice> _detectPhoneDevice() async {
    try {
      final plugin = DeviceInfoPlugin();
      if (kIsWeb) {
        final info = await plugin.webBrowserInfo;
        final browserName = info.browserName.name;
        return _LinkedDevice(
          id: _phoneDeviceId,
          name: 'Este navegador',
          kind: 'Web · $browserName',
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
        );
      }

      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        final brand = info.brand.trim();
        final model = info.model.trim();
        final manufacturer = info.manufacturer.trim();
        final resolvedBrand = brand.isNotEmpty ? brand : manufacturer;
        final label = [resolvedBrand, model]
            .where((value) => value.isNotEmpty)
            .join(' ');
        return _LinkedDevice(
          id: _phoneDeviceId,
          name: label.isEmpty ? _defaultPhoneDevice.name : label,
          kind: 'Android',
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
        );
      }

      if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        final label = [info.name.trim(), info.model.trim()]
            .where((value) => value.isNotEmpty)
            .join(' · ');
        return _LinkedDevice(
          id: _phoneDeviceId,
          name: label.isEmpty ? _defaultPhoneDevice.name : label,
          kind: 'iPhone',
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
        );
      }

      if (Platform.isMacOS) {
        final info = await plugin.macOsInfo;
        final label = [info.model.trim(), info.osRelease.trim()]
            .where((value) => value.isNotEmpty)
            .join(' · ');
        return _LinkedDevice(
          id: _phoneDeviceId,
          name: label.isEmpty ? 'Este Mac' : label,
          kind: 'macOS',
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
        );
      }

      if (Platform.isWindows) {
        final info = await plugin.windowsInfo;
        final label = info.computerName.trim();
        return _LinkedDevice(
          id: _phoneDeviceId,
          name: label.isEmpty ? 'Este PC' : label,
          kind: 'Windows',
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
        );
      }

      if (Platform.isLinux) {
        final info = await plugin.linuxInfo;
        final label = info.prettyName.trim();
        return _LinkedDevice(
          id: _phoneDeviceId,
          name: label.isEmpty ? 'Este equipo' : label,
          kind: 'Linux',
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
        );
      }
    } catch (_) {}

    return _defaultPhoneDevice;
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
          '$feature todavia no esta conectado a datos reales. Hemos quitado la simulacion para no inventar sesiones.',
        ),
      ),
    );
  }

  void _ensureSelectedDevice() {
    final exists = _devices.any((device) => device.id == _selectedDeviceId);
    if (exists) {
      _saveSelectedDeviceId();
      return;
    }
    _selectedDeviceId = _devices.any((d) => d.id == _phoneDeviceId)
        ? _phoneDeviceId
        : (_devices.isEmpty ? null : _devices.first.id);
    _saveSelectedDeviceId();
  }

  String? _spotNameForSession(_RecordedSession session) {
    final spotName = session.spotName;
    if (spotName != null && spotName.isNotEmpty) {
      return spotName;
    }
    const prefix = 'Sesion en ';
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
    final devices = List<_LinkedDevice>.from(_devices);
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
    final availableDevices = _detectedCompatibleDevices();
    _DetectedCompatibleDevice? selectedDevice = availableDevices.firstOrNull;
    String customName = selectedDevice?.defaultName ?? '';

    final linked = await showDialog<_DetectedCompatibleDevice>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Configurar dispositivo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aqui solo aparecen dispositivos compatibles detectados y aun no vinculados.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (availableDevices.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'No se han detectado mas dispositivos compatibles por ahora. El telefono del usuario ya queda disponible automaticamente.',
                      ),
                    )
                  else ...[
                    DropdownButtonFormField<String>(
                      initialValue: selectedDevice?.id,
                      decoration: const InputDecoration(
                        labelText: 'Dispositivo compatible disponible',
                        border: OutlineInputBorder(),
                      ),
                      items: availableDevices
                          .map(
                            (device) => DropdownMenuItem(
                              value: device.id,
                              child: Text(
                                '${device.defaultName} · ${device.kind}',
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        final next = availableDevices
                            .where((device) => device.id == value)
                            .firstOrNull;
                        if (next == null) {
                          return;
                        }
                        setDialogState(() {
                          selectedDevice = next;
                          customName = next.defaultName;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (selectedDevice != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedDevice!.defaultName,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${selectedDevice!.kind} · ${selectedDevice!.status}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedDevice!.sensorSummary,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: TextEditingController(text: customName)
                        ..selection = TextSelection.collapsed(
                          offset: customName.length,
                        ),
                      decoration: const InputDecoration(
                        labelText: 'Nombre del dispositivo en la app',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        customName = value;
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton.icon(
                  onPressed: selectedDevice == null
                      ? null
                      : () => Navigator.of(context).pop(
                          selectedDevice!.copyWith(
                            customName: customName.trim().isEmpty
                                ? selectedDevice!.defaultName
                                : customName.trim(),
                          ),
                        ),
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('Vincular'),
                ),
              ],
            );
          },
        );
      },
    );

    if (linked == null || !mounted) {
      return;
    }

    setState(() {
      final linkedDevice = _LinkedDevice(
        id: linked.id,
        name: linked.customName,
        kind: linked.kind,
        status: 'Vinculado',
        lastSync: 'recién vinculado',
      );
      _devices.insert(0, linkedDevice);
      _sessionsModule.saveLinkedDevice(linkedDevice);
      _selectedDeviceId = linked.id;
    });
    _saveSelectedDeviceId();
  }

  List<_DetectedCompatibleDevice> _detectedCompatibleDevices() {
    final linkedIds = _devices.map((device) => device.id).toSet();
    return _supportedDetectedDevices
        .where((device) => !linkedIds.contains(device.id))
        .toList(growable: false);
  }

  Future<void> _syncSessionFromDevice() async {
    _showRealIntegrationPendingMessage('La sincronizacion de sesiones');
  }

  Future<void> _configureSyncedSession(_ImportedSessionResult imported) async {
    final device = _selectedDevice;
    if (device == null) {
      return;
    }

    final config = await _showUploadSessionDialog();
    if (!mounted || config == null) {
      return;
    }

    final session = _buildSyncedRecordedSession(
      device: device,
      imported: imported,
      config: config,
    );

    setState(() {
      _lastUsedGearSetupId = config.gearSetupId;
      _lastUsedUploadSpot = config.spot;
      _sessionFeed.insert(0, session);
      _syncedPendingSessions.remove(imported);
      if (_syncedPendingSessions.isEmpty) {
        _syncedPendingDeviceId = null;
      }
    });
    _saveSessionViewPreferences();
    await _sessionsModule.saveRecordedSession(session);
  }

  Future<void> _removeSyncedPendingSession(
    _ImportedSessionResult imported,
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

  _RecordedSession _buildSyncedRecordedSession({
    required _LinkedDevice device,
    required _ImportedSessionResult imported,
    required ({
      String spot,
      String notes,
      _SessionMediaSelection mediaSelection,
      String? sessionPhotoLocalPath,
      String? gearSetupId,
      String? gearSetupName,
    })
    config,
  }) {
    final baseInsights = _emptySessionInsights(
      deviceKind: device.kind,
      events: [
        'Sesion sincronizada desde dispositivo ${device.name}',
      ],
    );
    final highestJump = imported.jumpHistory
        .map((jump) => jump.heightMeters)
        .fold<double?>(null, (prev, h) => prev == null ? h : math.max(prev, h));
    final highestHangtime = imported.jumpHistory
        .map((jump) => jump.hangtimeSeconds)
        .fold<double?>(null, (prev, t) => prev == null ? t : math.max(prev, t));

    final importedInsights = baseInsights.copyWith(
      jumpsCount: imported.jumpHistory.length,
      maxJumpHeightMeters: highestJump,
      maxHangtimeSeconds: highestHangtime,
      jumpHistory: imported.jumpHistory,
    );

    return _RecordedSession(
      id: _newSessionId(),
      title: imported.title,
      deviceName: device.name,
      endedAt: imported.endedAt,
      duration: imported.duration,
      summary: config.notes.isEmpty ? imported.summary : config.notes,
      gearSetupId: config.gearSetupId,
      gearSetupName: config.gearSetupName,
      hasSessionPhoto: config.sessionPhotoLocalPath != null,
      sessionMediaLabel: switch (config.mediaSelection) {
        _SessionMediaSelection.none => 'Pantallazo del mapa del spot',
        _SessionMediaSelection.camera => 'Foto tomada con camara',
        _SessionMediaSelection.gallery => 'Foto elegida de galeria',
      },
      sessionPhotoLocalPath: config.sessionPhotoLocalPath,
      spotName: config.spot,
      insights: importedInsights,
    );
  }

  void _importSessionFile() {
    _showRealIntegrationPendingMessage('La importacion de sesiones');
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
    return _physicalSensorsForDeviceKind(selected.kind);
  }

  String _selectedDeviceSensorCountLabel() {
    final count = _selectedDeviceCapabilities().length;
    if (count == 1) {
      return '1 sensor relevante';
    }
    return '$count sensores relevantes';
  }

  Set<String> _physicalSensorsForDeviceKind(String kind) {
    switch (kind) {
      case 'Android':
      case 'Dispositivo Android':
        return {
          'gps',
          'accelerometer',
          'gyroscope',
          'magnetometer',
          'orientation',
        };
      case 'iPhone':
        return {
          'gps',
          'accelerometer',
          'gyroscope',
          'magnetometer',
          'orientation',
        };
      case 'Apple Watch':
      case 'Smartwatch':
        return {
          'gps',
          'accelerometer',
          'gyroscope',
          'orientation',
          'heart_rate',
          'barometer',
        };
      case 'Woo Sports':
        return {'gps', 'accelerometer', 'gyroscope', 'orientation'};
      case 'SurfR':
        return {'gps', 'accelerometer', 'gyroscope', 'orientation'};
      default:
        return {'gps', 'accelerometer', 'gyroscope'};
    }
  }

  String _captureButtonLabel() {
    switch (_captureState) {
      case _SessionCaptureState.ready:
        return 'Iniciar sesion real';
      case _SessionCaptureState.recording:
        return 'Detener sesion';
      case _SessionCaptureState.finished:
        return 'Guardar sesion';
      case _SessionCaptureState.syncing:
        return 'Guardando...';
      case _SessionCaptureState.synced:
        return 'Nueva sesion';
    }
  }

  IconData _captureButtonIcon() {
    switch (_captureState) {
      case _SessionCaptureState.ready:
        return Icons.play_circle_fill_rounded;
      case _SessionCaptureState.recording:
        return Icons.stop_circle_rounded;
      case _SessionCaptureState.finished:
        return Icons.sync_rounded;
      case _SessionCaptureState.syncing:
        return Icons.sync;
      case _SessionCaptureState.synced:
        return Icons.replay_rounded;
    }
  }

  String _captureStatusText() {
    switch (_captureState) {
      case _SessionCaptureState.ready:
        return _selectedDevice == null
            ? 'Selecciona un dispositivo para iniciar una sesion real.'
            : _selectedDevice!.id == _phoneDeviceId
            ? 'Listo para grabar una sesion real con GPS del telefono.'
            : 'La captura real de dispositivos externos aun no esta conectada. Usa el telefono.';
      case _SessionCaptureState.recording:
        return _isAutoPaused
            ? 'Sesion en pausa automatica. Esperando que vuelvas a moverte.'
            : _isAutoPausePending()
            ? 'Auto-pausa pendiente. Detectamos baja velocidad y sin actividad reciente.'
            : 'Sesion real en curso. Grabando recorrido y velocidad por GPS.';
      case _SessionCaptureState.finished:
        return 'Sesion finalizada. Revisa los datos y guardala.';
      case _SessionCaptureState.syncing:
        return 'Guardando track y resumen real de la sesion...';
      case _SessionCaptureState.synced:
        return 'Sesion guardada correctamente.';
    }
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

  String _gpsSignalChipLabel() {
    if (_captureState != _SessionCaptureState.recording) {
      return 'GPS pendiente';
    }
    final accuracy = _lastGpsAccuracyMeters;
    if (accuracy == null) {
      return 'Buscando GPS...';
    }
    final accuracyLabel = '${accuracy.toStringAsFixed(1)} m';
    if (accuracy <= 5) {
      return 'GPS OK · $accuracyLabel';
    }
    return 'GPS señal débil · $accuracyLabel';
  }

  String _autoPauseChipLabel() {
    if (_captureState != _SessionCaptureState.recording) {
      return 'Auto-pausa lista';
    }
    if (_isAutoPaused) {
      return 'Auto-pausa ON';
    }
    if (_isAutoPausePending()) {
      final remaining = _autoPauseDelay - _recordingLowSpeedCandidateDuration;
      final seconds = remaining.inSeconds.clamp(0, _autoPauseDelay.inSeconds);
      return 'Auto-pausa pendiente · ${seconds}s';
    }
    return 'Auto-pausa OFF';
  }

  Color _autoPauseChipBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_captureState != _SessionCaptureState.recording) {
      return colorScheme.surfaceContainerHighest;
    }
    return _isAutoPaused
        ? const Color(0x1F1565C0)
        : _isAutoPausePending()
        ? const Color(0x1FF57C00)
        : colorScheme.surfaceContainerHighest;
  }

  Color _autoPauseChipForegroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_captureState != _SessionCaptureState.recording) {
      return colorScheme.onSurfaceVariant;
    }
    return _isAutoPaused
        ? const Color(0xFF1565C0)
        : _isAutoPausePending()
        ? const Color(0xFFEF6C00)
        : colorScheme.onSurfaceVariant;
  }

  IconData _autoPauseChipIcon() {
    return _isAutoPaused
        ? Icons.pause_circle_filled_rounded
        : _isAutoPausePending()
        ? Icons.hourglass_bottom_rounded
        : Icons.play_circle_outline_rounded;
  }

  bool _isAutoPausePending() {
    if (_captureState != _SessionCaptureState.recording || _isAutoPaused) {
      return false;
    }
    return _recordingLowSpeedCandidateDuration > Duration.zero;
  }

  Color _gpsChipBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_captureState != _SessionCaptureState.recording) {
      return colorScheme.surfaceContainerHighest;
    }
    final accuracy = _lastGpsAccuracyMeters;
    if (accuracy == null) {
      return colorScheme.secondaryContainer;
    }
    if (accuracy <= 5) {
      return const Color(0x1F2E7D32);
    }
    return const Color(0x1FFF8F00);
  }

  Color _gpsChipForegroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_captureState != _SessionCaptureState.recording) {
      return colorScheme.onSurfaceVariant;
    }
    final accuracy = _lastGpsAccuracyMeters;
    if (accuracy == null) {
      return colorScheme.onSecondaryContainer;
    }
    if (accuracy <= 5) {
      return const Color(0xFF2E7D32);
    }
    return const Color(0xFF8D6E00);
  }

  IconData _gpsChipIcon() {
    if (_captureState != _SessionCaptureState.recording) {
      return Icons.gps_not_fixed_rounded;
    }
    final accuracy = _lastGpsAccuracyMeters;
    if (accuracy == null) {
      return Icons.gps_not_fixed_rounded;
    }
    if (accuracy <= 5) {
      return Icons.gps_fixed_rounded;
    }
    return Icons.gps_off_rounded;
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

  String _saveReadinessChipLabel() {
    if (_captureState != _SessionCaptureState.recording &&
        _captureState != _SessionCaptureState.finished) {
      return 'Guardado pendiente';
    }
    final count = _saveReadinessSatisfiedRuleCount();
    if (_hasEnoughRecordedTrackForSave()) {
      return 'Guardable · 3/3';
    }
    return 'Guardable · $count/3';
  }

  Color _saveReadinessChipBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_captureState != _SessionCaptureState.recording &&
        _captureState != _SessionCaptureState.finished) {
      return colorScheme.surfaceContainerHighest;
    }
    if (_hasEnoughRecordedTrackForSave()) {
      return const Color(0x1F2E7D32);
    }
    if (_saveReadinessSatisfiedRuleCount() > 0) {
      return const Color(0x1FFF8F00);
    }
    return colorScheme.surfaceContainerHighest;
  }

  Color _saveReadinessChipForegroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_captureState != _SessionCaptureState.recording &&
        _captureState != _SessionCaptureState.finished) {
      return colorScheme.onSurfaceVariant;
    }
    if (_hasEnoughRecordedTrackForSave()) {
      return const Color(0xFF2E7D32);
    }
    if (_saveReadinessSatisfiedRuleCount() > 0) {
      return const Color(0xFFEF6C00);
    }
    return colorScheme.onSurfaceVariant;
  }

  IconData _saveReadinessChipIcon() {
    if (_captureState != _SessionCaptureState.recording &&
        _captureState != _SessionCaptureState.finished) {
      return Icons.save_outlined;
    }
    if (_hasEnoughRecordedTrackForSave()) {
      return Icons.check_circle_rounded;
    }
    if (_saveReadinessSatisfiedRuleCount() > 0) {
      return Icons.timelapse_rounded;
    }
    return Icons.hourglass_empty_rounded;
  }

  Future<bool> _confirmStopRealSessionRecording() async {
    final hasEnoughTrack = _hasEnoughRecordedTrackForSave();
    final hasGoodSignal = _hasGoodGpsSignal();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            hasEnoughTrack
                ? 'Detener y revisar sesion'
                : 'Detener sin track suficiente',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasEnoughTrack
                    ? 'La sesion dejará de grabarse ahora.'
                    : 'Todavia no hemos registrado suficiente track GPS para guardar esta sesion.',
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                hasEnoughTrack
                    ? 'Podras revisar los datos y decidir si quieres guardarlos.'
                    : 'Si detienes ahora, esta sesion se descartara.',
              ),
              if (!hasEnoughTrack) ...[
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Necesitamos al menos 2 puntos GPS validos, 1 minuto de duracion y 20 metros de distancia.',
                ),
              ],
              if (hasEnoughTrack && !hasGoodSignal) ...[
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Aunque el GPS no este en OK ahora mismo, la sesion ya tiene track suficiente para revisarse y guardarse.',
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Text(
                hasEnoughTrack
                    ? 'Si sales sin guardar, se perderan los datos recogidos.'
                    : 'Los datos recogidos hasta ahora se perderan.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Seguir grabando'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                hasEnoughTrack ? 'Detener y revisar' : 'Detener y descartar',
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _resetRecordingState() {
    setState(() {
      _captureState = _SessionCaptureState.ready;
      _recordingStartedAt = null;
      _recordingSamples.clear();
      _recordingTimelineKnots.clear();
      _recordingDistanceMeters = 0;
      _recordingMaxSpeedKnots = 0;
      _lastGpsAccuracyMeters = null;
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
    });
  }

  String _formatSessionDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  Future<void> _showDeviceCapabilitiesDialog() async {
    final capabilities = _selectedDeviceCapabilities();
    final available = capabilities.length;
    final availableCapabilities = _deviceSensorOrder
        .where((key) => capabilities.contains(key))
        .toList(growable: false);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Capacidades del dispositivo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  available == 1
                      ? '1 sensor disponible'
                      : '$available sensores disponibles',
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Aqui solo mostramos sensores fisicos reales del dispositivo.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (availableCapabilities.isEmpty)
                  Text(
                    'Aun no hemos detectado capacidades utilizables para este dispositivo.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: availableCapabilities
                        .map((key) {
                          final label = _deviceSensorLabels[key] ?? key;
                          return Chip(
                            avatar: const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Color(0xFF2E7D32),
                            ),
                            label: Text(label),
                            backgroundColor: const Color(0x1F2E7D32),
                          );
                        })
                        .toList(growable: false),
                  ),
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

  Future<void> _onSessionControlPressed() async {
    if (_captureState == _SessionCaptureState.ready) {
      if (_selectedDevice == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona un dispositivo primero.')),
        );
        return;
      }
      if (_selectedDevice!.id != _phoneDeviceId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La captura real externa aun no esta conectada. Usa el telefono del usuario.',
            ),
          ),
        );
        return;
      }
      await _startRealSessionRecording();
      return;
    }

    if (_captureState == _SessionCaptureState.recording) {
      final confirm = await _confirmStopRealSessionRecording();
      if (!mounted || !confirm) {
        return;
      }
      await _stopRealSessionRecording();
      return;
    }

    if (_captureState == _SessionCaptureState.finished) {
      final config = await _showUploadSessionDialog();
      if (!mounted || config == null) {
        return;
      }

      setState(() {
        _captureState = _SessionCaptureState.syncing;
        _lastUsedGearSetupId = config.gearSetupId;
        _lastUsedUploadSpot = config.spot;
      });
      _saveSessionViewPreferences();

      final endedAt = _recordingSamples.isNotEmpty
          ? _recordingSamples.last.timestamp
          : DateTime.now();
      final duration = _recordingStartedAt == null
          ? Duration.zero
          : endedAt.difference(_recordingStartedAt!);
      final session = _buildRecordedSessionFromCapture(
        config: config,
        endedAt: endedAt,
        duration: duration,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _sessionFeed.insert(0, session);
        _captureState = _SessionCaptureState.synced;
      });
      await _sessionsModule.saveRecordedSession(session);
      return;
    }

    if (_captureState == _SessionCaptureState.synced) {
      _resetRecordingState();
    }
  }

  Future<void> _startRealSessionRecording() async {
    final servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activa la ubicacion del telefono para grabar la sesion.'),
        ),
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitamos permiso de ubicacion para grabar sesiones reales.'),
        ),
      );
      return;
    }

    _recordingTicker?.cancel();
    await _positionSubscription?.cancel();
    await _userAccelerometerSubscription?.cancel();
    await _gyroscopeSubscription?.cancel();

      setState(() {
        _captureState = _SessionCaptureState.recording;
        _recordingStartedAt = DateTime.now();
        _lastImportHint = null;
        _recordingSamples.clear();
        _recordingTimelineKnots.clear();
        _recordingDistanceMeters = 0;
        _recordingMaxSpeedKnots = 0;
        _lastGpsAccuracyMeters = null;
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
      });

    _recordingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _captureState != _SessionCaptureState.recording) {
        return;
      }
      setState(() {});
    });

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
    _gyroscopeSubscription = gyroscopeEventStream().listen(
      _onGyroscopeSample,
    );
  }

  void _onPositionSample(Position position) {
    if (_captureState != _SessionCaptureState.recording) {
      return;
    }

    _recordingRawPositionCount += 1;
    _lastGpsAccuracyMeters = position.accuracy;
    if (!_isUsableRecordingPosition(position)) {
      _recordingRejectedAccuracyCount += 1;
      if (mounted) {
        setState(() {});
      }
      return;
    }

    final speedKnots = _resolveSpeedKnots(position);

    final sample = _SessionLocationSample(
      latitude: position.latitude,
      longitude: position.longitude,
      speedKnots: speedKnots,
      timestamp: position.timestamp,
    );

    final previous = _recordingSamples.isEmpty ? null : _recordingSamples.last;
    if (!_isPlausibleTrackStep(previous: previous, current: sample)) {
      _recordingRejectedPlausibilityCount += 1;
      if (mounted) {
        setState(() {});
      }
      return;
    }

    if (previous != null) {
      final legMeters = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        sample.latitude,
        sample.longitude,
      );
      if (legMeters.isFinite && legMeters > 0) {
        _recordingDistanceMeters += legMeters;
      }
      final delta = sample.timestamp.difference(previous.timestamp);
      if (!delta.isNegative && delta.inSeconds > 0) {
        _updateAutoPauseState(delta: delta, speedKnots: sample.speedKnots);
        if (!_isAutoPaused && sample.speedKnots >= 8) {
          _recordingMovingDuration += delta;
        }
      }
    }

    _recordingSamples.add(sample);
    _recordingTimelineKnots.add(sample.speedKnots);
    if (sample.speedKnots > _recordingMaxSpeedKnots) {
      _recordingMaxSpeedKnots = sample.speedKnots;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onUserAccelerometerSample(UserAccelerometerEvent event) {
    if (_captureState != _SessionCaptureState.recording) {
      return;
    }
    const gravityMetersPerSecond2 = 9.80665;
    final metersPerSecond2 = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    final accelerationG = metersPerSecond2 / gravityMetersPerSecond2;
    if (accelerationG.isFinite) {
      _recentAccelerationGs.add(accelerationG);
      if (_recentAccelerationGs.length > _accelerationPeakWindowSize) {
        _recentAccelerationGs.removeAt(0);
      }
      final confirmationThreshold =
          accelerationG * _accelerationPeakConfirmationRatio;
      final confirmationMatches = _recentAccelerationGs
          .where((value) => value >= confirmationThreshold)
          .length;
      final hasConfirmedPeak =
          confirmationMatches >= _accelerationPeakRequiredMatches;
      if (hasConfirmedPeak && accelerationG > _recordingMaxAccelerationG) {
        _recordingMaxAccelerationG = accelerationG;
      }
      _updateJumpDetectionFromAcceleration(accelerationG);
      if (mounted) {
        setState(() {});
      }
    }
    if (accelerationG.isFinite &&
        accelerationG >= _accelerationEventThresholdG &&
        _currentTrackSpeedKnots() >= _motionEventMinSpeedKnots &&
        _canRegisterMotionEvent(_lastAccelerationEventAt)) {
      _recordingAccelerationEventCount += 1;
      _lastAccelerationEventAt = DateTime.now();
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _onGyroscopeSample(GyroscopeEvent event) {
    if (_captureState != _SessionCaptureState.recording) {
      return;
    }
    const radiansToDegrees = 57.295779513;
    final rotationDegPerSec =
        math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z) *
        radiansToDegrees;
    if (rotationDegPerSec.isFinite &&
        rotationDegPerSec > _recordingMaxRotationDegPerSec) {
      _recordingMaxRotationDegPerSec = rotationDegPerSec;
      if (mounted) {
        setState(() {});
      }
    }
    if (rotationDegPerSec.isFinite) {
      _updateJumpDetectionFromRotation(rotationDegPerSec);
    }
    if (rotationDegPerSec.isFinite &&
        rotationDegPerSec >= _rotationEventThresholdDegPerSec &&
        _currentTrackSpeedKnots() >= _motionEventMinSpeedKnots &&
        _canRegisterMotionEvent(_lastRotationEventAt)) {
      _recordingRotationEventCount += 1;
      _lastRotationEventAt = DateTime.now();
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _updateJumpDetectionFromAcceleration(double accelerationG) {
    switch (_activeJumpDetectionMode()) {
      case 'barometric':
        _updateBarometricJumpDetectionFromAcceleration(accelerationG);
        return;
      case 'inertial_fallback':
        _updateInertialJumpDetectionFromAcceleration(accelerationG);
        return;
    }
  }

  void _updateInertialJumpDetectionFromAcceleration(double accelerationG) {
    final now = DateTime.now();
    final currentSpeedKnots = _currentTrackSpeedKnots();
    _expirePendingJumpIfNeeded(now);
    _maybeStartJumpCandidate(
      now: now,
      currentSpeedKnots: currentSpeedKnots,
      accelerationG: accelerationG,
    );

    final candidate = _pendingJumpCandidate;
    if (candidate == null) {
      return;
    }

    _pendingJumpCandidate = candidate.copyWith(
      maxManeuverG: math.max(candidate.maxManeuverG, accelerationG),
    );

    final airborneTime = now.difference(candidate.startedAt);
    if (airborneTime >= _jumpMinAirTime &&
        airborneTime <= _jumpMaxAirTime &&
        accelerationG >= _jumpLandingThresholdG &&
        currentSpeedKnots >= _jumpLandingMinSpeedKnots) {
      _finalizeJumpCandidate(
        landedAt: now,
        landingG: accelerationG,
        landingSpeedKnots: currentSpeedKnots,
      );
    }
  }

  void _updateJumpDetectionFromRotation(double rotationDegPerSec) {
    switch (_activeJumpDetectionMode()) {
      case 'barometric':
        _updateBarometricJumpDetectionFromRotation(rotationDegPerSec);
        return;
      case 'inertial_fallback':
        _updateInertialJumpDetectionFromRotation(rotationDegPerSec);
        return;
    }
  }

  void _updateInertialJumpDetectionFromRotation(double rotationDegPerSec) {
    final now = DateTime.now();
    final currentSpeedKnots = _currentTrackSpeedKnots();
    _expirePendingJumpIfNeeded(now);
    _maybeStartJumpCandidate(
      now: now,
      currentSpeedKnots: currentSpeedKnots,
      rotationDegPerSec: rotationDegPerSec,
    );

    final candidate = _pendingJumpCandidate;
    if (candidate == null) {
      return;
    }

    _pendingJumpCandidate = candidate.copyWith(
      maxRotationDegPerSec: math.max(
        candidate.maxRotationDegPerSec,
        rotationDegPerSec,
      ),
    );
  }

  void _updateBarometricJumpDetectionFromAcceleration(double accelerationG) {
    // Ruta provisional hasta que conectemos deteccion real por altitud relativa.
    _updateInertialJumpDetectionFromAcceleration(accelerationG);
  }

  void _updateBarometricJumpDetectionFromRotation(double rotationDegPerSec) {
    // Ruta provisional hasta que conectemos perfil vertical barometrico real.
    _updateInertialJumpDetectionFromRotation(rotationDegPerSec);
  }

  String _activeJumpDetectionMode() {
    final deviceKind = _selectedDevice?.kind ?? 'Dispositivo Android';
    return SessionInsightData.jumpDetectionModeForSensors(
      _physicalSensorsForDeviceKind(deviceKind),
    );
  }

  void _maybeStartJumpCandidate({
    required DateTime now,
    required double currentSpeedKnots,
    double? accelerationG,
    double? rotationDegPerSec,
  }) {
    if (_pendingJumpCandidate != null ||
        currentSpeedKnots < _jumpMinTakeoffSpeedKnots) {
      return;
    }
    if (_lastJumpRecordedAt != null &&
        now.difference(_lastJumpRecordedAt!) < _jumpCooldown) {
      return;
    }

    final hasAccelerationTrigger =
        accelerationG != null && accelerationG >= _jumpMinManeuverG;
    final hasRotationTrigger =
        rotationDegPerSec != null &&
        rotationDegPerSec >= _jumpMinManeuverRotationDegPerSec;
    if (!hasAccelerationTrigger && !hasRotationTrigger) {
      return;
    }

    _pendingJumpCandidate = _PendingJumpCandidate(
      startedAt: now,
      takeoffSpeedKnots: currentSpeedKnots,
      maxManeuverG: accelerationG ?? 0,
      maxRotationDegPerSec: rotationDegPerSec ?? 0,
    );
  }

  void _expirePendingJumpIfNeeded(DateTime now) {
    final candidate = _pendingJumpCandidate;
    if (candidate == null) {
      return;
    }
    if (now.difference(candidate.startedAt) > _jumpMaxAirTime) {
      _pendingJumpCandidate = null;
    }
  }

  void _finalizeJumpCandidate({
    required DateTime landedAt,
    required double landingG,
    required double landingSpeedKnots,
  }) {
    final candidate = _pendingJumpCandidate;
    final startedAt = _recordingStartedAt;
    if (candidate == null || startedAt == null) {
      _pendingJumpCandidate = null;
      return;
    }

    final hangtime = landedAt.difference(candidate.startedAt);
    final hangtimeSeconds = hangtime.inMilliseconds / 1000;
    if (hangtimeSeconds < (_jumpMinAirTime.inMilliseconds / 1000)) {
      _pendingJumpCandidate = null;
      return;
    }

    const gravityMetersPerSecond2 = 9.80665;
    final estimatedHeightMeters =
        gravityMetersPerSecond2 *
        hangtimeSeconds *
        hangtimeSeconds /
        8;
    final estimatedFallSpeedMetersPerSecond =
        gravityMetersPerSecond2 * hangtimeSeconds / 2;

    _recordingJumpHistory.add(
      SessionJumpRecord(
        index: _recordingJumpHistory.length + 1,
        heightMeters: estimatedHeightMeters,
        hangtimeSeconds: hangtimeSeconds,
        maneuverG: candidate.maxManeuverG > 0 ? candidate.maxManeuverG : null,
        maneuverRotationDegPerSec: candidate.maxRotationDegPerSec > 0
            ? candidate.maxRotationDegPerSec
            : null,
        fallSpeedMetersPerSecond: estimatedFallSpeedMetersPerSecond,
        takeoffSpeedKnots: candidate.takeoffSpeedKnots,
        landingSpeedKnots: landingSpeedKnots,
        landingG: landingG,
        recordedAt: candidate.startedAt.difference(startedAt),
      ),
    );
    _lastJumpRecordedAt = landedAt;
    _pendingJumpCandidate = null;
  }

  bool _canRegisterMotionEvent(DateTime? lastEventAt) {
    if (lastEventAt == null) {
      return true;
    }
    return DateTime.now().difference(lastEventAt) >= _motionEventCooldown;
  }

  void _updateAutoPauseState({
    required Duration delta,
    required double speedKnots,
  }) {
    if (_isAutoPaused) {
      if (speedKnots >= _autoResumeSpeedKnots) {
        _recordingResumeCandidateDuration += delta;
        if (_recordingResumeCandidateDuration >= _autoResumeDelay) {
          _isAutoPaused = false;
          _recordingLowSpeedCandidateDuration = Duration.zero;
          _recordingResumeCandidateDuration = Duration.zero;
        }
        return;
      }
      _recordingResumeCandidateDuration = Duration.zero;
      _recordingAutoPausedDuration += delta;
      return;
    }

    final hasLowSpeed = speedKnots <= _autoPauseSpeedKnots;
    final hasNoRecentMotion = !_hasRecentMotionActivity(
      window: _autoPauseDelay,
    );
    if (hasLowSpeed && hasNoRecentMotion) {
      _recordingLowSpeedCandidateDuration += delta;
      _recordingResumeCandidateDuration = Duration.zero;
      if (_recordingLowSpeedCandidateDuration >= _autoPauseDelay) {
        _isAutoPaused = true;
        _recordingAutoPausedDuration += _recordingLowSpeedCandidateDuration;
        _recordingLowSpeedCandidateDuration = Duration.zero;
        _recordingAutoPauseCount += 1;
      }
      return;
    }

    _recordingLowSpeedCandidateDuration = Duration.zero;
    _recordingResumeCandidateDuration = Duration.zero;
  }

  bool _hasRecentMotionActivity({required Duration window}) {
    final now = DateTime.now();
    final lastMotionAt = <DateTime?>[
      _lastAccelerationEventAt,
      _lastRotationEventAt,
    ].whereType<DateTime>().fold<DateTime?>(
      null,
      (latest, value) => latest == null || value.isAfter(latest) ? value : latest,
    );
    if (lastMotionAt == null) {
      return false;
    }
    return now.difference(lastMotionAt) < window;
  }

  bool _isUsableRecordingPosition(Position position) {
    final accuracy = position.accuracy;
    if (!accuracy.isFinite || accuracy <= 0) {
      return false;
    }
    if (accuracy > _gpsSampleMaxAccuracyMeters) {
      return false;
    }
    if (!position.latitude.isFinite || !position.longitude.isFinite) {
      return false;
    }
    return true;
  }

  bool _isPlausibleTrackStep({
    required _SessionLocationSample? previous,
    required _SessionLocationSample current,
  }) {
    if (previous == null) {
      return true;
    }
    final deltaMs = current.timestamp.difference(previous.timestamp).inMilliseconds;
    if (deltaMs <= 0) {
      return false;
    }
    final legMeters = Geolocator.distanceBetween(
      previous.latitude,
      previous.longitude,
      current.latitude,
      current.longitude,
    );
    if (!legMeters.isFinite || legMeters < 0) {
      return false;
    }
    final metersPerSecond = legMeters / (deltaMs / 1000);
    if (!metersPerSecond.isFinite) {
      return false;
    }
    final knots = metersPerSecond * 1.943844;
    return knots <= _gpsMaxPlausibleSpeedKnots;
  }

  double _resolveSpeedKnots(Position position) {
    const metersPerSecondToKnots = 1.943844;
    final raw = position.speed;
    if (raw.isFinite && raw > 0) {
      return raw * metersPerSecondToKnots;
    }
    if (_recordingSamples.isNotEmpty) {
      final previous = _recordingSamples.last;
      final now = position.timestamp;
      final delta = now.difference(previous.timestamp);
      if (delta.inMilliseconds > 0) {
        final distance = Geolocator.distanceBetween(
          previous.latitude,
          previous.longitude,
          position.latitude,
          position.longitude,
        );
        final metersPerSecond = distance / (delta.inMilliseconds / 1000);
        if (metersPerSecond.isFinite && metersPerSecond > 0) {
          return metersPerSecond * metersPerSecondToKnots;
        }
      }
    }
    return 0;
  }

  double _computeNetDisplacementKm() {
    if (_recordingSamples.length < 2) {
      return 0;
    }
    final first = _recordingSamples.first;
    final last = _recordingSamples.last;
    return Geolocator.distanceBetween(
          first.latitude,
          first.longitude,
          last.latitude,
          last.longitude,
        ) /
        1000;
  }

  double _computeCoverageAreaKm2() {
    if (_recordingSamples.length < 2) {
      return 0;
    }
    var minLat = _recordingSamples.first.latitude;
    var maxLat = _recordingSamples.first.latitude;
    var minLon = _recordingSamples.first.longitude;
    var maxLon = _recordingSamples.first.longitude;

    for (final sample in _recordingSamples.skip(1)) {
      minLat = math.min(minLat, sample.latitude);
      maxLat = math.max(maxLat, sample.latitude);
      minLon = math.min(minLon, sample.longitude);
      maxLon = math.max(maxLon, sample.longitude);
    }

    final midLatRadians = ((minLat + maxLat) / 2) * math.pi / 180;
    final latKm = (maxLat - minLat) * 111.32;
    final lonKm = (maxLon - minLon) * 111.32 * math.cos(midLatRadians);
    final area = latKm * lonKm;
    return area.isFinite ? area.abs() : 0;
  }

  double _computeMaxDistanceFromStartKm() {
    if (_recordingSamples.length < 2) {
      return 0;
    }
    final first = _recordingSamples.first;
    var maxDistanceMeters = 0.0;
    for (final sample in _recordingSamples.skip(1)) {
      final distanceMeters = Geolocator.distanceBetween(
        first.latitude,
        first.longitude,
        sample.latitude,
        sample.longitude,
      );
      if (!distanceMeters.isFinite || distanceMeters < 0) {
        continue;
      }
      if (distanceMeters > maxDistanceMeters) {
        maxDistanceMeters = distanceMeters;
      }
    }
    return maxDistanceMeters / 1000;
  }

  Duration _computeTimeInRiskZone() {
    if (_recordingSamples.length < 2) {
      return Duration.zero;
    }
    const riskDistanceMeters = 500.0;
    final first = _recordingSamples.first;
    var total = Duration.zero;

    for (var i = 1; i < _recordingSamples.length; i++) {
      final previous = _recordingSamples[i - 1];
      final current = _recordingSamples[i];
      final distanceFromStartMeters = Geolocator.distanceBetween(
        first.latitude,
        first.longitude,
        current.latitude,
        current.longitude,
      );
      if (!distanceFromStartMeters.isFinite ||
          distanceFromStartMeters < riskDistanceMeters) {
        continue;
      }
      final delta = current.timestamp.difference(previous.timestamp);
      if (delta.isNegative || delta.inMilliseconds <= 0) {
        continue;
      }
      total += delta;
    }

    return total;
  }

  double _computeSweetspotPercent() {
    if (_recordingSamples.isEmpty || _recordingMaxSpeedKnots <= 0) {
      return 0;
    }
    final minSweetspot = _recordingMaxSpeedKnots * 0.7;
    final maxSweetspot = _recordingMaxSpeedKnots * 0.9;
    final matchingCount = _recordingSamples
        .where(
          (sample) =>
              sample.speedKnots >= minSweetspot &&
              sample.speedKnots <= maxSweetspot,
        )
        .length;
    return (matchingCount / _recordingSamples.length) * 100;
  }

  double _computeDirectionalStabilityPercent() {
    final bearings = <double>[];
    for (var i = 1; i < _recordingSamples.length; i++) {
      final previous = _recordingSamples[i - 1];
      final current = _recordingSamples[i];
      final distance = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        current.latitude,
        current.longitude,
      );
      if (!distance.isFinite || distance < 3) {
        continue;
      }
      bearings.add(
        Geolocator.bearingBetween(
          previous.latitude,
          previous.longitude,
          current.latitude,
          current.longitude,
        ),
      );
    }
    if (bearings.length < 2) {
      return 0;
    }
    var totalDelta = 0.0;
    for (var i = 1; i < bearings.length; i++) {
      final delta = (bearings[i] - bearings[i - 1]).abs();
      totalDelta += math.min(delta, 360 - delta);
    }
    final averageDelta = totalDelta / (bearings.length - 1);
    return (100 - (averageDelta / 180) * 100).clamp(0, 100);
  }

  double _computeRouteEfficiencyPercent() {
    if (_recordingDistanceMeters <= 0) {
      return 0;
    }
    final netDistanceMeters = _computeNetDisplacementKm() * 1000;
    return ((netDistanceMeters / _recordingDistanceMeters) * 100).clamp(
      0,
      100,
    );
  }

  double _computeAverageSampleIntervalSeconds() {
    if (_recordingSamples.length < 2) {
      return 0;
    }
    var totalSeconds = 0.0;
    var segmentCount = 0;
    for (var i = 1; i < _recordingSamples.length; i++) {
      final delta = _recordingSamples[i].timestamp
          .difference(_recordingSamples[i - 1].timestamp)
          .inMilliseconds /
          1000;
      if (!delta.isFinite || delta <= 0) {
        continue;
      }
      totalSeconds += delta;
      segmentCount += 1;
    }
    if (segmentCount == 0) {
      return 0;
    }
    return totalSeconds / segmentCount;
  }

  double _computeBoundedScore(List<double> components) {
    final normalized = components
        .where((value) => value.isFinite)
        .map((value) => value.clamp(0, 100).toDouble())
        .toList(growable: false);
    if (normalized.isEmpty) {
      return 0;
    }
    final total = normalized.reduce((a, b) => a + b);
    return total / normalized.length;
  }

  _TrackTransitionSummary _analyzeTrackTransitions() {
    if (_recordingSamples.length < 3) {
      return const _TrackTransitionSummary.empty();
    }

    var transitionCount = 0;
    var cleanCount = 0;
    var totalSpeedLossKnots = 0.0;
    var totalRecoverySeconds = 0.0;
    var recoveryCount = 0;

    for (var i = 1; i < _recordingSamples.length - 1; i++) {
      final previous = _recordingSamples[i - 1];
      final current = _recordingSamples[i];
      final next = _recordingSamples[i + 1];

      final previousDistance = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        current.latitude,
        current.longitude,
      );
      final nextDistance = Geolocator.distanceBetween(
        current.latitude,
        current.longitude,
        next.latitude,
        next.longitude,
      );
      if (!previousDistance.isFinite ||
          !nextDistance.isFinite ||
          previousDistance < 3 ||
          nextDistance < 3) {
        continue;
      }

      final previousBearing = Geolocator.bearingBetween(
        previous.latitude,
        previous.longitude,
        current.latitude,
        current.longitude,
      );
      final nextBearing = Geolocator.bearingBetween(
        current.latitude,
        current.longitude,
        next.latitude,
        next.longitude,
      );
      final rawDelta = (nextBearing - previousBearing).abs();
      final bearingDelta = math.min(rawDelta, 360 - rawDelta);
      if (bearingDelta < 35 || bearingDelta > 170) {
        continue;
      }

      final beforeSpeed = ((previous.speedKnots + current.speedKnots) / 2);
      final afterSpeed = ((current.speedKnots + next.speedKnots) / 2);
      if (beforeSpeed < _movingAverageMinSpeedKnots &&
          afterSpeed < _movingAverageMinSpeedKnots) {
        continue;
      }

      transitionCount += 1;
      final speedLoss = math.max(0.0, beforeSpeed - afterSpeed);
      totalSpeedLossKnots += speedLoss;

      if (afterSpeed >= beforeSpeed * 0.7) {
        cleanCount += 1;
      }

      final recoveryThreshold = math.max(_movingAverageMinSpeedKnots, beforeSpeed * 0.8);
      for (var j = i + 1; j < _recordingSamples.length; j++) {
        final recoverySample = _recordingSamples[j];
        if (recoverySample.speedKnots < recoveryThreshold) {
          continue;
        }
        final recoverySeconds = recoverySample.timestamp
            .difference(current.timestamp)
            .inMilliseconds /
            1000;
        if (recoverySeconds.isFinite && recoverySeconds >= 0) {
          totalRecoverySeconds += recoverySeconds;
          recoveryCount += 1;
        }
        break;
      }
    }

    if (transitionCount == 0) {
      return const _TrackTransitionSummary.empty();
    }

    return _TrackTransitionSummary(
      count: transitionCount,
      qualityPercent: (cleanCount / transitionCount) * 100,
      avgSpeedLossKnots: totalSpeedLossKnots / transitionCount,
      avgRecoverySeconds: recoveryCount == 0
          ? 0
          : totalRecoverySeconds / recoveryCount,
    );
  }

  Future<void> _stopRealSessionRecording() async {
    _recordingTicker?.cancel();
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    await _userAccelerometerSubscription?.cancel();
    _userAccelerometerSubscription = null;
    await _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;

    final hasEnoughSamples = _hasEnoughRecordedTrackForSave();
    if (!hasEnoughSamples) {
      if (!mounted) {
        return;
      }
      _resetRecordingState();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No hemos podido registrar suficiente track GPS. Necesitamos 2 puntos validos, 1 minuto y 20 metros.',
          ),
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _captureState = _SessionCaptureState.finished;
    });
  }

  _RecordedSession _buildRecordedSessionFromCapture({
    required ({
      String spot,
      String notes,
      _SessionMediaSelection mediaSelection,
      String? sessionPhotoLocalPath,
      String? gearSetupId,
      String? gearSetupName,
    })
    config,
    required DateTime endedAt,
    required Duration duration,
  }) {
    final title = 'Sesion en ${config.spot}';
    final selectedDevice = _selectedDevice;
    final deviceName = selectedDevice?.name ?? 'Desconocido';
    final deviceKind = selectedDevice?.kind ?? 'Dispositivo Android';
    final deviceSensorKeys = _physicalSensorsForDeviceKind(deviceKind)
        .toList(growable: false);
    final jumpDetectionMode = SessionInsightData.jumpDetectionModeForSensors(
      deviceSensorKeys,
    );
    final distanceKm = _recordingDistanceMeters / 1000;
    final avgSpeedKnots = _recordingSamples.isEmpty
        ? 0.0
        : _recordingSamples
                  .map((sample) => sample.speedKnots)
                  .reduce((a, b) => a + b) /
              _recordingSamples.length;
    final activeDuration = duration - _recordingAutoPausedDuration;
    final movingSpeedSamples = _recordingSamples
        .where((sample) => sample.speedKnots >= _movingAverageMinSpeedKnots)
        .map((sample) => sample.speedKnots)
        .toList(growable: false);
    final movingAvgSpeedKnots = movingSpeedSamples.isEmpty
        ? 0.0
        : movingSpeedSamples.reduce((a, b) => a + b) / movingSpeedSamples.length;
    final planingMinutes = _recordingMovingDuration.inMinutes > 0
        ? _recordingMovingDuration.inMinutes
        : null;
    final pausedDuration = _recordingAutoPausedDuration;
    final safeActiveDuration = activeDuration.isNegative
        ? Duration.zero
        : activeDuration;
    final safePausedDuration = pausedDuration.isNegative
        ? Duration.zero
        : pausedDuration;
    final timelineSamples = List<double>.from(_recordingTimelineKnots)
      ..sort();
    final speedP95Knots = timelineSamples.isEmpty
        ? 0.0
        : timelineSamples[((timelineSamples.length - 1) * 0.95).floor()];
    final netDisplacementKm = _computeNetDisplacementKm();
    final maxDistanceFromStartKm = _computeMaxDistanceFromStartKm();
    final timeInRiskZone = _computeTimeInRiskZone();
    final coverageAreaKm2 = _computeCoverageAreaKm2();
    final sweetspotPercent = _computeSweetspotPercent();
    final directionalStabilityPercent = _computeDirectionalStabilityPercent();
    final routeEfficiencyPercent = _computeRouteEfficiencyPercent();
    final transitionSummary = _analyzeTrackTransitions();
    final rawPositionCount = _recordingRawPositionCount;
    final rejectedCount =
        _recordingRejectedAccuracyCount + _recordingRejectedPlausibilityCount;
    final lostSamplesPercent = rawPositionCount <= 0
        ? 0.0
        : (rejectedCount / rawPositionCount) * 100;
    final datasetHealthPercent = rawPositionCount <= 0
        ? 0.0
        : ((_recordingSamples.length / rawPositionCount) * 100)
              .clamp(0, 100)
              .toDouble();
    final averageSampleIntervalSeconds = _computeAverageSampleIntervalSeconds();
    final sessionScore = _computeBoundedScore([
      datasetHealthPercent,
      (100 - lostSamplesPercent).toDouble(),
      sweetspotPercent,
      routeEfficiencyPercent,
      directionalStabilityPercent,
    ]);
    final freerideScore = _computeBoundedScore([
      routeEfficiencyPercent,
      sweetspotPercent,
      directionalStabilityPercent,
      timelineSamples.isEmpty
          ? 0.0
          : (10 - (timelineSamples.last - timelineSamples.first).clamp(0, 10)) *
                10.0,
    ]);
    final safetyScore = _computeBoundedScore([
      datasetHealthPercent,
      _lastGpsAccuracyMeters == null
          ? 0.0
          : (100 - (_lastGpsAccuracyMeters!.clamp(0, 25) / 25) * 100)
                .toDouble(),
      math.max(
        0.0,
        100 -
            ((duration.inSeconds <= 0
                        ? 0.0
                        : (_recordingAccelerationEventCount /
                              (duration.inSeconds / 3600))) *
                    18),
      ),
      math.max(0.0, 100 - (_recordingRotationEventCount * 10)),
    ]);
    final distancePlaningKm = movingAvgSpeedKnots > 0 && _recordingMovingDuration > Duration.zero
        ? ((movingAvgSpeedKnots * 0.514444) *
                  _recordingMovingDuration.inMilliseconds /
                  1000) /
              1000
        : 0.0;
    final transitionsCount = transitionSummary.count > 0
        ? transitionSummary.count
        : _recordingAccelerationEventCount + _recordingRotationEventCount;
    final transitionsPerHour = duration.inSeconds <= 0
        ? 0.0
        : transitionsCount / (duration.inSeconds / 3600);
    final jumpHistory = List<SessionJumpRecord>.unmodifiable(
      _recordingJumpHistory,
    );
    final jumpsCount = jumpHistory.length;
    final maxJumpHeightMeters = jumpHistory.isEmpty
        ? null
        : jumpHistory
            .map((jump) => jump.heightMeters)
            .reduce(math.max);
    final maxHangtimeSeconds = jumpHistory.isEmpty
        ? null
        : jumpHistory
            .map((jump) => jump.hangtimeSeconds)
            .reduce(math.max);
    final avgJumpHeightMeters = jumpHistory.isEmpty
        ? null
        : jumpHistory
                  .map((jump) => jump.heightMeters)
                  .reduce((a, b) => a + b) /
              jumpHistory.length;
    final top5AverageJumpMeters = jumpHistory.isEmpty
        ? null
        : (List<SessionJumpRecord>.from(jumpHistory)
                  ..sort((a, b) => b.heightMeters.compareTo(a.heightMeters)))
                .take(5)
                .map((jump) => jump.heightMeters)
                .reduce((a, b) => a + b) /
            math.min(5, jumpHistory.length);
    final hangtimeP95Seconds = jumpHistory.isEmpty
        ? null
        : (() {
            final values = jumpHistory
                .map((jump) => jump.hangtimeSeconds)
                .toList(growable: false)
              ..sort();
            return values[((values.length - 1) * 0.95).floor()];
          })();
    final takeoffSpeedKnots = jumpHistory
        .map((jump) => jump.takeoffSpeedKnots)
        .whereType<double>()
        .toList(growable: false);
    final landingSpeedKnots = jumpHistory
        .map((jump) => jump.landingSpeedKnots)
        .whereType<double>()
        .toList(growable: false);
    final landingGs = jumpHistory
        .map((jump) => jump.landingG)
        .toList(growable: false);
    final cleanLandingRate = landingGs.isEmpty
        ? null
        : (landingGs.where((value) => value <= 2.4).length / landingGs.length) *
              100;
    final impactScore = landingGs.isEmpty
        ? null
        : landingGs.reduce((a, b) => a + b) / landingGs.length;
    final jumpCadencePerHour = jumpsCount == 0 || duration.inSeconds <= 0
        ? null
        : jumpsCount / (duration.inSeconds / 3600);
    final jumpHeights = jumpHistory
        .map((jump) => jump.heightMeters)
        .toList(growable: false);
    final jumpHeightSpread = jumpHeights.length < 2
        ? null
        : jumpHeights.reduce(math.max) - jumpHeights.reduce(math.min);
    final jumpHeightConsistency = jumpHeightSpread == null || avgJumpHeightMeters == null
        ? null
        : math.max(
            0.0,
            100 -
                ((jumpHeightSpread /
                            math.max(avgJumpHeightMeters, 0.1)) *
                        100)
                    .clamp(0, 100),
          ).toDouble();
    final averageTakeoffSpeedKnots = takeoffSpeedKnots.isEmpty
        ? null
        : takeoffSpeedKnots.reduce((a, b) => a + b) / takeoffSpeedKnots.length;
    final jumpWindEfficiency = maxJumpHeightMeters == null ||
            averageTakeoffSpeedKnots == null ||
            averageTakeoffSpeedKnots <= 0
        ? null
        : (maxJumpHeightMeters / averageTakeoffSpeedKnots) * 10;
    final jumpHeightDistribution = jumpHeights.isEmpty
        ? null
        : '${jumpHeights.where((value) => value < 3).length}/'
            '${jumpHeights.where((value) => value >= 3 && value < 6).length}/'
            '${jumpHeights.where((value) => value >= 6).length}';
    final bigAirScore = jumpsCount == 0
        ? null
        : _computeBoundedScore([
            maxJumpHeightMeters == null
                ? 0
                : (maxJumpHeightMeters * 12).clamp(0, 100).toDouble(),
            maxHangtimeSeconds == null
                ? 0
                : (maxHangtimeSeconds * 20).clamp(0, 100).toDouble(),
            cleanLandingRate ?? 0,
            jumpHeightConsistency ?? 0,
          ]);
    final measuredValues = <String, String>{
      'duracion_total': _formatDuration(duration),
      'tiempo_activo': _formatDuration(safeActiveDuration),
      'tiempo_parado': _formatDuration(safePausedDuration),
      'ratio_activo_parado': safePausedDuration.inSeconds <= 0
          ? '${safeActiveDuration.inMinutes}:0'
          : '${(safeActiveDuration.inSeconds / safePausedDuration.inSeconds).toStringAsFixed(1)}:1',
      'distancia_total': '${distanceKm.toStringAsFixed(2)} km',
      'distancia_planeo': '${distancePlaningKm.toStringAsFixed(2)} km',
      'velocidad_media': '${avgSpeedKnots.toStringAsFixed(1)} kt',
      'velocidad_max': '${_recordingMaxSpeedKnots.toStringAsFixed(1)} kt',
      'velocidad_p95': '${speedP95Knots.toStringAsFixed(1)} kt',
      'transiciones': '$transitionsCount',
      'transiciones_hora': transitionsPerHour.toStringAsFixed(1),
      if (top5AverageJumpMeters != null)
        'top5_saltos': '${top5AverageJumpMeters.toStringAsFixed(1)} m',
      if (avgJumpHeightMeters != null)
        'altura_media_saltos': '${avgJumpHeightMeters.toStringAsFixed(1)} m',
      if (maxHangtimeSeconds != null)
        'hangtime_max': '${maxHangtimeSeconds.toStringAsFixed(1)} s',
      if (hangtimeP95Seconds != null)
        'hangtime_p95': '${hangtimeP95Seconds.toStringAsFixed(1)} s',
      if (jumpWindEfficiency != null)
        'eficiencia_salto_viento': jumpWindEfficiency.toStringAsFixed(2),
      if (jumpCadencePerHour != null)
        'cadencia_saltos': '${jumpCadencePerHour.toStringAsFixed(1)}/h',
      if (jumpHeightConsistency != null)
        'consistencia_alturas':
            '${jumpHeightConsistency.toStringAsFixed(0)}%',
      'eficiencia_bordos': '${routeEfficiencyPercent.toStringAsFixed(0)}%',
      'tiempo_sweetspot': '${sweetspotPercent.toStringAsFixed(0)}%',
      'deriva_neta': '${netDisplacementKm.toStringAsFixed(2)} km',
      'cobertura_area': '${coverageAreaKm2.toStringAsFixed(2)} km2',
      if (maxJumpHeightMeters != null)
        'salto_mas_alto': '${maxJumpHeightMeters.toStringAsFixed(1)} m',
      if (maxJumpHeightMeters != null)
        'distancia_salto_estimada':
            '${(maxJumpHeightMeters * 4.5).toStringAsFixed(0)} m',
      ...?jumpHeightDistribution == null
          ? null
          : <String, String>{
              'distribucion_alturas': jumpHeightDistribution,
            },
      if (takeoffSpeedKnots.isNotEmpty)
        'takeoff_speed':
            '${(takeoffSpeedKnots.reduce((a, b) => a + b) / takeoffSpeedKnots.length).toStringAsFixed(1)} kt',
      if (landingSpeedKnots.isNotEmpty)
        'landing_speed':
            '${(landingSpeedKnots.reduce((a, b) => a + b) / landingSpeedKnots.length).toStringAsFixed(1)} kt',
      if (cleanLandingRate != null)
        'clean_landing_rate': '${cleanLandingRate.toStringAsFixed(0)}%',
      if (impactScore != null)
        'impact_score': '${impactScore.toStringAsFixed(1)} G',
      'variabilidad_velocidad': timelineSamples.length >= 2
          ? '${(timelineSamples.last - timelineSamples.first).toStringAsFixed(1)} kt'
          : '0.0 kt',
      'estabilidad_direccional': '${directionalStabilityPercent.toStringAsFixed(0)}%',
      'calidad_jibe': transitionSummary.count > 0
          ? '${transitionSummary.qualityPercent.toStringAsFixed(0)}%'
          : '0%',
      'perdida_vel_transiciones': transitionSummary.avgSpeedLossKnots > 0
          ? '${transitionSummary.avgSpeedLossKnots.toStringAsFixed(1)} kt'
          : '0.0 kt',
      'recuperacion_planeo': transitionSummary.avgRecoverySeconds > 0
          ? '${transitionSummary.avgRecoverySeconds.toStringAsFixed(1)} s'
          : '0.0 s',
      'smoothness_score': timelineSamples.length >= 2
          ? '${(10 - (timelineSamples.last - timelineSamples.first).clamp(0, 10) / 2).toStringAsFixed(1)}/10'
          : '10.0/10',
      'caidas_hora': duration.inSeconds <= 0
          ? '0.0'
          : (_recordingAccelerationEventCount / (duration.inSeconds / 3600))
                .toStringAsFixed(1),
      'eventos_sobrepotencia': '$_recordingRotationEventCount',
      'distancia_max_costa': '${maxDistanceFromStartKm.toStringAsFixed(2)} km',
      'tiempo_zona_riesgo': _formatDuration(timeInRiskZone),
      'calidad_gps': _lastGpsAccuracyMeters == null
          ? '--'
          : '${_lastGpsAccuracyMeters!.toStringAsFixed(1)} m',
      'samples_perdidos': '${lostSamplesPercent.toStringAsFixed(0)}%',
      'latencia_sync': averageSampleIntervalSeconds > 0
          ? '${averageSampleIntervalSeconds.toStringAsFixed(1)} s'
          : '--',
      'health_dataset': '${datasetHealthPercent.toStringAsFixed(0)}%',
      'session_score': '${sessionScore.toStringAsFixed(0)}/100',
      if (bigAirScore != null)
        'big_air_score': '${bigAirScore.toStringAsFixed(0)}/100',
      'freeride_score': '${freerideScore.toStringAsFixed(0)}/100',
      'safety_score': '${safetyScore.toStringAsFixed(0)}/100',
    };
    final insights = SessionInsightData(
      deviceKind: deviceKind,
      deviceSensorKeys: deviceSensorKeys,
      jumpDetectionMode: jumpDetectionMode,
      distanceKm: distanceKm > 0 ? distanceKm : null,
      maxSpeedKnots: _recordingMaxSpeedKnots > 0 ? _recordingMaxSpeedKnots : null,
      avgSpeedKnots: avgSpeedKnots > 0 ? avgSpeedKnots : null,
      movingAvgSpeedKnots: movingAvgSpeedKnots > 0 ? movingAvgSpeedKnots : null,
      planingMinutes: planingMinutes,
      recordedPointCount: _recordingSamples.length,
      autoPauseCount: _recordingAutoPauseCount,
      accelerationEventCount: _recordingAccelerationEventCount,
      rotationEventCount: _recordingRotationEventCount,
      maxAccelerationG: null,
      maxRotationDegPerSec: _recordingMaxRotationDegPerSec > 0
          ? _recordingMaxRotationDegPerSec
          : null,
      batteryStart: null,
      batteryEnd: null,
      jumpsCount: jumpsCount > 0 ? jumpsCount : null,
      maxJumpHeightMeters: maxJumpHeightMeters,
      maxHangtimeSeconds: maxHangtimeSeconds,
      jumpHistory: jumpHistory,
      timelineKnots: List<double>.unmodifiable(_recordingTimelineKnots),
      routePoints: List<SessionTrackPoint>.unmodifiable(
        _recordingSamples
            .map(
              (sample) => SessionTrackPoint(
                latitude: sample.latitude,
                longitude: sample.longitude,
                speedKnots: sample.speedKnots,
                recordedAt: sample.timestamp,
              ),
            )
            .toList(growable: false),
      ),
      events: _buildDetectedEvents(
        pointCount: _recordingSamples.length,
        maxSpeedKnots: _recordingMaxSpeedKnots,
      ),
      groups: SessionInsightData.buildGroupsForRecordedSession(
        values: measuredValues,
      ),
    );

    return _RecordedSession(
      id: _newSessionId(),
      title: title,
      deviceName: deviceName,
      endedAt: endedAt,
      duration: duration,
      summary: config.notes.isEmpty
          ? 'Sesion real grabada con el telefono.'
          : config.notes,
      gearSetupId: config.gearSetupId,
      gearSetupName: config.gearSetupName,
      hasSessionPhoto: config.sessionPhotoLocalPath != null,
      sessionMediaLabel: switch (config.mediaSelection) {
        _SessionMediaSelection.none => 'Pantallazo del mapa del spot',
        _SessionMediaSelection.camera => 'Foto tomada con camara',
        _SessionMediaSelection.gallery => 'Foto elegida de galeria',
      },
      sessionPhotoLocalPath: config.sessionPhotoLocalPath,
      spotName: config.spot,
      insights: insights,
    );
  }

  List<String> _buildDetectedEvents({
    required int pointCount,
    required double maxSpeedKnots,
  }) {
    final events = <String>[
      'Sesion real grabada con el GPS del telefono',
      'Track validado con $pointCount puntos GPS',
    ];
    if (_recordingAutoPauseCount > 0) {
      events.add('$_recordingAutoPauseCount auto-pausas detectadas');
    }
    if (_recordingAccelerationEventCount > 0) {
      events.add(
        '$_recordingAccelerationEventCount aceleraciones bruscas detectadas',
      );
    }
    if (_recordingRotationEventCount > 0) {
      events.add('$_recordingRotationEventCount giros bruscos detectados');
    }
    if (maxSpeedKnots > 0) {
      events.add(
        'Punta maxima registrada: ${maxSpeedKnots.toStringAsFixed(1)} kt',
      );
    }
    return events;
  }

  List<_RecordedSession> _filteredSessions() {
    final query = _sessionSearchController.text.trim().toLowerCase();
    var items = _sessionFeed.where((session) {
      final byDevice =
          _sessionFilterDevice == 'Todos' ||
          session.deviceName == _sessionFilterDevice;
      final byQuery =
          query.isEmpty ||
          session.title.toLowerCase().contains(query) ||
          session.summary.toLowerCase().contains(query) ||
          session.deviceName.toLowerCase().contains(query);
      return byDevice && byQuery;
    }).toList();

    if (_sessionSort == 'Mas antiguas') {
      items = items.reversed.toList();
    }
    return items;
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

  String _formatDistanceMeters(double? meters) {
    if (meters == null) {
      return '--';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  double? _estimatedJumpDistanceMeters(SessionInsightData insights) {
    final maxSpeedKnots = insights.maxSpeedKnots;
    final maxHangtimeSeconds = insights.maxHangtimeSeconds;
    if (maxSpeedKnots == null || maxHangtimeSeconds == null) {
      return null;
    }
    const knotsToMetersPerSecond = 0.514444;
    return maxSpeedKnots * knotsToMetersPerSecond * maxHangtimeSeconds;
  }

  int _captureStepIndex() {
    switch (_captureState) {
      case _SessionCaptureState.ready:
        return 0;
      case _SessionCaptureState.recording:
        return 1;
      case _SessionCaptureState.finished:
        return 2;
      case _SessionCaptureState.syncing:
        return 3;
      case _SessionCaptureState.synced:
        return 4;
    }
  }

  Future<String?> _pickSessionMedia(_SessionMediaSelection selection) async {
    if (selection == _SessionMediaSelection.none) {
      return null;
    }

    try {
      final picked = await _imagePicker.pickImage(
        source: selection == _SessionMediaSelection.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: 88,
      );

      if (picked == null) {
        return null;
      }

      return _storeSessionMedia(picked);
    } on MissingPluginException {
      if (!mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seleccion de imagen no disponible en esta plataforma.',
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

  Future<String> _storeSessionMedia(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(
      '${appDir.path}${Platform.pathSeparator}session_media',
    );
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final dot = file.path.lastIndexOf('.');
    final extension = (dot < 0 || dot == file.path.length - 1)
        ? ''
        : file.path.substring(dot);
    final output = File(
      '${mediaDir.path}${Platform.pathSeparator}session_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await output.writeAsBytes(await file.readAsBytes(), flush: true);
    return output.path;
  }

  Future<
    ({
      String spot,
      String notes,
      _SessionMediaSelection mediaSelection,
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
    _SessionMediaSelection mediaSelection = _SessionMediaSelection.none;
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

    final result =
        await showDialog<
          ({
            String spot,
            String notes,
            _SessionMediaSelection mediaSelection,
            String? sessionPhotoLocalPath,
            String? gearSetupId,
            String? gearSetupName,
          })
        >(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text('Configurar sesion'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            'upload-spot-$spot-${uploadSpotOptions.length}',
                          ),
                          initialValue: spot,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Spot',
                            border: OutlineInputBorder(),
                          ),
                          items: uploadSpotOptions
                              .map(
                                (option) => DropdownMenuItem(
                                  value: option,
                                  child: Text(option),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              spot = value;
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          minLines: 2,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Resumen de sesion (opcional)',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            notes = value;
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            'upload-gear-$selectedGearSetupId-${gearSetups.length}',
                          ),
                          initialValue: selectedGearSetupId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Equipo utilizado (opcional)',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: noGearValue,
                              child: Text('Sin equipacion'),
                            ),
                            ...gearSetups.map(
                              (setup) => DropdownMenuItem<String>(
                                value: setup.id,
                                child: Text(setup.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setDialogState(() {
                              selectedGearSetupId = value;
                            });
                          },
                        ),
                        if (selectedGearSetupId != noGearValue) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.checkroom_rounded, size: 18),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    gearSetups
                                            .where(
                                              (setup) =>
                                                  setup.id ==
                                                  selectedGearSetupId,
                                            )
                                            .map((setup) => setup.name)
                                            .firstOrNull ??
                                        'Equipacion seleccionada',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              final selectedSetup = gearSetups
                                  .where(
                                    (setup) => setup.id == selectedGearSetupId,
                                  )
                                  .firstOrNull;
                              if (selectedSetup == null) {
                                return const SizedBox.shrink();
                              }

                              final kite =
                                  gearSnapshot.kitesById[selectedSetup.kiteId];
                              final board = gearSnapshot
                                  .boardsById[selectedSetup.boardId];
                              final bar = selectedSetup.barId == null
                                  ? null
                                  : gearSnapshot.barsById[selectedSetup.barId!];
                              final harness = selectedSetup.harnessId == null
                                  ? null
                                  : gearSnapshot.harnessesById[selectedSetup
                                        .harnessId!];
                              final wetsuit = selectedSetup.wetsuitId == null
                                  ? null
                                  : gearSnapshot.wetsuitsById[selectedSetup
                                        .wetsuitId!];
                              final helmet = selectedSetup.helmetId == null
                                  ? null
                                  : gearSnapshot.helmetsById[selectedSetup
                                        .helmetId!];
                              final vest = selectedSetup.vestId == null
                                  ? null
                                  : gearSnapshot.vestsById[selectedSetup
                                        .vestId!];
                              final detailLines = _buildGearSetupDetailLines(
                                kite: kite,
                                board: board,
                                bar: bar,
                                harness: harness,
                                wetsuit: wetsuit,
                                helmet: helmet,
                                vest: vest,
                              );

                              if (detailLines.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.xs,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: detailLines
                                      .map(
                                        (line) => Text(
                                          line,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      )
                                      .toList(growable: false),
                                ),
                              );
                            },
                          ),
                        ],
                        if (gearSetups.isEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'No hay equipaciones personalizadas en Perfil > Mi equipo.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Imagen de sesion'),
                              const SizedBox(height: AppSpacing.xs),
                              Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                children: [
                                  ChoiceChip(
                                    label: const Text('Hacer foto'),
                                    selected:
                                        mediaSelection ==
                                        _SessionMediaSelection.camera,
                                    onSelected: (_) async {
                                      final pickedPath =
                                          await _pickSessionMedia(
                                            _SessionMediaSelection.camera,
                                          );
                                      if (!context.mounted ||
                                          pickedPath == null) {
                                        return;
                                      }
                                      setDialogState(() {
                                        mediaSelection =
                                            _SessionMediaSelection.camera;
                                        sessionPhotoLocalPath = pickedPath;
                                      });
                                    },
                                  ),
                                  ChoiceChip(
                                    label: const Text('Galeria'),
                                    selected:
                                        mediaSelection ==
                                        _SessionMediaSelection.gallery,
                                    onSelected: (_) async {
                                      final pickedPath =
                                          await _pickSessionMedia(
                                            _SessionMediaSelection.gallery,
                                          );
                                      if (!context.mounted ||
                                          pickedPath == null) {
                                        return;
                                      }
                                      setDialogState(() {
                                        mediaSelection =
                                            _SessionMediaSelection.gallery;
                                        sessionPhotoLocalPath = pickedPath;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (sessionPhotoLocalPath != null) ...[
                                const SizedBox(height: AppSpacing.xs),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 120,
                                    child: Image.file(
                                      File(sessionPhotoLocalPath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'No se pudo cargar la foto seleccionada.',
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 16,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'Foto seleccionada',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xs,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        setDialogState(() {
                                          mediaSelection =
                                              _SessionMediaSelection.none;
                                          sessionPhotoLocalPath = null;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                      ),
                                      label: const Text('Quitar foto'),
                                    ),
                                    Text(
                                      'Para cambiarla, pulsa Hacer foto o Galeria.',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () {
                        final selectedGearName =
                            selectedGearSetupId == noGearValue
                            ? null
                            : gearSetups
                                  .where(
                                    (setup) => setup.id == selectedGearSetupId,
                                  )
                                  .map((setup) => setup.name)
                                  .firstOrNull;
                        Navigator.of(context).pop((
                          spot: spot,
                          notes: notes.trim(),
                          mediaSelection: mediaSelection,
                          sessionPhotoLocalPath: sessionPhotoLocalPath,
                          gearSetupId: selectedGearSetupId == noGearValue
                              ? null
                              : selectedGearSetupId,
                          gearSetupName: selectedGearName,
                        ));
                      },
                      child: const Text('Subir sesion'),
                    ),
                  ],
                );
              },
            );
          },
        );

    if (result == null) {
      return null;
    }
    return result;
  }

  _ProfileGearSnapshot _loadProfileGearSnapshot() {
    final items = _profileModule.gearController.savedGearSetups;
    final deduplicated = <String, GearSetup>{
      for (final setup in items) setup.id: setup,
    };
    return _ProfileGearSnapshot(
      setups: deduplicated.values.toList(growable: false),
      kitesById: {
        for (final kite in _profileModule.gearController.savedKites)
          kite.id: kite,
      },
      boardsById: {
        for (final board in _profileModule.gearController.savedBoards)
          board.id: board,
      },
      barsById: {
        for (final bar in _profileModule.gearController.savedBars) bar.id: bar,
      },
      harnessesById: {
        for (final harness in _profileModule.gearController.savedHarnesses)
          harness.id: harness,
      },
      wetsuitsById: {
        for (final wetsuit in _profileModule.gearController.savedWetsuits)
          wetsuit.id: wetsuit,
      },
      helmetsById: {
        for (final helmet in _profileModule.gearController.savedHelmets)
          helmet.id: helmet,
      },
      vestsById: {
        for (final vest in _profileModule.gearController.savedVests)
          vest.id: vest,
      },
    );
  }

  List<String> _buildGearSetupDetailLines({
    KiteItem? kite,
    BoardItem? board,
    BarItem? bar,
    HarnessItem? harness,
    WetsuitItem? wetsuit,
    HelmetItem? helmet,
    VestItem? vest,
  }) {
    return [
      if (kite != null)
        'Cometa: ${kite.brand} ${kite.model} ${kite.sizeMeters}m',
      if (board != null)
        board.sizeCm.trim().isEmpty
            ? 'Tabla: ${board.brand} ${board.model}'
            : 'Tabla: ${board.brand} ${board.model} ${board.sizeCm}cm',
      if (bar != null)
        'Barra: ${bar.brand} ${bar.model} · ${bar.lineLengthMeters}m/${bar.widthCm}cm',
      if (harness != null)
        'Arnes: ${harness.brand} ${harness.model} · ${harness.size}',
      if (wetsuit != null)
        'Traje: ${wetsuit.brand} ${wetsuit.model} · ${wetsuit.thickness} · ${wetsuit.size}',
      if (helmet != null)
        'Casco: ${helmet.brand} ${helmet.model} (${helmet.year})',
      if (vest != null)
        'Chaleco: ${vest.brand} ${vest.model} · ${vest.size} (${vest.year})',
    ];
  }

  GearSetup? _findGearSetup(
    _ProfileGearSnapshot snapshot,
    _RecordedSession session,
  ) {
    if (session.gearSetupId != null) {
      for (final setup in snapshot.setups) {
        if (setup.id == session.gearSetupId) {
          return setup;
        }
      }
    }
    if (session.gearSetupName != null) {
      for (final setup in snapshot.setups) {
        if (setup.name == session.gearSetupName) {
          return setup;
        }
      }
    }
    return null;
  }

  String _sessionKiteLabel(
    _ProfileGearSnapshot snapshot,
    _RecordedSession session,
  ) {
    final setup = _findGearSetup(snapshot, session);
    final kite = setup == null ? null : snapshot.kitesById[setup.kiteId];
    if (kite == null) {
      return 'Cometa --';
    }
    return 'Cometa ${kite.brand} ${kite.model} ${kite.sizeMeters}m';
  }

  String _sessionBoardLabel(
    _ProfileGearSnapshot snapshot,
    _RecordedSession session,
  ) {
    final setup = _findGearSetup(snapshot, session);
    final board = setup == null ? null : snapshot.boardsById[setup.boardId];
    if (board == null) {
      return 'Tabla --';
    }
    if (board.sizeCm.trim().isEmpty) {
      return 'Tabla ${board.brand} ${board.model}';
    }
    return 'Tabla ${board.brand} ${board.model} ${board.sizeCm}cm';
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
          title: const Text('Eliminar sesion'),
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
    ).showSnackBar(const SnackBar(content: Text('Sesion eliminada.')));
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

    final updated = _RecordedSession(
      id: session.id,
      title: session.title,
      deviceName: session.deviceName,
      endedAt: session.endedAt,
      duration: session.duration,
      summary: result.notes,
      gearSetupId: result.gearSetupId,
      gearSetupName: result.gearSetupName,
      hasSessionPhoto: result.sessionPhotoLocalPath != null,
      sessionMediaLabel: switch (result.mediaSelection) {
        _SessionMediaSelection.none => 'Pantallazo del mapa del spot',
        _SessionMediaSelection.camera => 'Foto tomada con camara',
        _SessionMediaSelection.gallery => 'Foto elegida de galeria',
      },
      sessionPhotoLocalPath: result.sessionPhotoLocalPath,
      spotName: session.spotName,
      insights: session.insights,
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
    ).showSnackBar(const SnackBar(content: Text('Sesion actualizada.')));
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
      _SessionMediaSelection mediaSelection,
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
    const noGearValue = '__none__';
    String notes = session.summary;
    final gearSnapshot = _loadProfileGearSnapshot();
    final gearSetups = gearSnapshot.setups;
    String selectedGearSetupId = noGearValue;
    if (session.gearSetupName != null) {
      final match = gearSetups
          .where((setup) => setup.name == session.gearSetupName)
          .firstOrNull;
      if (match != null) {
        selectedGearSetupId = match.id;
      }
    }

    _SessionMediaSelection mediaSelection;
    if (session.sessionPhotoLocalPath == null) {
      mediaSelection = _SessionMediaSelection.none;
    } else if (session.sessionMediaLabel.toLowerCase().contains('camara')) {
      mediaSelection = _SessionMediaSelection.camera;
    } else {
      mediaSelection = _SessionMediaSelection.gallery;
    }
    String? sessionPhotoLocalPath = session.sessionPhotoLocalPath;

    final result =
        await showDialog<
          ({
            String notes,
            _SessionMediaSelection mediaSelection,
            String? sessionPhotoLocalPath,
            String? gearSetupId,
            String? gearSetupName,
          })
        >(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text('Editar sesion'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            'edit-gear-$selectedGearSetupId-${gearSetups.length}',
                          ),
                          initialValue: selectedGearSetupId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Equipo utilizado (opcional)',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: noGearValue,
                              child: Text('Sin equipacion'),
                            ),
                            ...gearSetups.map(
                              (setup) => DropdownMenuItem(
                                value: setup.id,
                                child: Text(setup.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setDialogState(() {
                              selectedGearSetupId = value;
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          minLines: 2,
                          maxLines: 3,
                          initialValue: notes,
                          decoration: const InputDecoration(
                            labelText: 'Comentario de sesion',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            notes = value;
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            ChoiceChip(
                              label: const Text('Hacer foto'),
                              selected:
                                  mediaSelection ==
                                  _SessionMediaSelection.camera,
                              onSelected: (_) async {
                                final pickedPath = await _pickSessionMedia(
                                  _SessionMediaSelection.camera,
                                );
                                if (!context.mounted || pickedPath == null) {
                                  return;
                                }
                                setDialogState(() {
                                  mediaSelection =
                                      _SessionMediaSelection.camera;
                                  sessionPhotoLocalPath = pickedPath;
                                });
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Galeria'),
                              selected:
                                  mediaSelection ==
                                  _SessionMediaSelection.gallery,
                              onSelected: (_) async {
                                final pickedPath = await _pickSessionMedia(
                                  _SessionMediaSelection.gallery,
                                );
                                if (!context.mounted || pickedPath == null) {
                                  return;
                                }
                                setDialogState(() {
                                  mediaSelection =
                                      _SessionMediaSelection.gallery;
                                  sessionPhotoLocalPath = pickedPath;
                                });
                              },
                            ),
                            if (sessionPhotoLocalPath != null)
                              TextButton.icon(
                                onPressed: () {
                                  setDialogState(() {
                                    mediaSelection =
                                        _SessionMediaSelection.none;
                                    sessionPhotoLocalPath = null;
                                  });
                                },
                                icon: const Icon(Icons.delete_outline_rounded),
                                label: const Text('Quitar foto'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () {
                        final selectedGearName =
                            selectedGearSetupId == noGearValue
                            ? null
                            : gearSetups
                                  .where(
                                    (setup) => setup.id == selectedGearSetupId,
                                  )
                                  .map((setup) => setup.name)
                                  .firstOrNull;
                        Navigator.of(context).pop((
                          notes: notes.trim(),
                          mediaSelection: mediaSelection,
                          sessionPhotoLocalPath: sessionPhotoLocalPath,
                          gearSetupId: selectedGearSetupId == noGearValue
                              ? null
                              : selectedGearSetupId,
                          gearSetupName: selectedGearName,
                        ));
                      },
                      child: const Text('Guardar cambios'),
                    ),
                  ],
                );
              },
            );
          },
        );

    return result;
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
                    Text(
                      'Aqui veras el dispositivo base de la app y los dispositivos compatibles que vincules para sesiones reales.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Dispositivos vinculados',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (_devices.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No hay dispositivos vinculados todavia.',
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _selectedDeviceId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Seleccionar dispositivo',
                              border: OutlineInputBorder(),
                            ),
                            items: _devicesForDisplay()
                                .map(
                                  (device) => DropdownMenuItem(
                                    value: device.id,
                                    child: Text(
                                      '${device.name} · ${device.kind}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _selectedDeviceId = value;
                                _lastImportHint = null;
                                _syncedPendingSessions.clear();
                                _syncedPendingDeviceId = null;
                              });
                              _saveSelectedDeviceId();
                            },
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          if (_selectedDevice != null)
                            Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.45),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHigh,
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainer,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Builder(
                                        builder: (context) {
                                          final isPhoneDeviceSelected =
                                              _selectedDevice!.id ==
                                              _phoneDeviceId;
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  IconButton.filledTonal(
                                                    tooltip:
                                                        'Ver capacidades del dispositivo',
                                                    onPressed:
                                                        _showDeviceCapabilitiesDialog,
                                                    icon: Icon(
                                                      _capabilitiesActionIcon(
                                                        _selectedDevice!.kind,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: AppSpacing.sm,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          _selectedDevice!.name,
                                                          style: textTheme
                                                              .titleMedium
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          _selectedDevice!.kind,
                                                          style: textTheme
                                                              .bodySmall,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: _statusChipColor(
                                                        _autoDetectedDeviceStatus(
                                                          _selectedDevice!,
                                                        ),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            999,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      _autoDetectedDeviceStatus(
                                                        _selectedDevice!,
                                                      ),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: AppSpacing.xs,
                                              ),
                                              Wrap(
                                                spacing: AppSpacing.xs,
                                                runSpacing: AppSpacing.xs,
                                                children: [
                                                  _buildDeviceMetaPill(
                                                    context: context,
                                                    icon: Icons
                                                        .devices_rounded,
                                                    text: _deviceAvailabilityLabel(
                                                      _selectedDevice!,
                                                    ),
                                                  ),
                                                  _buildDeviceMetaPill(
                                                    context: context,
                                                    icon:
                                                        Icons.sensors_rounded,
                                                    text:
                                                        _selectedDeviceSensorCountLabel(),
                                                  ),
                                                ],
                                              ),
                                              if (!isPhoneDeviceSelected) ...[
                                                const SizedBox(
                                                  height: AppSpacing.sm,
                                                ),
                                                OutlinedButton.icon(
                                                  onPressed:
                                                      _syncSessionFromDevice,
                                                  icon: const Icon(
                                                    Icons.sync_rounded,
                                                  ),
                                                  label: const Text(
                                                    'Sincronizar dispositivo',
                                                  ),
                                                ),
                                              ],
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (_selectedDeviceId != null &&
                              _syncedPendingDeviceId == _selectedDeviceId &&
                              _syncedPendingSessions.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sesiones sincronizadas del dispositivo',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Selecciona una sesion para revisarla y subirla a My Sessions.',
                                      style: textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    ..._syncedPendingSessions.map((session) {
                                      return Card(
                                        margin: const EdgeInsets.only(
                                          bottom: AppSpacing.xs,
                                        ),
                                        elevation: 0,
                                        clipBehavior: Clip.antiAlias,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          side: BorderSide(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.outlineVariant,
                                          ),
                                        ),
                                        child: Ink(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerLow,
                                                Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                              AppSpacing.sm,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 38,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .tertiaryContainer,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons
                                                        .cloud_download_rounded,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onTertiaryContainer,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: AppSpacing.sm,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        session.title,
                                                        style: textTheme
                                                            .titleSmall
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        '${session.duration.inMinutes} min · ${_formatSessionDateTime(session.endedAt)}',
                                                        style:
                                                            textTheme.bodySmall,
                                                      ),
                                                      const SizedBox(
                                                        height: AppSpacing.xs,
                                                      ),
                                                      Wrap(
                                                        spacing: AppSpacing.xs,
                                                        runSpacing:
                                                            AppSpacing.xs,
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .center,
                                                        children: [
                                                          OutlinedButton.icon(
                                                            onPressed: () {
                                                              _configureSyncedSession(
                                                                session,
                                                              );
                                                            },
                                                            style: OutlinedButton.styleFrom(
                                                              visualDensity:
                                                                  VisualDensity
                                                                      .compact,
                                                              minimumSize:
                                                                  const Size(
                                                                    0,
                                                                    34,
                                                                  ),
                                                            ),
                                                            icon: const Icon(
                                                              Icons
                                                                  .settings_rounded,
                                                              size: 16,
                                                            ),
                                                            label: const Text(
                                                              'Configurar',
                                                            ),
                                                          ),
                                                          Tooltip(
                                                            message:
                                                                'Eliminar sesion sincronizada',
                                                            child: SizedBox(
                                                              height: 34,
                                                              width: 34,
                                                              child: OutlinedButton(
                                                                style: OutlinedButton.styleFrom(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  visualDensity:
                                                                      VisualDensity
                                                                          .compact,
                                                                ),
                                                                onPressed: () {
                                                                  _removeSyncedPendingSession(
                                                                    session,
                                                                  );
                                                                },
                                                                child: const Icon(
                                                                  Icons
                                                                      .delete_outline_rounded,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Captura de sesion',
                              style: textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _captureStatusText(),
                              style: textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            SessionCaptureStatusCard(
                              statusText: _captureStatusText(),
                              stepProgress: (_captureStepIndex() + 1) / 5,
                              elapsedLabel: _recordingElapsedText(),
                              gpsLabel: _gpsSignalChipLabel(),
                              gpsBackgroundColor: _gpsChipBackgroundColor(
                                context,
                              ),
                              gpsForegroundColor: _gpsChipForegroundColor(
                                context,
                              ),
                              gpsIcon: _gpsChipIcon(),
                              autoPauseLabel: _autoPauseChipLabel(),
                              autoPauseBackgroundColor:
                                  _autoPauseChipBackgroundColor(context),
                              autoPauseForegroundColor:
                                  _autoPauseChipForegroundColor(context),
                              autoPauseIcon: _autoPauseChipIcon(),
                              currentSpeedLabel: _recordingCurrentSpeedText(),
                              maxSpeedLabel: _recordingMaxSpeedText(),
                              activeLabel: _recordingActiveText(),
                              pausedLabel: _recordingPausedText(),
                              saveReadinessLabel: _saveReadinessChipLabel(),
                              saveReadinessBackgroundColor:
                                  _saveReadinessChipBackgroundColor(context),
                              saveReadinessForegroundColor:
                                  _saveReadinessChipForegroundColor(context),
                              saveReadinessIcon: _saveReadinessChipIcon(),
                              actionLabel: _captureButtonLabel(),
                              actionIcon: _captureButtonIcon(),
                              actionTextStyle: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              onActionPressed: _onSessionControlPressed,
                              actionEnabled:
                                  _captureState != _SessionCaptureState.syncing,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'O importar sesion de archivo',
                              style: textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            OutlinedButton.icon(
                              onPressed: _importSessionFile,
                              icon: const Icon(Icons.file_upload_rounded),
                              label: const Text('Importar sesion real'),
                            ),
                            if (_lastImportHint != null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _lastImportHint!,
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _sessionSearchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Buscar sesiones...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final narrow = constraints.maxWidth < 700;

                        final deviceFilter = DropdownButtonFormField<String>(
                          initialValue: _sessionFilterDevice,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Dispositivo',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'Todos',
                              child: Text(
                                'Todos',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ..._devices.map(
                              (d) => DropdownMenuItem(
                                value: d.name,
                                child: Text(
                                  d.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _sessionFilterDevice = value;
                            });
                            _saveSessionViewPreferences();
                          },
                        );

                        final sortFilter = DropdownButtonFormField<String>(
                          initialValue: _sessionSort,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Orden',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Mas recientes',
                              child: Text(
                                'Mas recientes',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Mas antiguas',
                              child: Text(
                                'Mas antiguas',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _sessionSort = value;
                            });
                            _saveSessionViewPreferences();
                          },
                        );

                        if (narrow) {
                          return Column(
                            children: [
                              deviceFilter,
                              const SizedBox(height: AppSpacing.xs),
                              sortFilter,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: deviceFilter),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(child: sortFilter),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_filteredSessions().isEmpty)
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            'Todavia no hay sesiones finalizadas. Al sincronizar una sesion en Start Session aparecera aqui.',
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      ..._filteredSessions().map(
                        (session) => Builder(
                          builder: (context) {
                            final isNarrowPhone =
                                MediaQuery.sizeOf(context).width < 380;
                            final gearSnapshot = _loadProfileGearSnapshot();
                            final insights = _sessionInsightsForDetail(session);
                            final jumpDistanceEstimateMeters =
                                _estimatedJumpDistanceMeters(insights);
                            final sessionDate = session.endedAt.day
                                .toString()
                                .padLeft(2, '0');
                            final sessionMonth = session.endedAt.month
                                .toString()
                                .padLeft(2, '0');
                            final sessionHour = session.endedAt.hour
                                .toString()
                                .padLeft(2, '0');
                            final sessionMinute = session.endedAt.minute
                                .toString()
                                .padLeft(2, '0');
                            final kiteLabel = _sessionKiteLabel(
                              gearSnapshot,
                              session,
                            );
                            final boardLabel = _sessionBoardLabel(
                              gearSnapshot,
                              session,
                            );
                            final setup = _findGearSetup(gearSnapshot, session);
                            final gearDetailLines = setup == null
                                ? const <String>[]
                                : _buildGearSetupDetailLines(
                                    kite: gearSnapshot.kitesById[setup.kiteId],
                                    board:
                                        gearSnapshot.boardsById[setup.boardId],
                                    bar: setup.barId == null
                                        ? null
                                        : gearSnapshot.barsById[setup.barId!],
                                    harness: setup.harnessId == null
                                        ? null
                                        : gearSnapshot.harnessesById[
                                            setup.harnessId!
                                          ],
                                    wetsuit: setup.wetsuitId == null
                                        ? null
                                        : gearSnapshot.wetsuitsById[
                                            setup.wetsuitId!
                                          ],
                                    helmet: setup.helmetId == null
                                        ? null
                                        : gearSnapshot.helmetsById[
                                            setup.helmetId!
                                          ],
                                    vest: setup.vestId == null
                                        ? null
                                        : gearSnapshot.vestsById[setup.vestId!],
                                  );

                            return MySessionCard(
                              title: session.title,
                              subtitle:
                                  '${session.deviceName} · $sessionDate/$sessionMonth · $sessionHour:$sessionMinute',
                              summary:
                                  session.summary.isNotEmpty &&
                                      session.summary != _defaultSessionSummary
                                  ? session.summary
                                  : '',
                              gearSetupName:
                                  session.gearSetupName ?? 'Sin equipacion',
                              kiteLabel: kiteLabel,
                              boardLabel: boardLabel,
                              localPhotoPath: session.sessionPhotoLocalPath,
                              durationLabel: _formatDuration(session.duration),
                              jumpLabel: _formatJumpHeight(
                                insights.maxJumpHeightMeters,
                              ),
                              hangtimeLabel: _formatHangtime(
                                insights.maxHangtimeSeconds,
                              ),
                              jumpDistanceLabel: _formatDistanceMeters(
                                jumpDistanceEstimateMeters,
                              ),
                              maxSpeedLabel: _formatSpeedKnots(
                                insights.maxSpeedKnots,
                              ),
                              isNarrowPhone: isNarrowPhone,
                              onTap: () async {
                                final action = await Navigator.of(context)
                                    .push<SessionDetailAction>(
                                      MaterialPageRoute(
                                        builder: (_) => SessionDetailPage(
                                          title: session.title,
                                          deviceName: session.deviceName,
                                          deviceKind:
                                              _sessionInsightsForDetail(
                                                session,
                                              ).deviceKind ??
                                              'Dispositivo Android',
                                          deviceSensorKeys:
                                              _sessionInsightsForDetail(
                                                session,
                                              ).deviceSensorKeys,
                                          endedAt: session.endedAt,
                                          durationLabel: _formatDuration(
                                            session.duration,
                                          ),
                                          summary: session.summary,
                                          source:
                                              SessionDetailSource.mySessions,
                                          gearSetupName: session.gearSetupName,
                                          gearSetupDetailLines: gearDetailLines,
                                          hasSessionPhoto:
                                              session.hasSessionPhoto,
                                          sessionMediaLabel:
                                              session.sessionMediaLabel,
                                          sessionPhotoLocalPath:
                                              session.sessionPhotoLocalPath,
                                          spotBackgroundImagePath:
                                              _spotBackgroundForSession(session),
                                          insights: _sessionInsightsForDetail(
                                            session,
                                          ),
                                        ),
                                      ),
                                    );

                                if (!mounted || action == null) {
                                  return;
                                }

                                if (action.type ==
                                    SessionDetailActionType.delete) {
                                  await _confirmAndDeleteSession(session.id);
                                  return;
                                }

                                await _openEditSessionDialog(session.id);
                              },
                              onEdit: () {
                                _openEditSessionDialog(session.id);
                              },
                              onDelete: () {
                                _confirmAndDeleteSession(session.id);
                              },
                            );
                          },
                        ),
                      ),
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

class _ImportedSessionResult {
  const _ImportedSessionResult({
    required this.title,
    required this.fileName,
    required this.fileExtension,
    required this.endedAt,
    required this.duration,
    required this.summary,
    required this.jumpHistory,
  });

  final String title;
  final String fileName;
  final String fileExtension;
  final DateTime endedAt;
  final Duration duration;
  final String summary;
  final List<SessionJumpRecord> jumpHistory;
}

class _DetectedCompatibleDevice {
  const _DetectedCompatibleDevice({
    required this.id,
    required this.defaultName,
    required this.kind,
    required this.status,
    required this.sensorSummary,
    String? customName,
  }) : customName = customName ?? defaultName;

  final String id;
  final String defaultName;
  final String kind;
  final String status;
  final String sensorSummary;
  final String customName;

  _DetectedCompatibleDevice copyWith({String? customName}) {
    return _DetectedCompatibleDevice(
      id: id,
      defaultName: defaultName,
      kind: kind,
      status: status,
      sensorSummary: sensorSummary,
      customName: customName ?? this.customName,
    );
  }
}

class _SessionLocationSample {
  const _SessionLocationSample({
    required this.latitude,
    required this.longitude,
    required this.speedKnots,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double speedKnots;
  final DateTime timestamp;
}

class _TrackTransitionSummary {
  const _TrackTransitionSummary({
    required this.count,
    required this.qualityPercent,
    required this.avgSpeedLossKnots,
    required this.avgRecoverySeconds,
  });

  const _TrackTransitionSummary.empty()
      : count = 0,
        qualityPercent = 0,
        avgSpeedLossKnots = 0,
        avgRecoverySeconds = 0;

  final int count;
  final double qualityPercent;
  final double avgSpeedLossKnots;
  final double avgRecoverySeconds;
}

class _PendingJumpCandidate {
  const _PendingJumpCandidate({
    required this.startedAt,
    required this.takeoffSpeedKnots,
    required this.maxManeuverG,
    required this.maxRotationDegPerSec,
  });

  final DateTime startedAt;
  final double takeoffSpeedKnots;
  final double maxManeuverG;
  final double maxRotationDegPerSec;

  _PendingJumpCandidate copyWith({
    DateTime? startedAt,
    double? takeoffSpeedKnots,
    double? maxManeuverG,
    double? maxRotationDegPerSec,
  }) {
    return _PendingJumpCandidate(
      startedAt: startedAt ?? this.startedAt,
      takeoffSpeedKnots: takeoffSpeedKnots ?? this.takeoffSpeedKnots,
      maxManeuverG: maxManeuverG ?? this.maxManeuverG,
      maxRotationDegPerSec:
          maxRotationDegPerSec ?? this.maxRotationDegPerSec,
    );
  }
}

enum _SessionCaptureState { ready, recording, finished, syncing, synced }

enum _SessionTab { start, mySessions }

enum _SessionMediaSelection { none, camera, gallery }

class _ProfileGearSnapshot {
  const _ProfileGearSnapshot({
    required this.setups,
    required this.kitesById,
    required this.boardsById,
    required this.barsById,
    required this.harnessesById,
    required this.wetsuitsById,
    required this.helmetsById,
    required this.vestsById,
  });

  final List<GearSetup> setups;
  final Map<String, KiteItem> kitesById;
  final Map<String, BoardItem> boardsById;
  final Map<String, BarItem> barsById;
  final Map<String, HarnessItem> harnessesById;
  final Map<String, WetsuitItem> wetsuitsById;
  final Map<String, HelmetItem> helmetsById;
  final Map<String, VestItem> vestsById;
}

class _NoStretchScrollBehavior extends AppScrollBehavior {
  const _NoStretchScrollBehavior();
}
