import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:lifeos_client/utils/dialogs.dart';
import 'package:lifeos_client/utils/modal.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:lifeos_client/core/ui/ui.dart';

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
      title: 'Discard workout?',
      message: "Sets you've logged in this session won't be saved.",
      confirmLabel: 'Discard',
      destructive: true,
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

  Future<void> _finishWorkout(
    BuildContext context,
    WorkoutInProgress state,
  ) async {
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

    // The camera plugin has no macOS support: on desktop, offer a file
    // picker instead of the live camera page.
    // ignore: use_build_context_synchronously
    final String? photoPath = isDesktopPlatform
        ? await _pickProgressPhoto(context)
        : await Navigator.of(context).push<String>(
            MaterialPageRoute(builder: (context) => const WorkoutCameraPage()),
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

  /// Desktop replacement for the camera step. Returns a file path, '' to
  /// skip the photo, or null if the user backed out.
  Future<String?> _pickProgressPhoto(BuildContext context) async {
    final choose = await AppDialogs.confirm(
      context,
      title: 'Add a progress photo?',
      message: 'Choose a photo from your files, or skip this step.',
      confirmLabel: 'Choose photo',
      cancelLabel: 'Skip',
    );
    if (!choose) return '';
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 85,
    );
    return image?.path ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutBloc, WorkoutState>(
      listener: (context, state) {
        if (state is WorkoutError) {
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message,
          );
        }
      },
      builder: (context, state) {
        final isInProgress = state is WorkoutInProgress;
        final isLoading = state is WorkoutLoading;

        return Scaffold(
          headers: [
            AppHeader(
              title: isInProgress ? 'Workout' : 'Start workout',
              subtitle: isInProgress ? 'In progress' : null,
              actions: [
                if (isInProgress)
                  HeaderAction(
                    icon: HugeIcons.strokeRoundedAdd01,
                    tooltip: 'Add exercise',
                    label: 'Add exercise',
                    onTap: () => _showExerciseSelection(context),
                  ),
              ],
            ),
          ],
          child: isInProgress
              ? SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                    vertical: AppSpacing.lg,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: ContentWidth(
                    child: _buildWorkoutInProgress(context, state),
                  ),
                )
              : LoadingState(
                  message: isLoading ? 'Preparing workout…' : 'Loading…',
                ),
        );
      },
    );
  }

  Widget _buildWorkoutInProgress(
    BuildContext context,
    WorkoutInProgress state,
  ) {
    final count = state.workout.exercises.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            children: [
              Text(
                _formatDuration(state.elapsedTime),
                style: context.text.display,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                count == 1 ? '1 exercise' : '$count exercises',
                style: context.text.itemSubtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      onPressed: () => _confirmCancel(context),
                      leading: const HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        size: AppIconSize.sm,
                      ),
                      child: const Text('Discard'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: count == 0
                          ? null
                          : () => _finishWorkout(context, state),
                      leading: const HugeIcon(
                        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                        size: AppIconSize.sm,
                      ),
                      child: const Text('Finish'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        SectionHeader(
          title: 'Exercises',
          count: count,
          trailing: GhostButton(
            size: ButtonSize.small,
            density: ButtonDensity.compact,
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              size: AppIconSize.sm,
            ),
            onPressed: () => _showExerciseSelection(context),
            child: const Text('Add'),
          ),
        ),
        if (count == 0)
          AppCard(
            child: EmptyState(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedDumbbell02),
              title: 'Add your first exercise',
              description: 'Pick an exercise, then log sets as you go.',
              action: PrimaryButton(
                onPressed: () => _showExerciseSelection(context),
                child: const Text('Add exercise'),
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < count; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ExerciseSets(
                    exerciseIndex: i,
                    exercise: state.workout.exercises[i],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
