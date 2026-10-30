import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../injection.dart';
import '../../../habits/data/models/habit_dto.dart';
import '../../../habits/presentation/bloc/habits_list_bloc.dart';
import '../../../habits/presentation/bloc/log_entry_bloc.dart';
import '../../../habits/presentation/bloc/log_entry_event.dart';
import '../../../habits/presentation/bloc/log_entry_state.dart';
import '../../../habits/presentation/pages/habits_main_page.dart';
import '../../../habits/presentation/widgets/habit_card.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';

class HomeHabitsSection extends StatefulWidget {
  final List<HabitDto> habits;

  const HomeHabitsSection({super.key, required this.habits});

  @override
  State<HomeHabitsSection> createState() => _HomeHabitsSectionState();
}

class _HomeHabitsSectionState extends State<HomeHabitsSection> {
  int? _updatingHabitId;

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
          HabitCard(
            habit: habit,
            isUpdating: _updatingHabitId == habit.id,
            onChanged: () =>
                context.read<HomeBloc>().add(const HomeRefreshed()),
            onCheckIn: () {
              if (_updatingHabitId == null) {
                _toggleHabitCompletion(context, habit.id);
              }
            },
          ),
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
    // Check-ins made on the habits page should show up here too.
    if (context.mounted) context.read<HomeBloc>().add(const HomeRefreshed());
  }

  Future<void> _toggleHabitCompletion(BuildContext context, int habitId) async {
    setState(() => _updatingHabitId = habitId);
    final logEntryBloc = getIt<LogEntryBloc>();
    try {
      final now = DateTime.now();
      String two(int v) => v.toString().padLeft(2, '0');
      final date = '${now.year}-${two(now.month)}-${two(now.day)}';
      logEntryBloc.add(
        LogEntrySubmitted(
          habitId: habitId,
          date: date,
          completedAt:
              '$date ${two(now.hour)}:${two(now.minute)}:${two(now.second)}',
          note: null,
        ),
      );

      final result = await logEntryBloc.stream.firstWhere(
        (state) => state is LogEntrySuccess || state is LogEntryFailure,
      );
      if (!context.mounted) return;
      if (result is LogEntryFailure) {
        AppToast.error(context, "Couldn't check in", message: result.message);
      } else {
        context.read<HomeBloc>().add(const HomeRefreshed());
      }
    } catch (_) {
      if (context.mounted) AppToast.error(context, "Couldn't check in");
    } finally {
      await logEntryBloc.close();
      if (mounted) setState(() => _updatingHabitId = null);
    }
  }
}
