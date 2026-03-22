enum DashboardMainTab { spots, sessions, community, profile }

class DashboardToolbarState {
  const DashboardToolbarState({
    required this.showSpotsMenu,
    required this.showSessionsActions,
    required this.showProfileSettings,
  });

  final bool showSpotsMenu;
  final bool showSessionsActions;
  final bool showProfileSettings;
}

class DashboardToolbarService {
  const DashboardToolbarService();

  DashboardToolbarState resolve({
    required int selectedIndex,
    required bool isSessionStartTab,
  }) {
    final tab = _tabFromIndex(selectedIndex);
    return DashboardToolbarState(
      showSpotsMenu: tab == DashboardMainTab.spots,
      showSessionsActions:
          tab == DashboardMainTab.sessions && isSessionStartTab,
      showProfileSettings: tab == DashboardMainTab.profile,
    );
  }

  DashboardMainTab _tabFromIndex(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return DashboardMainTab.spots;
      case 1:
        return DashboardMainTab.sessions;
      case 2:
        return DashboardMainTab.community;
      case 3:
        return DashboardMainTab.profile;
      default:
        return DashboardMainTab.spots;
    }
  }
}
