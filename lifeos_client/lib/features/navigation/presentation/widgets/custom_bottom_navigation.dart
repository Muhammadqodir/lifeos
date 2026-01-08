import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';

/// Custom bottom navigation bar following shadcn design principles
class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItemData> items;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.background,
        border: Border(top: BorderSide(color: colorScheme.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _NavigationButton(
                item: items[index],
                isSelected: currentIndex == index,
                onTap: () => onTap(index),
                colorScheme: colorScheme,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual navigation button
class _NavigationButton extends StatefulWidget {
  final NavigationItemData item;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _NavigationButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final colorScheme = widget.colorScheme;

    // Colors based on selection state
    // Use background.withValues(alpha: 0) instead of Colors.transparent to avoid black flashing
    final backgroundColor = isSelected
        ? colorScheme.muted
        : _isHovered
        ? colorScheme.accent
        : colorScheme.background.withValues(alpha: 0);

    final iconColor = isSelected
        ? colorScheme.foreground
        : colorScheme.mutedForeground;

    final textColor = isSelected
        ? colorScheme.foreground
        : colorScheme.mutedForeground;

    double strokeWidth = isSelected ? 2 : 1;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: widget.item.icon,
                  color: iconColor,
                  size: 24,
                  strokeWidth: strokeWidth,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                    height: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigation item data class
class NavigationItemData {
  final String label;
  final dynamic icon;

  const NavigationItemData({required this.label, required this.icon});
}
