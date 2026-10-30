import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Spacing scale. Every padding, gap and margin in the app should come from
/// here so screens line up with each other.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal inset of page content from the window edge.
  static const double page = lg;

  /// Vertical gap between sections on a page.
  static const double section = xl;
}

abstract final class AppIconSize {
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;

  /// Icons used as illustrations (empty and error states).
  static const double hero = 40;
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
}

abstract final class AppLayout {
  /// Readable width for lists and forms on iPad / Mac.
  static const double maxContentWidth = 760;

  /// Width for dashboards that lay out cards in columns.
  static const double maxWideContentWidth = 1120;

  static const double sidebarWidth = 240;
  static const double railWidth = 76;

  /// Max width of dialogs used in place of bottom sheets on wide screens.
  static const double dialogWidth = 520;

  /// Minimum hit target (Apple HIG 44pt).
  static const double minTouchTarget = 44;

  /// Leading tile of list rows (icons, avatars, category emoji).
  static const double leadingSize = 36;
}

/// Corner radii derived from the shadcn theme radius so changing
/// `ThemeData.radius` reshapes the whole app consistently.
extension AppRadius on ThemeData {
  /// Cards, sections, sheets.
  BorderRadius get cardRadius => borderRadiusXl;

  /// Leading tiles, inputs, pressable rows inside cards.
  BorderRadius get controlRadius => borderRadiusLg;

  /// Badges and small chips.
  BorderRadius get chipRadius => borderRadiusMd;
}
