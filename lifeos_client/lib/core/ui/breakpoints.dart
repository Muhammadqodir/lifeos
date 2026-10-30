import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Window size classes, aligned with Apple's compact / regular split.
///
/// * compact  – iPhone, iPad Slide Over, narrow Mac windows
/// * medium   – iPad portrait, iPad split view, small Mac windows
/// * expanded – iPad landscape, full Mac windows
enum WindowClass {
  compact,
  medium,
  expanded;

  static const double mediumMin = 600;
  static const double expandedMin = 1024;

  static WindowClass fromWidth(double width) {
    if (width >= expandedMin) return WindowClass.expanded;
    if (width >= mediumMin) return WindowClass.medium;
    return WindowClass.compact;
  }

  bool get isCompact => this == WindowClass.compact;
  bool get isAtLeastMedium => this != WindowClass.compact;
  bool get isExpanded => this == WindowClass.expanded;
}

extension WindowClassX on BuildContext {
  WindowClass get windowClass =>
      WindowClass.fromWidth(MediaQuery.sizeOf(this).width);
}

/// True on platforms driven primarily by mouse and keyboard, where hover
/// states, tooltips, right-click menus and refresh buttons replace touch
/// gestures such as pull-to-refresh and swipe actions.
bool get isDesktopPlatform {
  if (kIsWeb) return true;
  return switch (defaultTargetPlatform) {
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux => true,
    _ => false,
  };
}

bool get isApplePlatform => switch (defaultTargetPlatform) {
  TargetPlatform.iOS || TargetPlatform.macOS => true,
  _ => false,
};
