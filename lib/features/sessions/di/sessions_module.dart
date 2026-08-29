import 'package:flutter/foundation.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/sessions/application/use_cases/session_devices_use_cases.dart';
import 'package:windwisher/features/sessions/application/use_cases/session_records_use_cases.dart';
import 'package:windwisher/features/sessions/application/use_cases/session_view_preferences_use_cases.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/in_memory/in_memory_session_devices_adapter.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/in_memory/in_memory_session_records_adapter.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/in_memory/in_memory_session_view_preferences_adapter.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/local/local_file_session_devices_adapter.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/local/local_file_session_view_preferences_adapter.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/supabase/supabase_session_records_adapter.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/ble/ble_session_device_discovery_adapter.dart';

class SessionsModule {
  static BleSessionDeviceDiscoveryAdapter createDeviceDiscoveryAdapter() {
    return BleSessionDeviceDiscoveryAdapter();
  }

  const SessionsModule({
    required this.getLinkedDevices,
    required this.saveLinkedDevice,
    required this.deleteLinkedDevice,
    required this.getSelectedDeviceId,
    required this.saveSelectedDeviceId,
    required this.getSessionViewPreferences,
    required this.saveSessionViewPreferences,
    required this.getRecordedSessions,
    required this.saveRecordedSession,
    required this.deleteRecordedSession,
  });

  final GetLinkedDevicesUseCase getLinkedDevices;
  final SaveLinkedDeviceUseCase saveLinkedDevice;
  final DeleteLinkedDeviceUseCase deleteLinkedDevice;
  final GetSelectedDeviceIdUseCase getSelectedDeviceId;
  final SaveSelectedDeviceIdUseCase saveSelectedDeviceId;
  final GetSessionViewPreferencesUseCase getSessionViewPreferences;
  final SaveSessionViewPreferencesUseCase saveSessionViewPreferences;
  final GetRecordedSessionsUseCase getRecordedSessions;
  final SaveRecordedSessionUseCase saveRecordedSession;
  final DeleteRecordedSessionUseCase deleteRecordedSession;

  factory SessionsModule.inMemory() {
    final inMemoryDevicesPort = InMemorySessionDevicesAdapter();
    final inMemorySessionViewPreferencesPort =
        InMemorySessionViewPreferencesAdapter();
    final inMemoryRecordsPort = InMemorySessionRecordsAdapter();
    return SessionsModule(
      getLinkedDevices: GetLinkedDevicesUseCase(inMemoryDevicesPort),
      saveLinkedDevice: SaveLinkedDeviceUseCase(inMemoryDevicesPort),
      deleteLinkedDevice: DeleteLinkedDeviceUseCase(inMemoryDevicesPort),
      getSelectedDeviceId: GetSelectedDeviceIdUseCase(inMemoryDevicesPort),
      saveSelectedDeviceId: SaveSelectedDeviceIdUseCase(inMemoryDevicesPort),
      getSessionViewPreferences: GetSessionViewPreferencesUseCase(
        inMemorySessionViewPreferencesPort,
      ),
      saveSessionViewPreferences: SaveSessionViewPreferencesUseCase(
        inMemorySessionViewPreferencesPort,
      ),
      getRecordedSessions: GetRecordedSessionsUseCase(inMemoryRecordsPort),
      saveRecordedSession: SaveRecordedSessionUseCase(inMemoryRecordsPort),
      deleteRecordedSession: DeleteRecordedSessionUseCase(inMemoryRecordsPort),
    );
  }

  factory SessionsModule.localFile({
    required Object? Function(Object value) encodeInsights,
    required Object Function(Object? value) decodeInsights,
    String devicesFileName = 'sessions_devices_v1.json',
    String viewPreferencesFileName = 'sessions_view_preferences_v1.json',
    String recordsFileName = 'sessions_records_v1.json',
  }) {
    final devicesPort = LocalFileSessionDevicesAdapter(
      fileName: devicesFileName,
    );
    final sessionViewPreferencesPort = LocalFileSessionViewPreferencesAdapter(
      fileName: viewPreferencesFileName,
    );
    final recordsPort = LocalFileSessionRecordsAdapter(
      encodeInsights: encodeInsights,
      decodeInsights: decodeInsights,
      fileName: recordsFileName,
    );

    return SessionsModule(
      getLinkedDevices: GetLinkedDevicesUseCase(devicesPort),
      saveLinkedDevice: SaveLinkedDeviceUseCase(devicesPort),
      deleteLinkedDevice: DeleteLinkedDeviceUseCase(devicesPort),
      getSelectedDeviceId: GetSelectedDeviceIdUseCase(devicesPort),
      saveSelectedDeviceId: SaveSelectedDeviceIdUseCase(devicesPort),
      getSessionViewPreferences: GetSessionViewPreferencesUseCase(
        sessionViewPreferencesPort,
      ),
      saveSessionViewPreferences: SaveSessionViewPreferencesUseCase(
        sessionViewPreferencesPort,
      ),
      getRecordedSessions: GetRecordedSessionsUseCase(recordsPort),
      saveRecordedSession: SaveRecordedSessionUseCase(recordsPort),
      deleteRecordedSession: DeleteRecordedSessionUseCase(recordsPort),
    );
  }

  factory SessionsModule.auto({
    required Object? Function(Object value) encodeInsights,
    required Object Function(Object? value) decodeInsights,
    String devicesFileName = 'sessions_devices_v1.json',
    String viewPreferencesFileName = 'sessions_view_preferences_v1.json',
    String recordsFileName = 'sessions_records_v1.json',
  }) {
    final hasSupabase =
        EnvConfig.supabaseUrl.trim().isNotEmpty &&
        EnvConfig.supabaseAnonKey.trim().isNotEmpty;
    final devicesPort = kIsWeb
        ? InMemorySessionDevicesAdapter()
        : LocalFileSessionDevicesAdapter(fileName: devicesFileName);
    final sessionViewPreferencesPort = kIsWeb
        ? InMemorySessionViewPreferencesAdapter()
        : LocalFileSessionViewPreferencesAdapter(
            fileName: viewPreferencesFileName,
          );
    final localRecordsFallback = kIsWeb
        ? InMemorySessionRecordsAdapter()
        : LocalFileSessionRecordsAdapter(
            encodeInsights: encodeInsights,
            decodeInsights: decodeInsights,
            fileName: recordsFileName,
          );
    final recordsPort = hasSupabase
        ? SupabaseSessionRecordsAdapter(
            encodeInsights: encodeInsights,
            decodeInsights: decodeInsights,
            localFallback: localRecordsFallback,
          )
        : kIsWeb
        ? InMemorySessionRecordsAdapter()
        : localRecordsFallback;

    return SessionsModule(
      getLinkedDevices: GetLinkedDevicesUseCase(devicesPort),
      saveLinkedDevice: SaveLinkedDeviceUseCase(devicesPort),
      deleteLinkedDevice: DeleteLinkedDeviceUseCase(devicesPort),
      getSelectedDeviceId: GetSelectedDeviceIdUseCase(devicesPort),
      saveSelectedDeviceId: SaveSelectedDeviceIdUseCase(devicesPort),
      getSessionViewPreferences: GetSessionViewPreferencesUseCase(
        sessionViewPreferencesPort,
      ),
      saveSessionViewPreferences: SaveSessionViewPreferencesUseCase(
        sessionViewPreferencesPort,
      ),
      getRecordedSessions: GetRecordedSessionsUseCase(recordsPort),
      saveRecordedSession: SaveRecordedSessionUseCase(recordsPort),
      deleteRecordedSession: DeleteRecordedSessionUseCase(recordsPort),
    );
  }
}
