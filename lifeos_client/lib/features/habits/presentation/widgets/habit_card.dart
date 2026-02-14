import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/tappable.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/habits/presentation/pages/habit_stat_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class HabitCard extends StatelessWidget {
  final HabitDto habit;
  final VoidCallback onCheckIn;

  const HabitCard({super.key, required this.habit, required this.onCheckIn});

  Color _getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final habitColor = _getColorFromHex(habit.color);
    final isCompleted = habit.isCompletedToday ?? false;

    return Tappable(
      lowerBound: 0.98,
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => HabitStatPage(habit: habit),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color indicator
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: habitColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Stats row
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedFire,
                      size: 14,
                      color: colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${habit.currentStreak ?? 0} streak',
                      style: theme.typography.xSmall.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 12),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedClock01,
                      size: 14,
                      color: colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getFrequencyText(),
                      style: theme.typography.xSmall.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Check-in button
          IconButton.primary(
            size: ButtonSize.normal,
            onPressed: isCompleted ? null : onCheckIn,
            icon: HugeIcon(
              icon: isCompleted
                  ? HugeIcons.strokeRoundedCheckmarkCircle02
                  : HugeIcons.strokeRoundedCheckmarkCircle01,
              size: 20,
              color: isCompleted ? colorScheme.primary : colorScheme.background,
            ),
          ),
        ],
      ),
    );
  }

  String _getFrequencyText() {
    switch (habit.frequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return habit.frequency;
    }
  }
}
