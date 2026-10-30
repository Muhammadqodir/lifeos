import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app_theme_x.dart';
import '../tokens.dart';

/// Title row inside an [AppCard]: title, supporting line, trailing action.
class CardHeader extends StatelessWidget {
  const CardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.trailing,
    this.padding = const EdgeInsets.only(bottom: AppSpacing.lg),
  });

  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.itemTitle.copyWith(fontWeight: FontWeight.w600),
                ),
                if (subtitleWidget != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  DefaultTextStyle.merge(
                    style: text.itemSubtitle,
                    child: subtitleWidget!,
                  ),
                ] else if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(subtitle!, style: text.itemSubtitle),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}
