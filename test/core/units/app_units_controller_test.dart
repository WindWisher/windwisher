import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windwisher/core/units/app_units_controller.dart';
import 'package:windwisher/core/units/app_units_remote_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('uses metric defaults and knots when no preferences exist', () async {
    final controller = AppUnitsController.forTesting();

    await controller.initialize(userId: 'user-a');

    expect(controller.windSpeedUnit, WindSpeedUnit.knots);
    expect(controller.distanceUnit, DistanceUnit.kilometers);
    expect(controller.temperatureUnit, TemperatureUnit.celsius);
    expect(controller.heightUnit, HeightUnit.meters);
  });

  test('persists all selected units', () async {
    final controller = AppUnitsController.forTesting();
    await controller.initialize(userId: 'user-a');

    await controller.setWindSpeedUnit(WindSpeedUnit.kilometersPerHour);
    await controller.setDistanceUnit(DistanceUnit.nauticalMiles);
    await controller.setTemperatureUnit(TemperatureUnit.fahrenheit);
    await controller.setHeightUnit(HeightUnit.feet);

    final restoredController = AppUnitsController.forTesting();
    await restoredController.initialize(userId: 'user-a');
    expect(restoredController.windSpeedUnit, WindSpeedUnit.kilometersPerHour);
    expect(restoredController.distanceUnit, DistanceUnit.nauticalMiles);
    expect(restoredController.temperatureUnit, TemperatureUnit.fahrenheit);
    expect(restoredController.heightUnit, HeightUnit.feet);
  });

  test('falls back to defaults when stored values are invalid', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_units.user-a.wind_speed_unit': 'invalid',
      'app_units.user-a.distance_unit': 'invalid',
      'app_units.user-a.temperature_unit': 'invalid',
      'app_units.user-a.height_unit': 'invalid',
    });
    final controller = AppUnitsController.forTesting();

    await controller.initialize(userId: 'user-a');

    expect(controller.windSpeedUnit, WindSpeedUnit.knots);
    expect(controller.distanceUnit, DistanceUnit.kilometers);
    expect(controller.temperatureUnit, TemperatureUnit.celsius);
    expect(controller.heightUnit, HeightUnit.meters);
  });

  test('converts and formats distance, temperature and height', () async {
    final controller = AppUnitsController.forTesting();
    await controller.initialize(userId: 'user-a');

    await controller.setDistanceUnit(DistanceUnit.miles);
    await controller.setTemperatureUnit(TemperatureUnit.fahrenheit);
    await controller.setHeightUnit(HeightUnit.feet);

    expect(controller.distanceFromKilometers(10), closeTo(6.21371, 0.00001));
    expect(controller.temperatureFromCelsius(20), 68);
    expect(controller.heightFromMeters(1), closeTo(3.28084, 0.00001));
    expect(controller.formatDistance(10), '6.2 mi');
    expect(controller.formatTemperature(20), '68.0 °F');
    expect(controller.formatHeight(1), '3.3 ft');
  });

  test('keeps preferences isolated between users', () async {
    final controller = AppUnitsController.forTesting();
    await controller.initialize(userId: 'user-a');
    await controller.setDistanceUnit(DistanceUnit.nauticalMiles);
    await controller.setTemperatureUnit(TemperatureUnit.fahrenheit);

    await controller.switchUser('user-b');
    expect(controller.distanceUnit, DistanceUnit.kilometers);
    expect(controller.temperatureUnit, TemperatureUnit.celsius);
    await controller.setHeightUnit(HeightUnit.feet);

    await controller.switchUser('user-a');
    expect(controller.distanceUnit, DistanceUnit.nauticalMiles);
    expect(controller.temperatureUnit, TemperatureUnit.fahrenheit);
    expect(controller.heightUnit, HeightUnit.meters);

    await controller.switchUser('user-b');
    expect(controller.heightUnit, HeightUnit.feet);
  });

  test('migrates legacy preferences only to the current user', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_units.wind_speed_unit': 'milesPerHour',
      'app_units.distance_unit': 'miles',
    });
    final controller = AppUnitsController.forTesting();

    await controller.initialize(userId: 'user-a');
    expect(controller.windSpeedUnit, WindSpeedUnit.milesPerHour);
    expect(controller.distanceUnit, DistanceUnit.miles);

    await controller.switchUser('user-b');
    expect(controller.windSpeedUnit, WindSpeedUnit.knots);
    expect(controller.distanceUnit, DistanceUnit.kilometers);
  });

  test('loads the current user preferences from the remote store', () async {
    final remoteStore = _FakeAppUnitsRemoteStore()
      ..valuesByUser['user-a'] = <String, String>{
        'wind_speed_unit': 'milesPerHour',
        'distance_unit': 'nauticalMiles',
        'temperature_unit': 'fahrenheit',
        'height_unit': 'feet',
      };
    final controller = AppUnitsController.forTesting(remoteStore: remoteStore);

    await controller.initialize(userId: 'user-a');
    await controller.syncCurrentUser();

    expect(controller.windSpeedUnit, WindSpeedUnit.milesPerHour);
    expect(controller.distanceUnit, DistanceUnit.nauticalMiles);
    expect(controller.temperatureUnit, TemperatureUnit.fahrenheit);
    expect(controller.heightUnit, HeightUnit.feet);
  });

  test('saves changed preferences to the current user remote row', () async {
    final remoteStore = _FakeAppUnitsRemoteStore();
    final controller = AppUnitsController.forTesting(remoteStore: remoteStore);
    await controller.initialize(userId: 'user-a');

    await controller.setTemperatureUnit(TemperatureUnit.fahrenheit);

    expect(
      remoteStore.valuesByUser['user-a']?['temperature_unit'],
      'fahrenheit',
    );
    expect(remoteStore.valuesByUser.containsKey('user-b'), isFalse);
  });

  test('retries an offline local change during the next sync', () async {
    final remoteStore = _FakeAppUnitsRemoteStore()..failSaves = true;
    final controller = AppUnitsController.forTesting(remoteStore: remoteStore);
    await controller.initialize(userId: 'user-a');

    await controller.setHeightUnit(HeightUnit.feet);
    expect(remoteStore.valuesByUser['user-a'], isNull);

    remoteStore.failSaves = false;
    await controller.syncCurrentUser();

    expect(remoteStore.valuesByUser['user-a']?['height_unit'], 'feet');
  });
}

class _FakeAppUnitsRemoteStore implements AppUnitsRemoteStore {
  final Map<String, Map<String, String>> valuesByUser = {};
  bool failSaves = false;

  @override
  Future<Map<String, String>?> load(String userId) async {
    final values = valuesByUser[userId];
    return values == null ? null : Map<String, String>.from(values);
  }

  @override
  Future<void> save(String userId, Map<String, String> values) async {
    if (failSaves) {
      throw const FormatException('offline');
    }
    valuesByUser[userId] = Map<String, String>.from(values);
  }
}
