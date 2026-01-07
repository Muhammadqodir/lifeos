import 'package:flutter/cupertino.dart';
import 'package:lifeos_client/features/health/presentation/pages/workout_page.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../bloc/health_home_bloc.dart';
import '../bloc/health_home_event.dart';
import '../bloc/health_home_state.dart';
import '../widgets/sleep_chart_card.dart';
import '../widgets/wellbeing_chart_card.dart';
import '../widgets/workout_streak_card.dart';

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
                    _showComingSoonToast(context, 'Start Workout');
                  },
                ),
                AppBarAction(
                  icon: HugeIcons.strokeRoundedChartUp,
                  tooltip: 'Progress',
                  onTap: () {
                    _showComingSoonToast(context, 'Progress');
                  },
                ),
                AppBarAction(
                  icon: HugeIcons.strokeRoundedDatabaseSetting,
                  tooltip: 'Health Settings',
                  onTap: () {
                    _showComingSoonToast(context, 'Health Settings');
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
    final theme = Theme.of(context);

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
            _showComingSoonToast(context, 'Add Health Entry');
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
              onStartWorkout: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) {
                      return WorkoutPage();
                    },
                  ),
                );
              },
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
                _showComingSoonToast(context, 'Add Sleep Entry');
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
                _showComingSoonToast(context, 'Add Wellbeing Entry');
              },
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  void _showComingSoonToast(BuildContext context, String feature) {
    showToast(
      context: context,
      builder: (context, overlay) => Utils.buildToast(
        context,
        overlay,
        'Coming Soon',
        '$feature feature is not yet implemented',
      ),
      location: ToastLocation.topCenter,
    );
  }
}
