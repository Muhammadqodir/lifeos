import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/finance/presentation/widgets/money_text.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/category_summary_dto.dart';

class PieChartSection extends StatefulWidget {
  final String title;
  final List<CategorySummaryDto> categories;
  final double totalAmount;
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
  int? selectedIndexSorted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.categories.isEmpty) {
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

    final sorted = _sortedCategories();

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
            child: Center(child: _buildSimplePieChart(context, sorted)),
          ),
          const SizedBox(height: 20),

          // Legend
          Text(
            'By categories',
            style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...sorted.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final percentage =
                (category.totalAmount.abs() /
                sorted.fold<double>(0, (a, b) => a + b.totalAmount.abs()) *
                100);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryLegendItem(
                category: category,
                percentage: percentage,
                currencyIcon: widget.currencyIcon,
                isSelected: selectedIndexSorted == index,
                onTap: () {
                  setState(() {
                    selectedIndexSorted = selectedIndexSorted == index
                        ? null
                        : index;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  List<CategorySummaryDto> _sortedCategories() {
    final List<CategorySummaryDto> sorted = List.from(widget.categories);
    sorted.sort((a, b) => b.totalAmount.abs().compareTo(a.totalAmount.abs()));
    return sorted;
  }

  Widget _buildSimplePieChart(
    BuildContext context,
    List<CategorySummaryDto> sorted,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final values = sorted.map((c) => c.totalAmount.abs()).toList();
        final sum = values.fold<double>(0, (a, b) => a + b);
        Color parseHex(String hex) {
          final clean = hex.replaceFirst('#', '');
          return Color(int.parse('0xFF$clean'));
        }

        List<PieChartSectionData> sections = List.generate(sorted.length, (i) {
          final value = values[i];
          final color = parseHex(sorted[i].categoryColor);
          final category = sorted[i];
          final percent = sum > 0 ? (value / sum * 100) : 0.0;
          final isSelected = selectedIndexSorted == i;
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
        });
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
                        selectedIndexSorted = null;
                        return;
                      }
                      selectedIndexSorted =
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
