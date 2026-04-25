import 'dart:async';

import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/account/account_deletion_request_presenter.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/account/account_deletion_request_repository.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  static const _deleteConfirmationPhrase = 'ELIMINAR CUENTA';

  final TextEditingController _confirmationController = TextEditingController();
  Timer? _countdownTimer;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isCancelling = false;
  String? _errorText;
  Map<String, dynamic>? _existingRequest;

  @override
  void initState() {
    super.initState();
    unawaited(_loadExistingRequest());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingRequest() async {
    final userId = AccountDeletionRequestRepository.currentUserId;
    if (userId == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorText = 'No se ha encontrado una sesion valida.';
      });
      return;
    }

    try {
      final row = await AccountDeletionRequestRepository.fetchLatestScheduledRequest();
      if (!mounted) {
        return;
      }
      setState(() {
        _existingRequest = row;
        _isLoading = false;
      });
      _syncCountdown();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorText =
            'No se pudo consultar el estado de la solicitud. Intentalo de nuevo.';
      });
      _syncCountdown();
    }
  }

  Future<void> _submitRequest() async {
    final userId = AccountDeletionRequestRepository.currentUserId;
    if (userId == null || _isSubmitting) {
      return;
    }

    final confirmationValue = _confirmationController.text.trim().toUpperCase();
    if (confirmationValue != _deleteConfirmationPhrase) {
      setState(() {
        _errorText =
            'Escribe exactamente "$_deleteConfirmationPhrase" para continuar.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await AccountDeletionRequestRepository.scheduleDeletion(
        confirmationNote: 'Self-service confirmed by typed phrase',
      );
      if (!mounted) {
        return;
      }
      await _loadExistingRequest();
      setState(() {
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _errorText =
            'No se pudo registrar la solicitud. Si ya existe una programada, anula primero la anterior.';
      });
    }
  }

  Future<void> _cancelRequest() async {
    final requestId = _existingRequest?['id'];
    if (requestId == null || _isCancelling || !_canCancelExistingRequest) {
      return;
    }

    setState(() {
      _isCancelling = true;
      _errorText = null;
    });

    try {
      await AccountDeletionRequestRepository.cancelRequest(requestId as String);
      if (!mounted) {
        return;
      }
      await _loadExistingRequest();
      setState(() {
        _isCancelling = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isCancelling = false;
        _errorText =
            'No se pudo anular la solicitud. Intentalo de nuevo dentro del plazo.';
      });
    }
  }

  bool get _canCancelExistingRequest {
    return AccountDeletionRequestPresenter.canCancel(
      _existingRequest?['execute_after'],
    );
  }

  Duration? _remainingTime() {
    return AccountDeletionRequestPresenter.remainingTime(
      _existingRequest?['execute_after'],
    );
  }

  String? _countdownLabel() {
    return AccountDeletionRequestPresenter.countdownLabel(
      _existingRequest?['execute_after'],
    );
  }

  Color? _countdownColor(BuildContext context) {
    return AccountDeletionRequestPresenter.countdownColor(
      context,
      _existingRequest?['execute_after'],
    );
  }

  void _syncCountdown() {
    _countdownTimer?.cancel();
    if (_remainingTime() == null) {
      return;
    }
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) {
        return;
      }
      if (_remainingTime() == null) {
        _countdownTimer?.cancel();
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final existingRequest = _existingRequest;
    final existingRequestStatus = AccountDeletionRequestPresenter.statusLabel(
      (existingRequest?['status'] as String?)?.trim(),
    ) ?? (existingRequest?['status'] as String?)?.trim();
    final executeAfter = existingRequest?['execute_after'];
    final canCancelExistingRequest = _canCancelExistingRequest;
    final countdownLabel = _countdownLabel();
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_forever_outlined,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Eliminar cuenta',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Confirma manualmente la eliminacion y abre un periodo de 7 dias antes del borrado definitivo.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: LinearProgressIndicator(),
                )
              else if (existingRequest != null) ...[
                Text(
                  'La eliminacion de esta cuenta ya esta programada.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado: ${existingRequestStatus ?? 'Pendiente'}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (countdownLabel != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          countdownLabel,
                          style: textTheme.bodySmall?.copyWith(
                            color: _countdownColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Creada: ${AccountDeletionRequestPresenter.formatTimestamp(existingRequest['created_at'])}',
                        style: textTheme.bodySmall,
                      ),
                      if (executeAfter != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Se eliminara automaticamente a partir de: ${AccountDeletionRequestPresenter.formatTimestamp(executeAfter)}',
                          style: textTheme.bodySmall,
                        ),
                        if (!canCancelExistingRequest) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'El plazo de anulacion ya ha terminado y la cuenta queda pendiente de ejecucion automatica.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'Escribe manualmente la frase de confirmacion para programar la eliminacion de la cuenta. Desde ese momento empezara el periodo de 7 dias en el que todavia podras anular la solicitud.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _confirmationController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Escribe "$_deleteConfirmationPhrase"',
                    hintText: _deleteConfirmationPhrase,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    if (_errorText != null) {
                      setState(() => _errorText = null);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'No hay revision manual. Si confirmas, la cuenta quedara programada para borrado automatico al terminar el plazo.',
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorText!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: OverflowBar(
                  alignment: MainAxisAlignment.end,
                  spacing: AppSpacing.sm,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                    if (!_isLoading && existingRequest != null)
                      FilledButton.tonal(
                        onPressed: _isCancelling || !canCancelExistingRequest
                            ? null
                            : _cancelRequest,
                        child: _isCancelling
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Anular solicitud'),
                      ),
                    if (!_isLoading && existingRequest == null)
                      FilledButton.tonal(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Solicitar eliminacion'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
