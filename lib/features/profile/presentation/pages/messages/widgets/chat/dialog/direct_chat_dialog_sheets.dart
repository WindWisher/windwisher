import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/feed/direct_chat_message_view_model.dart';

Future<String?> showDirectChatMessageActionsSheet(
  BuildContext context,
  DirectChatMessageViewModel message,
) {
  return showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.type == DirectChatMessageTypeView.text)
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Editar mensaje'),
                onTap: () => Navigator.of(sheetContext).pop('edit'),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Eliminar mensaje'),
              onTap: () => Navigator.of(sheetContext).pop('delete'),
            ),
          ],
        ),
      );
    },
  );
}

Future<DirectChatMessageTypeView?> showDirectChatAttachmentSheet(
  BuildContext context,
) {
  return showModalBottomSheet<DirectChatMessageTypeView>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Foto desde galería'),
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(DirectChatMessageTypeView.image),
            ),
            ListTile(
              leading: const Icon(Icons.video_library_rounded),
              title: const Text('Vídeo desde galería'),
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(DirectChatMessageTypeView.video),
            ),
          ],
        ),
      );
    },
  );
}
