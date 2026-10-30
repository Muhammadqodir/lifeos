import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app_theme_x.dart';
import '../tokens.dart';
import 'app_pressable.dart';
import 'section_header.dart';

/// A titled, card-style group of rows separated by hairlines
/// (the iOS "inset grouped" list, in shadcn styling).
class AppListSection extends StatelessWidget {
  const AppListSection({
    super.key,
    required this.children,
    this.title,
    this.count,
    this.headerTrailing,
    this.footer,
    this.dividerIndent = AppSpacing.md + AppLayout.leadingSize + AppSpacing.md,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.section),
    this.empty,
  });

  final String? title;
  final int? count;
  final Widget? headerTrailing;
  final List<Widget> children;

  /// Muted helper text under the card.
  final String? footer;

  /// Left inset of dividers so they start under the row text, not the icon.
  final double dividerIndent;
  final EdgeInsetsGeometry margin;

  /// Shown inside the card when [children] is empty.
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(left: dividerIndent),
            child: Container(height: 1, color: colors.border),
          ),
        );
      }
      rows.add(children[i]);
    }

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            SectionHeader(
              title: title!,
              count: count,
              trailing: headerTrailing,
            ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: rows.isEmpty && empty != null ? [empty!] : rows,
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Text(footer!, style: context.text.caption),
            ),
        ],
      ),
    );
  }
}

/// The standard surface: card fill, hairline border, card radius.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.card,
        borderRadius: theme.cardRadius,
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return AppPressable(
      onTap: onTap,
      highlight: false,
      borderRadius: theme.cardRadius,
      child: card,
    );
  }
}
