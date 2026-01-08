import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../data/models/sleep_summary_dto.dart';
import 'package:intl/intl.dart';

class SleepChartCard extends StatelessWidget {
  final SleepSummaryDto sleepSummary;
  final VoidCallback? onAddEntry;

  const SleepChartCard({
    super.key,
    required this.sleepSummary,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Duration (Last 7 Days)',
                      style: theme.typography.small.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Avg: ${sleepSummary.avgDurationHours.toStringAsFixed(1)} hrs',
                      style: theme.typography.xSmall.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
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

    final points = sleepSummary.points;

    // If no data, show empty chart with 7 days of 0 values
    if (points.isEmpty) {
      final now = DateTime.now();
      final emptyPoints = List.generate(7, (i) {
        return FlSpot(i.toDouble(), 0);
      });

      return LineChart(
        LineChartData(
          minY: 0,
          maxY: 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: colorScheme.border.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
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
                reservedSize: 30,
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
          lineBarsData: [
            LineChartBarData(
              spots: emptyPoints,
              isCurved: true,
              color: colorScheme.primary.withOpacity(0.3),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: colorScheme.primary.withOpacity(0.05),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
      );
    }

    // Fill missing days with 0 values
    final filledData = _fillMissingDays(points);

    // Create bar groups
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < filledData.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: filledData[i].durationHours,
              color: colorScheme.primary,
              width: 18,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    // Find max value for Y axis
    final values = filledData.map((p) => p.durationHours).toList();
    final maxY = values.isEmpty ? 10.0 : values.reduce((a, b) => a > b ? a : b);
    final yAxisMax = maxY > 0 ? (maxY + 2).ceilToDouble() : 10.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => colorScheme.background,
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 0,
            getTooltipItem:
                (
                  BarChartGroupData group,
                  int groupIndex,
                  BarChartRodData rod,
                  int rodIndex,
                ) {
                  return BarTooltipItem(
                    rod.toY.toStringAsFixed(1),
                    TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: ' hrs',
                        style: theme.typography.xSmall.copyWith(
                          color: colorScheme.mutedForeground,
                          fontWeight: FontWeight.normal,
                          fontSize: 8,
                        ),
                      ),
                    ],
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

  List<SleepSummaryPoint> _fillMissingDays(List<SleepSummaryPoint> points) {
    final now = DateTime.now();
    final dateMap = <String, SleepSummaryPoint>{};

    // Create a map of existing data
    for (final point in points) {
      dateMap[point.date] = point;
    }

    // Generate all 7 days
    final filled = <SleepSummaryPoint>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      if (dateMap.containsKey(dateStr)) {
        filled.add(dateMap[dateStr]!);
      } else {
        // Add missing day with 0 values
        filled.add(
          SleepSummaryPoint(date: dateStr, durationHours: 0.0, quality: null),
        );
      }
    }

    return filled;
  }
}
