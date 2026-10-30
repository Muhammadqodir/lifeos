import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app_theme_x.dart';
import '../tokens.dart';

/// The square visual at the start of a list row: a tinted icon, an emoji,
/// a remote image, or a plain colour swatch. Every list uses one of these
/// so rows line up across features.
class LeadingTile extends StatelessWidget {
  const LeadingTile.icon(
    List<List<dynamic>> this.icon, {
    super.key,
    this.color,
    this.size = AppLayout.leadingSize,
    this.solid = false,
  }) : emoji = null,
       imageUrl = null;

  const LeadingTile.emoji(
    String this.emoji, {
    super.key,
    this.color,
    this.size = AppLayout.leadingSize,
  }) : icon = null,
       imageUrl = null,
       solid = false;

  const LeadingTile.image(
    String this.imageUrl, {
    super.key,
    this.color,
    this.size = AppLayout.leadingSize,
  }) : icon = null,
       emoji = null,
       solid = false;

  /// A coloured swatch (projects without an icon, habits).
  const LeadingTile.swatch(
    Color this.color, {
    super.key,
    this.size = AppLayout.leadingSize,
  }) : icon = null,
       emoji = null,
       imageUrl = null,
       solid = false;

  final List<List<dynamic>>? icon;
  final String? emoji;
  final String? imageUrl;

  /// Accent colour. Icons and emoji get a soft tint of it behind them.
  final Color? color;
  final double size;

  /// Fill with [color] instead of tinting (high-emphasis rows).
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantic = context.semantic;
    final radius = context.theme.controlRadius;
    final accent = color ?? colors.foreground;

    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: radius,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _box(colors.muted, radius),
          errorWidget: (_, __, ___) => _box(
            color == null ? colors.muted : semantic.tint(color!),
            radius,
          ),
        ),
      );
    }

    if (icon == null && emoji == null) {
      // Swatch: a soft square with a solid inner dot.
      return _box(
        semantic.tint(accent),
        radius,
        child: Center(
          child: Container(
            width: size * 0.36,
            height: size * 0.36,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(size * 0.12),
            ),
          ),
        ),
      );
    }

    final background = solid
        ? accent
        : color == null
        ? colors.muted
        : semantic.tint(accent);

    return _box(
      background,
      radius,
      child: Center(
        child: emoji != null
            ? Text(
                emoji!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: size * 0.48, height: 1.1),
              )
            : HugeIcon(
                icon: icon!,
                size: size * 0.5,
                strokeWidth: 1.8,
                color: solid ? colors.background : accent,
              ),
      ),
    );
  }

  Widget _box(Color color, BorderRadius radius, {Widget? child}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, borderRadius: radius),
      child: child,
    );
  }
}
