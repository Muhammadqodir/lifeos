import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/create_habit_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_state.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/pages/create_habit_page.dart';
import 'package:lifeos_client/features/habits/presentation/pages/habit_stat_page.dart';
import 'package:lifeos_client/features/habits/presentation/widgets/habit_card.dart';
import 'package:lifeos_client/features/habits/presentation/widgets/log_entry_sheet.dart';
import 'package:lifeos_client/injection.dart';
import 'package:lifeos_client/utils/modal.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:lifeos_client/core/ui/ui.dart';

class HabitsMainPage extends StatefulWidget {
  const HabitsMainPage({super.key});

  @override
  State<HabitsMainPage> createState() => _HabitsMainPageState();
}

class _HabitsMainPageState extends State<HabitsMainPage> {
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  /// Habit shown beside the list on wide windows (split view).
  String? _selectedId;

  void _refresh() =>
      context.read<HabitsListBloc>().add(const HabitsListRefreshed());

  void _openCreateHabit() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => BlocProvider<CreateHabitBloc>(
          create: (context) => getIt<CreateHabitBloc>(),
          child: const CreateHabitPage(),
        ),
      ),
    );
  }

  void _openCheckIn(BuildContext context, HabitDto habit) {
    final habitsListBloc = context.read<HabitsListBloc>();
    BottomSheetModal.openSheet(
      context: context,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<LogEntryBloc>(
            create: (context) => getIt<LogEntryBloc>(),
          ),
          BlocProvider<HabitsListBloc>.value(value: habitsListBloc),
        ],
        child: LogEntrySheet(habitId: habit.id),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<HabitsListBloc>().add(const HabitsListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitsListBloc, HabitsListState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final page = Scaffold(
              headers: [
                AppHeader(
                  title: 'Habits',
                  onRefresh: _refresh,
                  actions: [
                    HeaderAction(
                      icon: HugeIcons.strokeRoundedAdd01,
                      tooltip: 'New habit',
                      label: 'New habit',
                      primary: true,
                      onTap: _openCreateHabit,
                    ),
                  ],
                ),
              ],
              child: RefreshTrigger(
                key: _refreshTriggerKey,
                onRefresh: () async {
                  _refresh();
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: _buildBody(
                  context,
                  state,
                  split: SplitView.fits(constraints),
                ),
              ),
            );
            if (!SplitView.fits(constraints)) return page;

            final habits = state is HabitsListSuccess
                ? state.habits
                : const <HabitDto>[];
            final selected =
                habits.where((h) => h.id == _selectedId).firstOrNull ??
                habits.firstOrNull;
            return SplitView(
              list: page,
              detail: selected == null
                  ? Scaffold(
                      child: EmptyState(
                        title: 'No habit selected',
                        description: 'Choose a habit to see its streaks.',
                        icon: const HugeIcon(icon: HugeIcons.strokeRoundedFire),
                      ),
                    )
                  : HabitStatPage(
                      // Reload the stats after a check-in in the list.
                      key: ValueKey((
                        selected.id,
                        selected.currentStreak,
                        selected.isCompletedToday,
                      )),
                      habit: selected,
                      onArchived: _refresh,
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    HabitsListState state, {
    required bool split,
  }) {
    if (state is HabitsListLoading || state is HabitsListInitial) {
      return const LoadingState(message: 'Loading habits…');
    }

    if (state is HabitsListFailure) {
      return ErrorState(
        message: state.message,
        onRetry: () {
          context.read<HabitsListBloc>().add(const HabitsListRequested());
        },
      );
    }

    if (state is HabitsListEmpty) {
      return EmptyState(
        title: 'Build your first habit',
        description: 'Small daily actions add up. Pick one to track.',
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedCheckmarkCircle01,
          size: 24,
        ),
        action: PrimaryButton(
          onPressed: _openCreateHabit,
          child: const Text('Create habit'),
        ),
      );
    }

    final HabitsListSuccess successState = state as HabitsListSuccess;
    final habits = successState.habits;
    final doneToday = habits.where((h) => h.isCompletedToday ?? false).length;
    final selectedId = habits.any((h) => h.id == _selectedId)
        ? _selectedId
        : habits.firstOrNull?.id;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.lg,
      ),
      child: ContentWidth(
        child: AppListSection(
          title: 'Active habits',
          count: habits.length,
          headerTrailing: Text(
            '$doneToday done today',
            style: context.text.caption,
          ),
          children: [
            for (final habit in habits)
              HabitCard(
                habit: habit,
                onChanged: _refresh,
                onCheckIn: () => _openCheckIn(context, habit),
                selected: split && habit.id == selectedId,
                onOpen: split
                    ? () => setState(() => _selectedId = habit.id)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
