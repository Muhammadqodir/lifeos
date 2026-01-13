import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/health/data/models/workout_completion_dto.dart';
import 'package:lifeos_client/features/health/data/models/workout_session_dto.dart';
import 'package:lifeos_client/features/health/presentation/bloc/workout_bloc.dart';
import 'package:lifeos_client/features/health/presentation/bloc/workout_event.dart';
import 'package:lifeos_client/features/health/presentation/bloc/workout_state.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class WorkoutCompletionPage extends StatefulWidget {
  final String photoPath;
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
          showToast(
            context: context,
            location: ToastLocation.topCenter,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Success',
                'Workout completed successfully!',
              );
            },
          );
          // Pop back to main health page
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

        if (state is WorkoutError) {
          showToast(
            context: context,
            location: ToastLocation.topCenter,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Error',
                state.message,
              );
            },
          );
        }
      },
      child: Scaffold(
        headers: [
          CustomAppBar(
            title: 'Complete Workout',
            leftActions: [
              AppBarAction(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                tooltip: 'Back',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Photo Preview
                      Card(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(widget.photoPath),
                                height: 300,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Post-Workout Photo',
                              style: theme.typography.small.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Total Weight Lifted
                      Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Weight Lifted',
                              style: theme.typography.normal.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (weightTotals.isEmpty)
                              Text(
                                'No weight data recorded',
                                style: theme.typography.small.copyWith(
                                  color: colorScheme.mutedForeground,
                                ),
                              )
                            else
                              ...weightTotals.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.key,
                                          style: theme.typography.small,
                                        ),
                                      ),
                                      Text(
                                        '${entry.value.toStringAsFixed(1)} kg',
                                        style: theme.typography.small.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            if (weightTotals.isNotEmpty) ...[
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Grand Total',
                                    style: theme.typography.normal.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${weightTotals.values.reduce((a, b) => a + b).toStringAsFixed(1)} kg',
                                    style: theme.typography.normal.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Measurements
                      Text(
                        'Body Measurements',
                        style: theme.typography.normal.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildMeasurementField(
                        controller: _bodyWeightController,
                        label: 'Body Weight',
                        unit: 'kg',
                        icon: HugeIcons.strokeRoundedDumbbell02,
                      ),
                      const SizedBox(height: 12),

                      _buildMeasurementField(
                        controller: _heightController,
                        label: 'Height',
                        unit: 'cm',
                        icon: HugeIcons.strokeRoundedArrowMoveUpRight,
                      ),
                      const SizedBox(height: 12),

                      _buildMeasurementField(
                        controller: _bicepsController,
                        label: 'Biceps',
                        unit: 'cm',
                        icon: HugeIcons.strokeRoundedDumbbell02,
                      ),
                      const SizedBox(height: 12),

                      _buildMeasurementField(
                        controller: _chestController,
                        label: 'Chest',
                        unit: 'cm',
                        icon: HugeIcons.strokeRoundedDumbbell01,
                      ),
                      const SizedBox(height: 12),

                      _buildMeasurementField(
                        controller: _waistController,
                        label: 'Waist',
                        unit: 'cm',
                        icon: HugeIcons.strokeRoundedTarget01,
                      ),
                      const SizedBox(height: 12),

                      _buildMeasurementField(
                        controller: _thighsController,
                        label: 'Thighs',
                        unit: 'cm',
                        icon: HugeIcons.strokeRoundedFootball,
                      ),
                      const SizedBox(height: 12),

                      _buildMeasurementField(
                        controller: _calfsController,
                        label: 'Calfs',
                        unit: 'cm',
                        icon: HugeIcons.strokeRoundedSquare,
                      ),
                      const SizedBox(height: 24),

                      // Notes
                      Text(
                        'Notes',
                        style: theme.typography.normal.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),

              // Submit Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.border,
                      width: 1,
                    ),
                  ),
                ),
                child: BlocBuilder<WorkoutBloc, WorkoutState>(
                  builder: (context, state) {
                    final isLoading = state is WorkoutLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        onPressed: isLoading ? null : _submitCompletion,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const HugeIcon(
                                    icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                                    size: 18,
                                    strokeWidth: 2.5,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Complete Workout',
                                    style: theme.typography.normal.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementField({
    required TextEditingController controller,
    required String label,
    required String unit,
    required List<List<dynamic>> icon,
  }) {
    return Row(
      children: [
        HugeIcon(
          icon: icon,
          size: 20,
          color: Theme.of(context).colorScheme.mutedForeground,
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).typography.small.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded( 
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: Theme.of(context).typography.small.copyWith(
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
