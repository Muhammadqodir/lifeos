import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:lifeos_client/core/config/app_config.dart';
import 'package:lifeos_client/core/theme/app_colors.dart';
import 'package:lifeos_client/core/widgets/badge.dart';
import 'package:lifeos_client/core/widgets/tappable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../data/models/todo_dto.dart';

class TodoCard extends StatelessWidget {
  final TodoDto todo;
  final VoidCallback onTap;
  final Function({required String status, DateTime? plannedDate})
  onStatusChanged;
  final VoidCallback onDelete;
  final bool isUpdating;
  final EdgeInsets padding;
  final bool showProject;
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
    this.padding = const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Tappable(
      lowerBound: 0.98,
      onTap: onTap,
      child: Container(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 42,
                  decoration: BoxDecoration(
                    color: todo.priority == 'high'
                        ? AppColors.redColor
                        : todo.priority == 'middle'
                        ? AppColors.amberColor
                        : AppColors.greenColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: 8),
                if (showProject && todo.project != null) ...[
                  todo.project!.icon == null
                      ? Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _parseColor(todo.project!.color),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl:
                                "${AppConfig.serverBaseUrl}/storage/${todo.project!.icon ?? ''}",
                            width: 32,
                            height: 32,
                          ),
                        ),
                ],
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (todo.energy.isNotEmpty) ...[_buildEnergyBadge()],
                          Expanded(
                            child: Text(
                              todo.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).typography.small
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ).gap(4),
                      Row(
                        children: [
                          if (todo.plannedDate != null)
                            Text(
                              _formatDate(todo.plannedDate!, todo.plannedTime),
                              style: Theme.of(context).typography.xSmall
                                  .copyWith(color: colorScheme.mutedForeground),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (todo.urgency.isNotEmpty) ...[
                            _buildUrgencyBadge(),
                          ],
                        ],
                      ).gap(8),
                    ],
                  ),
                ),
                _buildActions(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgencyBadge() {
    switch (todo.urgency) {
      case 'low':
        return CustomBadge(label: "Low", color: AppColors.greenColor);
      case 'middle':
        return CustomBadge(label: "Medium", color: AppColors.amberColor);
      case 'high':
        return CustomBadge(label: "Urgent", color: AppColors.redColor);
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildEnergyBadge() {
    int energy = 0;
    switch (todo.energy) {
      case 'easy':
        energy = 1;
        break;
      case 'medium':
        energy = 2;
        break;
      case 'hard':
        energy = 3;
        break;
    }
    return Row(
      children: List.generate(
        energy,
        (index) => HugeIcon(
          icon: HugeIcons.strokeRoundedEnergy,
          size: 14,
          strokeWidth: 2,
          color: todo.energy == 'easy'
              ? AppColors.greenColor
              : todo.energy == 'medium'
              ? AppColors.orangeColor
              : AppColors.redColor,
        ),
      ).toList(),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      // Remove # if present
      String hex = hexColor.replaceAll('#', '');
      // Add FF for full opacity if not present
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      // Return a default color if parsing fails
      return const Color(0xFF6B7280);
    }
  }

  Widget _buildActions() {
    // Show loading indicator when updating
    if (isUpdating) {
      return Row(
        children: [
          SizedBox(width: 12),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    }

    // Kanban mode: only done button for in_progress, nothing for others
    if (kanbanMode) {
      if (todo.status == 'in_progress') {
        return IconButton.ghost(
          size: ButtonSize.xSmall,
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedCheckmarkSquare02,
            strokeWidth: 2,
          ),
          onPressed: () => onStatusChanged(status: 'done'),
        );
      }
      return const SizedBox.shrink();
    }

    switch (todo.status) {
      case 'planned':
        return Row(
          children: [
            IconButton.ghost(
              size: ButtonSize.xSmall,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedPlaySquare,
                strokeWidth: 2,
              ),
              onPressed: () {
                onStatusChanged(status: 'in_progress');
              },
            ),
            IconButton.ghost(
              size: ButtonSize.xSmall,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkSquare02,
                strokeWidth: 2,
              ),
              onPressed: () {
                onStatusChanged(status: 'done');
              },
            ),
          ],
        ).gap(8);
      case 'in_progress':
        return IconButton.ghost(
          size: ButtonSize.xSmall,
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCheckmarkSquare02,
            strokeWidth: 2,
          ),
          onPressed: () {
            onStatusChanged(status: 'done');
          },
        );
      case 'blocked':
        return IconButton.ghost(
          size: ButtonSize.xSmall,
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArchive, strokeWidth: 2),
          onPressed: () {
            onStatusChanged(status: 'done');
          },
        );
      case 'inbox':
        return Row(
          children: [
            IconButton.ghost(
              size: ButtonSize.xSmall,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedCalendar02,
                strokeWidth: 2,
              ),
              onPressed: () {
                onStatusChanged(status: 'planned');
              },
            ),
            IconButton.ghost(
              size: ButtonSize.xSmall,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedPlaySquare,
                strokeWidth: 2,
              ),
              onPressed: () {
                onStatusChanged(status: 'in_progress');
              },
            ),
            IconButton.ghost(
              size: ButtonSize.xSmall,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkSquare02,
                strokeWidth: 2,
              ),
              onPressed: () {
                onStatusChanged(status: 'done');
              },
            ),
          ],
        ).gap(8);
      default:
        return SizedBox.shrink();
    }
  }

  String _formatDate(DateTime date, String? plannedTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      if (plannedTime != null) {
        final time = DateFormat('HH:mm:ss').parse(plannedTime);
        return 'Today at ${DateFormat('h:mm a').format(time)}';
      }
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('d MMMM, y').format(date);
    }
  }
}

class ToDoCheckbox extends StatelessWidget {
  const ToDoCheckbox({super.key, required this.status, this.onChanged});

  final String status;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: getBgColor(context),
        border: Border.all(
          color: getBorderColor(context),
          width: status == 'done' || status == 'blocked' ? 0 : 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: getIcon(context),
    );
  }

  Color getBorderColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (status == 'done' || status == 'blocked') {
      return colorScheme.primary;
    }
    return colorScheme.border;
  }

  Color getBgColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (status == 'done' || status == 'blocked') {
      return colorScheme.primary;
    }
    return colorScheme.background;
  }

  Widget getIcon(BuildContext context) {
    if (status == 'done') {
      return HugeIcon(
        icon: HugeIcons.strokeRoundedTick01,
        strokeWidth: 2,
        color: Theme.of(context).colorScheme.background,
      );
    }

    if (status == 'blocked') {
      return HugeIcon(
        icon: HugeIcons.strokeRoundedCancel01,
        strokeWidth: 2,
        color: Theme.of(context).colorScheme.background,
      );
    }

    return SizedBox.shrink();
  }
}
