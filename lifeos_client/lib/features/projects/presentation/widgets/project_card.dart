import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/utils/color_utils.dart';
import '../../data/models/project_dto.dart';
import '../pages/project_details_page.dart';
import 'project_leading.dart';

/// Project summary card: identity, description, progress and tags.
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

  void _open(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => ProjectDetailsPage(project: project)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final accent = parseHexColor(project.color);
    final open = project.pendingTodosCount;
    final done = project.completedTodosCount;
    final total = open + done;
    final progress = total == 0 ? 0.0 : done / total;

    final actions = [
      AppAction(
        label: 'Open',
        icon: HugeIcons.strokeRoundedArrowRight01,
        onSelected: () => _open(context),
      ),
      if (onDelete != null)
        AppAction(
          label: 'Delete project',
          icon: HugeIcons.strokeRoundedDelete02,
          destructive: true,
          onSelected: onDelete!,
        ),
    ];

    return AppContextActions(
      actions: actions,
      child: AppPressable(
        onTap: () => _open(context),
        highlight: false,
        borderRadius: context.theme.cardRadius,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: context.theme.cardRadius,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ProjectLeading(project: project),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: text.itemTitle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          open == 1 ? '1 open todo' : '$open open todos',
                          style: text.itemSubtitle,
                        ),
                      ],
                    ),
                  ),
                  AppActionsButton(actions: actions),
                ],
              ),
              if (project.description != null &&
                  project.description!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Text(
                    project.description!,
                    style: text.itemSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 6,
                          child: Stack(
                            children: [
                              Container(color: colors.muted),
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(color: accent),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      total == 0 ? 'No todos' : '$done/$total done',
                      style: text.caption,
                    ),
                  ],
                ),
              ),
              if (project.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs + 2,
                  runSpacing: AppSpacing.xs + 2,
                  children: [
                    for (final tag in project.tags.take(4))
                      AppBadge.outline(label: tag),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
