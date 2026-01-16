import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/core/widgets/streak_card.dart';
import 'package:lifeos_client/features/health/domain/repositories/workout_repository.dart';
import 'package:lifeos_client/features/health/presentation/bloc/exercise_bloc.dart';
import 'package:lifeos_client/features/health/presentation/bloc/workout_bloc.dart';
import 'package:lifeos_client/features/health/presentation/pages/workout_page.dart';
import 'package:lifeos_client/injection.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../data/models/workout_summary_dto.dart';

class WorkoutStreakCard extends StatelessWidget {
  final WorkoutSummaryDto workoutSummary;

  const WorkoutStreakCard({super.key, required this.workoutSummary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Convert workout sessions to generic streak data points
    final dataPoints = workoutSummary.sessions
        .map((session) => StreakDataPoint(
              date: session.date,
              hasActivity: session.hasSession,
            ))
        .toList();

    return StreakCard(
      title: 'Workout Streak',
      currentStreak: workoutSummary.currentStreak,
      dataPoints: dataPoints,
      child: SizedBox(
        width: double.infinity,
        child: PrimaryButton(
          onPressed: () {
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
          child: Builder(
            builder: (context) {
              final hasActiveWorkout =
                  getIt<WorkoutRepository>().hasActiveWorkout();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: hasActiveWorkout
                        ? HugeIcons.strokeRoundedArrowRight01
                        : HugeIcons.strokeRoundedPlay,
                    size: 18,
                    strokeWidth: 2.5,
                    color: colorScheme.primaryForeground,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasActiveWorkout ? 'Continue Workout' : 'Start Workout',
                    style: theme.typography.small.copyWith(
                      color: colorScheme.primaryForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
