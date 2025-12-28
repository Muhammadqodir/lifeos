import 'package:shadcn_flutter/shadcn_flutter.dart';

/// A unified selectable chip widget for currency, wallet type, and similar inputs
class SelectableChip extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.muted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(
                color: isSelected
                    ? colorScheme.primaryForeground
                    : colorScheme.foreground,
              ),
              child: DefaultTextStyle(
                style: Theme.of(context).typography.xSmall.copyWith(
                  color: isSelected
                      ? colorScheme.primaryForeground
                      : colorScheme.foreground,
                ),
                child: icon,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).typography.xSmall.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? colorScheme.primaryForeground
                    : colorScheme.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
