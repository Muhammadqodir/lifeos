import 'package:flutter/widgets.dart';

/// App color palette used across the application
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  /// Default color palette (hex values without #)
  static const List<String> palette = [
    'FF6B7280', // Gray
    'FFEF4444', // Red
    'FFF97316', // Orange
    'FFF59E0B', // Amber
    'FFEAB308', // Yellow
    'FF84CC16', // Lime
    'FF22C55E', // Green
    'FF10B981', // Emerald
    'FF14B8A6', // Teal
    'FF06B6D4', // Cyan
    'FF0EA5E9', // Sky
    'FF3B82F6', // Blue
    'FF6366F1', // Indigo
    'FF8B5CF6', // Violet
    'FFA855F7', // Purple
    'FFD946EF', // Fuchsia
    'FFEC4899', // Pink
    'FFF43F5E', // Rose
  ];

  // Named color constants
  static const String gray = 'FF6B7280';
  static const String red = 'FFEF4444';
  static const String orange = 'FFF97316';
  static const String amber = 'FFF59E0B';
  static const String yellow = 'FFEAB308';
  static const String lime = 'FF84CC16';
  static const String green = 'FF22C55E';
  static const String emerald = 'FF10B981';
  static const String teal = 'FF14B8A6';
  static const String cyan = 'FF06B6D4';
  static const String sky = 'FF0EA5E9';
  static const String blue = 'FF3B82F6';
  static const String indigo = 'FF6366F1';
  static const String violet = 'FF8B5CF6';
  static const String purple = 'FFA855F7';
  static const String fuchsia = 'FFD946EF';
  static const String pink = 'FFEC4899';
  static const String rose = 'FFF43F5E';

  // Color objects
  static const Color grayColor = Color(0xFF6B7280);
  static const Color redColor = Color(0xFFEF4444);
  static const Color orangeColor = Color(0xFFF97316);
  static const Color amberColor = Color(0xFFF59E0B);
  static const Color yellowColor = Color(0xFFEAB308);
  static const Color limeColor = Color(0xFF84CC16);
  static const Color greenColor = Color(0xFF22C55E);
  static const Color emeraldColor = Color(0xFF10B981);
  static const Color tealColor = Color(0xFF14B8A6);
  static const Color cyanColor = Color(0xFF06B6D4);
  static const Color skyColor = Color(0xFF0EA5E9);
  static const Color blueColor = Color(0xFF3B82F6);
  static const Color indigoColor = Color(0xFF6366F1);
  static const Color violetColor = Color(0xFF8B5CF6);
  static const Color purpleColor = Color(0xFFA855F7);
  static const Color fuchsiaColor = Color(0xFFD946EF);
  static const Color pinkColor = Color(0xFFEC4899);
  static const Color roseColor = Color(0xFFF43F5E);

  /// Helper method to convert hex string to Color
  static Color fromHex(String hexColor) {
    return Color(int.parse('0x$hexColor'));
  }
}
