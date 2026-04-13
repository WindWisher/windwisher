import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/direct_message_manager_tile.dart';

class DirectMessageActionsRow extends StatelessWidget {
  const DirectMessageActionsRow({
    super.key,
    required this.thread,
    required this.onOpenChat,
    required this.onToggleMute,
    required this.onBlock,
    required this.onDelete,
  });

  final DirectMessageThread thread;
  final ValueChanged<DirectMessageThread> onOpenChat;
  final ValueChanged<String> onToggleMute;
  final Future<void> Function(String id, String participant) onBlock;
  final Future<void> Function(String id, String participant) onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (thread.unreadCount > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          thread.unreadCount > 99 ? '99+' : '${thread.unreadCount}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return PopupMenuButton<DirectMessageAction>(
      padding: EdgeInsets.zero,
      splashRadius: 18,
      icon: Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
      tooltip: 'Opciones de chat',
      onSelected: (action) async {
        switch (action) {
          case DirectMessageAction.toggleMute:
            onToggleMute(thread.id);
          case DirectMessageAction.block:
            await onBlock(thread.id, thread.participant);
          case DirectMessageAction.delete:
            await onDelete(thread.id, thread.participant);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<DirectMessageAction>(
          value: DirectMessageAction.toggleMute,
          child: Text(
            thread.isMuted ? 'Activar notificaciones' : 'Silenciar usuario',
          ),
        ),
        PopupMenuItem<DirectMessageAction>(
          value: DirectMessageAction.block,
          child: Text(
            thread.isBlocked ? 'Desbloquear usuario' : 'Bloquear usuario',
          ),
        ),
        const PopupMenuItem<DirectMessageAction>(
          value: DirectMessageAction.delete,
          child: Text('Eliminar chat'),
        ),
      ],
    );
  }
}
