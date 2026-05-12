part of '../../../spot_detail_page.dart';

class _LiveMetricData {
  const _LiveMetricData({required this.label, required this.value});

  final String label;
  final String value;
}

class _LiveMetricsGrid extends StatelessWidget {
  const _LiveMetricsGrid({required this.metrics});

  final List<_LiveMetricData> metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.2,
      children: metrics
          .map(
            (metric) =>
                _LiveMetricCard(label: metric.label, value: metric.value),
          )
          .toList(growable: false),
    );
  }
}

class _LiveMetricCard extends StatelessWidget {
  const _LiveMetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
