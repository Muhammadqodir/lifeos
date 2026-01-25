import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../../injection.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../../data/models/workout_session_dto.dart';
import '../bloc/workout_sessions_bloc.dart';
import '../bloc/workout_sessions_event.dart';
import '../bloc/workout_sessions_state.dart';
import 'workout_session_details_page.dart';

class WorkoutSessionsPage extends StatefulWidget {
  const WorkoutSessionsPage({super.key});

  @override
  State<WorkoutSessionsPage> createState() => _WorkoutSessionsPageState();
}

class _WorkoutSessionsPageState extends State<WorkoutSessionsPage> {
  late final WorkoutSessionsBloc _bloc;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  @override
  void initState() {
    super.initState();
    _bloc = getIt<WorkoutSessionsBloc>()..add(const WorkoutSessionsLoad());

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      _bloc.add(const WorkoutSessionsLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WorkoutSessionsBloc>.value(
      value: _bloc,
      child: Scaffold(
        headers: [
          CustomAppBar(
            title: "Workout History",
            leftActions: [
              AppBarAction(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                tooltip: 'Back',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
        child: RefreshTrigger(
          key: _refreshTriggerKey,
          onRefresh: () async {
            _bloc.add(const WorkoutSessionsRefresh());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<WorkoutSessionsBloc, WorkoutSessionsState>(
      builder: (context, state) {
        if (state is WorkoutSessionsLoading) {
          return const LoadingState(message: "Loading workout sessions...");
        }

        if (state is WorkoutSessionsFailure) {
          print('WorkoutSessionsFailure: ${state.message}');
          return ErrorState(
            message: state.message,
            onRetry: () {
              _bloc.add(const WorkoutSessionsLoad());
            },
          );
        }

        if (state is WorkoutSessionsEmpty) {
          return EmptyState(
            title: 'No Workouts Yet',
            description: 'Start your first workout to see your history here',
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedDumbbell01,
              size: 24,
            ),
          );
        }

        final sessions = state is WorkoutSessionsSuccess
            ? state.sessions
            : state is WorkoutSessionsLoadingMore
            ? state.sessions
            : <WorkoutSessionDto>[];

        if (sessions.isEmpty) {
          return const EmptyState(
            title: 'No Workouts Yet',
            description: 'Start your first workout to see your history here',
            icon: HugeIcon(icon: HugeIcons.strokeRoundedDumbbell01, size: 24),
          );
        }

        return _buildSessionsList(context, sessions, state);
      },
    );
  }

  Widget _buildSessionsList(
    BuildContext context,
    List<WorkoutSessionDto> sessions,
    WorkoutSessionsState state,
  ) {
    // Group sessions by date
    final groupedSessions = _groupSessionsByDate(sessions);
    final dates = groupedSessions.keys.toList()..sort((a, b) => b.compareTo(a));

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Stats Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildStatsCard(context, sessions),
          ),
        ),

        // Sessions grouped by date
        ...dates.map((date) {
          final dateSessions = groupedSessions[date]!;
          return SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(child: _buildDateHeader(context, date)),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildSessionCard(context, dateSessions[index]);
                }, childCount: dateSessions.length),
              ),
            ],
          );
        }),

        // Loading more indicator
        if (state is WorkoutSessionsLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Map<String, List<WorkoutSessionDto>> _groupSessionsByDate(
    List<WorkoutSessionDto> sessions,
  ) {
    final Map<String, List<WorkoutSessionDto>> grouped = {};

    for (final session in sessions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(session.startedAt);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(session);
    }

    return grouped;
  }

  Widget _buildStatsCard(
    BuildContext context,
    List<WorkoutSessionDto> sessions,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate stats
    final totalWorkouts = sessions.length;
    final totalDuration = sessions.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + session.duration,
    );
    final totalSets = sessions.fold<int>(
      0,
      (sum, session) =>
          sum +
          session.exercises.fold<int>(
            0,
            (exerciseSum, exercise) => exerciseSum + exercise.sets.length,
          ),
    );

    final avgDuration = totalWorkouts > 0
        ? Duration(seconds: totalDuration.inSeconds ~/ totalWorkouts)
        : Duration.zero;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: theme.typography.semiBold.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Workouts',
                  totalWorkouts.toString(),
                  HugeIcons.strokeRoundedDumbbell01,
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Total Time',
                  _formatDuration(totalDuration),
                  HugeIcons.strokeRoundedClock01,
                  colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Avg Duration',
                  _formatDuration(avgDuration),
                  HugeIcons.strokeRoundedTimer01,
                  colorScheme.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Total Sets',
                  totalSets.toString(),
                  HugeIcons.strokeRoundedTickDouble02,
                  colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    dynamic iconData,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(icon: iconData, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.typography.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.typography.semiBold.copyWith(
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, String date) {
    final theme = Theme.of(context);
    final parsedDate = DateTime.parse(date);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
    );

    String displayText;
    if (sessionDate == today) {
      displayText = 'Today';
    } else if (sessionDate == yesterday) {
      displayText = 'Yesterday';
    } else {
      displayText = DateFormat('EEEE, MMMM d').format(parsedDate);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        displayText,
        style: theme.typography.semiBold.copyWith(
          fontSize: 14,
          color: theme.colorScheme.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, WorkoutSessionDto session) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate session stats
    final exerciseCount = session.exercises.length;
    final setCount = session.exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets.length,
    );

    // Calculate total volume
    double totalVolume = 0;
    for (final exercise in session.exercises) {
      for (final set in exercise.sets) {
        if (set.weightKg != null && set.reps != null) {
          totalVolume += set.weightKg! * set.reps!;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Tappable(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => WorkoutSessionDetailsPage(workout: session),
            ),
          );
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedDumbbell01,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('h:mm a').format(session.startedAt),
                            style: theme.typography.semiBold.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDuration(session.duration),
                            style: theme.typography.small.copyWith(
                              color: colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSessionStat(
                      context,
                      'Exercises',
                      exerciseCount.toString(),
                      HugeIcons.strokeRoundedActivity01,
                    ),
                    const SizedBox(width: 16),
                    _buildSessionStat(
                      context,
                      'Sets',
                      setCount.toString(),
                      HugeIcons.strokeRoundedTickDouble02,
                    ),
                    if (totalVolume > 0) ...[
                      const SizedBox(width: 16),
                      _buildSessionStat(
                        context,
                        'Volume',
                        '${totalVolume.toStringAsFixed(0)} kg',
                        HugeIcons.strokeRoundedChartUp,
                      ),
                    ],
                  ],
                ),
                if (session.note != null && session.note!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedNote,
                        size: 16,
                        color: colorScheme.mutedForeground,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          session.note!,
                          style: theme.typography.small.copyWith(
                            color: colorScheme.mutedForeground,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionStat(
    BuildContext context,
    String label,
    String value,
    dynamic iconData,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        HugeIcon(icon: iconData, size: 14, color: colorScheme.mutedForeground),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: theme.typography.small.copyWith(
            color: colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
