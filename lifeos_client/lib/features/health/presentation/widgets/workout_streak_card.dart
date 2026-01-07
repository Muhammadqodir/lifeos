import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../data/models/workout_summary_dto.dart';
import 'package:intl/intl.dart';

class WorkoutStreakCard extends StatelessWidget {
  final WorkoutSummaryDto workoutSummary;
  final VoidCallback? onStartWorkout;

  const WorkoutStreakCard({
    super.key,
    required this.workoutSummary,
    this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Fill missing days
    final filledSessions = _fillMissingDays(workoutSummary.sessions);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Workout Streak',
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: workoutSummary.currentStreak > 0
                      ? colorScheme.muted
                      : colorScheme.muted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedFire02,
                      size: 16,
                      strokeWidth: 2,
                      color: workoutSummary.currentStreak > 0
                          ? colorScheme.primary
                          : colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${workoutSummary.currentStreak} day${workoutSummary.currentStreak != 1 ? 's' : ''}',
                      style: theme.typography.small.copyWith(
                        color: workoutSummary.currentStreak > 0
                            ? colorScheme.primary
                            : colorScheme.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Week day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: filledSessions.map((session) {
              final date = DateTime.parse(session.date);
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
          // Workout indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: filledSessions.map((session) {
              return Expanded(
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: session.hasSession
                          ? colorScheme.primary
                          : colorScheme.muted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: session.hasSession
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
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Start workout button
          if (onStartWorkout != null)
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: onStartWorkout,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedPlay,
                      size: 18,
                      strokeWidth: 2.5,
                      color: colorScheme.primaryForeground,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Start Workout',
                      style: theme.typography.small.copyWith(
                        color: colorScheme.primaryForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<WorkoutSessionPoint> _fillMissingDays(
    List<WorkoutSessionPoint> sessions,
  ) {
    final now = DateTime.now();
    final dateMap = <String, WorkoutSessionPoint>{};

    // Create a map of existing data
    for (final session in sessions) {
      dateMap[session.date] = session;
    }

    // Generate all 7 days
    final filled = <WorkoutSessionPoint>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      if (dateMap.containsKey(dateStr)) {
        filled.add(dateMap[dateStr]!);
      } else {
        // Add missing day with no session
        filled.add(WorkoutSessionPoint(date: dateStr, hasSession: false));
      }
    }

    return filled;
  }
}
