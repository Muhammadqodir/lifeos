import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/tappable.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/habits/presentation/pages/habit_stat_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class HabitCard extends StatelessWidget {
  final HabitDto habit;
  final VoidCallback onCheckIn;
  final bool isUpdating;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onCheckIn,
    this.isUpdating = false,
  });

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
    print(habit);

    return Tappable(
      lowerBound: 0.98,
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (context) => HabitStatPage(habit: habit)),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Color indicator
          Container(
            width: 4,
            height: 42,
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
          if (!isUpdating) ...[
            IconButton.ghost(
              size: ButtonSize.xSmall,
              icon: HugeIcon(
                icon: isCompleted
                    ? HugeIcons.strokeRoundedCheckmarkSquare02
                    : HugeIcons.strokeRoundedSquare,
                color: colorScheme.primary,
                strokeWidth: 2,
              ),
              onPressed: isCompleted ? null : onCheckIn,
            ),
          ] else ...[
            Row(
              children: [
                SizedBox(width: 12),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
          ],
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
