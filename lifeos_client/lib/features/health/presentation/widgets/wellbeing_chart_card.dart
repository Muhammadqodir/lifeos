import 'package:flutter/widgets.dart';
import 'package:lifeos_client/core/theme/app_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../data/models/wellbeing_summary_dto.dart';
import 'package:intl/intl.dart';

class WellbeingChartCard extends StatelessWidget {
  final WellbeingSummaryDto wellbeingSummary;
  final VoidCallback? onAddEntry;

  const WellbeingChartCard({
    super.key,
    required this.wellbeingSummary,
    this.onAddEntry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wellbeing (Last 7 Days)',
                      style: theme.typography.small.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedEnergy,
                          size: 14,
                          strokeWidth: 2,
                          color: AppColors.cyanColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Energy: ${wellbeingSummary.avgEnergy.toStringAsFixed(1)}',
                          style: theme.typography.xSmall.copyWith(
                            color: colorScheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(width: 16),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedAlert02,
                          size: 14,
                          strokeWidth: 2,
                          color: AppColors.roseColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stress: ${wellbeingSummary.avgStress.toStringAsFixed(1)}',
                          style: theme.typography.xSmall.copyWith(
                            color: colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onAddEntry != null)
                IconButton.primary(
                  size: ButtonSize.normal,
                  onPressed: onAddEntry,
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedAdd01,
                    size: 16,
                    strokeWidth: 3,
                    color: colorScheme.primaryForeground,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 150, child: _buildLineChart(context)),
        ],
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final points = wellbeingSummary.points;

    // If no data, show empty chart with 7 days of 0 values
    if (points.isEmpty) {
      final now = DateTime.now();

      final emptyBarGroups = <BarChartGroupData>[];
      for (int i = 0; i < 7; i++) {
        emptyBarGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: 0,
                color: AppColors.cyanColor,
                width: 14,
                borderRadius: BorderRadius.circular(12),
              ),
              BarChartRodData(
                toY: 0,
                color: AppColors.roseColor,
                width: 14,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
        );
      }

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: 0,
          maxY: 6,
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= 7) {
                    return const SizedBox.shrink();
                  }
                  final date = now.subtract(Duration(days: 6 - index));
                  final dayName = DateFormat('E').format(date);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dayName.substring(0, 2),
                      style: theme.typography.xSmall.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: emptyBarGroups,
          barTouchData: const BarTouchData(enabled: false),
        ),
      );
    }

    // Fill missing days with 0 values
    final filledData = _fillMissingDays(points);

    // Create bar groups with energy and stress bars
    final barGroups = <BarChartGroupData>[];
    final allValues = <double>[];

    for (int i = 0; i < filledData.length; i++) {
      final energy = filledData[i].energy?.toDouble() ?? 0.0;
      final stress = filledData[i].stress?.toDouble() ?? 0.0;

      allValues.add(energy);
      allValues.add(stress);

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: energy,
              color: AppColors.cyanColor,
              width: 14,
              borderRadius: BorderRadius.circular(12),
            ),
            BarChartRodData(
              toY: stress,
              color: AppColors.roseColor,
              width: 14,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
      );
    }

    // Calculate max Y value
    final maxY = allValues.isEmpty
        ? 6.0
        : allValues.reduce((a, b) => a > b ? a : b);
    final yAxisMax = maxY > 0 ? (maxY + 2).ceilToDouble() : 6.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => colorScheme.background,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 4),
            tooltipMargin: 0,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final index = group.x.toInt();
              if (index < 0 || index >= filledData.length) {
                return null;
              }
              final isEnergy = rodIndex == 0;
              final label = isEnergy ? 'Energy' : 'Stress';
              return BarTooltipItem(
                '$label: ${rod.toY.toStringAsFixed(0)}',
                TextStyle(
                  color: isEnergy ? AppColors.cyanColor : AppColors.roseColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        minY: 0,
        maxY: yAxisMax,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= filledData.length) {
                  return const SizedBox.shrink();
                }
                final date = DateTime.parse(filledData[index].date);
                final dayName = DateFormat('E').format(date);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dayName.substring(0, 2),
                    style: theme.typography.xSmall.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  List<WellbeingSummaryPoint> _fillMissingDays(
    List<WellbeingSummaryPoint> points,
  ) {
    final now = DateTime.now();
    final dateMap = <String, WellbeingSummaryPoint>{};

    // Create a map of existing data
    for (final point in points) {
      dateMap[point.date] = point;
    }

    // Generate all 7 days
    final filled = <WellbeingSummaryPoint>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      if (dateMap.containsKey(dateStr)) {
        filled.add(dateMap[dateStr]!);
      } else {
        // Add missing day with 0 values
        filled.add(
          WellbeingSummaryPoint(date: dateStr, energy: null, stress: null),
        );
      }
    }

    return filled;
  }
}
