import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windwisher/core/units/app_units_controller.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/units/units_settings_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await AppUnitsController.instance.setWindSpeedUnit(WindSpeedUnit.knots);
    await AppUnitsController.instance.setDistanceUnit(DistanceUnit.kilometers);
    await AppUnitsController.instance.setTemperatureUnit(
      TemperatureUnit.celsius,
    );
    await AppUnitsController.instance.setHeightUnit(HeightUnit.meters);
  });

  tearDown(() async {
    await AppUnitsController.instance.setWindSpeedUnit(WindSpeedUnit.knots);
    await AppUnitsController.instance.setDistanceUnit(DistanceUnit.kilometers);
    await AppUnitsController.instance.setTemperatureUnit(
      TemperatureUnit.celsius,
    );
    await AppUnitsController.instance.setHeightUnit(HeightUnit.meters);
  });

  testWidgets('selects and displays a global wind speed unit', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: UnitsSettingsSection()),
        ),
      ),
    );

    expect(find.text('kt, km, °C, m'), findsOneWidget);
    await tester.tap(find.text('Unidades'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nudos (kt)'));
    await tester.pumpAndSettle();

    expect(find.text('Unidad de velocidad'), findsOneWidget);
    await tester.tap(find.text('Kilometros por hora'));
    await tester.pumpAndSettle();

    expect(find.text('Kilometros por hora (km/h)'), findsOneWidget);
    expect(
      AppUnitsController.instance.windSpeedUnit,
      WindSpeedUnit.kilometersPerHour,
    );
  });

  testWidgets('selects and displays distance, temperature and height', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: UnitsSettingsSection()),
        ),
      ),
    );

    await tester.tap(find.text('Unidades'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kilometros (km)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Millas nauticas'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Celsius (°C)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fahrenheit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Metros (m)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pies'));
    await tester.pumpAndSettle();

    expect(find.text('Millas nauticas (nm)'), findsOneWidget);
    expect(find.text('Fahrenheit (°F)'), findsOneWidget);
    expect(find.text('Pies (ft)'), findsOneWidget);
    expect(
      AppUnitsController.instance.distanceUnit,
      DistanceUnit.nauticalMiles,
    );
    expect(
      AppUnitsController.instance.temperatureUnit,
      TemperatureUnit.fahrenheit,
    );
    expect(AppUnitsController.instance.heightUnit, HeightUnit.feet);
  });
}
