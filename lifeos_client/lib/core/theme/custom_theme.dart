import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Custom theme configuration with 30% smaller font sizes
/// Based on shadcn_flutter's default themes
class CustomTheme {
  /// Scaling factor: 0.7 = 30% reduction (100% - 30% = 70%)
  static const double _fontScaleFactor = 0.85;

  /// Light theme with reduced font sizes
  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorSchemes.lightDefaultColor,
      radius: 0.7,
      typography: const Typography.geist().scale(_fontScaleFactor),
    );
  }

  /// Dark theme with reduced font sizes
  static ThemeData darkTheme() {
    return ThemeData(
      colorScheme: ColorSchemes.darkDefaultColor,
      radius: 0.7,
      typography: const Typography.geist().scale(_fontScaleFactor),
    );
  }
}
