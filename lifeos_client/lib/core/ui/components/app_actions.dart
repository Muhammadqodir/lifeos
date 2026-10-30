import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app_theme_x.dart';
import '../tokens.dart';

/// A secondary action on an item (edit, move, delete, …).
///
/// The same list is rendered as a ⋯ dropdown, a right-click menu on
/// Mac/iPad and a long-press menu on iPhone, so every item in the app
/// exposes its actions the same way.
@immutable
class AppAction {
  const AppAction({
    required this.label,
    required this.onSelected,
    this.icon,
    this.destructive = false,
    this.enabled = true,
  });

  final String label;
  final List<List<dynamic>>? icon;
  final VoidCallback onSelected;
  final bool destructive;
  final bool enabled;
}

List<MenuItem> buildActionMenuItems(
  BuildContext context,
  List<AppAction> actions,
) {
  final colors = context.colors;
  final items = <MenuItem>[];
  final hasDestructive = actions.any((a) => a.destructive);
  for (final action in actions) {
    // Keep destructive actions visually separated at the bottom.
    if (action.destructive && hasDestructive && items.isNotEmpty) {
      final previousIsDestructive = actions
          .sublist(0, actions.indexOf(action))
          .any((a) => a.destructive);
      if (!previousIsDestructive) items.add(const MenuDivider());
    }
    final color = action.destructive ? colors.destructive : null;
    items.add(
      MenuButton(
        enabled: action.enabled,
        leading: action.icon == null
            ? null
            : HugeIcon(
                icon: action.icon!,
                size: AppIconSize.sm,
                strokeWidth: 1.8,
                color: color,
              ),
        onPressed: (_) => action.onSelected(),
        child: Text(action.label, style: TextStyle(color: color)),
      ),
    );
  }
  return items;
}

/// Ghost ⋯ button that opens [actions] in a dropdown.
class AppActionsButton extends StatelessWidget {
  const AppActionsButton({
    super.key,
    required this.actions,
    this.tooltip = 'More actions',
  });

  final List<AppAction> actions;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      tooltip: (context) => TooltipContainer(child: Text(tooltip)),
      child: IconButton.ghost(
        size: ButtonSize.small,
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedMoreHorizontal,
          size: AppIconSize.md,
          color: context.colors.mutedForeground,
        ),
        onPressed: () {
          showDropdown(
            context: context,
            alignment: Alignment.topRight,
            anchorAlignment: Alignment.bottomRight,
            builder: (context) =>
                DropdownMenu(children: buildActionMenuItems(context, actions)),
          );
        },
      ),
    );
  }
}

/// Wraps [child] so right-click (pointer) or long-press (touch) shows
/// [actions].
class AppContextActions extends StatelessWidget {
  const AppContextActions({
    super.key,
    required this.actions,
    required this.child,
  });

  final List<AppAction> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return child;
    return ContextMenu(
      items: buildActionMenuItems(context, actions),
      child: child,
    );
  }
}
