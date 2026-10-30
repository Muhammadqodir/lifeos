import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../ui/components/app_list_tile.dart';

/// Navigation row (settings, feature lists). Use inside an AppListSection.
class ActionListItem extends StatelessWidget {
  const ActionListItem({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.icon,
    this.trailing,
  });

  final String title;
  final String description;
  final VoidCallback onTap;

  /// Usually a [LeadingTile].
  final Widget? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leading: icon,
      title: title,
      subtitle: description,
      trailing: trailing,
      onTap: onTap,
      showChevron: true,
    );
  }
}
