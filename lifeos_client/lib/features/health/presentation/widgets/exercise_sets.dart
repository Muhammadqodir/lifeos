import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/health/data/models/workout_exercise_dto.dart';
import 'package:lifeos_client/features/health/data/models/workout_set_dto.dart';
import 'package:lifeos_client/features/health/presentation/bloc/workout_event.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:lifeos_client/utils/server.dart';
import 'package:lifeos_client/core/ui/ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/features/health/presentation/bloc/workout_bloc.dart';

class ExerciseSets extends StatefulWidget {
  final int exerciseIndex;
  final WorkoutExerciseDto exercise;

  const ExerciseSets({required this.exerciseIndex, required this.exercise});

  @override
  State<ExerciseSets> createState() => _ExerciseSetsState();
}

class _ExerciseSetsState extends State<ExerciseSets> {
  bool _open = true;

  Future<void> _confirmRemove() async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: 'Remove exercise?',
      message: 'Its sets in this workout will be removed too.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (confirmed && mounted) {
      context.read<WorkoutBloc>().add(RemoveExercise(widget.exerciseIndex));
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise.exercise;
    final image = exercise?.image;
    final sets = widget.exercise.sets;
    final done = sets.where((set) => set.isDone).length;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppListTile(
            leading: image != null && image.isNotEmpty
                ? LeadingTile.image(StorageUrl.resolve(image))
                : LeadingTile.icon(HugeIcons.strokeRoundedDumbbell03),
            title: exercise?.name ?? 'Exercise',
            subtitle: sets.isEmpty
                ? 'No sets yet'
                : '$done of ${sets.length} sets done',
            onTap: () => setState(() => _open = !_open),
            trailing: AnimatedRotation(
              turns: _open ? 0.5 : 0,
              duration: AppDurations.base,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowDown01,
                size: AppIconSize.md,
                color: context.colors.mutedForeground,
              ),
            ),
            actions: [
              AppAction(
                label: 'Remove exercise',
                icon: HugeIcons.strokeRoundedDelete02,
                destructive: true,
                onSelected: _confirmRemove,
              ),
            ],
          ),
          AnimatedSize(
            duration: AppDurations.base,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_open
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < sets.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _SetRow(
                              exerciseIndex: widget.exerciseIndex,
                              setIndex: i,
                              set: sets[i],
                              exerciseType: exercise?.type ?? 'strength',
                              lastSessionSets: exercise?.lastSessionSets,
                            ),
                          ),
                        OutlineButton(
                          size: ButtonSize.small,
                          leading: const HugeIcon(
                            icon: HugeIcons.strokeRoundedAdd01,
                            size: AppIconSize.sm,
                          ),
                          onPressed: () => context.read<WorkoutBloc>().add(
                            AddSet(widget.exerciseIndex),
                          ),
                          child: const Text('Add set'),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final int exerciseIndex;
  final int setIndex;
  final WorkoutSetDto set;
  final String exerciseType;
  final List<WorkoutSetDto>? lastSessionSets;

  const _SetRow({
    required this.exerciseIndex,
    required this.setIndex,
    required this.set,
    required this.exerciseType,
    this.lastSessionSets,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController weightController;
  late TextEditingController repsController;
  late TextEditingController durationController;
  late TextEditingController distanceController;
  bool showRpeSelector = false;

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController(
      text: widget.set.weightKg?.toString() ?? '',
    );
    repsController = TextEditingController(
      text: widget.set.reps?.toString() ?? '',
    );
    durationController = TextEditingController(
      text: widget.set.durationSeconds?.toString() ?? '',
    );
    distanceController = TextEditingController(
      text: widget.set.distanceMeters?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    durationController.dispose();
    distanceController.dispose();
    super.dispose();
  }

  void _updateSet({int? rpe}) {
    context.read<WorkoutBloc>().add(
      UpdateSet(
        exerciseIndex: widget.exerciseIndex,
        setIndex: widget.setIndex,
        weightKg: double.tryParse(weightController.text),
        reps: int.tryParse(repsController.text),
        durationSeconds: int.tryParse(durationController.text),
        distanceMeters: double.tryParse(distanceController.text),
        rpe: rpe ?? widget.set.rpe,
      ),
    );
  }

  Text? _getLastSessionHint(String field) {
    if (widget.lastSessionSets == null || widget.lastSessionSets!.isEmpty) {
      return null;
    }

    // Get the set at the same index from last session, or the last set if index is beyond
    final lastSet = widget.setIndex < widget.lastSessionSets!.length
        ? widget.lastSessionSets![widget.setIndex]
        : widget.lastSessionSets!.last;

    String? hintValue = "default";
    switch (field) {
      case 'weight':
        hintValue = lastSet.weightKg?.toString();
        break;
      case 'reps':
        hintValue = lastSet.reps?.toString();
        break;
      case 'duration':
        hintValue = lastSet.durationSeconds?.toString();
        break;
      case 'distance':
        hintValue = lastSet.distanceMeters?.toString();
        break;
    }

    if (hintValue == null) return null;

    return Text(
      hintValue,
      style: context.text.caption.copyWith(
        color: const Color(0xFF71717A), // muted foreground
      ),
    );
  }

  int _getInitialRpe() {
    // If the current set already has an RPE, use it
    if (widget.set.rpe != null) {
      return widget.set.rpe!;
    }

    // Otherwise, try to get RPE from last session
    if (widget.lastSessionSets != null && widget.lastSessionSets!.isNotEmpty) {
      final lastSet = widget.setIndex < widget.lastSessionSets!.length
          ? widget.lastSessionSets![widget.setIndex]
          : widget.lastSessionSets!.last;

      if (lastSet.rpe != null) {
        _updateSet(rpe: lastSet.rpe);
        return lastSet.rpe!;
      }
    }

    // Default to 1 if no previous data
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final isStrength = widget.exerciseType == 'strength';
    final isDistance =
        widget.exerciseType == 'distance' || widget.exerciseType == 'time';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.muted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).colorScheme.border),
              ),
              alignment: Alignment.center,
              child: Text(
                '${widget.setIndex + 1}',
                style: Theme.of(
                  context,
                ).typography.small.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            if (isStrength) ...[
              Expanded(
                child: TextField(
                  features: [
                    InputFeature.trailing(
                      Text('kg', style: Theme.of(context).typography.xSmall),
                    ),
                  ],
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  placeholder: _getLastSessionHint('weight'),
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onChanged: (_) => _updateSet(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  features: [
                    InputFeature.trailing(
                      Text('reps', style: Theme.of(context).typography.xSmall),
                    ),
                  ],
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  placeholder: _getLastSessionHint('reps'),
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onChanged: (_) => _updateSet(),
                ),
              ),
            ],
            if (isDistance) ...[
              Expanded(
                child: TextField(
                  features: [
                    InputFeature.trailing(
                      Text('mins', style: Theme.of(context).typography.xSmall),
                    ),
                  ],
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  placeholder: _getLastSessionHint('duration'),
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onChanged: (_) => _updateSet(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  features: [
                    InputFeature.trailing(
                      Text('m', style: Theme.of(context).typography.xSmall),
                    ),
                  ],
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  controller: distanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  placeholder: _getLastSessionHint('distance'),
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onChanged: (_) => _updateSet(),
                ),
              ),
            ],
            const SizedBox(width: 8),
            RPESelector(
              initialRpe: _getInitialRpe(),
              onUpdate: (rpe) {
                _updateSet(rpe: rpe);
              },
            ),
            IconButton.ghost(
              size: ButtonSize.small,
              onPressed: () {
                context.read<WorkoutBloc>().add(
                  RemoveSet(
                    exerciseIndex: widget.exerciseIndex,
                    setIndex: widget.setIndex,
                  ),
                );
              },
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                size: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RPESelector extends StatelessWidget {
  const RPESelector({super.key, required this.onUpdate, this.initialRpe = 1});

  final Function(int?) onUpdate;
  final int initialRpe;

  String _getRpeLabel(int rpe) {
    switch (rpe) {
      case 1:
      case 2:
        return 'Very Easy';
      case 3:
      case 4:
        return 'Easy';
      case 5:
      case 6:
        return 'Moderate';
      case 7:
      case 8:
        return 'Hard';
      case 9:
      case 10:
        return 'Very Hard';
      default:
        return '';
    }
  }

  Color _getRpeColor(int rpe) {
    switch (rpe) {
      case 1:
      case 2:
        return const Color(0xFF22C55E); // green
      case 3:
      case 4:
        return const Color(0xFF84CC16); // light green
      case 5:
      case 6:
        return const Color(0xFFEAB308); // yellow
      case 7:
      case 8:
        return const Color(0xFFF97316); // orange
      case 9:
      case 10:
        return const Color(0xFFEF4444); // red
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Select<int>(
      padding: EdgeInsets.all(8),
      value: initialRpe,
      placeholder: const Text('Select RPE'),
      onChanged: onUpdate,
      popup: SelectPopup(
        items: SelectItemList(
          children: List.generate(10, (index) => index + 1)
              .map(
                (value) => SelectItemButton<int>(
                  value: value,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getRpeColor(value).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _getRpeColor(value)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$value',
                          style: Theme.of(context).typography.small.copyWith(
                            color: _getRpeColor(value),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getRpeLabel(value),
                        style: Theme.of(context).typography.small,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ).call,
      itemBuilder: (context, value) {
        return Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: _getRpeColor(value).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _getRpeColor(value)),
              ),
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: Theme.of(context).typography.xSmall.copyWith(
                  color: _getRpeColor(value),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
