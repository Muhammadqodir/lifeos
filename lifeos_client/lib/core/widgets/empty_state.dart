import 'package:shadcn_flutter/shadcn_flutter.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final Widget? action;
  final Widget? icon;
  final EdgeInsets padding;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.action,
    this.icon,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) icon!,
            if (icon != null) const SizedBox(height: 16),
            Text(
              title,
              style: theme.typography.normal.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.typography.xSmall.copyWith(
                color: colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
