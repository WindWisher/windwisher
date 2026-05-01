import 'package:flutter/material.dart';

enum SpotChatMessageAction { edit, delete }

Future<SpotChatMessageAction?> showSpotChatMessageActionsSheet(
  BuildContext context,
) {
  return showModalBottomSheet<SpotChatMessageAction>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Editar mensaje'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(SpotChatMessageAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Eliminar mensaje'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(SpotChatMessageAction.delete),
            ),
          ],
        ),
      );
    },
  );
}
