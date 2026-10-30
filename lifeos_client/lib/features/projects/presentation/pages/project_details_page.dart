import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/selectable_group.dart';
import '../../../../injection.dart';
import '../../data/models/project_dto.dart';
import '../../data/models/todo_dto.dart';
import '../bloc/manage_todos_bloc.dart';
import '../bloc/manage_todos_event.dart';
import '../bloc/manage_todos_state.dart';
import '../widgets/plan_date_dialog.dart';
import '../widgets/todo_card.dart';
import 'create_todo_page.dart';
import 'todo_details_page.dart';

/// A project's todos, one page per status.
class ProjectDetailsPage extends StatefulWidget {
  final ProjectDto project;

  const ProjectDetailsPage({super.key, required this.project});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _StatusTab {
  const _StatusTab(this.status, this.label, this.icon, this.emptyText);
  final String status;
  final String label;
  final List<List<dynamic>> icon;
  final String emptyText;
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  static const _tabs = [
    _StatusTab(
      'inbox',
      'Inbox',
      HugeIcons.strokeRoundedInboxDownload,
      'Capture ideas here, then plan them.',
    ),
    _StatusTab(
      'planned',
      'Planned',
      HugeIcons.strokeRoundedCalendar03,
      'Todos with a date show up here.',
    ),
    _StatusTab(
      'in_progress',
      'In progress',
      HugeIcons.strokeRoundedLoading03,
      'Start a todo to track it here.',
    ),
    _StatusTab(
      'blocked',
      'Blocked',
      HugeIcons.strokeRoundedAlertCircle,
      'Nothing is blocked.',
    ),
    _StatusTab(
      'done',
      'Done',
      HugeIcons.strokeRoundedCheckmarkCircle02,
      'Completed todos land here.',
    ),
  ];

  late final ManageTodosBloc _todosBloc;
  late final PageController _pageController;
  int _selectedTabIndex = 0;

  List<String> get _statuses => _tabs.map((t) => t.status).toList();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTabIndex);
    _todosBloc = getIt<ManageTodosBloc>();
    _loadAllData();
  }

  void _loadAllData() {
    _todosBloc.add(
      LoadAllStatuses(projectId: widget.project.id, statuses: _statuses),
    );
  }

  void _loadCurrentTab() {
    _todosBloc.add(
      LoadTodosByStatus(
        projectId: widget.project.id,
        status: _statuses[_selectedTabIndex],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _todosBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ManageTodosBloc>.value(
      value: _todosBloc,
      child: BlocListener<ManageTodosBloc, ManageTodosState>(
        listener: (context, state) {
          if (state is ManageTodosError) {
            AppToast.error(
              context,
              "Couldn't update todos",
              message: state.message,
            );
          } else if (state is TodoStatusUpdated) {
            _loadAllData();
          }
        },
        child: BlocBuilder<ManageTodosBloc, ManageTodosState>(
          builder: (context, state) {
            final counts = state is ManageTodosWithData
                ? state.countsByStatus
                : const <String, int>{};
            return Scaffold(
              headers: [
                AppHeader(
                  title: widget.project.title,
                  subtitle: widget.project.description,
                  onRefresh: _loadAllData,
                  actions: [
                    HeaderAction(
                      icon: HugeIcons.strokeRoundedAdd01,
                      tooltip: 'New todo',
                      label: 'New todo',
                      primary: true,
                      onTap: () => _navigateToCreateTodo(context),
                    ),
                  ],
                  bottom: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      0,
                      AppSpacing.page,
                      AppSpacing.md,
                    ),
                    child: SelectableGroup<int>(
                      scrollable: true,
                      value: _selectedTabIndex,
                      options: [
                        for (var i = 0; i < _tabs.length; i++)
                          SelectableGroupOption(
                            value: i,
                            widget: _tabLabel(
                              _tabs[i],
                              counts[_tabs[i].status] ?? 0,
                              selected: i == _selectedTabIndex,
                            ),
                          ),
                      ],
                      onChanged: (index) => _pageController.animateToPage(
                        index,
                        duration: AppDurations.slow,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                ),
              ],
              child: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ManageTodosState state) {
    if (state is ManageTodosLoading || state is ManageTodosInitial) {
      return const LoadingState(message: 'Loading todos…');
    }
    if (state is! ManageTodosWithData) return const SizedBox.shrink();

    final updatingTodoId = state is TodoStatusUpdating ? state.todoId : null;

    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() => _selectedTabIndex = index);
        _loadCurrentTab();
      },
      children: [
        for (final tab in _tabs)
          _buildTodoList(
            context,
            tab,
            state.todosByStatus[tab.status] ?? const [],
            hasMore: state.hasMoreByStatus[tab.status] ?? false,
            isLoadingMore: state.isLoadingMoreByStatus[tab.status] ?? false,
            updatingTodoId: updatingTodoId,
          ),
      ],
    );
  }

  Widget _buildTodoList(
    BuildContext context,
    _StatusTab tab,
    List<TodoDto> todos, {
    required bool hasMore,
    required bool isLoadingMore,
    required int? updatingTodoId,
  }) {
    if (todos.isEmpty) {
      return EmptyState(
        icon: HugeIcon(icon: tab.icon),
        title: 'No ${tab.label.toLowerCase()} todos',
        description: tab.emptyText,
        action: tab.status == 'inbox'
            ? OutlineButton(
                onPressed: () => _navigateToCreateTodo(context),
                child: const Text('New todo'),
              )
            : null,
      );
    }

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
              margin: EdgeInsets.zero,
              children: [
                for (final todo in todos)
                  TodoCard(
                    todo: todo,
                    isUpdating: updatingTodoId == todo.id,
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => TodoDetailsPage(todo: todo),
                      ),
                    ),
                    onStatusChanged: ({required status, plannedDate}) =>
                        _changeStatus(context, todo, status, plannedDate),
                    onDelete: () => _confirmDelete(context, todo),
                  ),
              ],
            ),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: Center(
                  child: isLoadingMore
                      ? const CircularProgressIndicator(size: 20)
                      : OutlineButton(
                          onPressed: () =>
                              _todosBloc.add(LoadMoreTodos(status: tab.status)),
                          child: const Text('Show more'),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tabLabel(_StatusTab tab, int count, {required bool selected}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(icon: tab.icon, size: AppIconSize.sm),
        const SizedBox(width: AppSpacing.xs + 2),
        Text(tab.label),
        if (count > 0) ...[
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            '$count',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    TodoDto todo,
    String status,
    DateTime? plannedDate,
  ) async {
    var date = plannedDate;
    if (status == 'planned' && date == null) {
      date = await pickPlannedDate(context);
      if (date == null) return;
    }
    _todosBloc.add(
      UpdateTodoStatus(
        todoId: todo.id,
        status: status,
        oldStatus: todo.status,
        plannedDate: date,
      ),
    );
  }

  Future<void> _navigateToCreateTodo(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (_) => CreateTodoPage(projectId: widget.project.id),
      ),
    );
    if (result == true) _todosBloc.add(const RefreshTodos());
  }

  Future<void> _confirmDelete(BuildContext context, TodoDto todo) async {
    final confirmed = await AppDialogs.confirmDelete(
      context,
      itemName: 'todo',
      message: '"${todo.title}" will be removed.',
    );
    if (confirmed) _todosBloc.add(DeleteTodo(todo.id));
  }
}
