import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/finance/presentation/widgets/money_text.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/category_summary_dto.dart';

class PieChartSection extends StatefulWidget {
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
  State<PieChartSection> createState() => _PieChartSectionState();
}

class _PieChartSectionState extends State<PieChartSection> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (double.parse(widget.totalAmount) <= 0 || widget.categories.isEmpty) {
      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: theme.typography.small.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedPieChart,
                    size: 48,
                    color: theme.colorScheme.mutedForeground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data',
                    style: theme.typography.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No transactions in this period',
                    style: theme.typography.xSmall.copyWith(
                      color: theme.colorScheme.mutedForeground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          // Pie Chart Visualization
          SizedBox(
            height: 200,
            child: Center(child: _buildSimplePieChart(context)),
          ),
          const SizedBox(height: 20),

          // Legend
          Text(
            'By categories',
            style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...widget.categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final percentage =
                (double.parse(category.totalAmount) /
                double.parse(widget.totalAmount) *
                100);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryLegendItem(
                category: category,
                percentage: percentage,
                currencyIcon: widget.currencyIcon,
                isSelected: selectedIndex == index,
                onTap: () {
                  setState(() {
                    selectedIndex = selectedIndex == index ? null : index;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSimplePieChart(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        // Compute totals from category amounts to avoid division by zero
        final values = widget.categories
            .map((c) => double.tryParse(c.totalAmount) ?? 0)
            .toList();
        final sum = values.fold<double>(0, (a, b) => a + b);

        // Parse colors from category hex, fallback palette when needed
        Color parseHex(String hex) {
          final clean = hex.replaceFirst('#', '');
          return Color(int.parse('0xFF$clean'));
        }

        List<PieChartSectionData> sections = List.generate(
          widget.categories.length,
          (i) {
            final value = values[i];
            final color = parseHex(widget.categories[i].categoryColor);
            final category = widget.categories[i];
            final percent = sum > 0 ? (value / sum * 100) : 0.0;
            final isSelected = selectedIndex == i;

            return PieChartSectionData(
              color: color,
              value: value,
              title: '${category.categoryIcon}${percent.toStringAsFixed(1)}%',
              titleStyle: theme.typography.xSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              radius: isSelected ? 65 : 60,
            );
          },
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                borderData: FlBorderData(show: false),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        selectedIndex = null;
                        return;
                      }
                      selectedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
              ),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryLegendItem({
    required this.category,
    required this.percentage,
    required this.currencyIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 2,
                )
              : Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.0),
                  width: 2,
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Color(
                  int.parse(
                    '0xFF${category.categoryColor.replaceFirst('#', '')}',
                  ),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.categoryIcon + category.categoryTitle,
                    style: theme.typography.small.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}% • ${category.transactionCount}',
                    style: theme.typography.xSmall,
                  ),
                ],
              ),
            ),
            MoneyText(
              amount: category.totalAmount,
              currencyCode: currencyIcon,
              size: MoneyTextSize.small,
            ),
          ],
        ),
      ),
    );
  }
}
