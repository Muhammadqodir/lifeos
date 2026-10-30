import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/create_habit_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_state.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/pages/create_habit_page.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<HabitsListBloc>().add(const HabitsListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitsListBloc, HabitsListState>(
      builder: (context, state) {
        return Scaffold(
          headers: [
            AppHeader(
              title: 'Habits',
              onRefresh: () => context.read<HabitsListBloc>().add(
                const HabitsListRefreshed(),
              ),
              actions: [
                HeaderAction(
                  icon: HugeIcons.strokeRoundedAdd01,
                  tooltip: 'New habit',
                  label: 'New habit',
                  primary: true,
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) {
                          return BlocProvider<CreateHabitBloc>(
                            create: (context) => getIt<CreateHabitBloc>(),
                            child: const CreateHabitPage(),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
          child: RefreshTrigger(
            key: _refreshTriggerKey,
            onRefresh: () async {
              context.read<HabitsListBloc>().add(const HabitsListRefreshed());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HabitsListState state) {
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
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) {
                  return BlocProvider<CreateHabitBloc>(
                    create: (context) => getIt<CreateHabitBloc>(),
                    child: const CreateHabitPage(),
                  );
                },
              ),
            );
          },
          child: const Text('Create habit'),
        ),
      );
    }

    final HabitsListSuccess successState = state as HabitsListSuccess;
    final habits = successState.habits;
    final doneToday = habits.where((h) => h.isCompletedToday ?? false).length;
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
                onChanged: () => context.read<HabitsListBloc>().add(
                  const HabitsListRefreshed(),
                ),
                onCheckIn: () {
                  final habitsListBloc = context.read<HabitsListBloc>();
                  BottomSheetModal.openSheet(
                    context: context,
                    builder: (context) => MultiBlocProvider(
                      providers: [
                        BlocProvider<LogEntryBloc>(
                          create: (context) => getIt<LogEntryBloc>(),
                        ),
                        BlocProvider<HabitsListBloc>.value(
                          value: habitsListBloc,
                        ),
                      ],
                      child: LogEntrySheet(habitId: habit.id),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
