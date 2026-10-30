import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/kanban_board.dart';
import '../../../projects/data/models/todo_dto.dart';
import '../../../projects/presentation/bloc/manage_todos_bloc.dart';
import '../../../projects/presentation/bloc/manage_todos_event.dart';
import '../../../projects/presentation/bloc/manage_todos_state.dart';
import '../../../projects/presentation/pages/todo_details_page.dart';
import '../../../projects/presentation/widgets/plan_date_dialog.dart';
import '../../../projects/presentation/widgets/todo_card.dart';
import '../bloc/home_state.dart';

class _ColumnData {
  final String title;
  final List<TodoDto> todos;
  final Color color;

  /// null = read-only column (no drop accepted)
  final String? targetStatus;
  final DateTime? targetPlannedDate;

  const _ColumnData({
    required this.title,
    required this.todos,
    required this.color,
    this.targetStatus,
    this.targetPlannedDate,
  });
}

/// Today's todos: grouped lists on narrow layouts, a drag-and-drop board
/// when there is room for four columns.
class MainPageTodosList extends StatefulWidget {
  const MainPageTodosList({
    super.key,
    required this.state,
    this.useBoard = false,
  });

  final HomeSuccess state;
  final bool useBoard;

  @override
  State<MainPageTodosList> createState() => _MainPageTodosListState();
}

class _MainPageTodosListState extends State<MainPageTodosList> {
  List<_ColumnData> _columns(BuildContext context) {
    final semantic = context.semantic;
    final today = DateTime.now();
    return [
      _ColumnData(
        title: 'Overdue',
        todos: widget.state.overdueTodos,
        color: semantic.danger,
        targetStatus: null, // read-only — overdue is a derived view
      ),
      _ColumnData(
        title: 'Today',
        todos: widget.state.todosToday,
        color: semantic.success,
        targetStatus: 'planned',
        targetPlannedDate: DateTime(today.year, today.month, today.day),
      ),
      _ColumnData(
        title: 'In progress',
        todos: widget.state.inProgressTodos,
        color: semantic.warning,
        targetStatus: 'in_progress',
      ),
      _ColumnData(
        title: 'Inbox',
        todos: widget.state.inboxTodos,
        color: semantic.neutral,
        targetStatus: 'inbox',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Changes are saved on the device at once, so there is no "updating"
    // state to show; only a local failure is reported.
    return BlocListener<ManageTodosBloc, ManageTodosState>(
      listenWhen: (_, state) => state is ManageTodosError,
      listener: (context, state) => AppToast.error(
        context,
        "Couldn't update todo",
        message: (state as ManageTodosError).message,
      ),
      child: widget.useBoard
          ? _buildKanbanBoard(context)
          : _buildListView(context),
    );
  }

  // ─── List view (iPhone, narrow windows) ───────────────────────────

  Widget _buildListView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final col in _columns(context))
          if (col.todos.isNotEmpty)
            AppListSection(
              title: col.title,
              count: col.todos.length,
              children: [
                for (final todo in col.todos)
                  _buildTodoTile(context, todo, showProject: true),
              ],
            ),
      ],
    );
  }

  // ─── Kanban board (iPad landscape, Mac) ───────────────────────────

  Widget _buildKanbanBoard(BuildContext context) {
    final columns = _columns(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.section),
      child: KanbanBoard<TodoDto>(
        columns: columns
            .map(
              (col) => KanbanColumnConfig<TodoDto>(
                title: col.title,
                items: col.todos,
                color: col.color,
                isDroppable: col.targetStatus != null,
              ),
            )
            .toList(),
        emptyText: 'Nothing here',
        itemBuilder: (context, todo, isDragging) => Opacity(
          opacity: isDragging ? 0.3 : 1.0,
          child: _buildTodoTile(context, todo, kanbanMode: true),
        ),
        feedbackBuilder: _buildDragFeedback,
        onItemDropped: (todo, columnIndex) {
          final col = columns[columnIndex];
          if (col.targetStatus == null) return;

          // Skip if already in this column
          final alreadySameStatus = todo.status == col.targetStatus;
          final alreadySamePlannedDate =
              col.targetPlannedDate == null ||
              (todo.plannedDate != null &&
                  _isSameDay(todo.plannedDate!, col.targetPlannedDate!));
          if (alreadySameStatus && alreadySamePlannedDate) return;

          _handleTodoStatusChanged(
            context,
            todo.id,
            todo.status,
            col.targetStatus!,
            col.targetPlannedDate,
          );
        },
      ),
    );
  }

  Widget _buildDragFeedback(BuildContext context, TodoDto todo, double width) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: context.theme.controlRadius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TodoCard(
          todo: todo,
          kanbanMode: true,
          showProject: true,
          onTap: () {},
          onStatusChanged: ({plannedDate, required status}) {},
          onDelete: () {},
        ),
      ),
    );
  }

  // ─── Shared ───────────────────────────────────────────────────────

  Widget _buildTodoTile(
    BuildContext context,
    TodoDto todo, {
    bool kanbanMode = false,
    bool showProject = true,
  }) {
    return TodoCard(
      todo: todo,
      showProject: showProject,
      kanbanMode: kanbanMode,
      onTap: () => Navigator.of(
        context,
      ).push(CupertinoPageRoute(builder: (_) => TodoDetailsPage(todo: todo))),
      onStatusChanged: ({plannedDate, required status}) =>
          _handleTodoStatusChanged(
            context,
            todo.id,
            todo.status,
            status,
            plannedDate,
          ),
      onDelete: () => _handleTodoDelete(context, todo),
    );
  }

  Future<void> _handleTodoDelete(BuildContext context, TodoDto todo) async {
    final confirmed = await AppDialogs.confirmDelete(
      context,
      itemName: 'todo',
      message: '"${todo.title}" will be removed.',
    );
    if (confirmed && context.mounted) {
      context.read<ManageTodosBloc>().add(DeleteTodo(todo.id));
    }
  }

  Future<void> _handleTodoStatusChanged(
    BuildContext context,
    String todoId,
    String oldStatus,
    String newStatus,
    DateTime? plannedDate,
  ) async {
    var date = plannedDate;
    if (newStatus == 'planned' && date == null) {
      date = await pickPlannedDate(context);
      if (date == null) return;
    }
    if (!context.mounted) return;
    context.read<ManageTodosBloc>().add(
      UpdateTodoStatus(todoId: todoId, status: newStatus, plannedDate: date),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
