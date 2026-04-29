import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final TextEditingController _suggestionController = TextEditingController();
  bool _isSendingSuggestion = false;

  Future<void> _sendSuggestion() async {
    final message = _suggestionController.text.trim();
    if (message.isEmpty || _isSendingSuggestion) {
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesion para enviar sugerencias.')),
      );
      return;
    }

    setState(() => _isSendingSuggestion = true);
    try {
      await Supabase.instance.client.from('user_feedback').insert({
        'user_id': user.id,
        'message': message,
      });
      _suggestionController.clear();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sugerencia enviada. El equipo podra revisarla.'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo enviar la sugerencia. Intentalo de nuevo.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingSuggestion = false);
      }
    }
  }

  @override
  void dispose() {
    _suggestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final faqs = [
      _FaqItem(
        question: 'Como vinculo mi dispositivo wearable?',
        answer:
            'Ve a la pestaña Session y pulsa el boton + para vincular un nuevo dispositivo. Selecciona el tipo de dispositivo y sigue las instrucciones de emparejamiento.',
      ),
      _FaqItem(
        question: 'Que significan los valores de Big Air Score?',
        answer:
            'El Big Air Score es una metrica que combina la altura maxima del salto, el hangtime maximo y la tasa de aterrizajes limpios para resumir el rendimiento Big Air de una sesion.',
      ),
      _FaqItem(
        question: 'Como cambio las unidades de medicion?',
        answer:
            'En Ajustes > Unidades puedes seleccionar tu preferencia para velocidad, distancia, temperatura y altura.',
      ),
      _FaqItem(
        question: 'Mis datos se guardan automaticamente?',
        answer:
            'Si, todos los datos de sesion se sincronizan automaticamente cuando conectas tu dispositivo wearable.',
      ),
      _FaqItem(
        question: 'Como contacto con soporte?',
        answer:
            'Puedes escribirnos desde la seccion Mensajes en tu perfil o enviar una sugerencia.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: kAppBouncingScrollPhysics,
        children: [
          ...faqs.map(
            (faq) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                childrenPadding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                ),
                title: Text(
                  faq.question,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      faq.answer,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Buzon de sugerencias', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Envianos tus ideas para mejorar la app',
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _suggestionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu sugerencia...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSendingSuggestion ? null : _sendSuggestion,
                      child: _isSendingSuggestion
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Enviar sugerencia'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  _FaqItem({required this.question, required this.answer});
}
