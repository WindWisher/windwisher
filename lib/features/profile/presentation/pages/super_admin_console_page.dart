import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class SuperAdminConsolePage extends StatefulWidget {
  const SuperAdminConsolePage({super.key});

  @override
  State<SuperAdminConsolePage> createState() => _SuperAdminConsolePageState();
}

class _SuperAdminConsolePageState extends State<SuperAdminConsolePage> {
  static const int _searchResultPageSize = 10;
  static const int _auditPageSize = 10;
  static const List<String> _assignableRoles = [
    'user',
    'pro',
    'vip',
    'moderator',
    'manager',
    'admin',
    'super_admin',
  ];

  late Future<_SuperAdminSnapshot> _snapshotFuture = _loadSnapshot();
  final Set<String> _updatingRoleKeys = <String>{};
  final TextEditingController _userSearchController = TextEditingController();
  final ScrollController _pageScrollController = ScrollController();
  final ScrollController _searchResultsScrollController = ScrollController();
  final List<Map<String, dynamic>> _auditRows = <Map<String, dynamic>>[];
  String _userSearchQuery = '';
  String? _selectedUserId;
  int _visibleSearchResultCount = _searchResultPageSize;
  bool _isLoadingAudit = false;
  bool _hasMoreAudit = true;

  Future<_SuperAdminSnapshot> _loadSnapshot() async {
    final client = Supabase.instance.client;
    final usersResponse = await _safeRpcList(
      () => client.rpc('get_role_management_directory'),
    );

    final users = usersResponse
        .whereType<Map<String, dynamic>>()
        .map(_RoleManagedUser.fromRow)
        .toList(growable: false);

    await _resetAuditPagination();

    return _SuperAdminSnapshot(users: users);
  }

  Future<List<dynamic>> _safeRpcList(Future<dynamic> Function() loader) async {
    try {
      final response = await loader();
      return response is List<dynamic> ? response : const <dynamic>[];
    } catch (_) {
      return const <dynamic>[];
    }
  }

  void _reloadSnapshot({bool keepSelectedUser = false}) {
    setState(() {
      _auditRows.clear();
      _hasMoreAudit = true;
      _snapshotFuture = _loadSnapshot();
      if (!keepSelectedUser) {
        _selectedUserId = null;
      }
      _visibleSearchResultCount = _searchResultPageSize;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageScrollController.addListener(_onPageScroll);
    _searchResultsScrollController.addListener(_onSearchResultsScroll);
  }

  @override
  void dispose() {
    _pageScrollController.removeListener(_onPageScroll);
    _searchResultsScrollController.removeListener(_onSearchResultsScroll);
    _userSearchController.dispose();
    _pageScrollController.dispose();
    _searchResultsScrollController.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    if (!_pageScrollController.hasClients ||
        _isLoadingAudit ||
        !_hasMoreAudit) {
      return;
    }
    final position = _pageScrollController.position;
    if (position.pixels < position.maxScrollExtent - 240) {
      return;
    }
    _loadMoreAudit();
  }

  void _onSearchResultsScroll() {
    if (!_searchResultsScrollController.hasClients) {
      return;
    }
    final position = _searchResultsScrollController.position;
    if (position.pixels < position.maxScrollExtent - 72) {
      return;
    }
    setState(() {
      _visibleSearchResultCount += _searchResultPageSize;
    });
  }

  Future<void> _resetAuditPagination() async {
    _auditRows.clear();
    _hasMoreAudit = true;
    await _loadMoreAudit();
  }

  Future<void> _loadMoreAudit() async {
    if (_isLoadingAudit || !_hasMoreAudit) {
      return;
    }
    setState(() => _isLoadingAudit = true);
    final rows = await _safeRpcList(
      () => Supabase.instance.client.rpc(
        'get_admin_action_audit',
        params: <String, dynamic>{
          'limit_count': _auditPageSize,
          'offset_count': _auditRows.length,
        },
      ),
    );
    final nextRows = rows.whereType<Map<String, dynamic>>().toList(
      growable: false,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _auditRows.addAll(nextRows);
      _hasMoreAudit = nextRows.length == _auditPageSize;
      _isLoadingAudit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel superadmin'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _reloadSnapshot,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<_SuperAdminSnapshot>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Acceso restringido o datos no disponibles.',
                      style: textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            );
          }

          final data = snapshot.requireData;
          return ListView(
            controller: _pageScrollController,
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resumen global', style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Usuarios gestionables: ${data.users.length}'),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Asignaciones de rol: ${data.roleAssignmentCount}'),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Eventos auditados cargados: ${_auditRows.length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Gestion de roles', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              _buildUserSearchField(),
              const SizedBox(height: AppSpacing.sm),
              if (data.users.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('No hay usuarios disponibles.'),
                  ),
                )
              else
                _buildRoleSearchResult(data.users),
              const SizedBox(height: AppSpacing.md),
              Text('Auditoria admin', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              if (_auditRows.isEmpty && !_isLoadingAudit)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('No hay acciones auditadas todavia.'),
                  ),
                )
              else
                ..._auditRows.map(_buildAuditCard),
              if (_isLoadingAudit)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_hasMoreAudit)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Center(child: Text('Desplazate para cargar mas.')),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserSearchField() {
    return TextField(
      controller: _userSearchController,
      decoration: InputDecoration(
        labelText: 'Buscar usuario',
        hintText: 'Handle, nombre o email',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _userSearchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar busqueda',
                onPressed: () {
                  _userSearchController.clear();
                  setState(() {
                    _userSearchQuery = '';
                    _selectedUserId = null;
                    _visibleSearchResultCount = _searchResultPageSize;
                  });
                },
                icon: const Icon(Icons.close_rounded),
              ),
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          _userSearchQuery = value.trim().toLowerCase();
          _selectedUserId = null;
          _visibleSearchResultCount = _searchResultPageSize;
        });
      },
    );
  }

  Widget _buildRoleSearchResult(List<_RoleManagedUser> users) {
    if (_userSearchQuery.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Text('Busca un usuario para gestionar sus roles.'),
        ),
      );
    }

    final matches = users
        .where((user) => user.matches(_userSearchQuery))
        .toList(growable: false);
    if (matches.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Text('No se ha encontrado ningun usuario.'),
        ),
      );
    }

    final selectedUser = _selectedUserId == null
        ? null
        : matches.cast<_RoleManagedUser?>().firstWhere(
            (user) => user?.id == _selectedUserId,
            orElse: () => null,
          );

    if (selectedUser != null) {
      return _buildManagedUserCard(selectedUser);
    }

    final visibleMatches = matches
        .take(_visibleSearchResultCount)
        .toList(growable: false);
    final hasMoreMatches = visibleMatches.length < matches.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: Scrollbar(
              controller: _searchResultsScrollController,
              thumbVisibility: matches.length > 5,
              child: ListView.builder(
                controller: _searchResultsScrollController,
                shrinkWrap: true,
                itemCount: visibleMatches.length + (hasMoreMatches ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= visibleMatches.length) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _buildUserSearchResultTile(visibleMatches[index]);
                },
              ),
            ),
          ),
        ),
        if (matches.length > _searchResultPageSize) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Mostrando ${visibleMatches.length} de ${matches.length} coincidencias.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildUserSearchResultTile(_RoleManagedUser user) {
    final title = user.displayName.isNotEmpty
        ? user.displayName
        : (user.handle.isNotEmpty ? '@${user.handle}' : 'Usuario');
    final subtitleParts = [
      if (user.handle.isNotEmpty) '@${user.handle}',
      if (user.email.isNotEmpty) user.email,
    ];

    return ListTile(
      leading: const Icon(Icons.person_search_rounded),
      title: Text(title),
      subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' · ')),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        setState(() => _selectedUserId = user.id);
      },
    );
  }

  Widget _buildManagedUserCard(_RoleManagedUser user) {
    final textTheme = Theme.of(context).textTheme;
    final title = user.displayName.isNotEmpty
        ? user.displayName
        : (user.handle.isNotEmpty ? '@${user.handle}' : 'Usuario');
    final subtitleParts = [
      if (user.handle.isNotEmpty) '@${user.handle}',
      if (user.email.isNotEmpty) user.email,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Volver a resultados',
                  onPressed: () {
                    setState(() => _selectedUserId = null);
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Icon(Icons.person_outline_rounded),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitleParts.isNotEmpty)
                        Text(
                          subtitleParts.join(' · '),
                          style: textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _assignableRoles
                  .map((role) => _buildRoleActionChip(user, role))
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleActionChip(_RoleManagedUser user, String role) {
    final hasRole = user.roles.contains(role);
    final updateKey = '${user.id}:$role';
    final isUpdating = _updatingRoleKeys.contains(updateKey);
    final canRevoke = role != 'super_admin';

    return FilterChip(
      selected: hasRole,
      showCheckmark: true,
      label: Text(_roleLabel(role)),
      avatar: isUpdating
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onSelected: isUpdating || (hasRole && !canRevoke)
          ? null
          : (_) =>
                _toggleUserRole(user: user, role: role, shouldAssign: !hasRole),
    );
  }

  Future<void> _toggleUserRole({
    required _RoleManagedUser user,
    required String role,
    required bool shouldAssign,
  }) async {
    final updateKey = '${user.id}:$role';
    setState(() => _updatingRoleKeys.add(updateKey));
    try {
      await Supabase.instance.client.rpc(
        shouldAssign ? 'assign_user_role' : 'revoke_user_role',
        params: <String, dynamic>{
          'target_user_id': user.id,
          'target_role': role,
        },
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            shouldAssign
                ? 'Rol ${_roleLabel(role)} asignado.'
                : 'Rol ${_roleLabel(role)} revocado.',
          ),
        ),
      );
      _reloadSnapshot(keepSelectedUser: true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_roleUpdateErrorLabel(error))));
    } finally {
      if (mounted) {
        setState(() => _updatingRoleKeys.remove(updateKey));
      }
    }
  }

  Widget _buildAuditCard(Map<String, dynamic> row) {
    final actorHandle = (row['actor_handle'] as String?)?.trim();
    final actorRole = (row['actor_role'] as String?)?.trim() ?? 'user';
    final actionName = (row['action_name'] as String?)?.trim() ?? 'accion';
    final targetHandle = (row['target_handle'] as String?)?.trim();
    final targetResource = (row['target_resource'] as String?)?.trim();
    final createdAt = DateTime.tryParse((row['created_at'] as String?) ?? '');
    final details = row['details'];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    actionName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(label: Text(actorRole)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Actor: ${actorHandle?.isNotEmpty == true ? '@$actorHandle' : 'desconocido'}',
            ),
            if (targetHandle != null && targetHandle.isNotEmpty)
              Text('Objetivo: @$targetHandle'),
            if (targetResource != null && targetResource.isNotEmpty)
              Text('Recurso: $targetResource'),
            if (createdAt != null) Text('Fecha: ${_formatDateTime(createdAt)}'),
            if (details != null) ...[
              const SizedBox(height: AppSpacing.xs),
              SelectableText(
                const JsonEncoder.withIndent('  ').convert(details),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _roleLabel(String role) {
    return switch (role) {
      'user' => 'User',
      'pro' => 'Pro',
      'vip' => 'VIP',
      'moderator' => 'Moderador',
      'manager' => 'Manager',
      'admin' => 'Admin',
      'super_admin' => 'Superadmin',
      _ => role,
    };
  }

  String _roleUpdateErrorLabel(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('super-admin-already-assigned')) {
      return 'Ya existe otro superadmin.';
    }
    if (message.contains('cannot-revoke-super-admin')) {
      return 'El rol superadmin no se puede revocar desde esta pantalla.';
    }
    if (message.contains('forbidden')) {
      return 'No tienes permisos para cambiar roles.';
    }
    return 'No se pudo actualizar el rol.';
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}

class _RoleManagedUser {
  const _RoleManagedUser({
    required this.id,
    required this.handle,
    required this.displayName,
    required this.email,
    required this.roles,
  });

  final String id;
  final String handle;
  final String displayName;
  final String email;
  final Set<String> roles;

  bool matches(String query) {
    final normalized = query.replaceFirst('@', '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return handle.toLowerCase().contains(normalized) ||
        displayName.toLowerCase().contains(normalized) ||
        email.toLowerCase().contains(normalized) ||
        id.toLowerCase().contains(normalized);
  }

  static _RoleManagedUser fromRow(Map<String, dynamic> row) {
    final rawRoles = row['roles'];
    final roles = rawRoles is List
        ? rawRoles
              .map((role) => role.toString().trim())
              .where((role) => role.isNotEmpty)
              .toSet()
        : <String>{};
    return _RoleManagedUser(
      id: (row['user_id'] as String?) ?? '',
      handle: (row['handle'] as String?)?.trim() ?? '',
      displayName: (row['display_name'] as String?)?.trim() ?? '',
      email: (row['email'] as String?)?.trim() ?? '',
      roles: roles,
    );
  }
}

class _SuperAdminSnapshot {
  const _SuperAdminSnapshot({required this.users});

  final List<_RoleManagedUser> users;

  int get roleAssignmentCount {
    return users.fold<int>(0, (total, user) => total + user.roles.length);
  }
}
