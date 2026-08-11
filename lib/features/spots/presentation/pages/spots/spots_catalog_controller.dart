// ignore_for_file: invalid_use_of_protected_member

part of 'spots_page.dart';

extension _SpotsCatalogController on SpotsPageState {
  void _subscribeToAuthChanges() {
    if (!EnvConfig.supabaseConfigured) {
      return;
    }
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange
        .listen((_) {
          unawaited(_loadMyRoles());
          unawaited(_hydrateSpotsCatalog());
        });
  }

  Future<void> _loadMyRoles() async {
    if (widget.initialRoles.isNotEmpty) {
      _setRoles(Set<String>.unmodifiable(widget.initialRoles));
      return;
    }
    if (!EnvConfig.supabaseConfigured) {
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setRoles(const <String>{});
      return;
    }

    try {
      final rows = await Supabase.instance.client
          .from('user_roles')
          .select('role')
          .eq('user_id', user.id);
      _setRoles(
        (rows as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((row) => (row['role'] as String? ?? '').trim())
            .where((role) => role.isNotEmpty)
            .toSet(),
      );
    } catch (_) {
      _setRoles(const <String>{});
    }
  }

  void _setRoles(Set<String> roles) {
    if (!mounted) {
      return;
    }
    setState(() {
      _myRoles = roles;
    });
  }

  Future<void> _hydrateSpotsCatalog() async {
    final spots = await _spotsModule.getSpots.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _spotOrderKeys = _loadSpotOrderKeys();
      _spots
        ..clear()
        ..addAll(spots);
      _applyStoredSpotOrder();
    });
  }

  Future<void> _refreshSpotsAfterSave(_SpotItem spot) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) {
      return;
    }
    await _hydrateSpotsCatalog();
  }
}
