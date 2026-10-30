import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../ui/app_theme_x.dart';
import '../ui/tokens.dart';

/// Placeholder for an empty screen or section: icon, headline, one line of
/// explanation and an optional call to action.
class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final Widget? action;
  final Widget? icon;
  final EdgeInsets padding;

  /// Tint for the icon badge; defaults to neutral.
  final Color? color;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.action,
    this.icon,
    this.color,
    this.padding = const EdgeInsets.all(AppSpacing.xxl),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return Center(
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color == null
                        ? colors.muted
                        : context.semantic.tint(color!),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: IconTheme.merge(
                      data: IconThemeData(
                        size: AppIconSize.lg,
                        color: color ?? colors.mutedForeground,
                      ),
                      child: icon!,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                title,
                style: text.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: text.itemSubtitle,
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.xl),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
