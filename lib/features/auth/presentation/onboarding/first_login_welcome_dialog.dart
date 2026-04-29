import 'dart:async';

import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/errors/profile_handle_taken_exception.dart';
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

  static Future<FirstLoginWelcomeResult> show(
    BuildContext context, {
    required UserProfileData initialData,
    required Future<bool> Function(UserProfileData) onSave,
    required Future<bool> Function(String handle) isHandleAvailable,
  }) async {
    final result = await showDialog<FirstLoginWelcomeResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => FirstLoginWelcomeDialog(
        initialData: initialData,
        onSave: onSave,
        isHandleAvailable: isHandleAvailable,
      ),
    );
    return result ?? FirstLoginWelcomeResult.skipped;
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
  Timer? _handleAvailabilityDebounce;
  _HandleAvailabilityState _handleAvailabilityState =
      _HandleAvailabilityState.idle;
  String? _lastCheckedHandle;
  bool _isSaving = false;
  bool _isSyncingHandle = false;
  String? _displayNameError;
  String? _handleError;

  @override
  void initState() {
    super.initState();
    _displayName = TextEditingController(text: widget.initialData.displayName);
    _handle = TextEditingController(
      text: _sanitizedHandleInput(widget.initialData.handle),
    );
    _handle.addListener(_syncHandleInput);
    _scheduleHandleAvailabilityCheck();
  }

  @override
  void dispose() {
    _handleAvailabilityDebounce?.cancel();
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
    _scheduleHandleAvailabilityCheck();
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

  String? _validateHandleFormat(String handle) {
    final value = handle.replaceFirst('@', '');
    if (value.isEmpty) {
      return 'Introduce un handle publico.';
    }
    if (_handleInvalidCharacters.hasMatch(value)) {
      return 'El handle no puede contener espacios en blanco.';
    }
    return null;
  }

  bool _validate() {
    final displayName = _displayName.text.trim();
    final handle = _normalizedHandle(_handle.text);
    final displayNameError = displayName.isEmpty
        ? 'Introduce un nombre visible.'
        : null;
    final handleError = _validateHandleFormat(handle);
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
    if (_handleAvailabilityState != _HandleAvailabilityState.available) {
      setState(() {
        _handleError = 'Comprueba que el handle este disponible.';
      });
      return;
    }
    setState(() {
      _isSaving = true;
    });

    final normalizedHandle = _normalizedHandle(_handle.text);
    final initialHandle = _normalizedHandle(widget.initialData.handle);
    if (normalizedHandle != initialHandle) {
      final bool available;
      try {
        available = await widget.isHandleAvailable(normalizedHandle);
      } catch (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _handleError = 'No se pudo validar el handle. Intentalo de nuevo.';
          _isSaving = false;
        });
        return;
      }
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

    bool saved;
    try {
      saved = await widget.onSave(_buildUpdatedProfile());
    } on ProfileHandleTakenException {
      if (!mounted) {
        return;
      }
      setState(() {
        _handleAvailabilityState = _HandleAvailabilityState.taken;
        _handleError = 'Este nombre de usuario ya esta ocupado.';
        _isSaving = false;
      });
      return;
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _handleError = 'No se pudo guardar el perfil. Intentalo de nuevo.';
        _isSaving = false;
      });
      return;
    }
    if (!mounted) {
      return;
    }
    if (saved) {
      Navigator.of(context).pop(FirstLoginWelcomeResult.completed);
      return;
    }
    setState(() {
      _isSaving = false;
    });
  }

  void _scheduleHandleAvailabilityCheck() {
    _handleAvailabilityDebounce?.cancel();
    final normalizedHandle = _normalizedHandle(_handle.text);
    final formatError = _validateHandleFormat(normalizedHandle);
    if (formatError != null) {
      setState(() {
        _handleAvailabilityState = _HandleAvailabilityState.idle;
        _lastCheckedHandle = null;
      });
      return;
    }

    setState(() {
      _handleAvailabilityState = _HandleAvailabilityState.checking;
      _lastCheckedHandle = normalizedHandle;
    });

    _handleAvailabilityDebounce = Timer(
      const Duration(milliseconds: 450),
      () => unawaited(_checkHandleAvailability(normalizedHandle)),
    );
  }

  Future<void> _checkHandleAvailability(String normalizedHandle) async {
    final initialHandle = _normalizedHandle(widget.initialData.handle);
    final bool available;
    try {
      available = normalizedHandle == initialHandle
          ? true
          : await widget.isHandleAvailable(normalizedHandle);
    } catch (_) {
      if (!mounted || _lastCheckedHandle != normalizedHandle) {
        return;
      }
      setState(() {
        _handleAvailabilityState = _HandleAvailabilityState.idle;
        _handleError = 'No se pudo validar el handle. Intentalo de nuevo.';
      });
      return;
    }
    if (!mounted || _lastCheckedHandle != normalizedHandle) {
      return;
    }
    setState(() {
      _handleAvailabilityState = available
          ? _HandleAvailabilityState.available
          : _HandleAvailabilityState.taken;
      _handleError = available
          ? null
          : 'Este nombre de usuario ya esta ocupado.';
    });
  }

  bool get _canSave {
    return !_isSaving &&
        _handleAvailabilityState == _HandleAvailabilityState.available;
  }

  String? get _handleHelperText {
    return switch (_handleAvailabilityState) {
      _HandleAvailabilityState.idle =>
        'Sera tu identidad publica dentro de la comunidad.',
      _HandleAvailabilityState.checking => 'Comprobando disponibilidad...',
      _HandleAvailabilityState.available => 'Handle disponible.',
      _HandleAvailabilityState.taken => null,
    };
  }

  Color? _handleHelperColor(BuildContext context) {
    return switch (_handleAvailabilityState) {
      _HandleAvailabilityState.available => Colors.green.shade700,
      _HandleAvailabilityState.checking => Theme.of(
        context,
      ).colorScheme.primary,
      _ => null,
    };
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
                  _field('Nombre', _displayName, errorText: _displayNameError),
                  _field(
                    'Handle',
                    _handle,
                    errorText: _handleError,
                    hintText: '@tu_handle',
                    helperText: _handleHelperText,
                    helperColor: _handleHelperColor(context),
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
                        : () => Navigator.of(
                            context,
                          ).pop(FirstLoginWelcomeResult.skipped),
                    child: const Text('Saltar'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _canSave ? _save : null,
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
    Color? helperColor,
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
          if (label == 'Handle') {
            _scheduleHandleAvailabilityCheck();
          }
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          helperText: helperText,
          helperStyle: helperColor == null
              ? null
              : TextStyle(color: helperColor),
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

enum _HandleAvailabilityState { idle, checking, available, taken }

enum FirstLoginWelcomeResult { completed, skipped }
