import 'package:lifeos_client/core/ui/ui.dart';
import 'package:lifeos_client/core/widgets/tappable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

/// A data point representing activity on a specific date
class StreakDataPoint {
  final String date; // Format: 'yyyy-MM-dd'
  final bool hasActivity;

  const StreakDataPoint({required this.date, required this.hasActivity});
}

/// A reusable streak card widget that displays a week view of activities
class StreakCard extends StatelessWidget {
  /// Title of the streak card
  final String title;

  /// Current streak count
  final int currentStreak;

  /// List of data points for the past 7 days
  final List<StreakDataPoint> dataPoints;

  /// Optional callback when a day is tapped
  final void Function(StreakDataPoint)? onDayTap;

  /// Optional child widget to display below the streak visualization
  /// (e.g., action buttons)
  final Widget? child;

  /// Label for streak count (default: 'day')
  final String streakLabel;

  const StreakCard({
    super.key,
    required this.title,
    required this.currentStreak,
    required this.dataPoints,
    this.onDayTap,
    this.child,
    this.streakLabel = 'day',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Fill missing days to ensure 7 days are shown
    final filledDataPoints = _fillMissingDays(dataPoints);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: title,
            subtitle: 'Last 7 days',
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            trailing: AppBadge(
              label: '$currentStreak $streakLabel${currentStreak != 1 ? 's' : ''}',
              icon: HugeIcons.strokeRoundedFire02,
              color: currentStreak > 0
                  ? context.semantic.warning
                  : colorScheme.mutedForeground,
            ),
          ),
          // Week day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: filledDataPoints.map((dataPoint) {
              final date = DateTime.parse(dataPoint.date);
              final dayName = DateFormat('E').format(date);
              return Expanded(
                child: Center(
                  child: Text(
                    dayName.substring(0, 2),
                    style: theme.typography.xSmall.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Activity indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: filledDataPoints.map((dataPoint) {
              return Expanded(
                child: Center(
                  child: Tappable(
                    onTap: () {
                      if (onDayTap != null) {
                        onDayTap!(dataPoint);
                      }
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: dataPoint.hasActivity
                            ? colorScheme.primary
                            : colorScheme.muted,
                        borderRadius: theme.controlRadius,
                      ),
                      child: dataPoint.hasActivity
                          ? Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedTick02,
                                size: 18,
                                color: colorScheme.primaryForeground,
                                strokeWidth: 3,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (child != null) ...[const SizedBox(height: 20), child!],
        ],
      ),
    );
  }

  List<StreakDataPoint> _fillMissingDays(List<StreakDataPoint> dataPoints) {
    final now = DateTime.now();
    final dateMap = <String, StreakDataPoint>{};

    // Create a map of existing data
    for (final point in dataPoints) {
      dateMap[point.date] = point;
    }

    // Generate all 7 days
    final filled = <StreakDataPoint>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      if (dateMap.containsKey(dateStr)) {
        filled.add(dateMap[dateStr]!);
      } else {
        // Add missing day with no activity
        filled.add(StreakDataPoint(date: dateStr, hasActivity: false));
      }
    }

    return filled;
  }
}
