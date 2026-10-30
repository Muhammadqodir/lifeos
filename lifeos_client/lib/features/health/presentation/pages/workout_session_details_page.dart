import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/utils/date_labels.dart';
import '../../../../utils/server.dart';
import '../../data/models/workout_exercise_dto.dart';
import '../../data/models/workout_session_dto.dart';
import '../../data/models/workout_set_dto.dart';

/// Summary of a finished workout: totals, sets per exercise, post-workout
/// photo and measurements.
class WorkoutSessionDetailsPage extends StatelessWidget {
  final WorkoutSessionDto workout;

  const WorkoutSessionDetailsPage({super.key, required this.workout});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  /// Weight × reps per exercise, keyed by position so duplicates don't merge.
  List<double> get _volumes => [
    for (final exercise in workout.exercises)
      exercise.sets.fold<double>(
        0,
        (sum, set) => set.weightKg != null && set.reps != null
            ? sum + set.weightKg! * set.reps!
            : sum,
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final volumes = _volumes;
    final totalVolume = volumes.fold<double>(0, (a, b) => a + b);
    final totalSets = workout.exercises.fold<int>(
      0,
      (total, e) => total + e.sets.length,
    );
    final completion = workout.completion;

    return Scaffold(
      headers: [
        AppHeader(
          title: DateLabels.relativeDay(workout.startedAt),
          subtitle: DateFormat(
            'EEEE, d MMMM y · HH:mm',
          ).format(workout.startedAt),
        ),
      ],
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
              StatGrid(
                children: [
                  _stat(
                    'Duration',
                    _formatDuration(workout.duration),
                    HugeIcons.strokeRoundedClock01,
                  ),
                  _stat(
                    'Exercises',
                    '${workout.exercises.length}',
                    HugeIcons.strokeRoundedDumbbell01,
                  ),
                  _stat('Sets', '$totalSets', HugeIcons.strokeRoundedTickDouble02),
                  if (totalVolume > 0)
                    _stat(
                      'Volume',
                      '${totalVolume.toStringAsFixed(0)} kg',
                      HugeIcons.strokeRoundedWeightScale,
                    ),
                ],
              ),
              if (workout.note?.isNotEmpty ?? false) ...[
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CardHeader(
                        title: 'Note',
                        padding: EdgeInsets.only(bottom: AppSpacing.xs),
                      ),
                      Text(workout.note!, style: context.text.body),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.section),
              for (var i = 0; i < workout.exercises.length; i++)
                _exerciseSection(context, workout.exercises[i], volumes[i]),
              if (completion != null) ...[
                if (completion.photoPath != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.section),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader(title: 'Progress photo'),
                        ClipRRect(
                          borderRadius: context.theme.cardRadius,
                          child: CachedNetworkImage(
                            imageUrl: StorageUrl.resolve(completion.photoPath!),
                            height: 320,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_hasAnyMeasurement())
                  AppListSection(
                    title: 'Body measurements',
                    dividerIndent: AppSpacing.md,
                    children: [
                      for (final (label, value, unit, icon) in [
                        (
                          'Body weight',
                          completion.bodyWeightKg,
                          'kg',
                          HugeIcons.strokeRoundedWeightScale,
                        ),
                        (
                          'Height',
                          completion.heightCm,
                          'cm',
                          HugeIcons.strokeRoundedRuler,
                        ),
                        (
                          'Biceps',
                          completion.bicepsCm,
                          'cm',
                          HugeIcons.strokeRoundedBodyPartMuscle,
                        ),
                        (
                          'Chest',
                          completion.chestCm,
                          'cm',
                          HugeIcons.strokeRoundedTapeMeasure,
                        ),
                        (
                          'Waist',
                          completion.waistCm,
                          'cm',
                          HugeIcons.strokeRoundedTapeMeasure,
                        ),
                        (
                          'Thighs',
                          completion.thighsCm,
                          'cm',
                          HugeIcons.strokeRoundedTapeMeasure,
                        ),
                        (
                          'Calves',
                          completion.calfsCm,
                          'cm',
                          HugeIcons.strokeRoundedTapeMeasure,
                        ),
                      ])
                        if (value != null)
                          DetailRow(
                            icon: icon,
                            label: label,
                            value: '${value.toStringAsFixed(1)} $unit',
                          ),
                    ],
                  ),
                if (completion.notes?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.section),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CardHeader(
                            title: 'How it went',
                            padding: EdgeInsets.only(bottom: AppSpacing.xs),
                          ),
                          Text(completion.notes!, style: context.text.body),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, List<List<dynamic>> icon) =>
      StatTile(label: label, value: value, icon: icon);

  Widget _exerciseSection(
    BuildContext context,
    WorkoutExerciseDto exercise,
    double volume,
  ) {
    return AppListSection(
      title: exercise.exercise?.name ?? 'Exercise',
      headerTrailing: volume > 0
          ? AppBadge(
              label: '${volume.toStringAsFixed(0)} kg',
              color: context.semantic.info,
            )
          : null,
      footer: (exercise.note?.isNotEmpty ?? false) ? exercise.note : null,
      dividerIndent: AppSpacing.md + 28 + AppSpacing.md,
      children: [
        for (var i = 0; i < exercise.sets.length; i++)
          _SetRow(index: i, set: exercise.sets[i]),
      ],
    );
  }

  bool _hasAnyMeasurement() {
    final c = workout.completion;
    if (c == null) return false;
    return [
      c.bodyWeightKg,
      c.heightCm,
      c.bicepsCm,
      c.chestCm,
      c.waistCm,
      c.thighsCm,
      c.calfsCm,
    ].any((v) => v != null);
  }
}

/// One set: number (filled when done) followed by its metrics.
class _SetRow extends StatelessWidget {
  const _SetRow({required this.index, required this.set});

  final int index;
  final WorkoutSetDto set;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantic = context.semantic;
    final metrics = [
      if (set.weightKg != null) '${set.weightKg!.toStringAsFixed(1)} kg',
      if (set.reps != null) '${set.reps} reps',
      if (set.durationSeconds != null) '${set.durationSeconds} s',
      if (set.distanceMeters != null) '${set.distanceMeters} m',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: set.isDone ? colors.primary : colors.muted,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: context.text.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: set.isDone
                    ? colors.primaryForeground
                    : colors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              metrics.isEmpty ? 'No data' : metrics.join(' · '),
              style: context.text.itemTitle.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (set.rpe != null)
            AppBadge(
              label: 'RPE ${set.rpe}',
              color: set.rpe! <= 3
                  ? semantic.success
                  : set.rpe! <= 6
                  ? semantic.warning
                  : semantic.danger,
            ),
        ],
      ),
    );
  }
}
