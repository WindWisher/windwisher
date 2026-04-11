import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';

Future<bool> showConfirmDeleteItemDialog({
  required BuildContext context,
  required String itemLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: Text('Seguro que quieres eliminar $itemLabel?'),
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

  return result ?? false;
}

Future<void> showGearSetupDetailsDialog({
  required BuildContext context,
  required GearSetup setup,
  KiteItem? kite,
  BoardItem? board,
  BarItem? bar,
  HarnessItem? harness,
  WetsuitItem? wetsuit,
  HelmetItem? helmet,
  VestItem? vest,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(setup.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kite != null)
                Text('Cometa: ${kite.brand} ${kite.model} ${kite.sizeMeters}m'),
              if (board != null)
                Text(
                  board.sizeCm.trim().isEmpty
                      ? 'Tabla: ${board.brand} ${board.model}'
                      : 'Tabla: ${board.brand} ${board.model} ${board.sizeCm}cm',
                ),
              if (bar != null)
                Text(
                  'Barra: ${bar.brand} ${bar.model} · ${bar.lineLengthMeters}m/${bar.widthCm}cm',
                ),
              if (harness != null)
                Text(
                  'Arnes: ${harness.brand} ${harness.model} · ${harness.size}',
                ),
              if (wetsuit != null)
                Text(
                  'Traje: ${wetsuit.brand} ${wetsuit.model} · ${wetsuit.thickness} · ${wetsuit.size}',
                ),
              if (helmet != null)
                Text('Casco: ${helmet.brand} ${helmet.model} (${helmet.year})'),
              if (vest != null)
                Text(
                  'Chaleco: ${vest.brand} ${vest.model} · ${vest.size} (${vest.year})',
                ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}
