import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/features/health/data/models/exercise_dto.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../bloc/exercise_bloc.dart';
import '../bloc/exercise_event.dart';

void showDeleteExerciseDialog(BuildContext context, ExerciseDto exercise) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete Exercise'),
      content: Text(
        'Are you sure you want to delete "${exercise.name}"? This action cannot be undone.',
      ),
      actions: [
        OutlineButton(
          onPressed: () {
            Navigator.pop(dialogContext);
          },
          child: const Text('Cancel'),
        ),
        DestructiveButton(
          onPressed: () {
            context.read<ExerciseBloc>().add(DeleteExercise(exercise.id));
            Navigator.pop(dialogContext);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
