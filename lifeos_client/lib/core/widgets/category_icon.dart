import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../ui/components/leading_tile.dart';
import '../utils/color_utils.dart';

/// Emoji category tile; a [LeadingTile] tinted with the category colour.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.icon, required this.color});

  final String icon;
  final String color;

  @override
  Widget build(BuildContext context) {
    return LeadingTile.emoji(icon, color: parseHexColor(color));
  }
}
