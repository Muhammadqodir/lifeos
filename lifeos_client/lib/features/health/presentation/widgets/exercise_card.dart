import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/config/app_config.dart';
import 'package:lifeos_client/core/theme/app_colors.dart';
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    print(AppConfig.serverBaseUrl + (exercise.image ?? ''));
    return Card(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          // Leading Icon/Image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: AppConfig.serverBaseUrl + (exercise.image ?? ''),
                fit: BoxFit.cover,
                errorWidget: (context, error, stackTrace) {
                  return const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedDumbbell03,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: Theme.of(
                    context,
                  ).typography.small.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SecondaryBadge(
                      child: Text(
                        exercise.type.toUpperCase(),
                        style: Theme.of(context).typography.xSmall,
                      ),
                    ),
                    if (showMuscleGroup && exercise.muscleGroup != null) ...[
                      const SizedBox(width: 8),
                      SecondaryBadge(
                        child: Text(
                          exercise.muscleGroup!,
                          style: Theme.of(context).typography.xSmall,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (showDeleteButton)
            IconButton.ghost(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                size: 18,
                color: AppColors.redColor,
              ),
              onPressed: () => showDeleteExerciseDialog(context, exercise),
            ),
        ],
      ),
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
    );

    if (confirmed == true) {
      if (context.mounted) {
        context.read<ExerciseBloc>().add(DeleteExercise(exercise.id));
      }
    }
  }
}
