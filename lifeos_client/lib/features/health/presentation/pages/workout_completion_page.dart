import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/health/data/models/workout_completion_dto.dart';
import 'package:lifeos_client/features/health/data/models/workout_session_dto.dart';
import 'package:lifeos_client/features/health/presentation/bloc/workout_bloc.dart';
import 'package:lifeos_client/features/health/presentation/bloc/workout_event.dart';
import 'package:lifeos_client/features/health/presentation/bloc/workout_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:lifeos_client/core/ui/ui.dart';

class WorkoutCompletionPage extends StatefulWidget {
  final String? photoPath;
  final WorkoutSessionDto workout;

  const WorkoutCompletionPage({
    super.key,
    required this.photoPath,
    required this.workout,
  });

  @override
  State<WorkoutCompletionPage> createState() => _WorkoutCompletionPageState();
}

class _WorkoutCompletionPageState extends State<WorkoutCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _bodyWeightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bicepsController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _thighsController = TextEditingController();
  final _calfsController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _bodyWeightController.dispose();
    _heightController.dispose();
    _bicepsController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _thighsController.dispose();
    _calfsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Map<String, double> _calculateTotalWeightByExercise() {
    final Map<String, double> totals = {};

    for (final exercise in widget.workout.exercises) {
      double totalWeight = 0;
      for (final set in exercise.sets) {
        if (set.weightKg != null && set.reps != null) {
          totalWeight += set.weightKg! * set.reps!;
        }
      }
      totals[exercise.exercise?.name ?? 'Unknown'] = totalWeight;
    }

    return totals;
  }

  void _submitCompletion() {
    final completion = WorkoutCompletionDto(
      photoPath: widget.photoPath,
      bodyWeightKg: _bodyWeightController.text.isNotEmpty
          ? double.tryParse(_bodyWeightController.text)
          : null,
      heightCm: _heightController.text.isNotEmpty
          ? double.tryParse(_heightController.text)
          : null,
      bicepsCm: _bicepsController.text.isNotEmpty
          ? double.tryParse(_bicepsController.text)
          : null,
      chestCm: _chestController.text.isNotEmpty
          ? double.tryParse(_chestController.text)
          : null,
      waistCm: _waistController.text.isNotEmpty
          ? double.tryParse(_waistController.text)
          : null,
      thighsCm: _thighsController.text.isNotEmpty
          ? double.tryParse(_thighsController.text)
          : null,
      calfsCm: _calfsController.text.isNotEmpty
          ? double.tryParse(_calfsController.text)
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    context.read<WorkoutBloc>().add(SaveWorkoutCompletion(completion));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final weightTotals = _calculateTotalWeightByExercise();

    return BlocListener<WorkoutBloc, WorkoutState>(
      listener: (context, state) {
        if (state is WorkoutSaved) {
          AppToast.success(context, 'Workout completed');
          // Pop back to main health page
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

        if (state is WorkoutError) {
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message,
          );
        }
      },
      child: Scaffold(
        headers: const [
          AppHeader(title: 'Finish workout', subtitle: 'Optional details'),
        ],
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                    vertical: AppSpacing.lg,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: ContentWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.photoPath != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.section,
                            ),
                            child: ClipRRect(
                              borderRadius: theme.cardRadius,
                              child: Image.file(
                                File(widget.photoPath!),
                                height: 280,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        AppListSection(
                          title: 'Volume',
                          dividerIndent: AppSpacing.md,
                          empty: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Text(
                              'No weighted sets recorded',
                              style: context.text.caption,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          children: [
                            for (final entry in weightTotals.entries)
                              DetailRow(
                                label: entry.key,
                                value: '${entry.value.toStringAsFixed(0)} kg',
                              ),
                            if (weightTotals.isNotEmpty)
                              DetailRow(
                                label: 'Total',
                                valueWidget: AppBadge(
                                  label:
                                      '${weightTotals.values.reduce((a, b) => a + b).toStringAsFixed(0)} kg',
                                  color: context.semantic.info,
                                ),
                              ),
                          ],
                        ),
                        AppListSection(
                          title: 'Body measurements',
                          footer: 'Leave blank anything you did not measure.',
                          dividerIndent: AppSpacing.md,
                          children: [
                            _measurement(
                              _bodyWeightController,
                              'Body weight',
                              'kg',
                              HugeIcons.strokeRoundedWeightScale,
                            ),
                            _measurement(
                              _heightController,
                              'Height',
                              'cm',
                              HugeIcons.strokeRoundedRuler,
                            ),
                            _measurement(
                              _bicepsController,
                              'Biceps',
                              'cm',
                              HugeIcons.strokeRoundedBodyPartMuscle,
                            ),
                            _measurement(
                              _chestController,
                              'Chest',
                              'cm',
                              HugeIcons.strokeRoundedTapeMeasure,
                            ),
                            _measurement(
                              _waistController,
                              'Waist',
                              'cm',
                              HugeIcons.strokeRoundedTapeMeasure,
                            ),
                            _measurement(
                              _thighsController,
                              'Thighs',
                              'cm',
                              HugeIcons.strokeRoundedTapeMeasure,
                            ),
                            _measurement(
                              _calfsController,
                              'Calves',
                              'cm',
                              HugeIcons.strokeRoundedTapeMeasure,
                            ),
                          ],
                        ),
                        AppFormField(
                          label: 'How did it go?',
                          optional: true,
                          child: TextField(
                            controller: _notesController,
                            maxLines: 4,
                            placeholder: const Text(
                              'Felt strong, new PR on squat',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colorScheme.background,
                  border: Border(top: BorderSide(color: colorScheme.border)),
                ),
                child: SafeArea(
                  top: false,
                  child: ContentWidth(
                    child: BlocBuilder<WorkoutBloc, WorkoutState>(
                      builder: (context, state) => FormSubmitButton(
                        label: 'Save workout',
                        loadingLabel: 'Saving…',
                        loading: state is WorkoutLoading,
                        onPressed: _submitCompletion,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Measurement row: label left, numeric input with unit right.
  Widget _measurement(
    TextEditingController controller,
    String label,
    String unit,
    List<List<dynamic>> icon,
  ) {
    return DetailRow(
      icon: icon,
      label: label,
      valueWidget: SizedBox(
        width: 120,
        child: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          placeholder: const Text('—'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          features: [
            InputFeature.trailing(Text(unit, style: context.text.caption)),
          ],
        ),
      ),
    );
  }
}
