import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windwisher/core/units/app_units_remote_store.dart';

enum WindSpeedUnit { knots, kilometersPerHour, milesPerHour, beaufort }

enum DistanceUnit { kilometers, miles, nauticalMiles }

enum TemperatureUnit { celsius, fahrenheit }

enum HeightUnit { meters, feet }

extension WindSpeedUnitLabel on WindSpeedUnit {
  String get shortLabel => switch (this) {
    WindSpeedUnit.knots => 'kt',
    WindSpeedUnit.kilometersPerHour => 'km/h',
    WindSpeedUnit.milesPerHour => 'mph',
    WindSpeedUnit.beaufort => 'Bft',
  };

  String get displayName => switch (this) {
    WindSpeedUnit.knots => 'Nudos',
    WindSpeedUnit.kilometersPerHour => 'Kilometros por hora',
    WindSpeedUnit.milesPerHour => 'Millas por hora',
    WindSpeedUnit.beaufort => 'Escala Beaufort',
  };
}

extension DistanceUnitLabel on DistanceUnit {
  String get shortLabel => switch (this) {
    DistanceUnit.kilometers => 'km',
    DistanceUnit.miles => 'mi',
    DistanceUnit.nauticalMiles => 'nm',
  };

  String get displayName => switch (this) {
    DistanceUnit.kilometers => 'Kilometros',
    DistanceUnit.miles => 'Millas',
    DistanceUnit.nauticalMiles => 'Millas nauticas',
  };
}

extension TemperatureUnitLabel on TemperatureUnit {
  String get shortLabel => switch (this) {
    TemperatureUnit.celsius => '°C',
    TemperatureUnit.fahrenheit => '°F',
  };

  String get displayName => switch (this) {
    TemperatureUnit.celsius => 'Celsius',
    TemperatureUnit.fahrenheit => 'Fahrenheit',
  };
}

extension HeightUnitLabel on HeightUnit {
  String get shortLabel => switch (this) {
    HeightUnit.meters => 'm',
    HeightUnit.feet => 'ft',
  };

  String get displayName => switch (this) {
    HeightUnit.meters => 'Metros',
    HeightUnit.feet => 'Pies',
  };
}

class AppUnitsController extends ChangeNotifier {
  AppUnitsController._({AppUnitsRemoteStore? remoteStore})
    : _remoteStore = remoteStore;

  @visibleForTesting
  factory AppUnitsController.forTesting({AppUnitsRemoteStore? remoteStore}) =>
      AppUnitsController._(remoteStore: remoteStore);

  static const _legacyWindSpeedUnitKey = 'app_units.wind_speed_unit';
  static const _legacyDistanceUnitKey = 'app_units.distance_unit';
  static const _legacyTemperatureUnitKey = 'app_units.temperature_unit';
  static const _legacyHeightUnitKey = 'app_units.height_unit';
  static final AppUnitsController instance = AppUnitsController._();

  SharedPreferences? _preferences;
  AppUnitsRemoteStore? _remoteStore;
  WindSpeedUnit _windSpeedUnit = WindSpeedUnit.knots;
  DistanceUnit _distanceUnit = DistanceUnit.kilometers;
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  HeightUnit _heightUnit = HeightUnit.meters;
  bool _initialized = false;
  String? _activeUserId;

  WindSpeedUnit get windSpeedUnit => _windSpeedUnit;
  DistanceUnit get distanceUnit => _distanceUnit;
  TemperatureUnit get temperatureUnit => _temperatureUnit;
  HeightUnit get heightUnit => _heightUnit;

  void configureRemoteStore(AppUnitsRemoteStore remoteStore) {
    _remoteStore = remoteStore;
  }

  Future<void> initialize({String? userId}) async {
    final normalizedUserId = _normalizeUserId(userId);
    if (_initialized && _activeUserId == normalizedUserId) {
      return;
    }
    try {
      _preferences ??= await SharedPreferences.getInstance();
      _initialized = true;
      await _loadForUser(
        normalizedUserId,
        migrateLegacy: normalizedUserId != null,
      );
    } catch (_) {
      _initialized = true;
      _activeUserId = normalizedUserId;
      _applyDefaults();
    }
  }

  Future<void> switchUser(String? userId) async {
    await initialize(userId: userId);
    await syncCurrentUser();
  }

  Future<void> setWindSpeedUnit(WindSpeedUnit unit) async {
    await _ensureInitialized();
    if (_windSpeedUnit == unit) {
      return;
    }
    _windSpeedUnit = unit;
    notifyListeners();
    await _saveEnum('wind_speed_unit', unit);
    await _queueRemoteSave();
  }

  Future<void> setDistanceUnit(DistanceUnit unit) async {
    await _ensureInitialized();
    if (_distanceUnit == unit) return;
    _distanceUnit = unit;
    notifyListeners();
    await _saveEnum('distance_unit', unit);
    await _queueRemoteSave();
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    await _ensureInitialized();
    if (_temperatureUnit == unit) return;
    _temperatureUnit = unit;
    notifyListeners();
    await _saveEnum('temperature_unit', unit);
    await _queueRemoteSave();
  }

  Future<void> setHeightUnit(HeightUnit unit) async {
    await _ensureInitialized();
    if (_heightUnit == unit) return;
    _heightUnit = unit;
    notifyListeners();
    await _saveEnum('height_unit', unit);
    await _queueRemoteSave();
  }

  Future<void> syncCurrentUser() async {
    final userId = _activeUserId;
    final remoteStore = _remoteStore;
    if (userId == null || remoteStore == null) {
      return;
    }
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    _preferences = preferences;
    if (preferences.getBool(_pendingSyncKey(userId)) ?? false) {
      await _pushPreferences(userId, remoteStore);
      return;
    }

    try {
      final remoteValues = await remoteStore
          .load(userId)
          .timeout(const Duration(seconds: 8));
      if (_activeUserId != userId) {
        return;
      }
      if (remoteValues == null) {
        await _pushPreferences(userId, remoteStore);
        return;
      }
      if (preferences.getBool(_pendingSyncKey(userId)) ?? false) {
        await _pushPreferences(userId, remoteStore);
        return;
      }
      await _applyRemoteValues(preferences, userId, remoteValues);
    } catch (_) {
      // Local values remain authoritative until a later synchronization.
    }
  }

  double distanceFromKilometers(double kilometers) => switch (_distanceUnit) {
    DistanceUnit.kilometers => kilometers,
    DistanceUnit.miles => kilometers * 0.6213711922,
    DistanceUnit.nauticalMiles => kilometers * 0.5399568035,
  };

  double temperatureFromCelsius(double celsius) => switch (_temperatureUnit) {
    TemperatureUnit.celsius => celsius,
    TemperatureUnit.fahrenheit => (celsius * 9 / 5) + 32,
  };

  double heightFromMeters(double meters) => switch (_heightUnit) {
    HeightUnit.meters => meters,
    HeightUnit.feet => meters * 3.280839895,
  };

  double windSpeedFromKnots(double knots) => switch (_windSpeedUnit) {
    WindSpeedUnit.knots => knots,
    WindSpeedUnit.kilometersPerHour => knots * 1.852,
    WindSpeedUnit.milesPerHour => knots * 1.150779448,
    WindSpeedUnit.beaufort => _beaufortFromKnots(knots),
  };

  String formatDistance(double kilometers, {int decimals = 1}) =>
      '${distanceFromKilometers(kilometers).toStringAsFixed(decimals)} ${_distanceUnit.shortLabel}';

  String formatTemperature(double celsius, {int decimals = 1}) =>
      '${temperatureFromCelsius(celsius).toStringAsFixed(decimals)} ${_temperatureUnit.shortLabel}';

  String formatHeight(double meters, {int decimals = 1}) =>
      '${heightFromMeters(meters).toStringAsFixed(decimals)} ${_heightUnit.shortLabel}';

  String formatWindSpeed(double knots, {int decimals = 1}) {
    final value = windSpeedFromKnots(knots);
    final decimalsToUse = _windSpeedUnit == WindSpeedUnit.beaufort
        ? 0
        : decimals;
    return '${value.toStringAsFixed(decimalsToUse)} ${_windSpeedUnit.shortLabel}';
  }

  Future<void> _loadForUser(
    String? userId, {
    required bool migrateLegacy,
  }) async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    _preferences = preferences;
    _activeUserId = userId;

    if (migrateLegacy) {
      await _migrateLegacyPreferences(preferences, userId!);
    }

    final previousUnits = (
      _windSpeedUnit,
      _distanceUnit,
      _temperatureUnit,
      _heightUnit,
    );
    _windSpeedUnit = _enumByName(
      WindSpeedUnit.values,
      preferences.getString(_scopedKey('wind_speed_unit', userId)),
      WindSpeedUnit.knots,
    );
    _distanceUnit = _enumByName(
      DistanceUnit.values,
      preferences.getString(_scopedKey('distance_unit', userId)),
      DistanceUnit.kilometers,
    );
    _temperatureUnit = _enumByName(
      TemperatureUnit.values,
      preferences.getString(_scopedKey('temperature_unit', userId)),
      TemperatureUnit.celsius,
    );
    _heightUnit = _enumByName(
      HeightUnit.values,
      preferences.getString(_scopedKey('height_unit', userId)),
      HeightUnit.meters,
    );
    final currentUnits = (
      _windSpeedUnit,
      _distanceUnit,
      _temperatureUnit,
      _heightUnit,
    );
    if (previousUnits != currentUnits) {
      notifyListeners();
    }
  }

  Future<void> _migrateLegacyPreferences(
    SharedPreferences preferences,
    String userId,
  ) async {
    final legacyValues = <String, String?>{
      'wind_speed_unit': preferences.getString(_legacyWindSpeedUnitKey),
      'distance_unit': preferences.getString(_legacyDistanceUnitKey),
      'temperature_unit': preferences.getString(_legacyTemperatureUnitKey),
      'height_unit': preferences.getString(_legacyHeightUnitKey),
    };
    for (final entry in legacyValues.entries) {
      final scopedKey = _scopedKey(entry.key, userId);
      if (entry.value != null && !preferences.containsKey(scopedKey)) {
        await preferences.setString(scopedKey, entry.value!);
      }
    }
    await preferences.remove(_legacyWindSpeedUnitKey);
    await preferences.remove(_legacyDistanceUnitKey);
    await preferences.remove(_legacyTemperatureUnitKey);
    await preferences.remove(_legacyHeightUnitKey);
  }

  Future<void> _saveEnum(String preferenceName, Enum value) async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    _preferences = preferences;
    await preferences.setString(
      _scopedKey(preferenceName, _activeUserId),
      value.name,
    );
  }

  Future<void> _queueRemoteSave() async {
    final userId = _activeUserId;
    final remoteStore = _remoteStore;
    if (userId == null || remoteStore == null) {
      return;
    }
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    _preferences = preferences;
    await preferences.setBool(_pendingSyncKey(userId), true);
    await _pushPreferences(userId, remoteStore);
  }

  Future<void> _pushPreferences(
    String userId,
    AppUnitsRemoteStore remoteStore,
  ) async {
    final values = _currentValues();
    try {
      await remoteStore
          .save(userId, values)
          .timeout(const Duration(seconds: 8));
      if (_activeUserId == userId && mapEquals(values, _currentValues())) {
        final preferences =
            _preferences ?? await SharedPreferences.getInstance();
        _preferences = preferences;
        await preferences.remove(_pendingSyncKey(userId));
      }
    } catch (_) {
      // Keep pending_sync so the local change can be retried later.
    }
  }

  Future<void> _applyRemoteValues(
    SharedPreferences preferences,
    String userId,
    Map<String, String> values,
  ) async {
    final previousUnits = (
      _windSpeedUnit,
      _distanceUnit,
      _temperatureUnit,
      _heightUnit,
    );
    _windSpeedUnit = _enumByName(
      WindSpeedUnit.values,
      values['wind_speed_unit'],
      WindSpeedUnit.knots,
    );
    _distanceUnit = _enumByName(
      DistanceUnit.values,
      values['distance_unit'],
      DistanceUnit.kilometers,
    );
    _temperatureUnit = _enumByName(
      TemperatureUnit.values,
      values['temperature_unit'],
      TemperatureUnit.celsius,
    );
    _heightUnit = _enumByName(
      HeightUnit.values,
      values['height_unit'],
      HeightUnit.meters,
    );
    for (final entry in _currentValues().entries) {
      await preferences.setString(_scopedKey(entry.key, userId), entry.value);
    }
    final currentUnits = (
      _windSpeedUnit,
      _distanceUnit,
      _temperatureUnit,
      _heightUnit,
    );
    if (previousUnits != currentUnits) {
      notifyListeners();
    }
  }

  Map<String, String> _currentValues() => <String, String>{
    'wind_speed_unit': _windSpeedUnit.name,
    'distance_unit': _distanceUnit.name,
    'temperature_unit': _temperatureUnit.name,
    'height_unit': _heightUnit.name,
  };

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  String _scopedKey(String preferenceName, String? userId) =>
      'app_units.${userId ?? 'guest'}.$preferenceName';

  String _pendingSyncKey(String userId) => _scopedKey('pending_sync', userId);

  String? _normalizeUserId(String? userId) {
    final normalized = userId?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  void _applyDefaults() {
    _windSpeedUnit = WindSpeedUnit.knots;
    _distanceUnit = DistanceUnit.kilometers;
    _temperatureUnit = TemperatureUnit.celsius;
    _heightUnit = HeightUnit.meters;
  }

  T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
    return values.firstWhere(
      (value) => value.name == name,
      orElse: () => fallback,
    );
  }

  double _beaufortFromKnots(double knots) {
    const thresholds = <double>[1, 4, 7, 11, 17, 22, 28, 34, 41, 48, 56, 64];
    for (var index = 0; index < thresholds.length; index += 1) {
      if (knots < thresholds[index]) return index.toDouble();
    }
    return 12;
  }
}
