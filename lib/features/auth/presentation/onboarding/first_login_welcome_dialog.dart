import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';

class FirstLoginWelcomeDialog extends StatefulWidget {
  const FirstLoginWelcomeDialog({
    super.key,
    required this.initialData,
    required this.onSave,
    required this.isHandleAvailable,
  });

  final UserProfileData initialData;
  final Future<bool> Function(UserProfileData) onSave;
  final Future<bool> Function(String handle) isHandleAvailable;

  static Future<bool> show(
    BuildContext context, {
    required UserProfileData initialData,
    required Future<bool> Function(UserProfileData) onSave,
    required Future<bool> Function(String handle) isHandleAvailable,
  }) async {
    final completed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => FirstLoginWelcomeDialog(
        initialData: initialData,
        onSave: onSave,
        isHandleAvailable: isHandleAvailable,
      ),
    );
    return completed ?? false;
  }

  @override
  State<FirstLoginWelcomeDialog> createState() =>
      _FirstLoginWelcomeDialogState();
}

class _FirstLoginWelcomeDialogState extends State<FirstLoginWelcomeDialog> {
  static final RegExp _handleInvalidCharacters = RegExp(r'\s');
  static final RegExp _handleCharacters = RegExp(r'[^\s@]');

  late final TextEditingController _displayName;
  late final TextEditingController _handle;
  bool _isSaving = false;
  bool _isSyncingHandle = false;
  String? _displayNameError;
  String? _handleError;

  @override
  void initState() {
    super.initState();
    _displayName = TextEditingController(text: widget.initialData.displayName);
    _handle = TextEditingController(text: _sanitizedHandleInput(widget.initialData.handle));
    _handle.addListener(_syncHandleInput);
  }

  @override
  void dispose() {
    _displayName.dispose();
    _handle.removeListener(_syncHandleInput);
    _handle.dispose();
    super.dispose();
  }

  void _syncHandleInput() {
    if (_isSyncingHandle) {
      return;
    }
    final sanitized = _sanitizedHandleInput(_handle.text);
    if (sanitized == _handle.text) {
      return;
    }
    _isSyncingHandle = true;
    _handle.value = TextEditingValue(
      text: sanitized,
      selection: TextSelection.collapsed(offset: sanitized.length),
    );
    _isSyncingHandle = false;
  }

  String _sanitizedHandleInput(String raw) {
    final buffer = StringBuffer();
    for (final rune in raw.runes) {
      final character = String.fromCharCode(rune);
      if (_handleCharacters.hasMatch(character)) {
        buffer.write(character);
      }
    }
    return '@${buffer.toString()}';
  }

  String _normalizedHandle(String raw) {
    final trimmed = raw.trim().replaceFirst('@', '').toLowerCase();
    return trimmed.isEmpty ? '' : '@$trimmed';
  }

  bool _validate() {
    final displayName = _displayName.text.trim();
    final handle = _normalizedHandle(_handle.text);
    final displayNameError = displayName.isEmpty
        ? 'Introduce un nombre visible.'
        : null;
    String? handleError;
    if (handle.replaceFirst('@', '').isEmpty) {
      handleError = 'Introduce un handle publico.';
    } else if (_handleInvalidCharacters.hasMatch(handle.replaceFirst('@', ''))) {
      handleError = 'El handle no puede contener espacios en blanco.';
    }
    setState(() {
      _displayNameError = displayNameError;
      _handleError = handleError;
    });
    return displayNameError == null && handleError == null;
  }

  UserProfileData _buildUpdatedProfile() {
    return widget.initialData.copyWith(
      displayName: _displayName.text.trim(),
      handle: _normalizedHandle(_handle.text),
    );
  }

  Future<void> _save() async {
    if (_isSaving || !_validate()) {
      return;
    }
    setState(() {
      _isSaving = true;
    });

    final normalizedHandle = _normalizedHandle(_handle.text);
    final initialHandle = _normalizedHandle(widget.initialData.handle);
    if (normalizedHandle != initialHandle) {
      final available = await widget.isHandleAvailable(normalizedHandle);
      if (!mounted) {
        return;
      }
      if (!available) {
        setState(() {
          _handleError = 'Este nombre de usuario ya esta ocupado.';
          _isSaving = false;
        });
        return;
      }
    }

    final saved = await widget.onSave(_buildUpdatedProfile());
    if (!mounted) {
      return;
    }
    if (saved) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                'Bienvenido a WindWisher',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  const Text(
                    'Antes de empezar, completa lo minimo de tu perfil para que no entres con datos vacios en la app.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _field(
                    'Nombre',
                    _displayName,
                    errorText: _displayNameError,
                  ),
                  _field(
                    'Handle',
                    _handle,
                    errorText: _handleError,
                    hintText: '@tu_handle',
                    helperText: 'Sera tu identidad publica dentro de la comunidad.',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Salir'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Text('Guardar y continuar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? errorText,
    String? hintText,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: controller,
        onChanged: (_) {
          if (label == 'Nombre' && _displayNameError != null) {
            setState(() {
              _displayNameError = null;
            });
          }
          if (label == 'Handle' && _handleError != null) {
            setState(() {
              _handleError = null;
            });
          }
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
