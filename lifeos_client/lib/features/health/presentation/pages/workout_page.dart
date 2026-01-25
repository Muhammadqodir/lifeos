import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/health/data/models/exercise_dto.dart';
import 'package:lifeos_client/features/health/presentation/bloc/exercise_bloc.dart';
import 'package:lifeos_client/features/health/presentation/bloc/workout_bloc.dart';
import 'package:lifeos_client/features/health/presentation/bloc/workout_event.dart';
import 'package:lifeos_client/features/health/presentation/bloc/workout_state.dart';
import 'package:lifeos_client/features/health/presentation/pages/workout_camera_page.dart';
import 'package:lifeos_client/features/health/presentation/pages/workout_completion_page.dart';
import 'package:lifeos_client/features/health/presentation/widgets/exercise_selection_sheet.dart';
import 'package:lifeos_client/features/health/presentation/widgets/exercise_sets.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/utils/dialogs.dart';
import 'package:lifeos_client/utils/modal.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  @override
  void initState() {
    super.initState();
    // Load any active workout on page load
    context.read<WorkoutBloc>().add(LoadActiveWorkout());
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final bool? confirmed = await Dialogs.showConfirmDialog(
      context: context,
      title: 'Cancel Workout',
      message:
          'Are you sure you want to cancel the workout? Your progress will not be saved.',
    );

    if (confirmed == true) {
      if (context.mounted) {
        context.read<WorkoutBloc>().add(CancelWorkout());
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showExerciseSelection(BuildContext context) async {
    // Capture the bloc before the builder to avoid context issues
    final exerciseBloc = context.read<ExerciseBloc>();

    final ExerciseDto? exercise = await BottomSheetModal.openSheet<ExerciseDto>(
      context: context,
      builder: (context) => BlocProvider.value(
        value: exerciseBloc,
        child: const ExerciseSelectionSheet(),
      ),
    );

    if (exercise != null && context.mounted) {
      context.read<WorkoutBloc>().add(AddExercise(exercise));
    }
  }

  Future<void> _finishWorkout(BuildContext context, WorkoutInProgress state) async {
    // First validate the workout
    context.read<WorkoutBloc>().add(FinishWorkout());
    
    // Wait a bit to see if there's a validation error
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!context.mounted) return;
    
    // Check if we're still in WorkoutInProgress (validation passed)
    // ignore: use_build_context_synchronously
    final currentState = context.read<WorkoutBloc>().state;
    if (currentState is! WorkoutInProgress) return;
    
    // Capture the WorkoutBloc before navigation
    final workoutBloc = context.read<WorkoutBloc>();
    
    // Navigate to camera page
    // ignore: use_build_context_synchronously
    final String? photoPath = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const WorkoutCameraPage(),
      ),
    );

    // Navigate to completion page if camera returned a result (photo or skip)
    // Only skip if user pressed back button (photoPath == null)
    if (photoPath != null && mounted) {
      // Navigate to completion page
      // ignore: use_build_context_synchronously
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: workoutBloc,
            child: WorkoutCompletionPage(
              photoPath: photoPath.isNotEmpty ? photoPath : null,
              workout: state.workout,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutBloc, WorkoutState>(
      listener: (context, state) {
        if (state is WorkoutError) {
          showToast(
            context: context,
            location: ToastLocation.topCenter,
            builder: (context, overlay) {
              return Utils.buildToast(context, overlay, 'Error', state.message);
            },
          );
        }
      },
      builder: (context, state) {
        final isInProgress = state is WorkoutInProgress;
        final isLoading = state is WorkoutLoading;

        return Scaffold(
          headers: [
            CustomAppBar(
              title: isInProgress ? 'Workout in Progress' : 'Start Workout',
              leftActions: [
                AppBarAction(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  tooltip: 'Back',
                  onTap: () async {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              children: [
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (isInProgress)
                  _buildWorkoutInProgress(context, state)
                else
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutInProgress(
    BuildContext context,
    WorkoutInProgress state,
  ) {
    return Column(
      children: [
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDuration(state.elapsedTime),
                style: Theme.of(context).typography.h1,
              ),
              const SizedBox(width: 150, child: Divider(height: 24)),
              Text(
                '${state.workout.exercises.length} Exercise${state.workout.exercises.length == 1 ? '' : 's'}',
                style: Theme.of(
                  context,
                ).typography.normal.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: () {
                        _confirmCancel(context);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            size: 18,
                            strokeWidth: 2.5,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Cancel',
                            style: Theme.of(context).typography.small.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: state.workout.exercises.isEmpty
                          ? null
                          : () {
                              _finishWorkout(context, state);
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedStop,
                            size: 18,
                            strokeWidth: 2.5,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Finish',
                            style: Theme.of(context).typography.small.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                'Exercises:',
                style: Theme.of(
                  context,
                ).typography.small.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton.primary(
              size: ButtonSize.normal,
              onPressed: () => _showExerciseSelection(context),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedAdd01,
                size: 16,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.workout.exercises.isEmpty)
          SizedBox(
            width: double.infinity,
            child: Card(
              child: Column(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedDumbbell02,
                    size: 34,
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No exercises yet',
                    style: Theme.of(context).typography.small.copyWith(
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add exercises',
                    style: Theme.of(context).typography.xSmall.copyWith(
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: List.generate(
              state.workout.exercises.length,
              (index) => ExerciseSets(
                exerciseIndex: index,
                exercise: state.workout.exercises[index],
              ),
            ),
          ).gap(12),
      ],
    );
  }
}
