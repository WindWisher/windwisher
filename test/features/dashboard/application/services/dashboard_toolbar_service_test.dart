import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/dashboard/application/services/dashboard_toolbar_service.dart';

void main() {
  group('DashboardToolbarService', () {
    const service = DashboardToolbarService();

    test('shows spots menu in spots tab', () {
      final state = service.resolve(selectedIndex: 0, isSessionStartTab: true);

      expect(state.showSpotsMenu, isTrue);
      expect(state.showSessionsActions, isFalse);
      expect(state.showProfileSettings, isFalse);
    });

    test('shows session actions only for start sub-tab', () {
      final startState = service.resolve(
        selectedIndex: 1,
        isSessionStartTab: true,
      );
      final historyState = service.resolve(
        selectedIndex: 1,
        isSessionStartTab: false,
      );

      expect(startState.showSessionsActions, isTrue);
      expect(historyState.showSessionsActions, isFalse);
      expect(startState.showSpotsMenu, isFalse);
      expect(startState.showProfileSettings, isFalse);
    });

    test('shows settings in profile tab', () {
      final state = service.resolve(selectedIndex: 3, isSessionStartTab: true);

      expect(state.showProfileSettings, isTrue);
      expect(state.showSpotsMenu, isFalse);
      expect(state.showSessionsActions, isFalse);
    });
  });
}
