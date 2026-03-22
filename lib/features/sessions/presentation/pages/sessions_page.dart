import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/profile/di/profile_module.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/sessions/di/sessions_module.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/domain/entities/session_view_preferences.dart';
import 'package:windwisher/features/sessions/presentation/pages/session_detail_page.dart';
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
  static const String _defaultSessionSummary =
      'Track sincronizado con sensores de velocidad, GPS y eventos.';
  static const List<String> _uploadSpotOptions = [
    'Oliva Norte',
    'Gandia Harbor',
    'Cullera Beach',
  ];

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
  String _lastUsedUploadSpot = 'Oliva Norte';
  final List<_RecordedSession> _sessionFeed = [];
  final List<_ImportedSessionResult> _syncedPendingSessions = [];
  String? _syncedPendingDeviceId;
  _SessionCaptureState _captureState = _SessionCaptureState.ready;
  DateTime? _recordingStartedAt;
  Timer? _recordingTicker;
  final ImagePicker _imagePicker = ImagePicker();

  static const String _sortMostRecent = 'Mas recientes';
  static const String _sortOldest = 'Mas antiguas';

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
    _hydrateSessionViewPreferences();
    _ensurePhoneDeviceAvailable();
    _ensureSelectedDevice();
    _sanitizeSessionViewPreferences();
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
    final useLocalPersistence = widget.useLocalPersistence;
    if (useLocalPersistence == false) {
      return ProfileModule.inMemory();
    }
    if (useLocalPersistence == true) {
      return ProfileModule.localFile();
    }
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
    final hasDeviceFilter =
        _sessionFilterDevice == 'Todos' ||
        _devices.any((device) => device.name == _sessionFilterDevice);
    if (!hasDeviceFilter) {
      _sessionFilterDevice = 'Todos';
    }
    if (_sessionSort != _sortMostRecent && _sessionSort != _sortOldest) {
      _sessionSort = _sortMostRecent;
    }
    if (!_uploadSpotOptions.contains(_lastUsedUploadSpot)) {
      _lastUsedUploadSpot = _uploadSpotOptions.first;
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
    return value ??
        SessionInsightData.fromSession(
          title: 'Sesion',
          deviceName: 'Dispositivo',
          deviceKind: 'Dispositivo Android',
          endedAt: DateTime.now(),
          durationLabel: '45:00',
        );
  }

  SessionInsightData _sessionInsightsForDetail(_RecordedSession session) {
    final insights = session.insights;
    if (insights is SessionInsightData) {
      return insights;
    }
    if (insights is Map<String, dynamic>) {
      return SessionInsightData.fromJson(insights);
    }
    return SessionInsightData.fromSession(
      title: session.title,
      deviceName: session.deviceName,
      deviceKind: session.deviceName,
      endedAt: session.endedAt,
      durationLabel: _formatDuration(session.duration),
    );
  }

  @override
  void dispose() {
    _recordingTicker?.cancel();
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
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
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
    _devices.add(
      const _LinkedDevice(
        id: _phoneDeviceId,
        name: 'Telefono del usuario',
        kind: 'Dispositivo Android',
        status: 'Listo',
        lastSync: 'hace 2 min',
      ),
    );
    _sessionsModule.saveLinkedDevice(
      const _LinkedDevice(
        id: _phoneDeviceId,
        name: 'Telefono del usuario',
        kind: 'Dispositivo Android',
        status: 'Listo',
        lastSync: 'hace 2 min',
      ),
    );
    _saveSelectedDeviceId();
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
    String customName = '';
    String kind = 'Woo Sports';

    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Configurar dispositivo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: kind,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de dispositivo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Woo Sports',
                        child: Text('Woo Sports'),
                      ),
                      DropdownMenuItem(
                        value: 'Apple Watch',
                        child: Text('Apple Watch'),
                      ),
                      DropdownMenuItem(
                        value: 'Smartwatch',
                        child: Text('Smartwatch'),
                      ),
                      DropdownMenuItem(
                        value: 'Dispositivo Android',
                        child: Text('Dispositivo Android'),
                      ),
                      DropdownMenuItem(value: 'SurfR', child: Text('SurfR')),
                      DropdownMenuItem(
                        value: 'Personalizado',
                        child: Text('Personalizado'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setDialogState(() {
                        kind = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nombre del dispositivo',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      customName = value;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('Vincular'),
                ),
              ],
            );
          },
        );
      },
    );

    if (accepted != true || !mounted) {
      return;
    }

    final deviceName = customName.trim().isEmpty ? kind : customName.trim();
    final id =
        '${kind.toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      final linkedDevice = _LinkedDevice(
        id: id,
        name: deviceName,
        kind: kind,
        status: 'Pendiente',
        lastSync: 'recién vinculado',
      );
      _devices.insert(0, linkedDevice);
      _sessionsModule.saveLinkedDevice(linkedDevice);
      _selectedDeviceId = id;
    });
    _saveSelectedDeviceId();
  }

  Future<void> _syncSessionFromDevice() async {
    final device = _selectedDevice;
    if (device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un dispositivo primero.')),
      );
      return;
    }

    setState(() {
      _syncedPendingSessions
        ..clear()
        ..addAll(_mockParseImportedSessions(device));
      _syncedPendingDeviceId = device.id;
      _lastImportHint = _syncedPendingSessions.length == 1
          ? 'Sesion sincronizada desde ${device.name}. Pulsa la tarjeta para configurarla.'
          : '${_syncedPendingSessions.length} sesiones sincronizadas desde ${device.name}. Pulsa cada una para configurarla.';
    });

    if (!mounted || Scaffold.maybeOf(context) == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _syncedPendingSessions.length == 1
              ? 'Sesion sincronizada desde ${device.name} con ${_syncedPendingSessions.first.jumpHistory.length} saltos detectados.'
              : '${_syncedPendingSessions.length} sesiones sincronizadas desde ${device.name}.',
        ),
      ),
    );
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
    unawaited(_sessionsModule.saveRecordedSession(session));
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
    final baseInsights = SessionInsightData.fromSession(
      title: imported.title,
      deviceName: device.name,
      deviceKind: device.kind,
      endedAt: imported.endedAt,
      durationLabel: _formatDuration(imported.duration),
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
      events: [
        ...baseInsights.events,
        'Sesion sincronizada desde dispositivo ${device.name}',
      ],
    );

    return _RecordedSession(
      id: _newSessionId(),
      title: imported.title,
      deviceName: device.name,
      endedAt: imported.endedAt,
      duration: imported.duration,
      summary: config.notes.isEmpty ? imported.summary : config.notes,
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
    final device = _selectedDevice ?? _devices.first;
    final imported = _mockParseImportedSession(device);
    _saveImportedSession(
      device: device,
      imported: imported,
      hintText:
          'Sesion importada desde ${imported.fileName} (${imported.fileExtension}).',
      eventText: 'Sesion importada desde archivo ${imported.fileExtension}',
      snackBarText:
          'Sesion importada con ${imported.jumpHistory.length} saltos detectados.',
      switchToMySessions: true,
    );
  }

  void _saveImportedSession({
    required _LinkedDevice device,
    required _ImportedSessionResult imported,
    required String hintText,
    required String eventText,
    required String snackBarText,
    required bool switchToMySessions,
  }) {
    final baseInsights = SessionInsightData.fromSession(
      title: imported.title,
      deviceName: device.name,
      deviceKind: device.kind,
      endedAt: imported.endedAt,
      durationLabel: _formatDuration(imported.duration),
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
      events: [...baseInsights.events, eventText],
    );
    final session = _RecordedSession(
      id: _newSessionId(),
      title: imported.title,
      deviceName: device.name,
      endedAt: imported.endedAt,
      duration: imported.duration,
      summary: imported.summary,
      gearSetupName: null,
      hasSessionPhoto: false,
      sessionMediaLabel: 'Pantallazo del mapa del spot',
      sessionPhotoLocalPath: null,
      spotName: null,
      insights: importedInsights,
    );

    setState(() {
      _lastImportHint = hintText;
      _captureState = _SessionCaptureState.ready;
      _recordingStartedAt = null;
      _recordingTicker?.cancel();
      _sessionFeed.insert(0, session);
      if (switchToMySessions) {
        _sessionTab = _SessionTab.mySessions;
      }
    });
    unawaited(_sessionsModule.saveRecordedSession(session));

    if (Scaffold.maybeOf(context) != null) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(SnackBar(content: Text(snackBarText)));
    }
  }

  _ImportedSessionResult _mockParseImportedSession(_LinkedDevice device) {
    final endedAt = DateTime.now().subtract(const Duration(minutes: 9));
    final duration = const Duration(minutes: 73, seconds: 18);
    const jumpMoments = [
      182,
      268,
      377,
      491,
      614,
      743,
      877,
      1023,
      1162,
      1299,
      1448,
      1611,
    ];

    final jumpHistory = List<SessionJumpRecord>.generate(jumpMoments.length, (
      index,
    ) {
      final second = jumpMoments[index];
      final minuteLabel =
          '${(second ~/ 60).toString().padLeft(2, '0')}:${(second % 60).toString().padLeft(2, '0')}';
      final height = 4.1 + (index * 0.52) + ((index % 3) * 0.35);
      final hangtime = 2.4 + (index * 0.16) + ((index % 2) * 0.14);
      final fall = 5.4 + (index * 0.19);

      return SessionJumpRecord(
        jumpNumber: index + 1,
        heightMeters: height,
        hangtimeSeconds: hangtime,
        fallSpeedMetersPerSecond: fall,
        timeLabel: minuteLabel,
      );
    });

    return _ImportedSessionResult(
      title: 'Sesion importada en Oliva Norte',
      fileName: 'olive-bigair-track.fit',
      fileExtension: '.fit',
      endedAt: endedAt,
      duration: duration,
      summary:
          'Importada desde archivo del dispositivo ${device.name}. Datos de saltos y telemetria sincronizados.',
      jumpHistory: jumpHistory,
    );
  }

  List<_ImportedSessionResult> _mockParseImportedSessions(
    _LinkedDevice device,
  ) {
    final primary = _mockParseImportedSession(device);
    if (device.kind != 'Woo Sports' && device.kind != 'Garmin') {
      return <_ImportedSessionResult>[primary];
    }

    final secondEndedAt = DateTime.now().subtract(
      const Duration(hours: 3, minutes: 14),
    );
    final secondDuration = const Duration(minutes: 48, seconds: 37);
    final secondJumpHistory = [
      SessionJumpRecord(
        jumpNumber: 1,
        heightMeters: 4.9,
        hangtimeSeconds: 2.9,
        fallSpeedMetersPerSecond: 5.8,
        timeLabel: '06:18',
      ),
      SessionJumpRecord(
        jumpNumber: 2,
        heightMeters: 6.1,
        hangtimeSeconds: 3.2,
        fallSpeedMetersPerSecond: 6.0,
        timeLabel: '12:44',
      ),
      SessionJumpRecord(
        jumpNumber: 3,
        heightMeters: 5.7,
        hangtimeSeconds: 3.0,
        fallSpeedMetersPerSecond: 5.9,
        timeLabel: '19:25',
      ),
    ];

    final second = _ImportedSessionResult(
      title: 'Sesion sincronizada en El Saler',
      fileName: 'elsaler-freeride-track.fit',
      fileExtension: '.fit',
      endedAt: secondEndedAt,
      duration: secondDuration,
      summary:
          'Sesion sincronizada desde dispositivo ${device.name}. Navegacion freeride con 3 saltos destacados.',
      jumpHistory: secondJumpHistory,
    );

    return <_ImportedSessionResult>[primary, second];
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
    return SessionInsightData.capabilitiesForDeviceKind(selected.kind);
  }

  String _captureButtonLabel() {
    switch (_captureState) {
      case _SessionCaptureState.ready:
        return 'Iniciar sesion';
      case _SessionCaptureState.recording:
        return 'Detener sesion';
      case _SessionCaptureState.finished:
        return 'Subir sesion';
      case _SessionCaptureState.syncing:
        return 'Subiendo...';
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
            ? 'Selecciona un dispositivo para grabar en agua.'
            : 'Listo para iniciar con ${_selectedDevice!.name}.';
      case _SessionCaptureState.recording:
        return 'Sesion en curso. Datos de sensores llegando en tiempo real.';
      case _SessionCaptureState.finished:
        return 'Sesion finalizada. Pendiente por subir.';
      case _SessionCaptureState.syncing:
        return 'Subiendo track, eventos y sensores...';
      case _SessionCaptureState.synced:
        return 'Sesion sincronizada correctamente.';
    }
  }

  String _recordingElapsedText() {
    if (_recordingStartedAt == null) {
      return '--:--';
    }
    final elapsed = DateTime.now().difference(_recordingStartedAt!);
    final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
    final total = SessionInsightData.capabilityOrder.length;
    final available = capabilities.length;

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
                Text('$available/$total sensores disponibles'),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Los KPI se habilitan automaticamente segun los sensores disponibles.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: SessionInsightData.capabilityOrder
                      .map((key) {
                        final isAvailable = capabilities.contains(key);
                        final label =
                            SessionInsightData.capabilityLabels[key] ?? key;
                        return Chip(
                          avatar: Icon(
                            isAvailable
                                ? Icons.check_circle_rounded
                                : Icons.cancel_outlined,
                            size: 16,
                            color: isAvailable ? const Color(0xFF2E7D32) : null,
                          ),
                          label: Text(label),
                          backgroundColor: isAvailable
                              ? const Color(0x1F2E7D32)
                              : null,
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
      setState(() {
        _captureState = _SessionCaptureState.recording;
        _recordingStartedAt = DateTime.now();
        _lastImportHint = null;
      });
      _recordingTicker?.cancel();
      _recordingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _captureState != _SessionCaptureState.recording) {
          return;
        }
        setState(() {});
      });
      return;
    }

    if (_captureState == _SessionCaptureState.recording) {
      _recordingTicker?.cancel();
      setState(() {
        _captureState = _SessionCaptureState.finished;
      });
      return;
    }

    if (_captureState == _SessionCaptureState.finished) {
      final config = await _showUploadSessionDialog();
      if (!mounted) {
        return;
      }
      if (config == null) {
        return;
      }

      setState(() {
        _captureState = _SessionCaptureState.syncing;
        _lastUsedGearSetupId = config.gearSetupId;
        _lastUsedUploadSpot = config.spot;
      });
      _saveSessionViewPreferences();
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        final endedAt = DateTime.now();
        final duration = _recordingStartedAt == null
            ? const Duration()
            : endedAt.difference(_recordingStartedAt!);
        final session = _buildRecordedSession(
          config: config,
          endedAt: endedAt,
          duration: duration,
        );
        _sessionFeed.insert(0, session);
        _captureState = _SessionCaptureState.synced;
        unawaited(_sessionsModule.saveRecordedSession(session));
      });
      return;
    }

    if (_captureState == _SessionCaptureState.synced) {
      setState(() {
        _captureState = _SessionCaptureState.ready;
        _recordingStartedAt = null;
      });
    }
  }

  _RecordedSession _buildRecordedSession({
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
    final deviceKind = selectedDevice?.kind ?? 'Personalizado';

    return _RecordedSession(
      id: _newSessionId(),
      title: title,
      deviceName: deviceName,
      endedAt: endedAt,
      duration: duration,
      summary: config.notes.isEmpty ? _defaultSessionSummary : config.notes,
      gearSetupName: config.gearSetupName,
      hasSessionPhoto: config.sessionPhotoLocalPath != null,
      sessionMediaLabel: switch (config.mediaSelection) {
        _SessionMediaSelection.none => 'Pantallazo del mapa del spot',
        _SessionMediaSelection.camera => 'Foto tomada con camara',
        _SessionMediaSelection.gallery => 'Foto elegida de galeria',
      },
      sessionPhotoLocalPath: config.sessionPhotoLocalPath,
      spotName: config.spot,
      insights: SessionInsightData.fromSession(
        title: title,
        deviceName: deviceName,
        deviceKind: deviceKind,
        endedAt: endedAt,
        durationLabel: _formatDuration(duration),
      ),
    );
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
    const noGearValue = '__none__';
    String spot = _uploadSpotOptions.contains(_lastUsedUploadSpot)
        ? _lastUsedUploadSpot
        : _uploadSpotOptions.first;
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
                          initialValue: spot,
                          decoration: const InputDecoration(
                            labelText: 'Spot',
                            border: OutlineInputBorder(),
                          ),
                          items: _uploadSpotOptions
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

  GearSetup? _findGearSetupByName(
    _ProfileGearSnapshot snapshot,
    String? setupName,
  ) {
    if (setupName == null) {
      return null;
    }
    for (final setup in snapshot.setups) {
      if (setup.name == setupName) {
        return setup;
      }
    }
    return null;
  }

  String _sessionKiteLabel(
    _ProfileGearSnapshot snapshot,
    _RecordedSession session,
  ) {
    final setup = _findGearSetupByName(snapshot, session.gearSetupName);
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
    final setup = _findGearSetupByName(snapshot, session.gearSetupName);
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
    unawaited(_sessionsModule.deleteRecordedSession(sessionId));
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
    unawaited(_sessionsModule.saveRecordedSession(updated));
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
                          initialValue: selectedGearSetupId,
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
                      'Selecciona el dispositivo vinculado para grabar sesion o importa desde archivo.',
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
                                                        .history_toggle_off_rounded,
                                                    text:
                                                        'Sincronizado ${_selectedDevice!.lastSync.toLowerCase()}',
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
                              'Control de sesion',
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                minHeight: 8,
                                value: (_captureStepIndex() + 1) / 5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xs,
                              children: [
                                Chip(
                                  avatar: const Icon(
                                    Icons.timer_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Tiempo: ${_recordingElapsedText()}',
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                                const Chip(
                                  avatar: Icon(
                                    Icons.gps_fixed_rounded,
                                    size: 18,
                                  ),
                                  label: Text('GPS OK'),
                                ),
                                const Chip(
                                  avatar: Icon(Icons.speed_rounded, size: 18),
                                  label: Text('Sensores OK'),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(64),
                                  textStyle: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                onPressed:
                                    _captureState ==
                                        _SessionCaptureState.syncing
                                    ? null
                                    : _onSessionControlPressed,
                                icon: Icon(_captureButtonIcon(), size: 28),
                                label: Text(_captureButtonLabel()),
                              ),
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
                              label: const Text('Importar sesion'),
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
                        (session) => Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Builder(
                            builder: (context) {
                              final isNarrowPhone =
                                  MediaQuery.sizeOf(context).width < 380;
                              final gearSnapshot = _loadProfileGearSnapshot();
                              final localPhotoPath =
                                  session.sessionPhotoLocalPath;
                              final hasPhotoPreview =
                                  localPhotoPath != null &&
                                  File(localPhotoPath).existsSync();
                              final insights = _sessionInsightsForDetail(
                                session,
                              );
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

                              return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  final action = await Navigator.of(context)
                                      .push<SessionDetailAction>(
                                        MaterialPageRoute(
                                          builder: (_) => SessionDetailPage(
                                            title: session.title,
                                            deviceName: session.deviceName,
                                            endedAt: session.endedAt,
                                            durationLabel: _formatDuration(
                                              session.duration,
                                            ),
                                            summary: session.summary,
                                            source:
                                                SessionDetailSource.mySessions,
                                            gearSetupName:
                                                session.gearSetupName,
                                            hasSessionPhoto:
                                                session.hasSessionPhoto,
                                            sessionMediaLabel:
                                                session.sessionMediaLabel,
                                            sessionPhotoLocalPath:
                                                session.sessionPhotoLocalPath,
                                            spotBackgroundImagePath:
                                                _spotBackgroundForSession(
                                                  session,
                                                ),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: hasPhotoPreview
                                          ? Image.file(
                                              File(localPhotoPath),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 170,
                                            )
                                          : Container(
                                              width: double.infinity,
                                              height: 120,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons
                                                    .photo_camera_back_outlined,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.sm,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            session.title,
                                            style: textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${session.deviceName} · $sessionDate/$sessionMonth · $sessionHour:$sessionMinute',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                          if (session.summary.isNotEmpty &&
                                              session.summary !=
                                                  _defaultSessionSummary) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              session.summary,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.checkroom_rounded,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  session.gearSetupName ??
                                                      'Sin equipacion',
                                                  style: textTheme.bodySmall,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            kiteLabel,
                                            style: textTheme.bodySmall,
                                          ),
                                          Text(
                                            boardLabel,
                                            style: textTheme.bodySmall,
                                          ),
                                          const SizedBox(height: 8),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Chip(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  label: Text(
                                                    'Duracion ${_formatDuration(session.duration)}',
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: AppSpacing.xs,
                                                ),
                                                Chip(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  label: Text(
                                                    'Salto ${_formatJumpHeight(insights.maxJumpHeightMeters)}',
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: AppSpacing.xs,
                                                ),
                                                Chip(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  label: Text(
                                                    'Hangtime ${_formatHangtime(insights.maxHangtimeSeconds)}',
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: AppSpacing.xs,
                                                ),
                                                Chip(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  label: Text(
                                                    'Dist salto ${_formatDistanceMeters(jumpDistanceEstimateMeters)}',
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: AppSpacing.xs,
                                                ),
                                                Chip(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  label: Text(
                                                    'Vel max ${_formatSpeedKnots(insights.maxSpeedKnots)}',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () {
                                                    _openEditSessionDialog(
                                                      session.id,
                                                    );
                                                  },
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        minimumSize: const Size(
                                                          0,
                                                          36,
                                                        ),
                                                      ),
                                                  icon: isNarrowPhone
                                                      ? const SizedBox.shrink()
                                                      : const Icon(
                                                          Icons.edit_rounded,
                                                          size: 16,
                                                        ),
                                                  label: const Text('Editar'),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.xs,
                                              ),
                                              Tooltip(
                                                message: 'Eliminar sesion',
                                                child: SizedBox(
                                                  width: 36,
                                                  height: 36,
                                                  child: OutlinedButton(
                                                    onPressed: () {
                                                      _confirmAndDeleteSession(
                                                        session.id,
                                                      );
                                                    },
                                                    style:
                                                        OutlinedButton.styleFrom(
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
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
                              );
                            },
                          ),
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
