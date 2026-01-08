import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/selectable_group.dart';
import 'package:lifeos_client/features/health/data/models/exercise_dto.dart';
import 'package:lifeos_client/features/health/presentation/widgets/add_exercise_dialog.dart';
import 'package:lifeos_client/features/health/presentation/widgets/exercise_card.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../bloc/exercise_bloc.dart';
import '../bloc/exercise_event.dart';
import '../bloc/exercise_state.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final _searchController = TextEditingController();
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    context.read<ExerciseBloc>().add(LoadExercises());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outerContext = context;
    return Scaffold(
      headers: [
        CustomAppBar(
          title: 'My Exercises',
          leftActions: [
            AppBarAction(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              tooltip: 'Back',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
          rightActions: [
            AppBarAction(
              icon: HugeIcons.strokeRoundedAdd01,
              tooltip: 'Add Exercise',
              onTap: () => showAddExerciseDialog(context),
            ),
          ],
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: SelectableGroup(
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                        if (_selectedType == 'all') {
                          context.read<ExerciseBloc>().add(
                            const FilterExercises(),
                          );
                        } else {
                          context.read<ExerciseBloc>().add(
                            FilterExercises(type: value),
                          );
                        }
                      },
                      options: [
                        SelectableGroupOption(
                          value: "all",
                          widget: Row(children: [Text('All')]),
                        ),
                        SelectableGroupOption(
                          value: "strength",
                          widget: Row(children: [Text('Strength')]),
                        ),
                        SelectableGroupOption(
                          value: "distance",
                          widget: Row(children: [Text('Distance')]),
                        ),
                        SelectableGroupOption(
                          value: "time",
                          widget: Row(children: [Text('Time')]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildBody(outerContext),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext outerContext) {
    return BlocConsumer<ExerciseBloc, ExerciseState>(
      listener: (context, state) {
        if (state is ExerciseCreated) {
          showToast(
            context: outerContext,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Success',
                'Exercise "${state.exercise.name}" created!',
              );
            },
            location: ToastLocation.topCenter,
          );
        } else if (state is ExerciseDeleted) {
          showToast(
            context: outerContext,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Success',
                'Exercise deleted successfully',
              );
            },
            location: ToastLocation.topCenter,
          );
        } else if (state is ExerciseError) {
          showToast(
            context: outerContext,
            builder: (context, overlay) {
              return Utils.buildToast(context, overlay, 'Error', state.message);
            },
            location: ToastLocation.topCenter,
          );
        }
      },
      builder: (context, state) {
        if (state is ExerciseLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ExerciseCreating) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Creating exercise...'),
              ],
            ),
          );
        }

        if (state is ExerciseLoaded) {
          if (state.filteredExercises.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 42),
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedDumbbell03,
                  size: 32,
                ),
                const SizedBox(height: 16),
                Text(
                  state.searchQuery.isNotEmpty
                      ? 'No exercises found'
                      : 'No custom exercises yet',
                  style: Theme.of(context).typography.normal.copyWith(
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.searchQuery.isNotEmpty
                      ? 'Try a different search'
                      : 'Tap + to create your first exercise',
                  style: Theme.of(context).typography.small.copyWith(
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
              ],
            );
          }

          // Group exercises by muscle group
          final groupedExercises = <String, List<ExerciseDto>>{};
          for (final exercise in state.filteredExercises) {
            final group = exercise.muscleGroup?.isNotEmpty == true
                ? exercise.muscleGroup!
                : 'Other';
            groupedExercises.putIfAbsent(group, () => []).add(exercise);
          }

          // Sort groups alphabetically, but keep 'Other' at the end
          final sortedGroups = groupedExercises.keys.toList()
            ..sort((a, b) {
              if (a == 'Other') return 1;
              if (b == 'Other') return -1;
              return a.compareTo(b);
            });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sortedGroups.expand((group) {
              final exercises = groupedExercises[group]!;
              return [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Text(
                    group,
                    style: Theme.of(context).typography.small.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.foreground,
                    ),
                  ),
                ),
                ...exercises.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ExerciseCard(
                      exercise: e,
                      showDeleteButton: true,
                    ),
                  ),
                ),
              ];
            }).toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
