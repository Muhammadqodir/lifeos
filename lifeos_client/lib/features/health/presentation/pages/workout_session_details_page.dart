import 'dart:io';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/health/data/models/workout_session_dto.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart';

class WorkoutSessionDetailsPage extends StatelessWidget {
  final WorkoutSessionDto workout;

  const WorkoutSessionDetailsPage({
    super.key,
    required this.workout,
  });

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Map<String, double> _calculateTotalWeightByExercise() {
    final Map<String, double> totals = {};

    for (final exercise in workout.exercises) {
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

  int _getTotalSets() {
    return workout.exercises.fold(
      0,
      (total, exercise) => total + exercise.sets.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final weightTotals = _calculateTotalWeightByExercise();
    final totalVolume = weightTotals.values.fold(0.0, (a, b) => a + b);

    return Scaffold(
      headers: [
        CustomAppBar(
          title: 'Workout Details',
          leftActions: [
            AppBarAction(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              tooltip: 'Back',
              onTap: () => Navigator.of(context).pop(),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Workout Summary Card
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar03,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(workout.startedAt),
                        style: theme.typography.normal.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStat(
                        context,
                        'Duration',
                        _formatDuration(workout.duration),
                        HugeIcons.strokeRoundedClock01,
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        context,
                        'Exercises',
                        workout.exercises.length.toString(),
                        HugeIcons.strokeRoundedDumbbell01,
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        context,
                        'Sets',
                        _getTotalSets().toString(),
                        HugeIcons.strokeRoundedTickDouble02,
                      ),
                    ],
                  ),
                  if (totalVolume > 0) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Volume',
                          style: theme.typography.normal.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${totalVolume.toStringAsFixed(1)} kg',
                          style: theme.typography.large.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (workout.note != null && workout.note!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedNote,
                          size: 18,
                          color: colorScheme.mutedForeground,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            workout.note!,
                            style: theme.typography.small.copyWith(
                              color: colorScheme.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Completion Data (Photo & Measurements)
            if (workout.completion != null) ...[
              Text(
                'Post-Workout Data',
                style: theme.typography.normal.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Photo
              if (workout.completion!.photoPath != null) ...[
                Card(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(workout.completion!.photoPath!),
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
                const SizedBox(height: 12),
              ],

              // Body Measurements
              if (_hasAnyMeasurement()) ...[
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Body Measurements',
                        style: theme.typography.normal.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (workout.completion!.bodyWeightKg != null)
                        _buildMeasurementRow(
                          context,
                          'Body Weight',
                          '${workout.completion!.bodyWeightKg!.toStringAsFixed(1)} kg',
                          HugeIcons.strokeRoundedWeightScale,
                        ),
                      if (workout.completion!.heightCm != null)
                        _buildMeasurementRow(
                          context,
                          'Height',
                          '${workout.completion!.heightCm!.toStringAsFixed(1)} cm',
                          HugeIcons.strokeRoundedRuler,
                        ),
                      if (workout.completion!.bicepsCm != null)
                        _buildMeasurementRow(
                          context,
                          'Biceps',
                          '${workout.completion!.bicepsCm!.toStringAsFixed(1)} cm',
                          HugeIcons.strokeRoundedBodyPartMuscle,
                        ),
                      if (workout.completion!.chestCm != null)
                        _buildMeasurementRow(
                          context,
                          'Chest',
                          '${workout.completion!.chestCm!.toStringAsFixed(1)} cm',
                          HugeIcons.strokeRoundedTapeMeasure,
                        ),
                      if (workout.completion!.waistCm != null)
                        _buildMeasurementRow(
                          context,
                          'Waist',
                          '${workout.completion!.waistCm!.toStringAsFixed(1)} cm',
                          HugeIcons.strokeRoundedTapeMeasure,
                        ),
                      if (workout.completion!.thighsCm != null)
                        _buildMeasurementRow(
                          context,
                          'Thighs',
                          '${workout.completion!.thighsCm!.toStringAsFixed(1)} cm',
                          HugeIcons.strokeRoundedTapeMeasure,
                        ),
                      if (workout.completion!.calfsCm != null)
                        _buildMeasurementRow(
                          context,
                          'Calfs',
                          '${workout.completion!.calfsCm!.toStringAsFixed(1)} cm',
                          HugeIcons.strokeRoundedTapeMeasure,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Completion Notes
              if (workout.completion!.notes != null &&
                  workout.completion!.notes!.isNotEmpty) ...[
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedNote,
                            size: 18,
                            color: colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Completion Notes',
                            style: theme.typography.normal.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        workout.completion!.notes!,
                        style: theme.typography.small.copyWith(
                          color: colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
            ],

            // Exercises
            Text(
              'Exercises',
              style: theme.typography.normal.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ...workout.exercises.map((exercise) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise Header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.exercise?.name ?? 'Unknown Exercise',
                              style: theme.typography.normal.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (weightTotals.containsKey(exercise.exercise?.name))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${weightTotals[exercise.exercise?.name]!.toStringAsFixed(1)} kg',
                                style: theme.typography.small.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (exercise.note != null && exercise.note!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          exercise.note!,
                          style: theme.typography.small.copyWith(
                            color: colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Sets
                      ...exercise.sets.asMap().entries.map((entry) {
                        final index = entry.key;
                        final set = entry.value;
                        final isLast = index == exercise.sets.length - 1;

                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: set.isDone
                                      ? colorScheme.primary
                                      : colorScheme.muted,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: theme.typography.small.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: set.isDone
                                          ? colorScheme.primaryForeground
                                          : colorScheme.mutedForeground,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Row(
                                  children: [
                                    if (set.weightKg != null) ...[
                                      _buildSetDetail(
                                        context,
                                        '${set.weightKg!.toStringAsFixed(1)} kg',
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (set.reps != null) ...[
                                      _buildSetDetail(
                                        context,
                                        '${set.reps} reps',
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (set.durationSeconds != null) ...[
                                      _buildSetDetail(
                                        context,
                                        '${set.durationSeconds}s',
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (set.distanceMeters != null) ...[
                                      _buildSetDetail(
                                        context,
                                        '${set.distanceMeters}m',
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (set.rpe != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getRpeColor(set.rpe!, colorScheme)
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'RPE',
                                              style: theme.typography.xSmall.copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: _getRpeColor(
                                                  set.rpe!,
                                                  colorScheme,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${set.rpe}',
                                              style: theme.typography.xSmall.copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: _getRpeColor(
                                                  set.rpe!,
                                                  colorScheme,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    List<List<dynamic>> icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: icon,
                size: 14,
                color: colorScheme.mutedForeground,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.typography.xSmall.copyWith(
                  color: colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.typography.normal.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementRow(
    BuildContext context,
    String label,
    String value,
    List<List<dynamic>> icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          HugeIcon(
            icon: icon,
            size: 18,
            color: colorScheme.mutedForeground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.typography.small,
            ),
          ),
          Text(
            value,
            style: theme.typography.small.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetDetail(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.muted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.typography.small.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getRpeColor(int rpe, ColorScheme colorScheme) {
    if (rpe <= 3) {
      return const Color(0xFF10B981); // green
    } else if (rpe <= 6) {
      return const Color(0xFFF59E0B); // yellow/orange
    } else {
      return const Color(0xFFEF4444); // red
    }
  }

  bool _hasAnyMeasurement() {
    if (workout.completion == null) return false;
    return workout.completion!.bodyWeightKg != null ||
        workout.completion!.heightCm != null ||
        workout.completion!.bicepsCm != null ||
        workout.completion!.chestCm != null ||
        workout.completion!.waistCm != null ||
        workout.completion!.thighsCm != null ||
        workout.completion!.calfsCm != null;
  }
}
