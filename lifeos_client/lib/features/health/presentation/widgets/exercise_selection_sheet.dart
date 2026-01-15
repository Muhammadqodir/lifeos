import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/tappable.dart';
import 'package:lifeos_client/features/health/presentation/bloc/exercise_bloc.dart';
import 'package:lifeos_client/features/health/presentation/bloc/exercise_event.dart';
import 'package:lifeos_client/features/health/presentation/bloc/exercise_state.dart';
import 'package:lifeos_client/features/health/presentation/widgets/exercise_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ExerciseSelectionSheet extends StatefulWidget {
  const ExerciseSelectionSheet({super.key});

  @override
  State<ExerciseSelectionSheet> createState() => _ExerciseSelectionSheetState();
}

class _ExerciseSelectionSheetState extends State<ExerciseSelectionSheet> {
  String? selectedType;

  @override
  void initState() {
    super.initState();
    context.read<ExerciseBloc>().add(LoadExercises());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Add Exercise',
                  style: Theme.of(
                    context,
                  ).typography.large.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                TextField(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  features: [
                    InputFeature.trailing(
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        size: 20,
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  placeholder: Text("Search exercises"),
                  onChanged: (value) {
                    context.read<ExerciseBloc>().add(SearchExercises(value));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ExerciseBloc, ExerciseState>(
              builder: (context, state) {
                if (state is ExerciseLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ExerciseError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        state.message,
                        style: Theme.of(context).typography.small.copyWith(
                          color: Theme.of(context).colorScheme.destructive,
                        ),
                      ),
                    ),
                  );
                }

                if (state is ExerciseLoaded) {
                  if (state.filteredExercises.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedDumbbell02,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No exercises found',
                              style: Theme.of(context).typography.normal
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.mutedForeground,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create custom exercises to add them here',
                              style: Theme.of(context).typography.small
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.mutedForeground,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: state.filteredExercises.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final exercise = state.filteredExercises[index];
                      return Tappable(
                        lowerBound: 0.98,
                        child: ExerciseCard(
                          exercise: exercise,
                          showMuscleGroup: true,
                        ),
                        onTap: () => Navigator.pop(context, exercise),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
