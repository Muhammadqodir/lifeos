import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app_theme_x.dart';
import '../tokens.dart';

enum AppBadgeStyle { tinted, neutral, outline }

/// Small label for status, priority, tags and counts.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.style = AppBadgeStyle.tinted,
  });

  const AppBadge.neutral({super.key, required this.label, this.icon})
    : color = null,
      style = AppBadgeStyle.neutral;

  /// Tag chip (`#work`).
  const AppBadge.outline({super.key, required this.label, this.icon})
    : color = null,
      style = AppBadgeStyle.outline;

  // Can't be const: the label is built from [count] at runtime.
  // ignore: prefer_const_constructors_in_immutables
  AppBadge.count(int count, {super.key})
    : label = '$count',
      color = null,
      icon = null,
      style = AppBadgeStyle.neutral;

  final String label;
  final Color? color;
  final List<List<dynamic>>? icon;
  final AppBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantic = context.semantic;

    final (Color background, Color foreground, Color? border) = switch (style) {
      AppBadgeStyle.tinted when color != null => (
        semantic.tint(color!),
        color!,
        null,
      ),
      AppBadgeStyle.outline => (
        colors.background.withValues(alpha: 0),
        colors.mutedForeground,
        colors.border,
      ),
      _ => (colors.muted, colors.mutedForeground, null),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm - 1,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: context.theme.chipRadius,
        border: border == null ? null : Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            HugeIcon(icon: icon!, size: 12, strokeWidth: 2, color: foreground),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            maxLines: 1,
            style: context.text.caption.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
              height: 1.4,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
