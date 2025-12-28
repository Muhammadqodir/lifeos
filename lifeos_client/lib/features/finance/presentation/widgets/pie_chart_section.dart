import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/category_summary_dto.dart';

class PieChartSection extends StatelessWidget {
  final String title;
  final List<CategorySummaryDto> categories;
  final String totalAmount;
  final String currencyIcon;

  const PieChartSection({
    super.key,
    required this.title,
    required this.categories,
    required this.totalAmount,
    required this.currencyIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pie Chart Visualization
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: colorScheme.muted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _buildSimplePieChart(context),
              ),
            ),
            const SizedBox(height: 20),

            // Legend
            Text(
              'Breakdown',
              style: theme.typography.small.copyWith(
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            ...categories.asMap().entries.map((entry) {
              final category = entry.value;
              final percentage =
                  (double.parse(category.totalAmount) / double.parse(totalAmount) *
                      100);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategoryLegendItem(
                  category: category,
                  percentage: percentage,
                  currencyIcon: currencyIcon,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSimplePieChart(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        // Compute totals from category amounts to avoid division by zero
        final values = categories
            .map((c) => double.tryParse(c.totalAmount) ?? 0)
            .toList();
        final sum = values.fold<double>(0, (a, b) => a + b);

        // Parse colors from category hex, fallback palette when needed
        Color _parseHex(String hex) {
          final clean = hex.replaceFirst('#', '');
          return Color(int.parse('0xFF$clean'));
        }
        List<PieChartSectionData> sections = List.generate(categories.length, (i) {
          final value = values[i];
          final color = _parseHex(categories[i].categoryColor);
          final percent = sum > 0 ? (value / sum * 100) : 0.0;

          return PieChartSectionData(
            color: color,
            value: value,
            title: '${percent.toStringAsFixed(0)}%',
            titleStyle: theme.typography.small.copyWith(
              color: theme.colorScheme.cardForeground,
              fontWeight: FontWeight.bold,
            ),
            radius: 60,
          );
        });

        return Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total',
                  style: theme.typography.small.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                Text(
                  '$currencyIcon$totalAmount',
                  style: theme.typography.base.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CategoryLegendItem extends StatelessWidget {
  final CategorySummaryDto category;
  final double percentage;
  final String currencyIcon;

  const _CategoryLegendItem({
    required this.category,
    required this.percentage,
    required this.currencyIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Color(int.parse('0xFF${category.categoryColor.replaceFirst('#', '')}')),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.categoryTitle,
                style: theme.typography.base,
              ),
              Text(
                '${percentage.toStringAsFixed(1)}% • ${category.transactionCount} transactions',
                style: theme.typography.small.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          '$currencyIcon ${category.totalAmount}',
          style: theme.typography.base.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
 
