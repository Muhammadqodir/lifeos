import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/ui/ui.dart';
import 'package:lifeos_client/core/utils/color_utils.dart';
import 'package:lifeos_client/features/finance/presentation/providers/amount_visibility_provider.dart';
import 'package:lifeos_client/features/finance/presentation/widgets/money_text.dart';
import 'package:provider/provider.dart';
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
    if (widget.categories.isEmpty) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardHeader(title: widget.title),
            const EmptyState(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              icon: HugeIcon(icon: HugeIcons.strokeRoundedPieChart),
              title: 'No data',
              description: 'No transactions in this period.',
            ),
          ],
        ),
      );
    }

    final sorted = _sortedCategories();
    final sum = sorted.fold<double>(0, (a, b) => a + b.totalAmount.abs());
    final visible =
        context.watch<AmountVisibilityProvider?>()?.isVisible ?? true;

    final legend = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sorted.length; i++)
          AppListTile(
            leading: LeadingTile.emoji(
              sorted[i].categoryIcon,
              color: parseHexColor(sorted[i].categoryColor),
              size: 32,
            ),
            title: sorted[i].categoryTitle,
            subtitle:
                '${(sum == 0 ? 0 : sorted[i].totalAmount.abs() / sum * 100).toStringAsFixed(1)}% · '
                '${sorted[i].transactionCount} ${sorted[i].transactionCount == 1 ? 'transaction' : 'transactions'}',
            trailing: MoneyText(
              amount: sorted[i].totalAmount,
              currencyCode: widget.currencyIcon,
              size: MoneyTextSize.small,
              isVisible: visible,
            ),
            selected: selectedIndexSorted == i,
            borderRadius: context.theme.controlRadius,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            onTap: () => setState(
              () => selectedIndexSorted = selectedIndexSorted == i ? null : i,
            ),
          ),
      ],
    );

    final chart = SizedBox(
      height: 220,
      child: Center(child: _buildSimplePieChart(context, sorted)),
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: widget.title,
            subtitle:
                '${sorted.length} ${sorted.length == 1 ? 'category' : 'categories'}',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 620) {
                // Chart beside its legend on iPad / Mac.
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 260, child: chart),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: legend),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  chart,
                  const SizedBox(height: AppSpacing.lg),
                  legend,
                ],
              );
            },
          ),
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

        List<PieChartSectionData> sections = List.generate(sorted.length, (i) {
          final value = values[i];
          final color = parseHexColor(sorted[i].categoryColor);
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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MoneyText(
                  amount: widget.totalAmount.abs(),
                  currencyCode: widget.currencyIcon,
                  size: MoneyTextSize.large,
                  alignment: MainAxisAlignment.center,
                  isVisible:
                      context.watch<AmountVisibilityProvider?>()?.isVisible ??
                      true,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
