import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../injection.dart';
import '../../../../utils/modal.dart';
import '../bloc/exercise_bloc.dart';
import '../bloc/health_home_bloc.dart';
import '../bloc/health_home_event.dart';
import '../bloc/health_home_state.dart';
import '../bloc/sleep_entry_bloc.dart';
import '../bloc/wellbeing_entry_bloc.dart';
import '../bloc/workout_bloc.dart';
import '../widgets/add_sleep_entry_sheet.dart';
import '../widgets/add_wellbeing_entry_sheet.dart';
import '../widgets/sleep_chart_card.dart';
import '../widgets/wellbeing_chart_card.dart';
import '../widgets/workout_streak_card.dart';
import 'exercises_page.dart';
import 'workout_page.dart';
import 'workout_sessions_page.dart';

class GymMainPage extends StatefulWidget {
  const GymMainPage({super.key});

  @override
  State<GymMainPage> createState() => _GymMainPageState();
}

class _GymMainPageState extends State<GymMainPage> {
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  void _refresh() =>
      context.read<HealthHomeBloc>().add(const HealthHomeRefreshed());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthHomeBloc, HealthHomeState>(
      builder: (context, state) {
        return Scaffold(
          headers: [
            AppHeader(
              title: 'Health',
              onRefresh: _refresh,
              actions: [
                HeaderAction(
                  icon: HugeIcons.strokeRoundedChartUp,
                  tooltip: 'Workout history',
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const WorkoutSessionsPage(),
                    ),
                  ),
                ),
                HeaderAction(
                  icon: HugeIcons.strokeRoundedDumbbell01,
                  tooltip: 'Exercises',
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => BlocProvider<ExerciseBloc>(
                        create: (_) => getIt<ExerciseBloc>(),
                        child: const ExercisesPage(),
                      ),
                    ),
                  ),
                ),
                HeaderAction(
                  icon: HugeIcons.strokeRoundedPlay,
                  tooltip: 'Start workout',
                  label: 'Start workout',
                  primary: true,
                  onTap: () => _startWorkout(context),
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
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  void _startWorkout(BuildContext context) {
    // Workouts are immersive: present above the tab bar / sidebar.
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<WorkoutBloc>(create: (_) => getIt<WorkoutBloc>()),
            BlocProvider<ExerciseBloc>(create: (_) => getIt<ExerciseBloc>()),
          ],
          child: const WorkoutPage(),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HealthHomeState state) {
    if (state is HealthHomeLoading || state is HealthHomeInitial) {
      return const LoadingState(message: 'Loading health data…');
    }

    if (state is HealthHomeFailure) {
      return ErrorState(
        title: "Couldn't load health data",
        message: state.message,
        onRetry: () =>
            context.read<HealthHomeBloc>().add(const HealthHomeRetried()),
      );
    }

    if (state is HealthHomeEmpty) {
      return EmptyState(
        title: 'Start tracking your health',
        description: 'Log sleep and wellbeing, or start your first workout.',
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedBodyPartMuscle),
        action: PrimaryButton(
          onPressed: () => _logSleep(context),
          child: const Text('Log sleep'),
        ),
      );
    }

    final success = state as HealthHomeSuccess;
    final sleep = SleepChartCard(
      sleepSummary: success.sleepSummary,
      onAddEntry: () => _logSleep(context),
    );
    final wellbeing = WellbeingChartCard(
      wellbeingSummary: success.wellbeingSummary,
      onAddEntry: () => _logWellbeing(context),
    );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.lg,
      ),
      child: ContentWidth.wide(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 720;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WorkoutStreakCard(workoutSummary: success.workoutSummary),
                const SizedBox(height: AppSpacing.md),
                if (twoColumns)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: sleep),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: wellbeing),
                    ],
                  )
                else ...[
                  sleep,
                  const SizedBox(height: AppSpacing.md),
                  wellbeing,
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            );
          },
        ),
      ),
    );
  }

  void _logSleep(BuildContext context) {
    final healthHomeBloc = context.read<HealthHomeBloc>();
    BottomSheetModal.openSheet(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<SleepEntryBloc>(create: (_) => getIt<SleepEntryBloc>()),
          BlocProvider<HealthHomeBloc>.value(value: healthHomeBloc),
        ],
        child: const AddSleepEntrySheet(),
      ),
    );
  }

  void _logWellbeing(BuildContext context) {
    final healthHomeBloc = context.read<HealthHomeBloc>();
    BottomSheetModal.openSheet(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<WellbeingEntryBloc>(
            create: (_) => getIt<WellbeingEntryBloc>(),
          ),
          BlocProvider<HealthHomeBloc>.value(value: healthHomeBloc),
        ],
        child: const AddWellbeingEntrySheet(),
      ),
    );
  }
}
