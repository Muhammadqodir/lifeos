import 'package:shadcn_flutter/shadcn_flutter.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const HomeSectionHeader({super.key, required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: theme.typography.normal.copyWith(fontWeight: FontWeight.w600),
        ),
        if (onViewAll != null) ...[
          const Spacer(),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View All',
              style: theme.typography.small.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
