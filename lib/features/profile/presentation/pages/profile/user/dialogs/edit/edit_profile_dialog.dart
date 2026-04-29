import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/domain/errors/profile_handle_taken_exception.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/profile_media_image_provider.dart';

class EditProfileDialog extends StatefulWidget {
  final UserProfileData initialData;
  final Future<bool> Function(UserProfileData) onSave;
  final Future<bool> Function(String handle) isHandleAvailable;

  const EditProfileDialog({
    super.key,
    required this.initialData,
    required this.onSave,
    required this.isHandleAvailable,
  });

  static Future<void> show(
    BuildContext context, {
    required UserProfileData initialData,
    required Future<bool> Function(UserProfileData) onSave,
    required Future<bool> Function(String handle) isHandleAvailable,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditProfileDialog(
        initialData: initialData,
        onSave: onSave,
        isHandleAvailable: isHandleAvailable,
      ),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  static final RegExp _handleInvalidCharacters = RegExp(r'\s');
  static final RegExp _handleCharacters = RegExp(r'[^\s@]');

  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _displayName;
  late final TextEditingController _handle;
  late final TextEditingController _publicTagline;
  Timer? _handleAvailabilityDebounce;
  _HandleAvailabilityState _handleAvailabilityState =
      _HandleAvailabilityState.idle;
  String? _lastCheckedHandle;
  String? _avatarPath;
  String? _bannerPath;
  bool _isSaving = false;
  bool _isSyncingHandle = false;
  String? _displayNameError;
  String? _handleError;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _displayName = TextEditingController(text: data.displayName);
    _handle = TextEditingController(text: _sanitizedHandleInput(data.handle));
    _handle.addListener(_syncHandleInput);
    _publicTagline = TextEditingController(text: data.publicTagline);
    _avatarPath = data.avatarLocalPath;
    _bannerPath = data.bannerLocalPath;
    _scheduleHandleAvailabilityCheck();
  }

  @override
  void dispose() {
    _handleAvailabilityDebounce?.cancel();
    _displayName.dispose();
    _handle.removeListener(_syncHandleInput);
    _handle.dispose();
    _publicTagline.dispose();
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

  String? _validateHandle(String handle) {
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
    final handleError = _validateHandle(handle);

    setState(() {
      _displayNameError = displayNameError;
      _handleError = handleError;
    });

    return displayNameError == null && handleError == null;
  }

  UserProfileData _buildUpdatedProfile() {
    return UserProfileData(
      displayName: _displayName.text.trim(),
      handle: _normalizedHandle(_handle.text),
      publicTagline: _publicTagline.text.trim(),
      totalSessions: widget.initialData.totalSessions,
      waterHours: widget.initialData.waterHours,
      jumps: widget.initialData.jumps,
      topJump: widget.initialData.topJump,
      maxHangtime: widget.initialData.maxHangtime,
      avatarLocalPath: _avatarPath,
      bannerLocalPath: _bannerPath,
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
      final bool isAvailable;
      try {
        isAvailable = await widget.isHandleAvailable(normalizedHandle);
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
      if (!isAvailable) {
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
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isSaving = false;
    });
  }

  void _scheduleHandleAvailabilityCheck() {
    _handleAvailabilityDebounce?.cancel();
    final normalizedHandle = _normalizedHandle(_handle.text);
    final formatError = _validateHandle(normalizedHandle);
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

  Future<void> _pickProfileMedia({required bool isBanner}) async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    final savedPath = await _storeProfileMedia(picked, isBanner: isBanner);
    if (!mounted) {
      return;
    }
    setState(() {
      if (isBanner) {
        _bannerPath = savedPath;
      } else {
        _avatarPath = savedPath;
      }
    });
  }

  Future<String> _storeProfileMedia(
    XFile file, {
    required bool isBanner,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(
      '${appDir.path}${Platform.pathSeparator}profile_media',
    );
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final dot = file.path.lastIndexOf('.');
    final extension = (dot < 0 || dot == file.path.length - 1)
        ? ''
        : file.path.substring(dot);
    final output = File(
      '${mediaDir.path}${Platform.pathSeparator}${isBanner ? 'banner' : 'avatar'}_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await output.writeAsBytes(await file.readAsBytes(), flush: true);
    return output.path;
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int lines = 1,
    String? errorText,
    String? hintText,
    String? helperText,
    Color? helperColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: controller,
        minLines: lines,
        maxLines: lines,
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Editar usuario',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Foto y banner'),
                          const SizedBox(height: AppSpacing.sm),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: _bannerPath == null
                                    ? LinearGradient(
                                        colors: [
                                          Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondaryContainer,
                                        ],
                                      )
                                    : null,
                                image:
                                    profileMediaImageProvider(_bannerPath) ==
                                        null
                                    ? null
                                    : DecorationImage(
                                        image: profileMediaImageProvider(
                                          _bannerPath,
                                        )!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _pickProfileMedia(isBanner: true),
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Editar banner'),
                              ),
                              if (_bannerPath != null)
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _bannerPath = null;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                  label: const Text('Quitar banner'),
                                ),
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: profileMediaImageProvider(
                                  _avatarPath,
                                ),
                                child:
                                    profileMediaImageProvider(_avatarPath) ==
                                        null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _pickProfileMedia(isBanner: false),
                                icon: const Icon(Icons.account_circle_outlined),
                                label: const Text('Editar foto'),
                              ),
                              if (_avatarPath != null)
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _avatarPath = null;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                  label: const Text('Quitar foto'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _field('Nombre', _displayName, errorText: _displayNameError),
                  _field(
                    'Handle',
                    _handle,
                    errorText: _handleError,
                    hintText: '@tu_handle',
                    helperText: _handleHelperText,
                    helperColor: _handleHelperColor(context),
                  ),
                  _field('Tagline publica', _publicTagline, lines: 2),
                  FilledButton(
                    onPressed: _canSave ? _save : null,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Text('Guardar cambios'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _HandleAvailabilityState { idle, checking, available, taken }
