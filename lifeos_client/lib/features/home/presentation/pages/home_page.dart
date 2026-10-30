import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../injection.dart';
import '../../../../utils/modal.dart';
import '../../../projects/data/models/project_dto.dart';
import '../../../projects/presentation/bloc/manage_projects_bloc.dart';
import '../../../projects/presentation/bloc/manage_todos_bloc.dart';
import '../../../projects/presentation/bloc/manage_todos_state.dart';
import '../../../projects/presentation/pages/create_todo_page.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_habits_section.dart';
import '../widgets/projects_list_sheet.dart';
import '../widgets/todos_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  void _refresh() => context.read<HomeBloc>().add(const HomeRefreshed());

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageTodosBloc, ManageTodosState>(
      listener: (context, state) {
        if (state is TodoStatusUpdated || state is ManageTodosLoaded) {
          _refresh();
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            headers: [
              AppHeader(
                title: _greeting(),
                subtitle: DateFormat('EEEE, d MMMM').format(DateTime.now()),
                onRefresh: _refresh,
                actions: [
                  HeaderAction(
                    icon: HugeIcons.strokeRoundedAdd01,
                    tooltip: 'New todo',
                    label: 'New todo',
                    primary: true,
                    onTap: () => _showQuickAdd(context),
                  ),
                ],
              ),
            ],
            child: RefreshTrigger(
              key: _refreshTriggerKey,
              onRefresh: () async {
                _refresh();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: _buildBody(context, state),
            ),
          );
        },
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state is HomeLoading || state is HomeInitial) {
      return const LoadingState(message: 'Loading your day…');
    }

    if (state is HomeFailure) {
      return ErrorState(
        message: state.message,
        onRetry: () => context.read<HomeBloc>().add(const HomeRetried()),
      );
    }

    if (state is HomeEmpty) {
      return _welcome(context);
    }

    if (state is HomeSuccess) {
      final nothingToday =
          state.habitsToday.isEmpty &&
          state.todosToday.isEmpty &&
          state.overdueTodos.isEmpty &&
          state.inProgressTodos.isEmpty &&
          state.inboxTodos.isEmpty;

      return LayoutBuilder(
        builder: (context, constraints) {
          final useBoard = constraints.maxWidth >= 900;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.page,
              vertical: AppSpacing.lg,
            ),
            child: ContentWidth(
              maxWidth: useBoard
                  ? AppLayout.maxWideContentWidth + 200
                  : AppLayout.maxContentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (nothingToday)
                    _allClear(context)
                  else ...[
                    MainPageTodosList(state: state, useBoard: useBoard),
                    HomeHabitsSection(habits: state.habitsToday),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _welcome(BuildContext context) {
    return EmptyState(
      icon: const HugeIcon(icon: HugeIcons.strokeRoundedSparkles),
      title: 'Plan your first day',
      description: 'Add a todo or start a habit and it will show up here.',
      action: PrimaryButton(
        onPressed: () => _showQuickAdd(context),
        child: const Text('New todo'),
      ),
    );
  }

  Widget _allClear(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: EmptyState(
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle02),
        color: context.semantic.success,
        title: "You're all clear",
        description: 'Nothing is scheduled for today.',
        action: OutlineButton(
          onPressed: () => _showQuickAdd(context),
          child: const Text('New todo'),
        ),
      ),
    );
  }

  Future<void> _showQuickAdd(BuildContext context) async {
    final selectedProject = await BottomSheetModal.openSheet<ProjectDto>(
      context: context,
      builder: (context) => BlocProvider(
        create: (_) => getIt<ManageProjectsBloc>(),
        child: const ProjectsListSheet(),
      ),
    );
    if (selectedProject == null || !context.mounted) return;

    final created = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (_) => CreateTodoPage(projectId: selectedProject.id),
      ),
    );
    if (created == true && context.mounted) _refresh();
  }
}
