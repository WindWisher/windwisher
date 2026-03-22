import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:path_provider/path_provider.dart';

class DirectChatPage extends StatefulWidget {
  final String participant;
  final String initialPreview;

  const DirectChatPage({
    super.key,
    required this.participant,
    required this.initialPreview,
  });

  @override
  State<DirectChatPage> createState() => _DirectChatPageState();
}

class _DirectChatPageState extends State<DirectChatPage> {
  final TextEditingController _composerController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  late final List<_DirectChatMessage> _messages;
  bool _isPickingMedia = false;
  _DirectChatSelectionMode _selectionMode = _DirectChatSelectionMode.none;
  String? _editingMessageId;
  final Set<String> _selectedToDelete = <String>{};
  bool _deleteConfirmationArmed = false;
  int _messageCounter = 0;

  @override
  void initState() {
    super.initState();
    _messages = [
      _DirectChatMessage(
        id: 'm-${_messageCounter++}',
        sender: widget.participant,
        content: widget.initialPreview,
        sentAt: DateTime.now().subtract(const Duration(minutes: 18)),
        isMine: false,
      ),
      _DirectChatMessage(
        id: 'm-${_messageCounter++}',
        sender: 'Tu',
        content: 'Perfecto, lo reviso y te confirmo por aqui.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 9)),
        isMine: true,
      ),
    ];
  }

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _composerController.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      _messages.add(
        _DirectChatMessage(
          id: 'm-${_messageCounter++}',
          sender: 'Tu',
          content: text,
          sentAt: DateTime.now(),
          isMine: true,
        ),
      );
    });
    _composerController.clear();
  }

  void _startEditSelectionMode() {
    setState(() {
      _selectionMode = _DirectChatSelectionMode.edit;
      _editingMessageId = null;
      _selectedToDelete.clear();
      _deleteConfirmationArmed = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toca un mensaje para editarlo.')),
    );
  }

  void _startDeleteSelectionMode() {
    setState(() {
      _selectionMode = _DirectChatSelectionMode.delete;
      _editingMessageId = null;
      _selectedToDelete.clear();
      _deleteConfirmationArmed = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selecciona uno o varios mensajes para eliminar.'),
      ),
    );
  }

  void _cancelSelectionMode() {
    setState(() {
      _selectionMode = _DirectChatSelectionMode.none;
      _editingMessageId = null;
      _selectedToDelete.clear();
      _deleteConfirmationArmed = false;
    });
  }

  void _onMessageTap(_DirectChatMessage message) {
    if (_selectionMode == _DirectChatSelectionMode.none) {
      return;
    }

    if (_selectionMode == _DirectChatSelectionMode.edit) {
      if (!message.isMine) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solo puedes editar mensajes enviados por ti.'),
          ),
        );
        return;
      }

      if (_editingMessageId == message.id) {
        setState(() {
          _editingMessageId = null;
        });
        _composerController.clear();
        return;
      }

      setState(() {
        _editingMessageId = message.id;
        _composerController.text = message.content;
      });
      return;
    }

    if (!message.isMine) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo puedes eliminar mensajes enviados por ti.'),
        ),
      );
      return;
    }

    setState(() {
      if (_selectedToDelete.contains(message.id)) {
        _selectedToDelete.remove(message.id);
      } else {
        _selectedToDelete.add(message.id);
      }
      _deleteConfirmationArmed = false;
    });
  }

  void _saveEditedMessage() {
    final targetId = _editingMessageId;
    if (targetId == null) {
      return;
    }
    final value = _composerController.text.trim();
    if (value.isEmpty) {
      return;
    }

    final index = _messages.indexWhere((m) => m.id == targetId);
    if (index < 0) {
      return;
    }
    if (!_messages[index].isMine) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo puedes editar mensajes enviados por ti.'),
        ),
      );
      return;
    }

    setState(() {
      _messages[index] = _messages[index].copyWith(
        content: value,
        isEdited: true,
      );
      _selectionMode = _DirectChatSelectionMode.none;
      _editingMessageId = null;
      _deleteConfirmationArmed = false;
      _selectedToDelete.clear();
    });
    _composerController.clear();
  }

  void _confirmDeleteSelectionInline() {
    if (_selectedToDelete.isEmpty) {
      return;
    }

    if (!_deleteConfirmationArmed) {
      setState(() {
        _deleteConfirmationArmed = true;
      });
      return;
    }

    setState(() {
      _messages.removeWhere(
        (m) => m.isMine && _selectedToDelete.contains(m.id),
      );
      _selectionMode = _DirectChatSelectionMode.none;
      _editingMessageId = null;
      _selectedToDelete.clear();
      _deleteConfirmationArmed = false;
    });
  }

  Future<void> _pickAndSendMedia({required bool isVideo}) async {
    if (_isPickingMedia) {
      return;
    }

    setState(() {
      _isPickingMedia = true;
    });

    try {
      final XFile? picked = isVideo
          ? await _imagePicker.pickVideo(source: ImageSource.gallery)
          : await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked == null || !mounted) {
        return;
      }

      final storedPath = await _storeMediaLocally(picked);
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          _DirectChatMessage(
            id: 'm-${_messageCounter++}',
            sender: 'Tu',
            content: isVideo
                ? 'Video enviado desde galeria'
                : 'Foto enviada desde galeria',
            sentAt: DateTime.now(),
            isMine: true,
            type: isVideo
                ? _DirectChatMessageType.video
                : _DirectChatMessageType.image,
            localPath: storedPath,
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Archivo guardado localmente en el dispositivo.'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo adjuntar el archivo de la galeria.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingMedia = false;
        });
      }
    }
  }

  Future<void> _showAttachMediaOptions() async {
    final selection = await showModalBottomSheet<_DirectChatMessageType>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Foto desde galeria'),
                onTap: () => Navigator.of(
                  sheetContext,
                ).pop(_DirectChatMessageType.image),
              ),
              ListTile(
                leading: const Icon(Icons.video_library_rounded),
                title: const Text('Video desde galeria'),
                onTap: () => Navigator.of(
                  sheetContext,
                ).pop(_DirectChatMessageType.video),
              ),
            ],
          ),
        );
      },
    );

    if (selection == null) {
      return;
    }
    await _pickAndSendMedia(isVideo: selection == _DirectChatMessageType.video);
  }

  Future<String> _storeMediaLocally(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(
      '${appDir.path}${Platform.pathSeparator}direct_chats_media',
    );
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final extension = _fileExtension(file.path);
    final target = File(
      '${mediaDir.path}${Platform.pathSeparator}chat_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await target.writeAsBytes(await file.readAsBytes(), flush: true);
    return target.path;
  }

  String _fileExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) {
      return '';
    }
    return path.substring(dot);
  }

  String _formatHour(DateTime timestamp) {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat con ${widget.participant}'),
        actions: [
          if (_selectionMode != _DirectChatSelectionMode.none)
            IconButton(
              tooltip: 'Cancelar seleccion',
              onPressed: _cancelSelectionMode,
              icon: const Icon(Icons.close_rounded),
            ),
          PopupMenuButton<_DirectChatAppBarAction>(
            tooltip: 'Opciones de mensaje',
            onSelected: (action) async {
              switch (action) {
                case _DirectChatAppBarAction.editAny:
                  _startEditSelectionMode();
                case _DirectChatAppBarAction.deleteAny:
                  _startDeleteSelectionMode();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<_DirectChatAppBarAction>(
                value: _DirectChatAppBarAction.editAny,
                child: Text('Editar mensaje'),
              ),
              PopupMenuItem<_DirectChatAppBarAction>(
                value: _DirectChatAppBarAction.deleteAny,
                child: Text('Eliminar mensaje'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSelectedForEdit =
                    _selectionMode == _DirectChatSelectionMode.edit &&
                    _editingMessageId == message.id;
                final isSelectedForDelete =
                    _selectionMode == _DirectChatSelectionMode.delete &&
                    _selectedToDelete.contains(message.id);
                final bubbleColor = message.isMine
                    ? Colors.blue.shade50
                    : Theme.of(context).colorScheme.surfaceContainerHighest;

                return Align(
                  alignment: message.isMine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: InkWell(
                      onTap: () => _onMessageTap(message),
                      borderRadius: BorderRadius.circular(12),
                      child: Card(
                        color: bubbleColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelectedForEdit || isSelectedForDelete
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1.5,
                                )
                              : BorderSide.none,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (message.type == _DirectChatMessageType.text)
                                Text(message.content)
                              else if (message.type ==
                                  _DirectChatMessageType.image)
                                _ChatImageBubble(path: message.localPath)
                              else
                                _ChatVideoBubble(path: message.localPath),
                              if (message.type != _DirectChatMessageType.text &&
                                  message.content.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(message.content),
                                ),
                              const SizedBox(height: 4),
                              if (message.type != _DirectChatMessageType.text)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.download_done_rounded,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Guardado localmente',
                                        style: textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (message.isEdited)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Text(
                                        'editado',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    _formatHour(message.sentAt),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (isSelectedForEdit || isSelectedForDelete)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        size: 14,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectionMode != _DirectChatSelectionMode.none)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _selectionMode == _DirectChatSelectionMode.edit
                      ? (_editingMessageId == null
                            ? 'Toca un mensaje para editar.'
                            : 'Mensaje seleccionado para editar.')
                      : (_deleteConfirmationArmed
                            ? 'Pulsa Confirmar para borrar la seleccion.'
                            : 'Selecciona mensajes para eliminar.'),
                  style: textTheme.bodySmall,
                ),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Adjuntar',
                    onPressed:
                        _isPickingMedia ||
                            _selectionMode == _DirectChatSelectionMode.delete
                        ? null
                        : _showAttachMediaOptions,
                    icon: const Icon(Icons.add_rounded),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: TextField(
                      controller: _composerController,
                      enabled:
                          _selectionMode != _DirectChatSelectionMode.delete,
                      decoration: InputDecoration(
                        hintText:
                            _selectionMode == _DirectChatSelectionMode.edit
                            ? 'Edita el mensaje seleccionado...'
                            : 'Escribe un mensaje...',
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) {
                        if (_selectionMode == _DirectChatSelectionMode.edit) {
                          _saveEditedMessage();
                        } else {
                          _sendMessage();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (_selectionMode == _DirectChatSelectionMode.delete)
                    FilledButton.icon(
                      onPressed: _selectedToDelete.isEmpty
                          ? null
                          : _confirmDeleteSelectionInline,
                      icon: Icon(
                        _deleteConfirmationArmed
                            ? Icons.warning_amber_rounded
                            : Icons.delete_outline_rounded,
                      ),
                      label: Text(
                        _deleteConfirmationArmed
                            ? 'Confirmar'
                            : 'Eliminar (${_selectedToDelete.length})',
                      ),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _selectionMode == _DirectChatSelectionMode.edit
                          ? _saveEditedMessage
                          : _sendMessage,
                      icon: Icon(
                        _selectionMode == _DirectChatSelectionMode.edit
                            ? Icons.save_rounded
                            : Icons.send_rounded,
                      ),
                      label: Text(
                        _selectionMode == _DirectChatSelectionMode.edit
                            ? 'Editar'
                            : 'Enviar',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectChatMessage {
  final String id;
  final String sender;
  final String content;
  final DateTime sentAt;
  final bool isMine;
  final bool isEdited;
  final _DirectChatMessageType type;
  final String? localPath;

  const _DirectChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.sentAt,
    required this.isMine,
    this.isEdited = false,
    this.type = _DirectChatMessageType.text,
    this.localPath,
  });

  _DirectChatMessage copyWith({String? content, bool? isEdited}) {
    return _DirectChatMessage(
      id: id,
      sender: sender,
      content: content ?? this.content,
      sentAt: sentAt,
      isMine: isMine,
      isEdited: isEdited ?? this.isEdited,
      type: type,
      localPath: localPath,
    );
  }
}

enum _DirectChatMessageType { text, image, video }

enum _DirectChatSelectionMode { none, edit, delete }

enum _DirectChatAppBarAction { editAny, deleteAny }

class _ChatImageBubble extends StatelessWidget {
  final String? path;

  const _ChatImageBubble({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return const Text('Imagen no disponible');
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(
        File(path!),
        width: 220,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox(
          width: 220,
          height: 120,
          child: Center(child: Text('No se pudo cargar la imagen')),
        ),
      ),
    );
  }
}

class _ChatVideoBubble extends StatelessWidget {
  final String? path;

  const _ChatVideoBubble({required this.path});

  @override
  Widget build(BuildContext context) {
    final fileName = (path == null || path!.isEmpty)
        ? 'video'
        : path!.split(Platform.pathSeparator).last;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_fill_rounded, size: 28),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(fileName, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
