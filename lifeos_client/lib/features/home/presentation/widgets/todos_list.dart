import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/core/theme/app_colors.dart';
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
  String? _hoveredColumnTitle;

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
    final columnWidth = (constraints.maxWidth - 3 * 10) / 4;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _columns.length; i++) ...[
            SizedBox(
              width: columnWidth,
              child: _buildKanbanColumn(context, _columns[i], columnWidth),
            ),
            if (i < _columns.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    _ColumnData col,
    double columnWidth,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isHovered = _hoveredColumnTitle == col.title;
    final isDroppable = col.targetStatus != null;

    return DragTarget<TodoDto>(
      onWillAcceptWithDetails: (_) => isDroppable,
      onAcceptWithDetails: (details) {
        setState(() => _hoveredColumnTitle = null);
        final todo = details.data;
        // Skip if already in this column (same status, same planned date for today column)
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
      onMove: (_) {
        if (isDroppable && _hoveredColumnTitle != col.title) {
          setState(() => _hoveredColumnTitle = col.title);
        }
      },
      onLeave: (_) {
        if (_hoveredColumnTitle == col.title) {
          setState(() => _hoveredColumnTitle = null);
        }
      },
      builder: (context, candidateData, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isHovered ? col.color.withOpacity(0.07) : colorScheme.card,
            border: Border.all(
              color: isHovered
                  ? col.color.withOpacity(0.55)
                  : colorScheme.border,
              width: isHovered ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Column header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colorScheme.border)),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: col.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        col.title,
                        style: theme.typography.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.muted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${col.todos.length}',
                        style: theme.typography.xSmall.copyWith(
                          color: colorScheme.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Cards
              Padding(
                padding: const EdgeInsets.all(8),
                child: col.todos.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No todos',
                            style: theme.typography.small.copyWith(
                              color: colorScheme.mutedForeground,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: col.todos
                            .map(
                              (todo) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: _buildTodoTile(
                                  context,
                                  todo,
                                  kanbanMode: true,
                                  dragFeedbackWidth: columnWidth,
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          ),
        );
      },
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
    double? dragFeedbackWidth,
  }) {
    final isUpdating = _updatingTodoId == todo.id || _deletingTodoId == todo.id;

    final card = TodoCard(
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

    if (!kanbanMode) return card;

    return Draggable<TodoDto>(
      data: todo,
      feedback: _buildDragFeedback(context, todo, dragFeedbackWidth ?? 220),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
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
