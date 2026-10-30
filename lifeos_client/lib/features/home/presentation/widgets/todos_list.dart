import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/core/theme/app_colors.dart';
import 'package:lifeos_client/core/widgets/kanban_board.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_bloc.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_state.dart';
import 'package:lifeos_client/features/home/presentation/widgets/home_section_header.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_todos_bloc.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_todos_event.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_todos_state.dart';
import 'package:lifeos_client/features/projects/presentation/widgets/todo_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

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

class MainPageTodosList extends StatefulWidget {
  const MainPageTodosList({super.key, required this.state});

  final HomeSuccess state;

  @override
  State<MainPageTodosList> createState() => _MainPageTodosListState();
}

class _MainPageTodosListState extends State<MainPageTodosList> {
  int? _updatingTodoId;
  int? _deletingTodoId;

  List<_ColumnData> get _columns {
    final today = DateTime.now();
    return [
      _ColumnData(
        title: 'Overdue',
        todos: widget.state.overdueTodos,
        color: AppColors.redColor,
        targetStatus: null, // read-only — overdue is a derived view
      ),
      _ColumnData(
        title: 'Inbox',
        todos: widget.state.inboxTodos,
        color: AppColors.grayColor,
        targetStatus: 'inbox',
      ),
      _ColumnData(
        title: 'Planned for Today',
        todos: widget.state.todosToday,
        color: AppColors.greenColor,
        targetStatus: 'planned',
        targetPlannedDate: DateTime(today.year, today.month, today.day),
      ),
      _ColumnData(
        title: 'In Progress',
        todos: widget.state.inProgressTodos,
        color: AppColors.amberColor,
        targetStatus: 'in_progress',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ManageTodosBloc, ManageTodosState>(
          listener: (context, state) {
            if (state is TodoStatusUpdating) {
              setState(() => _updatingTodoId = state.todoId);
            } else if (state is TodoDeleting) {
              setState(() => _deletingTodoId = state.todoId);
            } else if (state is ManageTodosError) {
              setState(() {
                _updatingTodoId = null;
                _deletingTodoId = null;
              });
            }
          },
        ),
        BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeSuccess) {
              setState(() {
                _updatingTodoId = null;
                _deletingTodoId = null;
              });
            }
          },
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 768) {
            return _buildKanbanBoard(context, constraints);
          }
          return _buildListView(context);
        },
      ),
    );
  }

  // ─── List View (mobile) ───────────────────────────────────────────

  Widget _buildListView(BuildContext context) {
    return Column(
      children: [
        for (final col in _columns)
          if (col.todos.isNotEmpty) ...[
            HomeSectionHeader(title: col.title),
            const SizedBox(height: 12),
            for (final todo in col.todos)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildTodoTile(context, todo),
              ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  // ─── Kanban Board (desktop) ───────────────────────────────────────

  Widget _buildKanbanBoard(BuildContext context, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: KanbanBoard<TodoDto>(
        columns: _columns
            .map(
              (col) => KanbanColumnConfig<TodoDto>(
                title: col.title,
                items: col.todos,
                color: col.color,
                isDroppable: col.targetStatus != null,
              ),
            )
            .toList(),
        emptyText: 'No todos',
        itemBuilder: (context, todo, isDragging) => Opacity(
          opacity: isDragging ? 0.3 : 1.0,
          child: _buildTodoTile(context, todo, kanbanMode: true),
        ),
        feedbackBuilder: _buildDragFeedback,
        onItemDropped: (todo, columnIndex) {
          final col = _columns[columnIndex];
          if (col.targetStatus == null) return;

          // Skip if already in this column
          final alreadySameStatus = todo.status == col.targetStatus;
          final alreadySamePlannedDate = col.targetPlannedDate == null ||
              (todo.plannedDate != null &&
                  todo.plannedDate!.year == col.targetPlannedDate!.year &&
                  todo.plannedDate!.month == col.targetPlannedDate!.month &&
                  todo.plannedDate!.day == col.targetPlannedDate!.day);
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
    final theme = Theme.of(context);
    return Opacity(
      opacity: 0.92,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        width: width,
        child: TodoCard(
          todo: todo,
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
  }) {
    final isUpdating = _updatingTodoId == todo.id || _deletingTodoId == todo.id;

    return TodoCard(
      padding: const EdgeInsets.all(0),
      todo: todo,
      showProject: true,
      isUpdating: isUpdating,
      kanbanMode: kanbanMode,
      onTap: () {},
      onStatusChanged: ({plannedDate, required status}) {
        if (!isUpdating) {
          _handleTodoStatusChanged(
            context,
            todo.id,
            todo.status,
            status,
            plannedDate,
          );
        }
      },
      onDelete: () {
        if (!isUpdating) {
          _handleTodoDelete(context, todo.id);
        }
      },
    );
  }

  void _handleTodoDelete(BuildContext context, int todoId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ManageTodosBloc>().add(DeleteTodo(todoId));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleTodoStatusChanged(
    BuildContext context,
    int todoId,
    String oldStatus,
    String newStatus,
    DateTime? plannedDate,
  ) {
    if (newStatus == 'planned' && plannedDate == null) {
      showDialog<DateTime>(
        context: context,
        builder: (context) {
          DateTime selectedDate = DateTime.now();
          return AlertDialog(
            title: const Text('Select Planned Date'),
            content: DatePickerDialog(
              initialViewType: CalendarViewType.date,
              selectionMode: CalendarSelectionMode.single,
              onChanged: (value) {
                if (value is DateTime) {
                  Navigator.of(context).pop(value);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              PrimaryButton(
                child: const Text('Select'),
                onPressed: () => Navigator.of(context).pop(selectedDate),
              ),
            ],
          );
        },
      ).then((selectedDate) {
        if (selectedDate != null) {
          context.read<ManageTodosBloc>().add(
            UpdateTodoStatus(
              todoId: todoId,
              status: newStatus,
              oldStatus: oldStatus,
              plannedDate: selectedDate,
            ),
          );
        }
      });
    } else {
      context.read<ManageTodosBloc>().add(
        UpdateTodoStatus(
          todoId: todoId,
          status: newStatus,
          oldStatus: oldStatus,
          plannedDate: plannedDate,
        ),
      );
    }
  }
}
