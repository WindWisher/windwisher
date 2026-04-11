import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:windwisher/app/router/app_routes.dart';
import 'package:windwisher/features/dashboard/application/services/dashboard_toolbar_service.dart';
import 'package:windwisher/features/community/presentation/pages/community_page.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/profile_page.dart';
import 'package:windwisher/features/sessions/presentation/pages/sessions_page.dart';
import 'package:windwisher/features/spots/presentation/pages/spots_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  bool _isSessionStartTab = true;
  final DashboardToolbarService _toolbarService =
      const DashboardToolbarService();
  final GlobalKey<SpotsPageState> _spotsKey = GlobalKey<SpotsPageState>();
  final GlobalKey<SessionsPageState> _sessionsKey =
      GlobalKey<SessionsPageState>();
  final GlobalKey<ProfilePageState> _profileKey = GlobalKey<ProfilePageState>();

  List<Widget> get _pages => [
    SpotsPage(key: _spotsKey),
    SessionsPage(
      key: _sessionsKey,
      onStartTabChanged: (isStart) {
        if (!mounted || _isSessionStartTab == isStart) {
          return;
        }
        setState(() {
          _isSessionStartTab = isStart;
        });
      },
    ),
    const CommunityPage(),
    ProfilePage(key: _profileKey),
  ];

  Future<void> _handleSpotsToolbarAction(_SpotsToolbarAction action) async {
    final state = _spotsKey.currentState;
    if (state == null) {
      return;
    }

    switch (action) {
      case _SpotsToolbarAction.edit:
        state.editSpotFromToolbar();
      case _SpotsToolbarAction.delete:
        state.deleteMultipleSpotsFromToolbar();
    }
  }

  Future<void> _handleSessionsToolbarAction(
    _SessionsToolbarAction action,
  ) async {
    final state = _sessionsKey.currentState;
    if (state == null) {
      return;
    }
    switch (action) {
      case _SessionsToolbarAction.delete:
        await state.deleteSelectedDeviceFromToolbar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final toolbarState = _toolbarService.resolve(
      selectedIndex: _selectedIndex,
      isSessionStartTab: _isSessionStartTab,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('WindWisher'),
        actions: [
          if (toolbarState.showSpotsMenu)
            PopupMenuButton<_SpotsToolbarAction>(
              onSelected: _handleSpotsToolbarAction,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _SpotsToolbarAction.edit,
                  child: Text('Editar'),
                ),
                PopupMenuItem(
                  value: _SpotsToolbarAction.delete,
                  child: Text('Eliminar'),
                ),
              ],
            )
          else if (toolbarState.showSessionsActions) ...[
            IconButton(
              tooltip: 'Añadir dispositivo',
              onPressed: () {
                _sessionsKey.currentState?.addDeviceFromToolbar();
              },
              icon: const Icon(Icons.add_rounded),
            ),
            PopupMenuButton<_SessionsToolbarAction>(
              onSelected: _handleSessionsToolbarAction,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _SessionsToolbarAction.delete,
                  child: Text('Eliminar'),
                ),
              ],
            ),
          ] else if (toolbarState.showProfileSettings)
            IconButton(
              tooltip: 'Ajustes',
              onPressed: () {
                context.push(AppRoutes.settings);
              },
              icon: const Icon(Icons.settings),
            ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.place_outlined),
            selectedIcon: Icon(Icons.place),
            label: 'Spots',
          ),
          NavigationDestination(
            icon: Icon(Icons.surfing_outlined),
            selectedIcon: Icon(Icons.surfing),
            label: 'Session',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

enum _SpotsToolbarAction { edit, delete }

enum _SessionsToolbarAction { delete }
