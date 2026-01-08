import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';


/// Custom app bar following shadcn design principles
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? leftActions;
  final List<Widget>? rightActions;
  final bool showBorder;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leftActions,
    this.rightActions,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.background,
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.border,
                  width: 1,
                ),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              // Left actions
              if (leftActions != null && leftActions!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...leftActions!,
                    const SizedBox(width: 12),
                  ],
                ),

              // Title - takes remaining space
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).typography.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Right actions
              if (rightActions != null && rightActions!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 12),
                    ...rightActions!,
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

/// Custom app bar action button
class AppBarAction extends StatelessWidget {
  final dynamic icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;

  const AppBarAction({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final button = _AppBarActionButton(
      icon: icon,
      onTap: onTap,
      size: size,
    );

    return button;
  }
}

/// Internal stateful button widget for AppBarAction
class _AppBarActionButton extends StatefulWidget {
  final dynamic icon;
  final VoidCallback? onTap;
  final double size;

  const _AppBarActionButton({
    required this.icon,
    this.onTap,
    required this.size,
  });

  @override
  State<_AppBarActionButton> createState() => _AppBarActionButtonState();
}

class _AppBarActionButtonState extends State<_AppBarActionButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = _isPressed
        ? colorScheme.accent
        : _isHovered
            ? colorScheme.muted
            : colorScheme.background.withValues(alpha: 0);

    final iconColor = widget.onTap != null
        ? colorScheme.foreground
        : colorScheme.mutedForeground;

    Widget iconWidget;
    if (widget.icon is IconData) {
      iconWidget = Icon(
        widget.icon as IconData,
        size: widget.size,
        color: iconColor,
      );
    } else {
      // Assume it's a HugeIcon
      iconWidget = HugeIcon(
        icon: widget.icon,
        color: iconColor,
        size: widget.size,
        strokeWidth: 2,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: iconWidget,
          ),
        ),
      ),
    );
  }
}

