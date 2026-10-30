import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/date_labels.dart';
import '../../data/models/todo_dto.dart';
import '../widgets/todo_labels.dart';

/// Read-only overview of a todo.
class TodoDetailsPage extends StatelessWidget {
  final TodoDto todo;

  const TodoDetailsPage({super.key, required this.todo});

  String _dateTime(DateTime date) => DateFormat('d MMM y, HH:mm').format(date);

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final hasComment = (todo.comment ?? '').isNotEmpty;
    final plannedTime = DateLabels.apiTime(todo.plannedTime);

    return Scaffold(
      headers: [AppHeader(title: 'Todo', subtitle: todo.project?.title)],
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.lg,
        ),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppBadge(
                          label: TodoLabels.status(todo.status),
                          color: TodoLabels.statusColor(context, todo.status),
                        ),
                        if (todo.project != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: parseHexColor(todo.project!.color),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              todo.project!.title,
                              style: text.caption,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(todo.title, style: text.sectionTitle),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      hasComment ? todo.comment! : 'No description',
                      style: hasComment ? text.body : text.itemSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              AppListSection(
                title: 'Details',
                dividerIndent: AppSpacing.md,
                children: [
                  DetailRow(
                    icon: HugeIcons.strokeRoundedFlag02,
                    label: 'Priority',
                    valueWidget: AppBadge(
                      label: TodoLabels.level(todo.priority),
                      color: TodoLabels.levelColor(context, todo.priority),
                    ),
                  ),
                  DetailRow(
                    icon: HugeIcons.strokeRoundedAlarmClock,
                    label: 'Urgency',
                    valueWidget: AppBadge(
                      label: TodoLabels.level(todo.urgency),
                      color: TodoLabels.levelColor(context, todo.urgency),
                    ),
                  ),
                  DetailRow(
                    icon: HugeIcons.strokeRoundedFlash,
                    label: 'Energy',
                    value: TodoLabels.energy(todo.energy),
                  ),
                  DetailRow(
                    icon: HugeIcons.strokeRoundedCalendar03,
                    label: 'Planned',
                    value: todo.plannedDate == null
                        ? 'Not planned'
                        : [
                            DateLabels.relativeDay(todo.plannedDate!),
                            ?plannedTime,
                          ].join(', '),
                  ),
                  if (todo.timeSpentMinutes != null)
                    DetailRow(
                      icon: HugeIcons.strokeRoundedTimer02,
                      label: 'Time spent',
                      value: '${todo.timeSpentMinutes} min',
                    ),
                  if (todo.completedAt != null)
                    DetailRow(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      label: 'Completed',
                      value: _dateTime(todo.completedAt!),
                    ),
                ],
              ),
              if (todo.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.section),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeader(title: 'Tags'),
                      Wrap(
                        spacing: AppSpacing.xs + 2,
                        runSpacing: AppSpacing.xs + 2,
                        children: [
                          for (final tag in todo.tags)
                            AppBadge.outline(label: tag),
                        ],
                      ),
                    ],
                  ),
                ),
              AppListSection(
                title: 'Activity',
                dividerIndent: AppSpacing.md,
                children: [
                  DetailRow(
                    label: 'Created',
                    value: _dateTime(todo.createdAt),
                  ),
                  DetailRow(
                    label: 'Updated',
                    value: _dateTime(todo.updatedAt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
