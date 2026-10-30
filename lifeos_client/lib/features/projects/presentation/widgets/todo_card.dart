import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/date_labels.dart';
import '../../data/models/todo_dto.dart';

typedef TodoStatusChanged =
    void Function({required String status, DateTime? plannedDate});

/// A todo row. The leading check completes the todo; every other status
/// change lives in the actions menu (⋯, right-click, long-press).
class TodoCard extends StatelessWidget {
  final TodoDto todo;
  final VoidCallback onTap;
  final TodoStatusChanged onStatusChanged;
  final VoidCallback onDelete;
  final bool isUpdating;
  final EdgeInsetsGeometry? padding;
  final bool showProject;

  /// Rendered as a standalone card (Kanban columns, drag feedback).
  final bool kanbanMode;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onStatusChanged,
    required this.onDelete,
    this.isUpdating = false,
    this.showProject = false,
    this.kanbanMode = false,
    this.padding,
  });

  bool get _isDone => todo.status == 'done';

  @override
  Widget build(BuildContext context) {
    final tile = AppListTile(
      leading: TodoCheck(
        priority: todo.priority,
        done: _isDone,
        enabled: !isUpdating && !_isDone,
        onTap: () => onStatusChanged(status: 'done'),
      ),
      title: todo.title,
      muted: _isDone,
      titleMaxLines: kanbanMode ? 2 : 1,
      subtitleWidget: _TodoMeta(todo: todo, showProject: showProject),
      onTap: onTap,
      loading: isUpdating,
      actions: _actions(),
      padding: padding,
      borderRadius: kanbanMode ? context.theme.controlRadius : null,
    );

    if (!kanbanMode) return tile;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: context.theme.controlRadius,
        border: Border.all(color: context.colors.border),
      ),
      child: tile,
    );
  }

  List<AppAction> _actions() {
    final start = AppAction(
      label: 'Start',
      icon: HugeIcons.strokeRoundedPlay,
      onSelected: () => onStatusChanged(status: 'in_progress'),
    );
    final planToday = AppAction(
      label: 'Plan for today',
      icon: HugeIcons.strokeRoundedSun03,
      onSelected: () {
        final now = DateTime.now();
        onStatusChanged(
          status: 'planned',
          plannedDate: DateTime(now.year, now.month, now.day),
        );
      },
    );
    final planLater = AppAction(
      label: 'Plan for a date…',
      icon: HugeIcons.strokeRoundedCalendar03,
      onSelected: () => onStatusChanged(status: 'planned'),
    );
    final toInbox = AppAction(
      label: 'Move to inbox',
      icon: HugeIcons.strokeRoundedInboxDownload,
      onSelected: () => onStatusChanged(status: 'inbox'),
    );
    final block = AppAction(
      label: 'Mark as blocked',
      icon: HugeIcons.strokeRoundedAlertCircle,
      onSelected: () => onStatusChanged(status: 'blocked'),
    );
    final complete = AppAction(
      label: 'Mark as done',
      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
      onSelected: () => onStatusChanged(status: 'done'),
    );
    final reopen = AppAction(
      label: 'Reopen',
      icon: HugeIcons.strokeRoundedArrowTurnBackward,
      onSelected: () => onStatusChanged(status: 'inbox'),
    );
    final delete = AppAction(
      label: 'Delete',
      icon: HugeIcons.strokeRoundedDelete02,
      destructive: true,
      onSelected: onDelete,
    );

    return switch (todo.status) {
      'inbox' => [start, planToday, planLater, complete, delete],
      'planned' => [start, planLater, toInbox, complete, delete],
      'in_progress' => [complete, block, toInbox, delete],
      'blocked' => [start, complete, toInbox, delete],
      'done' => [reopen, delete],
      _ => [delete],
    };
  }
}

/// Date, project, urgency and energy under the todo title.
class _TodoMeta extends StatelessWidget {
  const _TodoMeta({required this.todo, required this.showProject});

  final TodoDto todo;
  final bool showProject;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    final style = context.text.itemSubtitle;
    final parts = <Widget>[];

    if (todo.plannedDate != null) {
      final overdue =
          todo.status != 'done' && DateLabels.isPastDay(todo.plannedDate!);
      final time = DateLabels.apiTime(todo.plannedTime);
      final label = DateLabels.relativeDay(todo.plannedDate!);
      parts.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedCalendar03,
              size: 12,
              strokeWidth: 2,
              color: overdue ? semantic.danger : style.color,
            ),
            const SizedBox(width: 3),
            Text(
              time == null ? label : '$label, $time',
              style: style.copyWith(color: overdue ? semantic.danger : null),
            ),
          ],
        ),
      );
    }

    if (showProject && todo.project != null) {
      parts.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: parseHexColor(todo.project!.color),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                todo.project!.title,
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (todo.urgency == 'high') {
      parts.add(AppBadge(label: 'Urgent', color: semantic.danger));
    }

    final energyLevel = switch (todo.energy) {
      'easy' => 1,
      'medium' => 2,
      'hard' => 3,
      _ => 0,
    };
    if (energyLevel > 0) {
      parts.add(
        Tooltip(
          tooltip: (context) =>
              TooltipContainer(child: Text('Energy: ${todo.energy}')),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              energyLevel,
              (_) => HugeIcon(
                icon: HugeIcons.strokeRoundedFlash,
                size: 11,
                strokeWidth: 2,
                color: style.color,
              ),
            ),
          ),
        ),
      );
    }

    if (parts.isEmpty) {
      return Text(_statusLabel(todo.status), style: style);
    }

    return ClipRect(
      child: Wrap(
        spacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: parts,
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
    'inbox' => 'Inbox',
    'planned' => 'Planned',
    'in_progress' => 'In progress',
    'blocked' => 'Blocked',
    'done' => 'Done',
    _ => status,
  };
}

/// Round completion check whose ring colour encodes priority.
class TodoCheck extends StatelessWidget {
  const TodoCheck({
    super.key,
    required this.priority,
    required this.done,
    required this.onTap,
    this.enabled = true,
  });

  final String priority;
  final bool done;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantic = context.semantic;
    final ring = switch (priority) {
      'high' => semantic.danger,
      'middle' => semantic.warning,
      _ => colors.mutedForeground,
    };

    return Tooltip(
      tooltip: (context) => TooltipContainer(
        child: Text(done ? 'Done' : 'Mark as done · ${_priorityLabel()}'),
      ),
      child: AppPressable(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        semanticLabel: done ? 'Done' : 'Mark as done',
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: AnimatedContainer(
          duration: AppDurations.base,
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? colors.primary
                : semantic
                      .tint(ring)
                      .withValues(alpha: priority == 'low' ? 0 : 0.08),
            border: Border.all(color: done ? colors.primary : ring, width: 1.6),
          ),
          child: done
              ? Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedTick02,
                    size: 13,
                    strokeWidth: 2.5,
                    color: colors.primaryForeground,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  String _priorityLabel() => switch (priority) {
    'high' => 'High priority',
    'middle' => 'Medium priority',
    _ => 'Low priority',
  };
}
