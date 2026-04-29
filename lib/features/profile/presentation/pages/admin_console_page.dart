import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminConsolePage extends StatefulWidget {
  const AdminConsolePage({super.key});

  @override
  State<AdminConsolePage> createState() => _AdminConsolePageState();
}

class _AdminConsolePageState extends State<AdminConsolePage> {
  late Future<_AdminConsoleSnapshot> _snapshotFuture = _loadSnapshot();

  Future<_AdminConsoleSnapshot> _loadSnapshot() async {
    final client = Supabase.instance.client;
    final roleDirectoryResponse = await _safeRpcList(
      () => client.rpc('get_role_directory'),
    );
    final auditResponse = await _safeRpcList(
      () => client.rpc(
        'get_admin_action_audit',
        params: <String, dynamic>{'limit_count': 50, 'offset_count': 0},
      ),
    );
    final feedbackResponse = await _safeRpcList(
      () => client.rpc(
        'get_user_feedback_admin',
        params: <String, dynamic>{'limit_count': 100, 'offset_count': 0},
      ),
    );

    final roles = roleDirectoryResponse
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
    final audit = auditResponse.whereType<Map<String, dynamic>>().toList(
      growable: false,
    );
    final feedback = feedbackResponse.whereType<Map<String, dynamic>>().toList(
      growable: false,
    );

    return _AdminConsoleSnapshot(
      roles: roles,
      audit: audit,
      feedback: feedback,
    );
  }

  Future<List<dynamic>> _safeRpcList(Future<dynamic> Function() loader) async {
    try {
      final response = await loader();
      return response is List<dynamic> ? response : const <dynamic>[];
    } catch (_) {
      return const <dynamic>[];
    }
  }

  void _reloadSnapshot() {
    setState(() {
      _snapshotFuture = _loadSnapshot();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Panel admin')),
      body: FutureBuilder<_AdminConsoleSnapshot>(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Acceso restringido o datos no disponibles',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text('${snapshot.error}', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          final data = snapshot.requireData;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resumen de roles', style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Usuarios con rol: ${data.roles.length}',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Eventos auditados: ${data.audit.length}',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Sugerencias abiertas: ${data.openFeedbackCount}',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Buzon de sugerencias', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              if (data.feedback.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('No hay sugerencias pendientes.'),
                  ),
                ),
              ...data.feedback.map(_buildFeedbackCard),
              const SizedBox(height: AppSpacing.md),
              Text('Directorio de roles', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              if (data.roles.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('No hay roles asignados todavia.'),
                  ),
                ),
              ...data.roles.map(_buildRoleCard),
              const SizedBox(height: AppSpacing.md),
              Text('Auditoria admin', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              if (data.audit.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('No hay acciones auditadas todavia.'),
                  ),
                ),
              ...data.audit.map(_buildAuditCard),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> row) {
    final handle = (row['handle'] as String?)?.trim();
    final displayName = (row['display_name'] as String?)?.trim();
    final role = (row['role'] as String?)?.trim() ?? 'user';
    final createdAt = DateTime.tryParse((row['created_at'] as String?) ?? '');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: const Icon(Icons.verified_user_outlined),
        title: Text(
          displayName?.isNotEmpty == true
              ? displayName!
              : (handle ?? 'Usuario'),
        ),
        subtitle: Text(
          [
            if (handle != null && handle.isNotEmpty) '@$handle',
            if (createdAt != null) _formatDateTime(createdAt),
          ].join(' · '),
        ),
        trailing: Chip(label: Text(role)),
      ),
    );
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

  Widget _buildFeedbackCard(Map<String, dynamic> row) {
    final id = row['id'] as String?;
    final userHandle = (row['user_handle'] as String?)?.trim();
    final userDisplayName = (row['user_display_name'] as String?)?.trim();
    final message = (row['message'] as String?)?.trim() ?? '';
    final status = (row['status'] as String?)?.trim() ?? 'open';
    final adminNote = (row['admin_note'] as String?)?.trim();
    final createdAt = DateTime.tryParse((row['created_at'] as String?) ?? '');
    final author = userDisplayName?.isNotEmpty == true
        ? userDisplayName!
        : (userHandle?.isNotEmpty == true ? '@$userHandle' : 'Usuario');

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
                    author,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(label: Text(_feedbackStatusLabel(status))),
              ],
            ),
            if (createdAt != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('Fecha: ${_formatDateTime(createdAt)}'),
            ],
            const SizedBox(height: AppSpacing.sm),
            SelectableText(message),
            if (adminNote != null && adminNote.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Nota admin: $adminNote',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                OutlinedButton(
                  onPressed: id == null || status == 'reviewed'
                      ? null
                      : () => _updateFeedbackStatus(id, 'reviewed'),
                  child: const Text('Revisado'),
                ),
                FilledButton.tonal(
                  onPressed: id == null || status == 'resolved'
                      ? null
                      : () => _updateFeedbackStatus(id, 'resolved'),
                  child: const Text('Resuelto'),
                ),
                TextButton(
                  onPressed: id == null || status == 'archived'
                      ? null
                      : () => _updateFeedbackStatus(id, 'archived'),
                  child: const Text('Archivar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateFeedbackStatus(String feedbackId, String status) async {
    try {
      await Supabase.instance.client.rpc(
        'update_user_feedback_status',
        params: <String, dynamic>{
          'feedback_id': feedbackId,
          'next_status': status,
          'next_admin_note': null,
        },
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sugerencia marcada como ${_feedbackStatusLabel(status)}.',
          ),
        ),
      );
      _reloadSnapshot();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar la sugerencia.')),
      );
    }
  }

  String _feedbackStatusLabel(String status) {
    return switch (status) {
      'open' => 'Abierta',
      'reviewed' => 'Revisada',
      'resolved' => 'Resuelta',
      'archived' => 'Archivada',
      _ => status,
    };
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

class _AdminConsoleSnapshot {
  const _AdminConsoleSnapshot({
    required this.roles,
    required this.audit,
    required this.feedback,
  });

  final List<Map<String, dynamic>> roles;
  final List<Map<String, dynamic>> audit;
  final List<Map<String, dynamic>> feedback;

  int get openFeedbackCount {
    return feedback.where((row) => row['status'] == 'open').length;
  }
}
