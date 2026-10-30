import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../breakpoints.dart';
import '../tokens.dart';

/// The single interaction primitive for custom tappable surfaces.
///
/// * Pointer (Mac, iPad trackpad): click cursor and hover highlight.
/// * Touch: pressed highlight plus a subtle scale, selection haptic on iOS.
/// * Keyboard: focusable, Enter/Space activate, visible focus ring.
class AppPressable extends StatefulWidget {
  const AppPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.padding,
    this.highlight = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  /// Paint a background on hover/press. Disable for surfaces that already
  /// have their own fill (cards, coloured tiles) and only need feedback.
  final bool highlight;
  final String? semanticLabel;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _handleTap() {
    if (widget.onTap == null) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      HapticFeedback.selectionClick();
    }
    widget.onTap!();
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = widget.borderRadius ?? theme.controlRadius;

    // Lerp from a transparent muted colour (not Colors.transparent) so the
    // animation never flashes through black.
    final idle = colors.muted.withValues(alpha: 0);
    final Color background;
    if (!_enabled || !widget.highlight) {
      background = idle;
    } else if (_pressed) {
      background = colors.muted;
    } else if (_hovered) {
      background = colors.muted.withValues(alpha: 0.6);
    } else {
      background = idle;
    }

    Widget content = AnimatedContainer(
      duration: AppDurations.fast,
      curve: Curves.easeOut,
      padding: widget.padding,
      decoration: BoxDecoration(color: background, borderRadius: radius),
      foregroundDecoration: _focused
          ? BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: colors.ring, width: 2),
            )
          : null,
      child: widget.child,
    );

    if (!isDesktopPlatform) {
      content = AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: AppDurations.fast,
        curve: Curves.easeOut,
        child: content,
      );
    }

    return Semantics(
      button: _enabled,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _handleTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap == null ? null : _handleTap,
          onLongPress: widget.onLongPress,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: _enabled ? () => _setPressed(false) : null,
          child: content,
        ),
      ),
    );
  }
}
