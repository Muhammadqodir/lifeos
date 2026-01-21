import 'package:intl/intl.dart';
import 'package:lifeos_client/core/widgets/badge.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../../data/models/todo_dto.dart';

class TodoDetailsPage extends StatelessWidget {
  final TodoDto todo;

  const TodoDetailsPage({super.key, required this.todo});

  String _titleCase(String value) {
    return value
        .split('_')
        .map((word) {
          if (word.isEmpty) {
            return word;
          }
          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('MMM d, y • HH:mm').format(date);
  }

  String _formatPlannedTime(String? time) {
    if (time == null || time.isEmpty) {
      return '-';
    }
    final parts = time.split(':');
    if (parts.length >= 2) {
      final hour = parts[0].padLeft(2, '0');
      final minute = parts[1].padLeft(2, '0');
      return '$hour:$minute';
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      headers: [
        CustomAppBar(
          title: 'Todo Details',
          leftActions: [
            AppBarAction(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              tooltip: 'Back',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: theme.typography.large.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (todo.comment ?? '').isEmpty
                        ? 'No description'
                        : todo.comment!,
                    style: theme.typography.normal.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    context,
                    'Status',
                    _titleCase(todo.status),
                  ),
                  _buildDetailRow(
                    context,
                    'Priority',
                    _titleCase(todo.priority),
                  ),
                  _buildDetailRow(
                    context,
                    'Urgency',
                    _titleCase(todo.urgency),
                  ),
                  _buildDetailRow(
                    context,
                    'Energy',
                    _titleCase(todo.energy),
                  ),
                  _buildDetailRow(
                    context,
                    'Planned Date',
                    todo.plannedDate == null
                        ? '-'
                        : _formatDate(todo.plannedDate!),
                  ),
                  _buildDetailRow(
                    context,
                    'Planned Time',
                    _formatPlannedTime(todo.plannedTime),
                  ),
                  _buildDetailRow(
                    context,
                    'Time Spent',
                    todo.timeSpentMinutes == null
                        ? '-'
                        : '${todo.timeSpentMinutes} min',
                  ),
                  _buildDetailRow(
                    context,
                    'Completed At',
                    todo.completedAt == null
                        ? '-'
                        : _formatDateTime(todo.completedAt!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tags',
                    style: theme.typography.normal.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (todo.tags.isEmpty)
                    Text(
                      'No tags',
                      style: theme.typography.small.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: todo.tags
                          .map(
                            (tag) => CustomBadge(
                              label: tag,
                              color: colorScheme.primary,
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    context,
                    'Created',
                    _formatDateTime(todo.createdAt),
                  ),
                  _buildDetailRow(
                    context,
                    'Updated',
                    _formatDateTime(todo.updatedAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.typography.small.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
