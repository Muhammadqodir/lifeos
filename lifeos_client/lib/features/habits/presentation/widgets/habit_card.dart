import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/utils/color_utils.dart';
import '../../data/models/habit_dto.dart';
import '../pages/habit_stat_page.dart';

/// Habit row: colour swatch, streak and frequency, and a check-in button
/// tinted with the habit's colour.
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

  @override
  Widget build(BuildContext context) {
    final habitColor = parseHexColor(habit.color);
    final isCompleted = habit.isCompletedToday ?? false;
    final streak = habit.currentStreak ?? 0;

    return AppListTile(
      leading: LeadingTile.icon(HugeIcons.strokeRoundedFire, color: habitColor),
      title: habit.title,
      subtitle: [
        if (streak > 0) '$streak day streak' else 'No streak yet',
        _frequencyLabel(),
      ].join(' · '),
      loading: isUpdating,
      trailing: HabitCheckButton(
        color: habitColor,
        done: isCompleted,
        onTap: isCompleted ? null : onCheckIn,
      ),
      onTap: () => Navigator.of(
        context,
      ).push(CupertinoPageRoute(builder: (_) => HabitStatPage(habit: habit))),
    );
  }

  String _frequencyLabel() => switch (habit.frequency) {
    'daily' => 'Daily',
    'weekly' => 'Weekly',
    'monthly' => 'Monthly',
    _ => habit.frequency,
  };
}

/// Circular check-in control. Filled with the habit colour once done.
class HabitCheckButton extends StatelessWidget {
  const HabitCheckButton({
    super.key,
    required this.color,
    required this.done,
    this.onTap,
  });

  final Color color;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    return Tooltip(
      tooltip: (context) =>
          TooltipContainer(child: Text(done ? 'Done today' : 'Check in')),
      child: AppPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        semanticLabel: done ? 'Done today' : 'Check in',
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: AnimatedContainer(
          duration: AppDurations.base,
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? color : semantic.tint(color),
            border: Border.all(color: color, width: 1.6),
          ),
          child: Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedTick02,
              size: 15,
              strokeWidth: 2.5,
              color: done ? const Color(0xFFFFFFFF) : color,
            ),
          ),
        ),
      ),
    );
  }
}
