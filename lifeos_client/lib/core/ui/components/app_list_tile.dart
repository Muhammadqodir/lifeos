import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app_theme_x.dart';
import '../tokens.dart';
import 'app_actions.dart';
import 'app_pressable.dart';

/// The one list row used across the app (todos, habits, transactions,
/// projects, settings, pickers).
///
/// Anatomy: [leading] · [title] + [titleTrailing] / [subtitle] · [trailing]
/// · ⋯ actions · chevron. Secondary [actions] are also available via
/// right-click and long-press.
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.leading,
    this.titleTrailing,
    this.subtitle,
    this.subtitleWidget,
    this.trailing,
    this.onTap,
    this.actions = const [],
    this.showActionsButton = true,
    this.showChevron = false,
    this.loading = false,
    this.selected = false,
    this.padding,
    this.borderRadius,
    this.titleMaxLines = 1,
    this.muted = false,
  });

  final String title;
  final Widget? leading;

  /// Inline adornments after the title (badges, energy icons).
  final Widget? titleTrailing;
  final String? subtitle;

  /// Rich subtitle; takes precedence over [subtitle].
  final Widget? subtitleWidget;

  /// Primary trailing element: an amount, a toggle, a check button.
  final Widget? trailing;
  final VoidCallback? onTap;
  final List<AppAction> actions;
  final bool showActionsButton;
  final bool showChevron;

  /// Replaces trailing controls with a spinner while an update is pending.
  final bool loading;
  final bool selected;
  final EdgeInsetsGeometry? padding;

  /// Rows inside an [AppListSection] are square; the section clips them.
  final BorderRadius? borderRadius;
  final int titleMaxLines;

  /// De-emphasise (completed items).
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    final titleStyle = text.itemTitle.copyWith(
      color: muted ? colors.mutedForeground : null,
      decoration: muted ? TextDecoration.lineThrough : null,
      decorationColor: colors.mutedForeground,
    );

    final trailingChildren = <Widget>[
      if (loading)
        const SizedBox(
          width: AppIconSize.md,
          height: AppIconSize.md,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      else ...[
        if (trailing != null) trailing!,
        if (actions.isNotEmpty && showActionsButton)
          AppActionsButton(actions: actions),
      ],
      if (showChevron)
        HugeIcon(
          icon: HugeIcons.strokeRoundedArrowRight01,
          size: AppIconSize.md,
          color: colors.mutedForeground,
        ),
    ];

    final row = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppLayout.minTouchTarget + 8,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: titleMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                    ),
                    if (titleTrailing != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      titleTrailing!,
                    ],
                  ],
                ),
                if (subtitleWidget != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  DefaultTextStyle.merge(
                    style: text.itemSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: subtitleWidget!,
                  ),
                ] else if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.itemSubtitle,
                  ),
                ],
              ],
            ),
          ),
          if (trailingChildren.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: trailingChildren,
            ).gap(AppSpacing.xs),
          ],
        ],
      ),
    );

    Widget tile = AppPressable(
      onTap: onTap,
      borderRadius: borderRadius ?? BorderRadius.zero,
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
      child: row,
    );

    if (selected) {
      tile = DecoratedBox(
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
        child: tile,
      );
    }

    return AppContextActions(actions: actions, child: tile);
  }
}
