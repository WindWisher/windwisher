part of '../../../spot_detail_page.dart';

class _HistoricalChartLegend extends StatelessWidget {
  const _HistoricalChartLegend({
    required this.showGust,
    required this.showForecast,
  });

  final bool showGust;
  final bool showForecast;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        const _HistoricalLegendChip(
          label: 'Viento real',
          color: Color(0xFF1F1F8F),
          style: _LegendStrokeStyle.solid,
        ),
        if (showGust)
          const _HistoricalLegendChip(
            label: 'Racha',
            color: Color(0xFFC2185B),
            style: _LegendStrokeStyle.solid,
          ),
        if (showForecast)
          const _HistoricalLegendChip(
            label: 'Forecast',
            color: Color(0xFFD84315),
            style: _LegendStrokeStyle.dashed,
          ),
      ],
    );
  }
}

enum _LegendStrokeStyle { solid, dashed }

class _HistoricalLegendChip extends StatelessWidget {
  const _HistoricalLegendChip({
    required this.label,
    required this.color,
    required this.style,
  });

  final String label;
  final Color color;
  final _LegendStrokeStyle style;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 10,
            child: CustomPaint(
              painter: _LegendStrokePainter(color: color, style: style),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendStrokePainter extends CustomPainter {
  const _LegendStrokePainter({required this.color, required this.style});

  final Color color;
  final _LegendStrokeStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    if (style == _LegendStrokeStyle.solid) {
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }
    const dash = 4.0;
    const gap = 3.0;
    var x = 0.0;
    while (x < size.width) {
      final end = math.min(size.width, x + dash);
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(end, size.height / 2),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _LegendStrokePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.style != style;
  }
}
