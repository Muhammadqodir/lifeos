import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../utils/server.dart';
import '../../data/models/project_dto.dart';

/// A project's icon image, or its colour swatch when it has none.
class ProjectLeading extends StatelessWidget {
  const ProjectLeading({
    super.key,
    required this.project,
    this.size = AppLayout.leadingSize,
  });

  final ProjectDto project;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(project.color);
    final icon = project.icon;
    if (icon != null && icon.isNotEmpty) {
      return LeadingTile.image(
        StorageUrl.resolve(icon),
        color: color,
        size: size,
      );
    }
    return LeadingTile.swatch(color, size: size);
  }
}
