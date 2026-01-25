import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/health/presentation/bloc/exercise_bloc.dart';
import 'package:lifeos_client/features/health/presentation/bloc/workout_bloc.dart';
import 'package:lifeos_client/features/health/presentation/pages/exercises_page.dart';
import 'package:lifeos_client/features/health/presentation/pages/workout_page.dart';
import 'package:lifeos_client/features/health/presentation/pages/workout_sessions_page.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/injection.dart';
import 'package:lifeos_client/utils/modal.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../bloc/health_home_bloc.dart';
import '../bloc/health_home_event.dart';
import '../bloc/health_home_state.dart';
import '../widgets/sleep_chart_card.dart';
import '../widgets/wellbeing_chart_card.dart';
import '../widgets/workout_streak_card.dart';
import '../widgets/add_sleep_entry_sheet.dart';
import '../bloc/sleep_entry_bloc.dart';
import '../widgets/add_wellbeing_entry_sheet.dart';
import '../bloc/wellbeing_entry_bloc.dart';

class GymMainPage extends StatefulWidget {
  const GymMainPage({super.key});

  @override
  State<GymMainPage> createState() => _GymMainPageState();
}

class _GymMainPageState extends State<GymMainPage> {
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthHomeBloc, HealthHomeState>(
      builder: (context, state) {
        return Column(
          children: [
            CustomAppBar(
              title: "Health",
              rightActions: [
                AppBarAction(
                  icon: HugeIcons.strokeRoundedPlay,
                  tooltip: 'Start workout',
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider<WorkoutBloc>(
                                create: (context) => getIt<WorkoutBloc>(),
                              ),
                              BlocProvider<ExerciseBloc>(
                                create: (context) => getIt<ExerciseBloc>(),
                              ),
                            ],
                            child: const WorkoutPage(),
                          );
                        },
                      ),
                    );
                  },
                ),
                AppBarAction(
                  icon: HugeIcons.strokeRoundedChartUp,
                  tooltip: 'Progress',
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const WorkoutSessionsPage(),
                      ),
                    );
                  },
                ),
                AppBarAction(
                  icon: HugeIcons.strokeRoundedDatabaseSetting,
                  tooltip: 'Workout Settings',
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider<ExerciseBloc>(
                                create: (context) => getIt<ExerciseBloc>(),
                              ),
                            ],
                            child: const ExercisesPage(),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: RefreshTrigger(
                key: _refreshTriggerKey,
                onRefresh: () async {
                  context.read<HealthHomeBloc>().add(
                    const HealthHomeRefreshed(),
                  );
                  // Wait a bit for the refresh to complete
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: _buildBody(context, state),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HealthHomeState state) {
    if (state is HealthHomeLoading || state is HealthHomeInitial) {
      return const LoadingState(message: "Loading health data...");
    }

    if (state is HealthHomeFailure) {
      print('HealthHomeFailure: ${state.message}');
      return ErrorState(
        message: state.message,
        onRetry: () {
          context.read<HealthHomeBloc>().add(const HealthHomeRetried());
        },
      );
    }

    if (state is HealthHomeEmpty) {
      return EmptyState(
        title: 'No Health Data',
        description: 'Start tracking your sleep and wellbeing',
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedBodyPartMuscle,
          size: 24,
        ),
        action: PrimaryButton(
          onPressed: () {
            // _showComingSoonToast(context, 'Add Health Entry');
          },
          child: const Text('Add Health Entry'),
        ),
      );
    }

    final HealthHomeSuccess successState = state as HealthHomeSuccess;
    return CustomScrollView(
      slivers: [
        // Workout Streak Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
            child: WorkoutStreakCard(
              workoutSummary: successState.workoutSummary,
            ),
          ),
        ),

        // Sleep Chart
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
            child: SleepChartCard(
              sleepSummary: successState.sleepSummary,
              onAddEntry: () {
                final healthHomeBloc = context.read<HealthHomeBloc>();
                BottomSheetModal.openSheet(
                  context: context,
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider<SleepEntryBloc>(
                        create: (context) => getIt<SleepEntryBloc>(),
                      ),
                      BlocProvider<HealthHomeBloc>.value(
                        value: healthHomeBloc,
                      ),
                    ],
                    child: const AddSleepEntrySheet(),
                  ),
                );
              },
            ),
          ),
        ),

        // Wellbeing Chart
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: WellbeingChartCard(
              wellbeingSummary: successState.wellbeingSummary,
              onAddEntry: () {
                final healthHomeBloc = context.read<HealthHomeBloc>();
                BottomSheetModal.openSheet(
                  context: context,
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider<WellbeingEntryBloc>(
                        create: (context) => getIt<WellbeingEntryBloc>(),
                      ),
                      BlocProvider<HealthHomeBloc>.value(
                        value: healthHomeBloc,
                      ),
                    ],
                    child: const AddWellbeingEntrySheet(),
                  ),
                );
              },
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}
