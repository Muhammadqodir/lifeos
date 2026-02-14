import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/empty_state.dart';
import 'package:lifeos_client/core/widgets/error_state.dart';
import 'package:lifeos_client/core/widgets/loading_state.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/create_habit_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_state.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/pages/create_habit_page.dart';
import 'package:lifeos_client/features/habits/presentation/widgets/habit_card.dart';
import 'package:lifeos_client/features/habits/presentation/widgets/log_entry_sheet.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/injection.dart';
import 'package:lifeos_client/utils/modal.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

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
            CustomAppBar(
              title: "Habits",
              leftActions: [
                AppBarAction(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  tooltip: 'Back',
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
              rightActions: [
                AppBarAction(
                  icon: HugeIcons.strokeRoundedAdd01,
                  tooltip: 'Create Habit',
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
      return const LoadingState(message: "Loading habits...");
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
        title: 'No Habits Yet',
        description: 'Create your first habit to start tracking',
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
          child: const Text('Create Habit'),
        ),
      );
    }

    final HabitsListSuccess successState = state as HabitsListSuccess;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final habit = successState.habits[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HabitCard(
                  habit: habit,
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
              );
            }, childCount: successState.habits.length),
          ),
        ),
      ],
    );
  }
}
