import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/activity_indicator.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habit_stats_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habit_stats_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habit_stats_state.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/injection.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class HabitStatPage extends StatefulWidget {
  final HabitDto habit;

  const HabitStatPage({super.key, required this.habit});

  @override
  State<HabitStatPage> createState() => _HabitStatPageState();
}

class _HabitStatPageState extends State<HabitStatPage> {
  Color _getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Color(int.parse(hex, radix: 16));
  }

  String _getFrequencyText() {
    switch (widget.habit.frequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        if (widget.habit.frequencyDays.isEmpty) {
          return 'Weekly';
        }
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final selectedDays = widget.habit.frequencyDays
            .map((index) => days[index])
            .join(', ');
        return selectedDays;
      default:
        return widget.habit.frequency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final habitColor = _getColorFromHex(widget.habit.color);

    return BlocProvider(
      create: (context) =>
          HabitStatsBloc(habitsRepository: getIt())
            ..add(LoadHabitStats(widget.habit.id)),
      child: Scaffold(
        headers: [
          CustomAppBar(
            title: widget.habit.title,
            leftActions: [
              AppBarAction(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                tooltip: 'Back',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
            rightActions: [
              AppBarAction(
                icon: HugeIcons.strokeRoundedArchive,
                tooltip: "Archive",
                onTap: () {
                  //realize archive functionality here
                },
              ),
            ],
          ),
        ],
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Habit Info Card
              Card(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 38,
                          decoration: BoxDecoration(
                            color: habitColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.habit.title,
                                style: theme.typography.normal.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.habit.description != null) ...[
                                Text(
                                  widget.habit.description!,
                                  style: theme.typography.xSmall.copyWith(
                                    color: colorScheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: colorScheme.border),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            context,
                            HugeIcons.strokeRoundedCalendar03,
                            'Frequency',
                            _getFrequencyText(),
                          ),
                        ),
                        if (widget.habit.reminderTime != null)
                          Expanded(
                            child: _buildInfoItem(
                              context,
                              HugeIcons.strokeRoundedClock01,
                              'Reminder',
                              widget.habit.reminderTime!,
                            ),
                          ),
                      ],
                    ),
                    if (widget.habit.goalDuration != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        context,
                        HugeIcons.strokeRoundedFlag02,
                        'Goal',
                        '${widget.habit.goalDuration} days',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      HugeIcons.strokeRoundedFire,
                      'Current Streak',
                      '${widget.habit.currentStreak ?? 0}',
                      'days',
                      colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      HugeIcons.strokeRoundedAward01,
                      'Longest Streak',
                      '${widget.habit.longestStreak ?? 0}',
                      'days',
                      colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                context,
                HugeIcons.strokeRoundedAnalytics01,
                'Completion Rate',
                (widget.habit.completionRate ?? 0).toStringAsFixed(0),
                '%',
                colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Card(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity',
                      style: theme.typography.small.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<HabitStatsBloc, HabitStatsState>(
                      builder: (context, state) {
                        if (state is HabitStatsLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (state is HabitStatsError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                'Failed to load stats',
                                style: theme.typography.small.copyWith(
                                  color: colorScheme.destructive,
                                ),
                              ),
                            ),
                          );
                        }

                        if (state is HabitStatsLoaded) {
                          return ActivityIndicatorChart(
                            data: state.entries
                                .map(
                                  (entry) => ActivityInficatorChartData(
                                    date: DateTime.parse(entry.date),
                                    data: entry,
                                  ),
                                )
                                .toList(),
                            startDate: DateTime.now().subtract(
                              Duration(days: 180),
                            ),
                            endDate: DateTime.now(),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tags if available
              if (widget.habit.tags.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tags',
                          style: theme.typography.small.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.habit.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.muted,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(tag, style: theme.typography.xSmall),
                            );
                          }).toList(),
                        ),
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

  Widget _buildInfoItem(
    BuildContext context,
    dynamic icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        HugeIcon(icon: icon, size: 16, color: colorScheme.mutedForeground),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.typography.xSmall.copyWith(
                color: colorScheme.mutedForeground,
              ),
            ),
            Text(
              value,
              style: theme.typography.small.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    dynamic icon,
    String label,
    String value,
    String unit,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      padding: EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: HugeIcon(icon: icon, size: 20, color: accentColor),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.typography.xSmall.copyWith(
                  color: colorScheme.mutedForeground,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: theme.typography.xSmall.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
