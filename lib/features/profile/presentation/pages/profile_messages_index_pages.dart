import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/app_message_index_entry.dart';
import 'package:path_provider/path_provider.dart';

class IndexedCommentDetailPage extends StatefulWidget {
  final AppMessageIndexEntry entry;
  final ValueChanged<AppMessageIndexEntry> onEntryUpdated;
  final ValueChanged<String> onEntryDeleted;

  const IndexedCommentDetailPage({
    super.key,
    required this.entry,
    required this.onEntryUpdated,
    required this.onEntryDeleted,
  });

  @override
  State<IndexedCommentDetailPage> createState() =>
      _IndexedCommentDetailPageState();
}

enum _IndexedAttachmentType { image, video }

class _IndexedCommentDetailPageState extends State<IndexedCommentDetailPage> {
  final ImagePicker _imagePicker = ImagePicker();
  late AppMessageIndexEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  Future<void> _editComment() async {
    String draft = _entry.message;
    String? attachedLabel;
    final updatedText = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> attachFromGallery() async {
              final selection =
                  await showModalBottomSheet<_IndexedAttachmentType>(
                    context: dialogContext,
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
                              ).pop(_IndexedAttachmentType.image),
                            ),
                            ListTile(
                              leading: const Icon(Icons.video_library_rounded),
                              title: const Text('Video desde galeria'),
                              onTap: () => Navigator.of(
                                sheetContext,
                              ).pop(_IndexedAttachmentType.video),
                            ),
                          ],
                        ),
                      );
                    },
                  );

              if (selection == null) {
                return;
              }

              final summary = await _pickCommentAttachmentSummary(
                isVideo: selection == _IndexedAttachmentType.video,
              );
              if (summary == null) {
                return;
              }

              setDialogState(() {
                attachedLabel = summary;
                draft = draft.trim().isEmpty
                    ? summary
                    : '${draft.trim()}\n$summary';
              });
            }

            return AlertDialog(
              title: const Text('Editar mensaje'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Adjuntar',
                        onPressed: attachFromGallery,
                        icon: const Icon(Icons.add_rounded),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          attachedLabel ?? 'Multimedia',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    initialValue: draft,
                    minLines: 3,
                    maxLines: 8,
                    onChanged: (value) {
                      draft = value;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(draft.trim()),
                  child: const Text('Editar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updatedText == null || updatedText.isEmpty || !mounted) {
      return;
    }

    final updated = _entry.copyWith(message: updatedText, isEdited: true);
    setState(() {
      _entry = updated;
    });
    widget.onEntryUpdated(updated);
  }

  Future<String?> _pickCommentAttachmentSummary({required bool isVideo}) async {
    final XFile? picked = isVideo
        ? await _imagePicker.pickVideo(source: ImageSource.gallery)
        : await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return null;
    }

    final savedPath = await _storeCommentMediaLocally(picked);
    final fileName = savedPath.split(Platform.pathSeparator).last;
    return isVideo ? '[Video adjunto: $fileName]' : '[Foto adjunta: $fileName]';
  }

  Future<String> _storeCommentMediaLocally(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(
      '${appDir.path}${Platform.pathSeparator}comment_media',
    );
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final extension = _commentFileExtension(file.path);
    final output = File(
      '${mediaDir.path}${Platform.pathSeparator}comment_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await output.writeAsBytes(await file.readAsBytes(), flush: true);
    return output.path;
  }

  String _commentFileExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) {
      return '';
    }
    return path.substring(dot);
  }

  Future<void> _deleteComment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar comentario'),
          content: const Text(
            'Se eliminara este comentario del indice de busqueda.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    widget.onEntryDeleted(_entry.id);
    Navigator.of(context).pop();
  }

  void _openThread() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _IndexedThreadPage(entry: _entry)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Comentario')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _entry.contextLabel,
                          style: textTheme.titleMedium,
                        ),
                      ),
                      PopupMenuButton<_IndexedCommentAction>(
                        onSelected: (action) async {
                          switch (action) {
                            case _IndexedCommentAction.edit:
                              await _editComment();
                            case _IndexedCommentAction.delete:
                              await _deleteComment();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<_IndexedCommentAction>(
                            value: _IndexedCommentAction.edit,
                            child: Text('Editar comentario'),
                          ),
                          PopupMenuItem<_IndexedCommentAction>(
                            value: _IndexedCommentAction.delete,
                            child: Text('Eliminar comentario'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SelectableText(_entry.message),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Chip(
                        label: Text(_entry.channel),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        label: Text(
                          'Hace ${DateTime.now().difference(_entry.createdAt).inHours}h',
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (_entry.isEdited)
                        const Chip(
                          label: Text('Editado'),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _openThread,
                      child: const Text('Ir al hilo'),
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

enum _IndexedCommentAction { edit, delete }

class _IndexedThreadPage extends StatefulWidget {
  final AppMessageIndexEntry entry;

  const _IndexedThreadPage({required this.entry});

  @override
  State<_IndexedThreadPage> createState() => _IndexedThreadPageState();
}

class _IndexedThreadPageState extends State<_IndexedThreadPage> {
  static const String _currentUser = 'Tu';

  final ImagePicker _imagePicker = ImagePicker();
  late final List<_ThreadMessage> _thread;

  @override
  void initState() {
    super.initState();
    _thread = _buildThreadMessages();
  }

  List<_ThreadMessage> _buildThreadMessages() {
    return [
      _ThreadMessage(
        id: 't-1',
        author: 'Tu',
        message: widget.entry.message,
        createdAt: widget.entry.createdAt,
        isOriginal: true,
        level: 0,
      ),
      _ThreadMessage(
        id: 't-2',
        author: 'Laura Wind',
        message: 'Buen aporte, justo hoy tuvimos condiciones parecidas.',
        createdAt: widget.entry.createdAt.add(const Duration(minutes: 22)),
        parentId: 't-1',
        level: 1,
      ),
      _ThreadMessage(
        id: 't-3',
        author: 'Nico Foil',
        message: 'Confirmo, el tramo de media tarde estuvo mucho mejor.',
        createdAt: widget.entry.createdAt.add(const Duration(minutes: 47)),
        parentId: 't-1',
        level: 1,
      ),
      _ThreadMessage(
        id: 't-4',
        author: 'Tu',
        message: 'Gracias, voy a dejar otro update si cambia el parte.',
        createdAt: widget.entry.createdAt.add(
          const Duration(hours: 1, minutes: 6),
        ),
        parentId: 't-2',
        level: 2,
      ),
      _ThreadMessage(
        id: 't-5',
        author: 'Laura Wind',
        message: 'Dale, asi dejamos el hilo actualizado para todos.',
        createdAt: widget.entry.createdAt.add(
          const Duration(hours: 1, minutes: 21),
        ),
        parentId: 't-4',
        level: 3,
      ),
    ];
  }

  Future<void> _editThreadMessage(_ThreadMessage message) async {
    if (!message.isMine) {
      return;
    }

    String draft = message.message;
    String? attachedLabel;
    final edited = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> attachFromGallery() async {
              final selection =
                  await showModalBottomSheet<_IndexedAttachmentType>(
                    context: dialogContext,
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
                              ).pop(_IndexedAttachmentType.image),
                            ),
                            ListTile(
                              leading: const Icon(Icons.video_library_rounded),
                              title: const Text('Video desde galeria'),
                              onTap: () => Navigator.of(
                                sheetContext,
                              ).pop(_IndexedAttachmentType.video),
                            ),
                          ],
                        ),
                      );
                    },
                  );

              if (selection == null) {
                return;
              }

              final summary = await _pickThreadAttachmentSummary(
                isVideo: selection == _IndexedAttachmentType.video,
              );
              if (summary == null) {
                return;
              }

              setDialogState(() {
                attachedLabel = summary;
                draft = draft.trim().isEmpty
                    ? summary
                    : '${draft.trim()}\n$summary';
              });
            }

            return AlertDialog(
              title: const Text('Editar mensaje'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Adjuntar',
                        onPressed: attachFromGallery,
                        icon: const Icon(Icons.add_rounded),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          attachedLabel ?? 'Multimedia',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    initialValue: draft,
                    minLines: 3,
                    maxLines: 8,
                    onChanged: (value) {
                      draft = value;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(draft.trim()),
                  child: const Text('Editar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (edited == null || edited.isEmpty || !mounted) {
      return;
    }

    final index = _thread.indexWhere((item) => item.id == message.id);
    if (index < 0) {
      return;
    }
    setState(() {
      _thread[index] = _thread[index].copyWith(message: edited, isEdited: true);
    });
  }

  Future<String?> _pickThreadAttachmentSummary({required bool isVideo}) async {
    final XFile? picked = isVideo
        ? await _imagePicker.pickVideo(source: ImageSource.gallery)
        : await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return null;
    }

    final savedPath = await _storeThreadMediaLocally(picked);
    final fileName = savedPath.split(Platform.pathSeparator).last;
    return isVideo ? '[Video adjunto: $fileName]' : '[Foto adjunta: $fileName]';
  }

  Future<String> _storeThreadMediaLocally(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(
      '${appDir.path}${Platform.pathSeparator}thread_media',
    );
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final extension = _threadFileExtension(file.path);
    final output = File(
      '${mediaDir.path}${Platform.pathSeparator}thread_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await output.writeAsBytes(await file.readAsBytes(), flush: true);
    return output.path;
  }

  String _threadFileExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) {
      return '';
    }
    return path.substring(dot);
  }

  Future<void> _deleteThreadMessage(_ThreadMessage message) async {
    if (!message.isMine) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar mensaje'),
          content: const Text(
            'Se eliminara este mensaje del hilo. Esta accion no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final idsToDelete = <String>{message.id};
    var keepSearching = true;
    while (keepSearching) {
      keepSearching = false;
      for (final item in _thread) {
        final parentId = item.parentId;
        if (parentId != null &&
            idsToDelete.contains(parentId) &&
            !idsToDelete.contains(item.id)) {
          idsToDelete.add(item.id);
          keepSearching = true;
        }
      }
    }

    setState(() {
      _thread.removeWhere((item) => idsToDelete.contains(item.id));
    });
  }

  String _relative(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h';
    }
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Hilo completo')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _thread.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (context, index) {
          final item = _thread[index];
          return Card(
            color: item.isOriginal
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: item.level * 14.0),
                    padding: const EdgeInsets.only(left: AppSpacing.xs),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: item.level == 0
                              ? Colors.transparent
                              : Theme.of(context).colorScheme.outlineVariant,
                          width: item.level == 0 ? 0 : 2,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(item.author, style: textTheme.titleSmall),
                            const SizedBox(width: AppSpacing.xs),
                            if (item.isOriginal)
                              const Chip(
                                label: Text('Original'),
                                visualDensity: VisualDensity.compact,
                              ),
                            if (item.isEdited)
                              const Chip(
                                label: Text('Editado'),
                                visualDensity: VisualDensity.compact,
                              ),
                            const Spacer(),
                            Text(
                              _relative(item.createdAt),
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                            if (item.isMine)
                              PopupMenuButton<_ThreadMessageAction>(
                                tooltip: 'Opciones del mensaje',
                                onSelected: (action) async {
                                  switch (action) {
                                    case _ThreadMessageAction.edit:
                                      await _editThreadMessage(item);
                                    case _ThreadMessageAction.delete:
                                      await _deleteThreadMessage(item);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem<_ThreadMessageAction>(
                                    value: _ThreadMessageAction.edit,
                                    child: Text('Editar mensaje'),
                                  ),
                                  PopupMenuItem<_ThreadMessageAction>(
                                    value: _ThreadMessageAction.delete,
                                    child: Text('Eliminar mensaje'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SelectableText(item.message),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ThreadMessage {
  final String id;
  final String author;
  final String message;
  final DateTime createdAt;
  final String? parentId;
  final int level;
  final bool isOriginal;
  final bool isEdited;

  bool get isMine => author == _IndexedThreadPageState._currentUser;

  const _ThreadMessage({
    required this.id,
    required this.author,
    required this.message,
    required this.createdAt,
    this.parentId,
    this.level = 0,
    this.isOriginal = false,
    this.isEdited = false,
  });

  _ThreadMessage copyWith({String? message, bool? isEdited}) {
    return _ThreadMessage(
      id: id,
      author: author,
      message: message ?? this.message,
      createdAt: createdAt,
      parentId: parentId,
      level: level,
      isOriginal: isOriginal,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}

enum _ThreadMessageAction { edit, delete }
