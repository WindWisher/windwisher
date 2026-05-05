part of '../spots_page.dart';

class _CustomMapCoordinateFields extends StatelessWidget {
  const _CustomMapCoordinateFields({
    required this.latController,
    required this.lonController,
    required this.latFocusNode,
    required this.lonFocusNode,
    required this.onApplyCoords,
  });

  final TextEditingController latController;
  final TextEditingController lonController;
  final FocusNode latFocusNode;
  final FocusNode lonFocusNode;
  final VoidCallback onApplyCoords;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CustomMapCoordinateField(
            controller: latController,
            focusNode: latFocusNode,
            textInputAction: TextInputAction.next,
            labelText: 'Latitud',
            hintText: '38.913972',
            onApplyCoords: onApplyCoords,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _CustomMapCoordinateField(
            controller: lonController,
            focusNode: lonFocusNode,
            textInputAction: TextInputAction.done,
            labelText: 'Longitud',
            hintText: '-0.073355',
            onApplyCoords: onApplyCoords,
          ),
        ),
      ],
    );
  }
}

class _CustomMapCoordinateField extends StatelessWidget {
  const _CustomMapCoordinateField({
    required this.controller,
    required this.focusNode,
    required this.textInputAction,
    required this.labelText,
    required this.hintText,
    required this.onApplyCoords,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final String labelText;
  final String hintText;
  final VoidCallback onApplyCoords;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          onApplyCoords();
        }
      },
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: textInputAction,
        decoration: InputDecoration(labelText: labelText, hintText: hintText),
        onSubmitted: (_) => onApplyCoords(),
        onEditingComplete: onApplyCoords,
      ),
    );
  }
}

class _CustomMapDialogActions extends StatelessWidget {
  const _CustomMapDialogActions({
    required this.canUsePoint,
    required this.onCancel,
    required this.onUsePoint,
  });

  final bool canUsePoint;
  final VoidCallback onCancel;
  final VoidCallback onUsePoint;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onCancel, child: const Text('Cancelar')),
        const SizedBox(width: AppSpacing.xs),
        FilledButton(
          onPressed: canUsePoint ? onUsePoint : null,
          child: const Text('Usar punto'),
        ),
      ],
    );
  }
}
