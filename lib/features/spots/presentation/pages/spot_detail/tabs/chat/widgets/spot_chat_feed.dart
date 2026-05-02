import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class SpotChatFeed extends StatelessWidget {
  const SpotChatFeed({
    super.key,
    required this.maxHeight,
    required this.isLoading,
    required this.hasMessages,
    required this.scrollController,
    required this.messageChildren,
    this.errorMessage,
  });

  final double maxHeight;
  final bool isLoading;
  final bool hasMessages;
  final ScrollController scrollController;
  final List<Widget> messageChildren;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        0,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: _buildContent(textTheme),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TextTheme textTheme) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!hasMessages && errorMessage == null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          'Aun no hay mensajes en este spot.',
          style: textTheme.bodyMedium,
        ),
      );
    }
    if (!hasMessages && errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(errorMessage!, style: textTheme.bodyMedium),
      );
    }
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: ListView(
        controller: scrollController,
        primary: false,
        children: messageChildren,
      ),
    );
  }
}
