import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app_theme_x.dart';
import '../breakpoints.dart';
import '../page_commands.dart';
import '../tokens.dart';

/// Page header used by every screen.
///
/// * Adds a back button automatically when the page can pop.
/// * Renders [HeaderAction]s with real tooltips; actions that carry a
///   label become labelled buttons on iPad/Mac.
/// * On Mac (no pull-to-refresh with a mouse) shows a refresh button when
///   [onRefresh] is provided.
/// * Binds ⌘R to [onRefresh] and ⌘N to the primary [HeaderAction] (see
///   [PageCommands]).
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBorder = true,
    this.automaticallyImplyLeading = true,
    this.onRefresh,
    this.bottom,
  });

  final String title;
  final String? subtitle;

  /// Replaces the automatic back button.
  final List<Widget>? leading;
  final List<Widget>? actions;
  final bool showBorder;
  final bool automaticallyImplyLeading;
  final VoidCallback? onRefresh;

  /// Optional row under the title bar (tabs, filters).
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;

    final leadingWidgets =
        leading ??
        [
          if (automaticallyImplyLeading && canPop)
            HeaderAction(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              tooltip: 'Back',
              onTap: () => Navigator.of(context).maybePop(),
            ),
        ];

    final trailing = <Widget>[
      ...?actions,
      if (onRefresh != null && isDesktopPlatform)
        HeaderAction(
          icon: HugeIcons.strokeRoundedRefresh,
          tooltip: 'Refresh',
          onTap: onRefresh,
        ),
    ];

    final primaryAction = actions
        ?.whereType<HeaderAction>()
        .where((a) => a.primary && a.onTap != null)
        .firstOrNull;

    return PageCommands(
      commands: PageCommandSet(
        onNew: primaryAction?.onTap,
        onRefresh: onRefresh,
      ),
      child: _buildBar(context, colors, leadingWidgets, trailing),
    );
  }

  Widget _buildBar(
    BuildContext context,
    ColorScheme colors,
    List<Widget> leadingWidgets,
    List<Widget> trailing,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: showBorder
            ? Border(bottom: BorderSide(color: colors.border))
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: leadingWidgets.isEmpty ? AppSpacing.page : AppSpacing.sm,
                right: AppSpacing.sm,
              ),
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    if (leadingWidgets.isNotEmpty) ...[
                      ...leadingWidgets,
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: context.text.pageTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: context.text.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (trailing.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: trailing,
                      ).gap(AppSpacing.xxs),
                  ],
                ),
              ),
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}

/// An action in [AppHeader]. With a [label] it renders as a labelled button
/// on iPad/Mac (icon-only on iPhone). [primary] highlights the main action;
/// use at most one per header.
class HeaderAction extends StatelessWidget {
  const HeaderAction({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip,
    this.label,
    this.primary = false,
  });

  final List<List<dynamic>> icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final String? label;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final showLabel = label != null && context.windowClass.isAtLeastMedium;

    Widget button;
    if (showLabel) {
      final iconWidget = HugeIcon(
        icon: icon,
        size: AppIconSize.sm,
        strokeWidth: 2,
        color: primary ? colors.primaryForeground : colors.foreground,
      );
      button = primary
          ? PrimaryButton(
              size: ButtonSize.small,
              onPressed: onTap,
              leading: iconWidget,
              child: Text(label!),
            )
          : OutlineButton(
              size: ButtonSize.small,
              onPressed: onTap,
              leading: iconWidget,
              child: Text(label!),
            );
    } else {
      button = IconButton.ghost(
        onPressed: onTap,
        icon: HugeIcon(
          icon: icon,
          size: AppIconSize.md,
          strokeWidth: 1.8,
          color: onTap == null ? colors.mutedForeground : colors.foreground,
        ),
      );
    }

    final tip = tooltip ?? label;
    if (tip == null || showLabel) {
      return Semantics(label: tip, button: true, child: button);
    }
    return Tooltip(
      tooltip: (context) => TooltipContainer(child: Text(tip)),
      child: Semantics(label: tip, button: true, child: button),
    );
  }
}
