import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app_theme_x.dart';
import '../tokens.dart';

/// Read-only property row for detail pages: label on the left, value on
/// the right. Use inside an AppListSection with `dividerIndent: 0` when
/// rows have no icon.
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.icon,
  }) : assert(value != null || valueWidget != null);

  final String label;
  final String? value;

  /// Rich value (badge, icons); takes precedence over [value].
  final Widget? valueWidget;
  final List<List<dynamic>>? icon;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppLayout.minTouchTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              HugeIcon(
                icon: icon!,
                size: AppIconSize.sm,
                strokeWidth: 1.8,
                color: context.colors.mutedForeground,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(label, style: text.itemSubtitle),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child:
                    valueWidget ??
                    Text(
                      value!,
                      textAlign: TextAlign.right,
                      style: text.itemTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
