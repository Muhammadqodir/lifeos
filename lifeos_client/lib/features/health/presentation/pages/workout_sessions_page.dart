import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/theme/app_colors.dart';
import 'package:lifeos_client/utils/dialogs.dart';
import 'package:lifeos_client/utils/toast.dart';
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

  @override
  void initState() {
    super.initState();
    _bloc = getIt<WorkoutSessionsBloc>()..add(const WorkoutSessionsLoad());
  }

  @override
  void dispose() {
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
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<WorkoutSessionsBloc, WorkoutSessionsState>(
      listener: (context, state) {
        if (state is WorkoutSessionsDeleteSuccess) {
          showToast(
            context: context,
            location: ToastLocation.topCenter,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Workout Deleted',
                'The workout has been deleted successfully.',
              );
            },
          );
        } else if (state is WorkoutSessionsDeleteError) {
          showToast(
            context: context,
            location: ToastLocation.topCenter,
            builder: (context, overlay) {
              return Utils.buildToast(context, overlay, 'Error', state.message);
            },
          );
        }
      },
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
            : state is WorkoutSessionsDeleteSuccess
            ? state.sessions
            : state is WorkoutSessionsDeleteError
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
    final hasMore = state is WorkoutSessionsSuccess && state.hasMore;
    final isLoadingMore = state is WorkoutSessionsLoadingMore;

    return CustomScrollView(
      slivers: [
        // Sessions list
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return _buildSessionCard(context, sessions[index]);
          }, childCount: sessions.length),
        ),

        // Load more button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: isLoadingMore
                  ? const CircularProgressIndicator()
                  : hasMore
                  ? Button.outline(
                      onPressed: () {
                        _bloc.add(const WorkoutSessionsLoadMore());
                      },
                      child: const Text('Load More'),
                    )
                  : sessions.length > 10
                  ? Text(
                      'No more workouts',
                      style: Theme.of(context).typography.small.copyWith(
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildSessionCard(BuildContext context, WorkoutSessionDto session) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get unique muscle groups
    final muscleGroups = <String>{};
    for (final exercise in session.exercises) {
      if (exercise.exercise?.muscleGroup != null &&
          exercise.exercise!.muscleGroup!.isNotEmpty) {
        muscleGroups.add(exercise.exercise!.muscleGroup!);
      }
    }

    // Format date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(
      session.startedAt.year,
      session.startedAt.month,
      session.startedAt.day,
    );

    String dateText;
    if (sessionDate == today) {
      dateText = 'Today';
    } else if (sessionDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('MMM d, yyyy').format(session.startedAt);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Tappable(
        lowerBound: 0.98,
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => WorkoutSessionDetailsPage(workout: session),
            ),
          );
        },
        child: Card(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateText,
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  Text(
                    '${DateFormat('h:mm a').format(session.startedAt)} • ${_formatDuration(session.duration)}',
                    style: theme.typography.small.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
              if (muscleGroups.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        runSpacing: 6,
                        spacing: 6,
                        children: muscleGroups.map((muscle) {
                          return SecondaryBadge(
                            child: Text(
                              muscle,
                              style: theme.typography.xSmall.copyWith(),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    IconButton.ghost(
                      size: ButtonSize.xSmall,
                      onPressed: () async {
                        final confirmed = await Dialogs.showConfirmDialog(
                          context: context,
                          title: 'Delete Workout',
                          message:
                              'Are you sure you want to delete this workout? This action cannot be undone.',
                        );
                        if (confirmed == true && context.mounted) {
                          _bloc.add(
                            WorkoutSessionsDelete(workoutId: session.id!),
                          );
                        }
                      },
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedDelete01,
                        color: AppColors.redColor,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
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
