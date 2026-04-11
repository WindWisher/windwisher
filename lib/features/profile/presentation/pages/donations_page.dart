import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';

class DonationsPage extends StatelessWidget {
  const DonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Donaciones')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: kAppBouncingScrollPhysics,
        children: [
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(Icons.favorite, size: 64, color: colorScheme.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Apoya WindWisher',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tu contribucion nos ayuda a seguir mejorando',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Por que donating?', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _buildBenefitCard(
            context,
            Icons.cloud,
            'Pronosticos mas precisos',
            'Con tu apoyo podemos integrar mas fuentes de datos meteorologicos y mejorar la precision de las predicciones.',
          ),
          _buildBenefitCard(
            context,
            Icons.phone_android,
            'Nuevas funcionalidades',
            'Tu donacion nos permite desarrollar nuevas caracteristicas que la comunidad pide.',
          ),
          _buildBenefitCard(
            context,
            Icons.group,
            'Comunidad activa',
            'Juntos creamos una comunidad de kitesurfers que comparten conocimiento y experiencias.',
          ),
          _buildBenefitCard(
            context,
            Icons.code,
            'Software libre',
            'WindWisher es open source. Tu apoyo ayuda a mantener el proyecto vivo y gratuito.',
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            color: colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Text(
                    'Elige tu contribucion',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildDonationOption(
                    context,
                    '3.99',
                    'Cafecito',
                    '☕ Un cafe para el equipo',
                  ),
                  _buildDonationOption(
                    context,
                    '9.99',
                    'Mensual',
                    '🌊 Un spot nuevo al mes',
                  ),
                  _buildDonationOption(
                    context,
                    '24.99',
                    'Unico',
                    '🏄 Tu equipo soñado',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Gracias por tu apoyo! Esta funcionalidad esta en desarrollo.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.favorite),
                      label: const Text('Donar ahora'),
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
                  Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green.shade600),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Transparencia',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Cada euro se invertido en mejorar la app. Puedes seguir nuestro progreso en GitHub y redes sociales.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Hecho con ❤️ para la comunidad de kitesurf',
              style: textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationOption(
    BuildContext context,
    String price,
    String title,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Seleccionado: $title - $price')),
          );
        },
      ),
    );
  }
}
