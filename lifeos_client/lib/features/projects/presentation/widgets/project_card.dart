import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:lifeos_client/core/config/app_config.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../data/models/project_dto.dart';
import '../../../projects/presentation/pages/project_details_page.dart';

class ProjectCard extends StatelessWidget {
  final ProjectDto project;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Parse color from hex string
    Color projectColor = _parseColor(project.color);

    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => ProjectDetailsPage(project: project),
              ),
            );
          },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with color indicator and actions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colorScheme.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  project.icon == null
                      ? Container(
                          width: 4,
                          height: 32,
                          decoration: BoxDecoration(
                            color: projectColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl:
                                "${AppConfig.serverBaseUrl}/storage/${project.icon ?? ''}",
                            width: 32,
                            height: 32,
                          ),
                        ),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: theme.typography.normal.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (project.description != null &&
                            project.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            project.description!,
                            style: theme.typography.xSmall.copyWith(
                              color: colorScheme.mutedForeground,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete button
                  if (onDelete != null)
                    IconButton.ghost(
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedDelete02,
                        size: 18,
                      ),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedTaskDone01,
                        size: 16,
                        color: colorScheme.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${project.todosCount} ${project.todosCount == 1 ? 'task' : 'tasks'}',
                        style: theme.typography.small.copyWith(
                          color: colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  // Tags
                  if (project.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: project.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.muted,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: theme.typography.xSmall.copyWith(
                              color: colorScheme.mutedForeground,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
}
