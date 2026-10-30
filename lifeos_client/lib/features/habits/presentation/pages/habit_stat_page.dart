import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/widgets/activity_indicator.dart';
import '../../../../injection.dart';
import '../../data/models/habit_dto.dart';
import '../bloc/habit_stats_bloc.dart';
import '../bloc/habit_stats_event.dart';
import '../bloc/habit_stats_state.dart';

/// Streaks, completion and activity history for one habit.
class HabitStatPage extends StatelessWidget {
  final HabitDto habit;

  /// Replaces the default "pop with true" after archiving, for when the
  /// page is shown beside the list (split view) rather than pushed.
  final VoidCallback? onArchived;

  const HabitStatPage({super.key, required this.habit, this.onArchived});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HabitStatsBloc(habitsRepository: getIt())
            ..add(LoadHabitStats(habit.id)),
      child: _HabitStatView(habit: habit, onArchived: onArchived),
    );
  }
}

class _HabitStatView extends StatelessWidget {
  const _HabitStatView({required this.habit, this.onArchived});

  final HabitDto habit;
  final VoidCallback? onArchived;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String get _frequency {
    if (habit.frequency == 'weekly' && habit.frequencyDays.isNotEmpty) {
      return habit.frequencyDays.map((i) => _weekdays[i % 7]).join(', ');
    }
    return switch (habit.frequency) {
      'daily' => 'Every day',
      'weekly' => 'Weekly',
      'monthly' => 'Monthly',
      _ => habit.frequency,
    };
  }

  Future<void> _confirmArchive(BuildContext context) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: 'Archive habit?',
      message:
          '"${habit.title}" will be hidden from your daily list. Its history is kept.',
      confirmLabel: 'Archive',
    );
    if (confirmed && context.mounted) {
      context.read<HabitStatsBloc>().add(ArchiveHabit(habit.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(habit.color);
    final text = context.text;

    return BlocListener<HabitStatsBloc, HabitStatsState>(
      listener: (context, state) {
        if (state is HabitArchived) {
          AppToast.success(context, 'Habit archived');
          if (onArchived != null) {
            onArchived!();
          } else {
            Navigator.of(context).pop(true);
          }
        } else if (state is HabitStatsError) {
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message,
          );
        }
      },
      child: Scaffold(
        headers: [
          AppHeader(
            title: habit.title,
            actions: [
              HeaderAction(
                icon: HugeIcons.strokeRoundedArchive,
                tooltip: 'Archive habit',
                onTap: () => _confirmArchive(context),
              ),
            ],
          ),
        ],
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.page,
            vertical: AppSpacing.lg,
          ),
          child: ContentWidth(
            child: BlocBuilder<HabitStatsBloc, HabitStatsState>(
              builder: (context, state) {
                final stats = state is HabitStatsLoaded ? state.stats : null;
                final current =
                    stats?.currentStreak ?? habit.currentStreak ?? 0;
                final longest =
                    stats?.longestStreak ?? habit.longestStreak ?? 0;
                final rate =
                    stats?.completionRate ?? habit.completionRate ?? 0.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      child: Row(
                        children: [
                          LeadingTile.icon(
                            HugeIcons.strokeRoundedFire,
                            color: color,
                            size: 44,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(habit.title, style: text.sectionTitle),
                                if ((habit.description ?? '').isNotEmpty)
                                  Text(
                                    habit.description!,
                                    style: text.itemSubtitle,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    StatGrid(
                      children: [
                        StatTile(
                          label: 'Current streak',
                          value: '$current',
                          caption: current == 1 ? 'day' : 'days',
                          icon: HugeIcons.strokeRoundedFire,
                          color: context.semantic.warning,
                        ),
                        StatTile(
                          label: 'Longest streak',
                          value: '$longest',
                          caption: longest == 1 ? 'day' : 'days',
                          icon: HugeIcons.strokeRoundedAward01,
                          color: context.semantic.info,
                        ),
                        StatTile(
                          label: 'Completion',
                          value: '${rate.toStringAsFixed(0)}%',
                          caption: 'since start',
                          icon: HugeIcons.strokeRoundedAnalytics01,
                          color: context.semantic.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CardHeader(
                            title: 'Activity',
                            subtitle: 'Last 6 months',
                          ),
                          _activity(context, state),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    AppListSection(
                      title: 'Schedule',
                      dividerIndent: AppSpacing.md,
                      children: [
                        DetailRow(
                          icon: HugeIcons.strokeRoundedCalendar03,
                          label: 'Frequency',
                          value: _frequency,
                        ),
                        if (habit.reminderTime != null)
                          DetailRow(
                            icon: HugeIcons.strokeRoundedClock01,
                            label: 'Reminder',
                            value: habit.reminderTime!,
                          ),
                        if (habit.goalDuration != null)
                          DetailRow(
                            icon: HugeIcons.strokeRoundedFlag02,
                            label: 'Goal',
                            value: '${habit.goalDuration} days',
                          ),
                      ],
                    ),
                    if (habit.tags.isNotEmpty) ...[
                      const SectionHeader(title: 'Tags'),
                      Wrap(
                        spacing: AppSpacing.xs + 2,
                        runSpacing: AppSpacing.xs + 2,
                        children: [
                          for (final tag in habit.tags)
                            AppBadge.outline(label: tag),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _activity(BuildContext context, HabitStatsState state) {
    if (state is HabitStatsLoaded) {
      final now = DateTime.now();
      return ActivityIndicatorChart(
        data: [
          for (final entry in state.entries)
            ActivityInficatorChartData(
              date: DateTime.parse(entry.date),
              data: entry,
            ),
        ],
        startDate: now.subtract(const Duration(days: 180)),
        endDate: now,
      );
    }
    if (state is HabitStatsError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: Text("Couldn't load activity", style: context.text.caption),
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(child: CircularProgressIndicator(size: 20)),
    );
  }
}
