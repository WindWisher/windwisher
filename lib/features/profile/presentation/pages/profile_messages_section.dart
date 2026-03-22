import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/app_message_index_entry.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';
import 'package:windwisher/features/profile/presentation/pages/profile_messages_chat_pages.dart';

class ProfileMessagesSection extends StatelessWidget {
  const ProfileMessagesSection({
    super.key,
    required this.selectedMessagesViewIndex,
    required this.onSelectMessagesView,
    required this.directMessageThreads,
    required this.onToggleMute,
    required this.onBlock,
    required this.onDelete,
    required this.messageSearchController,
    required this.messageSearchQuery,
    required this.onSearchChanged,
    required this.indexedResults,
    required this.onOpenIndexedMessage,
    required this.formatTimestamp,
  });

  final int selectedMessagesViewIndex;
  final ValueChanged<int> onSelectMessagesView;
  final List<DirectMessageThread> directMessageThreads;
  final ValueChanged<String> onToggleMute;
  final Future<void> Function(String id, String participant) onBlock;
  final Future<void> Function(String id, String participant) onDelete;
  final TextEditingController messageSearchController;
  final String messageSearchQuery;
  final ValueChanged<String> onSearchChanged;
  final List<AppMessageIndexEntry> indexedResults;
  final ValueChanged<AppMessageIndexEntry> onOpenIndexedMessage;
  final String Function(DateTime timestamp) formatTimestamp;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const ValueKey('mensajes'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.35),
                ),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                foregroundColor: Theme.of(context).colorScheme.primary,
                selectedForegroundColor: Colors.white,
                selectedBackgroundColor: Theme.of(context).colorScheme.primary,
              ),
              segments: const [
                ButtonSegment<int>(value: 0, label: Text('Directos')),
                ButtonSegment<int>(value: 1, label: Text('Buscar en app')),
              ],
              selected: {selectedMessagesViewIndex},
              onSelectionChanged: (selection) {
                onSelectMessagesView(selection.first);
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (selectedMessagesViewIndex == 0)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestor de mensajes directos',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Gestiona tus conversaciones activas sin entrar a un chat completo.',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (directMessageThreads.isEmpty)
                    Text(
                      'No hay conversaciones directas activas.',
                      style: textTheme.bodyMedium,
                    )
                  else
                    ...directMessageThreads.map(
                      (thread) => _DirectMessageManagerTile(
                        thread: thread,
                        textTheme: textTheme,
                        onToggleMute: onToggleMute,
                        onBlock: onBlock,
                        onDelete: onDelete,
                        formatTimestamp: formatTimestamp,
                      ),
                    ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buscador de mis mensajes en la app',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: messageSearchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Buscar en Comunidad, Spots, Sesiones...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: onSearchChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (indexedResults.isEmpty)
                    Text(
                      'No hay coincidencias para "${messageSearchQuery.trim()}".',
                      style: textTheme.bodyMedium,
                    )
                  else
                    ...indexedResults.map(
                      (entry) => _IndexedMessageResultTile(
                        entry: entry,
                        textTheme: textTheme,
                        onOpenIndexedMessage: onOpenIndexedMessage,
                        formatTimestamp: formatTimestamp,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DirectMessageManagerTile extends StatelessWidget {
  const _DirectMessageManagerTile({
    required this.thread,
    required this.textTheme,
    required this.onToggleMute,
    required this.onBlock,
    required this.onDelete,
    required this.formatTimestamp,
  });

  final DirectMessageThread thread;
  final TextTheme textTheme;
  final ValueChanged<String> onToggleMute;
  final Future<void> Function(String id, String participant) onBlock;
  final Future<void> Function(String id, String participant) onDelete;
  final String Function(DateTime timestamp) formatTimestamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    thread.participant,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (thread.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(right: AppSpacing.xs),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('${thread.unreadCount} sin leer'),
                        ),
                      Text(
                        formatTimestamp(thread.lastActivity),
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  if (thread.isMuted)
                    const Chip(
                      avatar: Icon(Icons.notifications_off_rounded, size: 16),
                      label: Text('Silenciado'),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (thread.isBlocked)
                    const Chip(
                      avatar: Icon(Icons.block_rounded, size: 16),
                      label: Text('Bloqueado'),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DirectChatPage(
                            participant: thread.participant,
                            initialPreview: thread.preview,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(40, 40),
                      padding: const EdgeInsets.all(8),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<_DirectMessageAction>(
                    icon: const Icon(Icons.more_vert_rounded),
                    tooltip: 'Opciones de chat',
                    onSelected: (action) async {
                      switch (action) {
                        case _DirectMessageAction.toggleMute:
                          onToggleMute(thread.id);
                        case _DirectMessageAction.block:
                          await onBlock(thread.id, thread.participant);
                        case _DirectMessageAction.delete:
                          await onDelete(thread.id, thread.participant);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<_DirectMessageAction>(
                        value: _DirectMessageAction.toggleMute,
                        child: Text(
                          thread.isMuted
                              ? 'Activar notificaciones'
                              : 'Silenciar usuario',
                        ),
                      ),
                      PopupMenuItem<_DirectMessageAction>(
                        value: _DirectMessageAction.block,
                        child: Text(
                          thread.isBlocked
                              ? 'Usuario bloqueado'
                              : 'Bloquear usuario',
                        ),
                      ),
                      const PopupMenuItem<_DirectMessageAction>(
                        value: _DirectMessageAction.delete,
                        child: Text('Eliminar chat'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _DirectMessageAction { toggleMute, block, delete }

class _IndexedMessageResultTile extends StatelessWidget {
  const _IndexedMessageResultTile({
    required this.entry,
    required this.textTheme,
    required this.onOpenIndexedMessage,
    required this.formatTimestamp,
  });

  final AppMessageIndexEntry entry;
  final TextTheme textTheme;
  final ValueChanged<AppMessageIndexEntry> onOpenIndexedMessage;
  final String Function(DateTime timestamp) formatTimestamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: const Icon(Icons.search_rounded),
          title: Text(entry.contextLabel),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 2),
              Text(entry.message),
              const SizedBox(height: 6),
              Row(
                children: [
                  Chip(
                    label: Text(entry.channel),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    formatTimestamp(entry.createdAt),
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: () => onOpenIndexedMessage(entry),
                  child: const Text('Ver comentario'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
