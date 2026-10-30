import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../theme/app_colors.dart';

/// Semantic status colours that shadcn's colour scheme does not provide.
///
/// Use [tint] for soft backgrounds behind a coloured icon or label so the
/// pairing reads correctly in both light and dark mode.
@immutable
class AppSemanticColors {
  const AppSemanticColors._({
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.neutral,
    required this.isDark,
  });

  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color neutral;
  final bool isDark;

  static const _light = AppSemanticColors._(
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
    info: Color(0xFF2563EB),
    neutral: AppColors.grayColor,
    isDark: false,
  );

  static const _dark = AppSemanticColors._(
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    info: Color(0xFF60A5FA),
    neutral: Color(0xFF9CA3AF),
    isDark: true,
  );

  static AppSemanticColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;

  /// Soft background for [color] (badges, leading tiles, highlights).
  Color tint(Color color) => color.withValues(alpha: isDark ? 0.18 : 0.12);

  /// Colour for signed money amounts.
  Color amount(num value) => value < 0 ? danger : success;
}

/// Text roles. Screens pick a role instead of a raw size so the type scale
/// stays consistent: page › section › item › subtitle › caption.
@immutable
class AppTextStyles {
  const AppTextStyles(this._theme);

  final ThemeData _theme;

  Typography get _t => _theme.typography;
  ColorScheme get _c => _theme.colorScheme;

  TextStyle get pageTitle => _t.h4.copyWith(color: _c.foreground);

  TextStyle get sectionTitle =>
      _t.large.copyWith(fontWeight: FontWeight.w600, color: _c.foreground);

  TextStyle get itemTitle =>
      _t.base.copyWith(fontWeight: FontWeight.w500, color: _c.foreground);

  TextStyle get itemSubtitle =>
      _t.small.copyWith(color: _c.mutedForeground, height: 1.3);

  TextStyle get body => _t.base.copyWith(color: _c.foreground);

  TextStyle get label =>
      _t.small.copyWith(fontWeight: FontWeight.w500, color: _c.foreground);

  TextStyle get caption => _t.xSmall.copyWith(color: _c.mutedForeground);

  /// Numbers that line up in columns (balances, counts, durations).
  TextStyle get amount => _t.base.copyWith(
    fontWeight: FontWeight.w600,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  TextStyle get display => _t.x3Large.copyWith(
    fontWeight: FontWeight.w700,
    color: _c.foreground,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

extension AppThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  AppTextStyles get text => AppTextStyles(Theme.of(this));
  AppSemanticColors get semantic => AppSemanticColors.of(this);
}
