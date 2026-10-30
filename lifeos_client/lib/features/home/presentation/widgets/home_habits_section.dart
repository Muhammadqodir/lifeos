import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../injection.dart';
import '../../../habits/data/models/habit_dto.dart';
import '../../../habits/domain/habit_stats.dart';
import '../../../habits/domain/repositories/habits_repository.dart';
import '../../../habits/presentation/bloc/habits_list_bloc.dart';
import '../../../habits/presentation/pages/habits_main_page.dart';
import '../../../habits/presentation/widgets/habit_card.dart';

class HomeHabitsSection extends StatefulWidget {
  final List<HabitDto> habits;

  const HomeHabitsSection({super.key, required this.habits});

  @override
  State<HomeHabitsSection> createState() => _HomeHabitsSectionState();
}

class _HomeHabitsSectionState extends State<HomeHabitsSection> {
  @override
  Widget build(BuildContext context) {
    if (widget.habits.isEmpty) return const SizedBox.shrink();

    final done = widget.habits.where((h) => h.isCompletedToday ?? false).length;

    return AppListSection(
      title: 'Habits',
      headerTrailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$done of ${widget.habits.length} done',
            style: context.text.caption,
          ),
          const SizedBox(width: AppSpacing.xs),
          GhostButton(
            size: ButtonSize.small,
            density: ButtonDensity.compact,
            onPressed: () => _openAllHabits(context),
            child: const Text('View all'),
          ),
        ],
      ),
      children: [
        for (final habit in widget.habits)
          HabitCard(habit: habit, onCheckIn: () => _checkIn(context, habit.id)),
      ],
    );
  }

  Future<void> _openAllHabits(BuildContext context) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => BlocProvider<HabitsListBloc>(
          create: (_) => getIt<HabitsListBloc>(),
          child: const HabitsMainPage(),
        ),
      ),
    );
  }

  /// Saved on the device at once; Home and the habit list update by
  /// themselves.
  Future<void> _checkIn(BuildContext context, String habitId) async {
    try {
      await getIt<HabitsRepository>().createHabitEntry(
        habitId: habitId,
        date: HabitStats.todayKey(),
      );
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, "Couldn't check in", message: '$e');
      }
    }
  }
}
