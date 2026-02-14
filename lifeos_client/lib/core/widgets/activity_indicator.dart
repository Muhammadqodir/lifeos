import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ActivityIndicatorChart extends StatelessWidget {
  const ActivityIndicatorChart({
    super.key,
    required this.data,
    required this.startDate,
    required this.endDate,
  });
  final List<ActivityInficatorChartData>? data;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [SizedBox(height: 14), ..._buildWeekDays(theme)],
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(children: _buildMonths(theme)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMonths(ThemeData theme) {
    // Get all weeks between start and end date
    List<List<DateTime?>> weeks = _generateWeeks();

    // Group weeks by month
    Map<String, List<List<DateTime?>>> monthWeeks = {};
    List<String> monthOrder = [];

    for (var week in weeks) {
      DateTime? firstDay = week.firstWhere(
        (day) => day != null,
        orElse: () => null,
      );

      if (firstDay != null) {
        String monthKey = DateFormat('MMM yyyy').format(firstDay);
        if (!monthWeeks.containsKey(monthKey)) {
          monthWeeks[monthKey] = [];
          monthOrder.add(monthKey);
        }
        monthWeeks[monthKey]!.add(week);
      }
    }

    // Build columns with month labels centered
    List<Widget> allColumns = [];

    for (String monthKey in monthOrder) {
      List<List<DateTime?>> weeksInMonth = monthWeeks[monthKey]!;
      int weekCount = weeksInMonth.length;
      String monthLabel = monthKey.split(' ').first; // Get just "MMM" part

      // Build week columns for this month
      List<Widget> monthColumns = [];

      for (int i = 0; i < weekCount; i++) {
        Widget label;

        // Show month label only in the middle week
        if (i == weekCount ~/ 2) {
          label = Text(
            monthLabel,
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.mutedForeground,
              fontSize: 11,
            ),
          );
        } else {
          label = const SizedBox(height: 14);
        }

        monthColumns.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              children: [label, _buildWeekColumn(theme, weeksInMonth[i])],
            ),
          ),
        );
      }

      allColumns.addAll(monthColumns);
    }

    return allColumns;
  }

  List<List<DateTime?>> _generateWeeks() {
    List<List<DateTime?>> weeks = [];

    // Find the Monday of the week containing startDate
    DateTime current = startDate;
    int dayOfWeek = current.weekday; // Monday = 1, Sunday = 7
    DateTime weekStart = current.subtract(Duration(days: dayOfWeek - 1));

    while (weekStart.isBefore(endDate) || weekStart.isAtSameMomentAs(endDate)) {
      List<DateTime?> week = [];

      for (int i = 0; i < 7; i++) {
        DateTime day = weekStart.add(Duration(days: i));

        // Only include days within the start and end date range
        if ((day.isAfter(startDate) || day.isAtSameMomentAs(startDate)) &&
            (day.isBefore(endDate) || day.isAtSameMomentAs(endDate))) {
          week.add(day);
        } else {
          week.add(null); // Empty cell for days outside range
        }
      }

      weeks.add(week);
      weekStart = weekStart.add(const Duration(days: 7));
    }

    return weeks;
  }

  Widget _buildWeekColumn(ThemeData theme, List<DateTime?> week) {
    return Column(
      children: week.map((day) {
        if (day == null) {
          return Container(
            margin: const EdgeInsets.all(1),
            width: 14,
            height: 14,
          );
        }

        return Container(
          margin: const EdgeInsets.all(1),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: _isActivityExists(day) ? theme.colorScheme.primary : theme.colorScheme.muted,
            borderRadius: BorderRadius.circular(3),
          ),
          // child: Center(
          //   child: Text(
          //     '${day.day}',
          //     style: theme.typography.xSmall.copyWith(
          //       color: theme.colorScheme.primary,
          //       fontSize: 10,
          //     ),
          //   ),
          // ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildWeekDays(ThemeData theme) {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekDays
        .map(
          (day) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(
              day,
              style: theme.typography.xSmall.copyWith(
                color: theme.colorScheme.mutedForeground,
                fontSize: 11,
              ),
            ),
          ),
        )
        .toList();
  }

  bool _isActivityExists(DateTime date) {
    if (data == null) return false;
    return data!.any(
      (entry) =>
          entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day,
    );
  }
}

class ActivityInficatorChartData<T> {
  final DateTime date;
  final T data;

  ActivityInficatorChartData({required this.date, required this.data});
}
