import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windwisher/features/sessions/di/sessions_module.dart';
import 'package:windwisher/features/sessions/domain/ports/out/private_canonical_inbox_port.dart';
import 'package:windwisher/features/sessions/domain/services/private_canonical_validator.dart';

class PrivateCanonicalInboxPage extends StatefulWidget {
  const PrivateCanonicalInboxPage({
    required this.accountId,
    this.accountIdChanges,
    super.key,
  });

  final String accountId;
  final Stream<String?>? accountIdChanges;

  @override
  State<PrivateCanonicalInboxPage> createState() =>
      _PrivateCanonicalInboxPageState();
}

class _PrivateCanonicalInboxPageState extends State<PrivateCanonicalInboxPage> {
  static const _channel = MethodChannel('windwisher/private_canonical_import');
  PrivateCanonicalInboxPort? _inbox;
  List<PrivateCanonicalSession> _sessions = [];
  StreamSubscription<String?>? _accountSubscription;
  bool _accountActive = true;
  bool _busy = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _accountSubscription = widget.accountIdChanges?.listen(
      _handleAccountChange,
    );
    _load();
  }

  void _handleAccountChange(String? accountId) {
    if (accountId?.trim() == widget.accountId.trim()) {
      return;
    }
    _accountActive = false;
    if (!mounted) {
      return;
    }
    setState(() {
      _inbox = null;
      _sessions = const [];
      _busy = false;
      _message =
          'La cuenta ha cambiado. Cierra esta pantalla para abrir la bandeja correcta.';
    });
  }

  Future<void> _load() async {
    try {
      if (!Platform.isAndroid) throw UnsupportedError('Android only');
      final root = await _channel.invokeMethod<String>('privateDirectory');
      if (root == null) throw StateError('Missing private storage');
      final schema =
          jsonDecode(
                await rootBundle.loadString(
                  'assets/contracts/canonical-session-record.schema.json',
                ),
              )
              as Map<String, dynamic>;
      final inbox = SessionsModule.createPrivateCanonicalInbox(
        installationRootPath: root,
        accountId: widget.accountId,
        schema: schema,
      );
      final sessions = await inbox.list();
      if (mounted && _accountActive) {
        setState(() {
          _inbox = inbox;
          _sessions = sessions;
        });
      }
    } catch (_) {
      if (mounted && _accountActive) {
        setState(
          () => _message =
              'No se pudo abrir la bandeja privada. Disponible inicialmente en Android. No se ha borrado ningún archivo.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    if (!_accountActive || _inbox == null) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final bytes = await _channel.invokeMethod<Uint8List>('pickCanonical');
      if (bytes == null || !_accountActive) return;
      final added = await _inbox!.importBytes(bytes);
      final sessions = await _inbox!.list();
      if (mounted && _accountActive) {
        setState(() {
          _sessions = sessions;
          _message = added
              ? 'Sesión importada sólo en este dispositivo.'
              : 'Esta sesión ya estaba importada; no se ha duplicado.';
        });
      }
    } on FormatException catch (e) {
      if (mounted && _accountActive) {
        setState(() => _message = e.message);
      }
    } catch (_) {
      if (mounted && _accountActive) {
        setState(
          () => _message =
              'No se pudo importar el archivo. Los originales permanecen intactos.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _accountSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Bandeja privada del reloj')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Sólo local · Sin publicar · Sin sincronización con la nube',
        ),
        const SizedBox(height: 8),
        const Text(
          'Importa un archivo canónico .jsonl de WindWisher Watch. No admite archivos SurfR, FIT o GPX. Conserva una copia externa: esta bandeja se pierde al desinstalar la app.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _busy || !_accountActive || _inbox == null
              ? null
              : _import,
          icon: const Icon(Icons.file_open),
          label: const Text('Seleccionar archivo canónico'),
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(_message!),
          ),
        for (final session in _sessions)
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text('Sesión del ${session.endedAt}'),
              subtitle: Text(
                '${Duration(milliseconds: session.durationMs)} · ${session.recordCount} registros\nIntegridad verificada · Sólo local',
              ),
              onTap: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sesión privada importada'),
                  content: Text(
                    'Duración: ${Duration(milliseconds: session.durationMs)}\nRegistros: ${session.recordCount}\nArchivo original conservado íntegramente.\nNo se han calculado ni validado saltos.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
