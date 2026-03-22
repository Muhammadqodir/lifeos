import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/empty_state.dart';
import 'package:lifeos_client/core/widgets/error_state.dart';
import 'package:lifeos_client/core/widgets/loading_state.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_bloc.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_event.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_state.dart';
import 'package:lifeos_client/features/home/presentation/widgets/home_habits_section.dart';
import 'package:lifeos_client/features/home/presentation/widgets/todos_list.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_projects_bloc.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_todos_bloc.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_todos_state.dart';
import 'package:lifeos_client/features/projects/presentation/pages/create_todo_page.dart';
import 'package:lifeos_client/features/home/presentation/widgets/projects_list_sheet.dart';
import 'package:lifeos_client/injection.dart';
import 'package:lifeos_client/utils/modal.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageTodosBloc, ManageTodosState>(
      listener: (context, state) {
        if (state is TodoStatusUpdated || state is ManageTodosLoaded) {
          context.read<HomeBloc>().add(const HomeRefreshed());
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Scaffold(
              headers: [
                CustomAppBar(
                  title: _getGreeting(),
                  rightActions: [
                    AppBarAction(
                      icon: HugeIcons.strokeRoundedAdd01,
                      tooltip: 'Quick Add',
                      onTap: () => _showQuickAddMenu(context),
                    ),
                  ],
                ),
              ],
              child: RefreshTrigger(
                key: _refreshTriggerKey,
                onRefresh: () async {
                  context.read<HomeBloc>().add(const HomeRefreshed());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: _buildBody(context, state),
              ),
            );
          },
        ),
    );
  }
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state is HomeLoading || state is HomeInitial) {
      return const LoadingState(message: "Loading your day...");
    }

    if (state is HomeFailure) {
      return ErrorState(
        message: state.message,
        onRetry: () {
          context.read<HomeBloc>().add(const HomeRetried());
        },
      );
    }

    if (state is HomeEmpty) {
      return const EmptyState(
        title: "Welcome to LifeOS",
        description: "Start by creating your first habit or todo!",
      );
    }

    if (state is HomeSuccess) {
      return _buildSuccessContent(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildSuccessContent(BuildContext context, HomeSuccess state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateCard(context, theme, colorScheme),
          const SizedBox(height: 12),

          MainPageTodosList(state: state),

          HomeHabitsSection(habits: state.habitsToday),

          if (state.habitsToday.isEmpty &&
              state.todosToday.isEmpty &&
              state.overdueTodos.isEmpty &&
              state.inProgressTodos.isEmpty &&
              state.inboxTodos.isEmpty) ...[
            const SizedBox(height: 40),
            const Center(
              child: EmptyState(
                title: "All Clear!",
                description: "You have no tasks or habits scheduled for today.",
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedCalendar03,
            color: colorScheme.primaryForeground,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(now),
                style: theme.typography.p.copyWith(
                  color: colorScheme.primaryForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Today',
                style: theme.typography.xSmall.copyWith(
                  color: colorScheme.primaryForeground.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuickAddMenu(BuildContext context) {
    BottomSheetModal.openSheet(
      context: context,
      builder: (context) {
        return BlocProvider(
          create: (_) => getIt<ManageProjectsBloc>(),
          child: const ProjectsListSheet(),
        );
      },
    ).then((selectedProject) {
      if (selectedProject != null && mounted) {
        _navigateToCreateTodo(context, selectedProject.id);
      }
    });
  }

  Future<void> _navigateToCreateTodo(
    BuildContext context,
    int projectId,
  ) async {
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (context) => CreateTodoPage(projectId: projectId),
      ),
    );

    if (result == true && mounted) {
      context.read<HomeBloc>().add(const HomeRefreshed());
    }
  }
}
