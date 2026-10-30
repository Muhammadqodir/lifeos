import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../../../injection.dart';
import '../../data/models/workout_session_dto.dart';
import '../bloc/workout_sessions_bloc.dart';
import '../bloc/workout_sessions_event.dart';
import '../bloc/workout_sessions_state.dart';
import 'workout_session_details_page.dart';
import 'package:lifeos_client/core/ui/ui.dart';
import 'package:lifeos_client/core/utils/date_labels.dart';

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
        headers: [AppHeader(title: "Workout History")],
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    BuildContext parentContext = context;
    return BlocConsumer<WorkoutSessionsBloc, WorkoutSessionsState>(
      listener: (context, state) {
        if (state is WorkoutSessionsDeleteSuccess) {
          AppToast.success(parentContext, 'Workout deleted');
        } else if (state is WorkoutSessionsDeleteError) {
          AppToast.error(
            parentContext,
            'Something went wrong',
            message: state.message,
          );
        }
      },
      builder: (context, state) {
        if (state is WorkoutSessionsLoading) {
          return const LoadingState(message: "Loading workout sessions...");
        }

        if (state is WorkoutSessionsFailure) {
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

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.lg,
      ),
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppListSection(
              title: 'Workouts',
              count: sessions.length,
              margin: EdgeInsets.zero,
              children: [
                for (final session in sessions)
                  _buildSessionCard(context, session),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: isLoadingMore
                    ? const CircularProgressIndicator(size: 20)
                    : hasMore
                    ? OutlineButton(
                        onPressed: () =>
                            _bloc.add(const WorkoutSessionsLoadMore()),
                        child: const Text('Show more'),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, WorkoutSessionDto session) {
    final muscleGroups = <String>{
      for (final exercise in session.exercises)
        if (exercise.exercise?.muscleGroup?.isNotEmpty ?? false)
          exercise.exercise!.muscleGroup!,
    };

    return AppListTile(
      leading: LeadingTile.icon(
        HugeIcons.strokeRoundedDumbbell01,
        color: context.semantic.warning,
      ),
      title: DateLabels.relativeDay(session.startedAt),
      titleTrailing: Text(
        '${DateLabels.time(session.startedAt)} · ${_formatDuration(session.duration)}',
        style: context.text.caption,
      ),
      subtitle: muscleGroups.isEmpty
          ? '${session.exercises.length} exercises'
          : muscleGroups.join(' · '),
      showChevron: true,
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => WorkoutSessionDetailsPage(workout: session),
        ),
      ),
      actions: [
        AppAction(
          label: 'Delete workout',
          icon: HugeIcons.strokeRoundedDelete02,
          destructive: true,
          onSelected: () async {
            final confirmed = await AppDialogs.confirmDelete(
              context,
              itemName: 'workout',
            );
            if (confirmed && context.mounted) {
              _bloc.add(WorkoutSessionsDelete(workoutId: session.id!));
            }
          },
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
