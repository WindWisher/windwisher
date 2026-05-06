import 'package:flutter/material.dart';

class ForecastTableCard extends StatelessWidget {
  const ForecastTableCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class ForecastMetricChip extends StatelessWidget {
  const ForecastMetricChip({
    super.key,
    required this.label,
    required this.value,
    this.backgroundColor,
  });

  final String label;
  final String value;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class ForecastPillChip extends StatelessWidget {
  const ForecastPillChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.fontWeight,
  });

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: foregroundColor,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

class ForecastInfoCard extends StatelessWidget {
  const ForecastInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tint.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tint),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tint,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ForecastDailySummaryCard extends StatelessWidget {
  const ForecastDailySummaryCard({
    super.key,
    required this.title,
    required this.lines,
    this.mutedLines = const <String>[],
    this.width = 172,
    this.padding = const EdgeInsets.all(10),
  });

  final String title;
  final List<String> lines;
  final List<String> mutedLines;
  final double width;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(line, style: textTheme.bodySmall),
            ),
          ),
          ...mutedLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForecastCompactLabelCell extends StatelessWidget {
  const ForecastCompactLabelCell(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        text,
        style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class ForecastCompactValueCell extends StatelessWidget {
  const ForecastCompactValueCell(
    this.text, {
    super.key,
    this.color,
    this.bold = false,
  });

  final String text;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );

    if (color == null) {
      return child;
    }

    return Container(color: color, child: child);
  }
}

class ForecastCompactDirectionCell extends StatelessWidget {
  const ForecastCompactDirectionCell({
    super.key,
    required this.degrees,
    required this.cardinalLabel,
  });

  final int? degrees;
  final String Function(double degrees) cardinalLabel;

  @override
  Widget build(BuildContext context) {
    if (degrees == null) {
      return const ForecastCompactValueCell('-');
    }

    final normalizedDegrees = ((degrees! % 360) + 360) % 360;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: ((normalizedDegrees - 45 + 180) * 3.1415926535897932) / 180,
            child: const Icon(Icons.near_me_rounded, size: 18),
          ),
          const SizedBox(height: 2),
          Text(
            cardinalLabel(normalizedDegrees.toDouble()),
            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
