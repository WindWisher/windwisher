import 'dart:io';

import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class SessionUploadDialog extends StatefulWidget {
  const SessionUploadDialog({
    super.key,
    required this.data,
    required this.onPickMedia,
  });

  final SessionUploadDialogData data;
  final Future<String?> Function(SessionMediaSelection selection) onPickMedia;

  static Future<SessionUploadDialogResult?> show(
    BuildContext context, {
    required SessionUploadDialogData data,
    required Future<String?> Function(SessionMediaSelection selection) onPickMedia,
  }) {
    return showDialog<SessionUploadDialogResult>(
      context: context,
      builder: (context) {
        return SessionUploadDialog(
          data: data,
          onPickMedia: onPickMedia,
        );
      },
    );
  }

  @override
  State<SessionUploadDialog> createState() => _SessionUploadDialogState();
}

class _SessionUploadDialogState extends State<SessionUploadDialog> {
  static const String _noGearValue = '__none__';

  late String _spot;
  late String _notes;
  late SessionMediaSelection _mediaSelection;
  late String? _sessionPhotoLocalPath;
  late String _selectedGearSetupId;

  @override
  void initState() {
    super.initState();
    _spot = widget.data.initialSpot;
    _notes = widget.data.initialNotes;
    _mediaSelection = widget.data.initialMediaSelection;
    _sessionPhotoLocalPath = widget.data.initialSessionPhotoLocalPath;
    _selectedGearSetupId = widget.data.initialGearSetupId ?? _noGearValue;
  }

  SessionGearSetupOptionData? get _selectedGearOption {
    if (_selectedGearSetupId == _noGearValue) {
      return null;
    }
    for (final option in widget.data.gearSetupOptions) {
      if (option.id == _selectedGearSetupId) {
        return option;
      }
    }
    return null;
  }

  Future<void> _selectMedia(SessionMediaSelection selection) async {
    final pickedPath = await widget.onPickMedia(selection);
    if (!mounted || pickedPath == null) {
      return;
    }
    setState(() {
      _mediaSelection = selection;
      _sessionPhotoLocalPath = pickedPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedGear = _selectedGearOption;

    return AlertDialog(
      title: Text(widget.data.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.data.showSpotField) ...[
              DropdownButtonFormField<String>(
                key: ValueKey(
                  'upload-spot-$_spot-${widget.data.spotOptions.length}',
                ),
                initialValue: _spot,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Spot',
                  border: OutlineInputBorder(),
                ),
                items: widget.data.spotOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _spot = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            TextFormField(
              minLines: 2,
              maxLines: 3,
              initialValue: _notes,
              decoration: InputDecoration(
                labelText: widget.data.notesLabel,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _notes = value;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              key: ValueKey(
                'upload-gear-$_selectedGearSetupId-${widget.data.gearSetupOptions.length}',
              ),
              initialValue: _selectedGearSetupId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Equipo utilizado (opcional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: _noGearValue,
                  child: Text('Sin equipación'),
                ),
                ...widget.data.gearSetupOptions.map(
                  (setup) => DropdownMenuItem<String>(
                    value: setup.id,
                    child: Text(setup.name),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedGearSetupId = value;
                });
              },
            ),
            if (selectedGear != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.checkroom_rounded, size: 18),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(child: Text(selectedGear.name)),
                  ],
                ),
              ),
              if (selectedGear.detailLines.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: selectedGear.detailLines
                        .map(
                          (line) => Text(
                            line,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
            ],
            if (widget.data.gearSetupOptions.isEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'No hay equipaciones personalizadas en Perfil > Mi equipo.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Imagen de sesión'),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      ChoiceChip(
                        label: const Text('Hacer foto'),
                        selected: _mediaSelection == SessionMediaSelection.camera,
                        onSelected: (_) => _selectMedia(SessionMediaSelection.camera),
                      ),
                      ChoiceChip(
                        label: const Text('Galería'),
                        selected:
                            _mediaSelection == SessionMediaSelection.gallery,
                        onSelected: (_) => _selectMedia(SessionMediaSelection.gallery),
                      ),
                    ],
                  ),
                  if (_sessionPhotoLocalPath != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 120,
                        child: Image.file(
                          File(_sessionPhotoLocalPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color:
                                  Theme.of(context).colorScheme.surfaceContainerHighest,
                              alignment: Alignment.center,
                              child: const Text(
                                'No se pudo cargar la foto seleccionada.',
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 16),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Foto seleccionada',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _mediaSelection = SessionMediaSelection.none;
                              _sessionPhotoLocalPath = null;
                            });
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Quitar foto'),
                        ),
                        Text(
                          'Para cambiarla, pulsa Hacer foto o Galería.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              SessionUploadDialogResult(
                spot: _spot,
                notes: _notes.trim(),
                mediaSelection: _mediaSelection,
                sessionPhotoLocalPath: _sessionPhotoLocalPath,
                gearSetupId:
                    _selectedGearSetupId == _noGearValue ? null : _selectedGearSetupId,
                gearSetupName: selectedGear?.name,
              ),
            );
          },
          child: Text(widget.data.submitLabel),
        ),
      ],
    );
  }
}
