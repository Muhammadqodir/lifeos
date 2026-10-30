import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app_theme_x.dart';
import '../tokens.dart';

/// Summary metric: muted label over a large number. Use in rows of 2–4.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.caption,
  });

  final String label;
  final String value;
  final List<List<dynamic>>? icon;
  final Color? color;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: context.theme.cardRadius,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                HugeIcon(
                  icon: icon!,
                  size: 14,
                  strokeWidth: 2,
                  color: color ?? colors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  style: text.caption.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            value,
            maxLines: 1,
            style: context.theme.typography.x2Large.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.foreground,
              fontFeatures: const [FontFeature.tabularFigures()],
              height: 1.1,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(caption!, style: text.caption),
          ],
        ],
      ),
    );
  }
}
