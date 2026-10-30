import 'package:flutter/painting.dart';

const Color _fallbackColor = Color(0xFF6B7280);

/// Parses colours as stored by the backend: `RRGGBB`, `AARRGGBB`, with or
/// without a leading `#`. Returns [fallback] for null or malformed input.
Color parseHexColor(String? hex, {Color fallback = _fallbackColor}) {
  if (hex == null) return fallback;
  var value = hex.trim().replaceFirst('#', '');
  if (value.startsWith('0x') || value.startsWith('0X')) {
    value = value.substring(2);
  }
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return fallback;
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}
