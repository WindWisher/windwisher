import 'package:windwisher/features/profile/domain/entities/app_message_index_entry.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_messages_repository_port.dart';

class InMemoryProfileMessagesRepositoryAdapter
    implements ProfileMessagesRepositoryPort {
  InMemoryProfileMessagesRepositoryAdapter({DateTime? now}) {
    final current = now ?? DateTime.now();
    _directThreads = [
      DirectMessageThread(
        id: 'dm-juan',
        participant: 'Juan Kitesurf',
        preview:
            'Mañana hay 24kt en Oliva. Si quieres vamos al downwind de las 10.',
        lastActivity: current.subtract(const Duration(minutes: 24)),
        unreadCount: 2,
        isMuted: false,
        isBlocked: false,
        lastLocation: 'Mensajes directos',
      ),
      DirectMessageThread(
        id: 'dm-marta',
        participant: 'Marta Loop',
        preview: 'Te comparto el setup que mejor me funciono con 30kt.',
        lastActivity: current.subtract(const Duration(hours: 3)),
        unreadCount: 0,
        isMuted: false,
        isBlocked: false,
        lastLocation: 'Mensajes directos',
      ),
      DirectMessageThread(
        id: 'dm-carlos',
        participant: 'Carlos Freeride',
        preview: 'Recibido, cierro la conversacion por hoy.',
        lastActivity: current.subtract(const Duration(days: 1)),
        unreadCount: 0,
        isMuted: true,
        isBlocked: false,
        lastLocation: 'Mensajes directos',
      ),
    ];
    _indexedMessages = [
      AppMessageIndexEntry(
        id: 'idx-community-1',
        channel: 'Comunidad',
        contextLabel: 'Post: Wind Window Gandia',
        message:
            'Subi el parte de hoy con rachas de 28kt y mejor ventana entre 14:00 y 16:00.',
        createdAt: current.subtract(const Duration(hours: 5)),
      ),
      AppMessageIndexEntry(
        id: 'idx-sessions-1',
        channel: 'Sesiones',
        contextLabel: 'Sesion en Oliva Norte',
        message: 'Anoté: buena ceñida con cometa 10m, ola corta al final.',
        createdAt: current.subtract(const Duration(hours: 9)),
      ),
      AppMessageIndexEntry(
        id: 'idx-spot-1',
        channel: 'Spots',
        contextLabel: 'Spot detail: Cullera Beach',
        message: 'Dejé comentario sobre corriente lateral en bajamar.',
        createdAt: current.subtract(const Duration(days: 1)),
      ),
      AppMessageIndexEntry(
        id: 'idx-community-2',
        channel: 'Comunidad',
        contextLabel: 'Chat grupo Big Air',
        message: 'Propuse abrir hilo de seguridad para saltos con mas de 30kt.',
        createdAt: current.subtract(const Duration(days: 2)),
      ),
    ];
  }

  late List<DirectMessageThread> _directThreads;
  late List<AppMessageIndexEntry> _indexedMessages;

  @override
  List<DirectMessageThread> getDirectMessageThreads() {
    return List<DirectMessageThread>.unmodifiable(_directThreads);
  }

  @override
  List<AppMessageIndexEntry> getIndexedMessages() {
    return List<AppMessageIndexEntry>.unmodifiable(_indexedMessages);
  }

  @override
  Future<void> hydrate() async {}

  @override
  void toggleMuteDirectThread(String threadId) {
    final index = _directThreads.indexWhere((item) => item.id == threadId);
    if (index < 0) {
      return;
    }
    final current = _directThreads[index];
    _directThreads[index] = current.copyWith(isMuted: !current.isMuted);
  }

  @override
  bool blockDirectThread(String threadId) {
    final index = _directThreads.indexWhere((item) => item.id == threadId);
    if (index < 0) {
      return false;
    }
    final current = _directThreads[index];
    if (current.isBlocked) {
      return false;
    }
    _directThreads[index] = current.copyWith(isBlocked: true);
    return true;
  }

  @override
  void deleteDirectThread(String threadId) {
    _directThreads.removeWhere((item) => item.id == threadId);
  }

  @override
  void updateIndexedMessage(AppMessageIndexEntry updated) {
    final index = _indexedMessages.indexWhere((item) => item.id == updated.id);
    if (index < 0) {
      return;
    }
    _indexedMessages[index] = updated;
  }

  @override
  void deleteIndexedMessage(String id) {
    _indexedMessages.removeWhere((item) => item.id == id);
  }
}
