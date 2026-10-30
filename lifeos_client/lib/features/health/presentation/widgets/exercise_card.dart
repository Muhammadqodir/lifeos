import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/ui/ui.dart';
import 'package:lifeos_client/utils/server.dart';
import 'package:lifeos_client/features/health/data/models/exercise_dto.dart';
import 'package:lifeos_client/features/health/presentation/bloc/exercise_bloc.dart';
import 'package:lifeos_client/features/health/presentation/bloc/exercise_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/utils/dialogs.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseDto exercise;
  final bool showMuscleGroup;
  final bool showDeleteButton;

  const ExerciseCard({
    required this.exercise,
    this.showMuscleGroup = false,
    this.showDeleteButton = false,
    this.onTap,
    super.key,
  });

  /// Selects the exercise; when set the row shows a chevron.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final image = exercise.image;
    final details = [
      exercise.type[0].toUpperCase() + exercise.type.substring(1),
      if (showMuscleGroup && (exercise.muscleGroup?.isNotEmpty ?? false))
        exercise.muscleGroup!,
    ].join(' · ');

    return AppListTile(
      leading: image != null && image.isNotEmpty
          ? LeadingTile.image(StorageUrl.resolve(image))
          : LeadingTile.icon(HugeIcons.strokeRoundedDumbbell03),
      title: exercise.name,
      subtitle: details,
      onTap: onTap,
      showChevron: onTap != null,
      actions: [
        if (showDeleteButton)
          AppAction(
            label: 'Delete exercise',
            icon: HugeIcons.strokeRoundedDelete02,
            destructive: true,
            onSelected: () => showDeleteExerciseDialog(context, exercise),
          ),
      ],
    );
  }

  void showDeleteExerciseDialog(
    BuildContext context,
    ExerciseDto exercise,
  ) async {
    bool? confirmed = await Dialogs.showConfirmDialog(
      context: context,
      title: 'Delete Exercise',
      message:
          'Are you sure you want to delete "${exercise.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (confirmed == true) {
      if (context.mounted) {
        context.read<ExerciseBloc>().add(DeleteExercise(exercise.id));
      }
    }
  }
}
