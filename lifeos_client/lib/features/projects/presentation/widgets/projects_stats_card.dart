import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';

/// Overview metrics above the projects list.
class ProjectsStatsCard extends StatelessWidget {
  final int totalProjects;
  final int activeTodos;
  final int completedTodos;
  final bool isLoading;

  const ProjectsStatsCard({
    super.key,
    required this.totalProjects,
    required this.activeTodos,
    required this.completedTodos,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    final tiles = [
      StatTile(
        label: 'Projects',
        value: '$totalProjects',
        icon: HugeIcons.strokeRoundedFolder01,
      ),
      StatTile(
        label: 'Open todos',
        value: '$activeTodos',
        icon: HugeIcons.strokeRoundedTask01,
        color: semantic.warning,
      ),
      StatTile(
        label: 'Completed',
        value: '$completedTodos',
        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
        color: semantic.success,
      ),
    ];
    return StatGrid(minTileWidth: 100, children: tiles)
        .asSkeleton(enabled: isLoading);
  }
}
