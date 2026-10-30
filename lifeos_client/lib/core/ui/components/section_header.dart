import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app_theme_x.dart';
import '../tokens.dart';
import 'app_badge.dart';

/// Heading above a group of content: title, optional count, optional
/// trailing action (usually a ghost "View all" button).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.trailing,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.only(
      left: AppSpacing.xxs,
      bottom: AppSpacing.sm,
    ),
  });

  final String title;
  final int? count;
  final Widget? trailing;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: context.text.sectionTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: AppSpacing.sm),
              AppBadge.count(count!),
            ],
            const Spacer(),
            if (trailing != null) trailing!,
            if (actionLabel != null && onAction != null)
              GhostButton(
                size: ButtonSize.small,
                density: ButtonDensity.compact,
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
          ],
        ),
      ),
    );
  }
}
