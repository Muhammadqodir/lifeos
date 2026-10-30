import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../ui/components/app_pressable.dart';

/// Press feedback for surfaces that paint their own background (cards,
/// tiles). Thin wrapper over [AppPressable] without a hover fill.
class Tappable extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  /// Unused; press scale is now uniform across the app.
  final double lowerBound;

  const Tappable({
    super.key,
    required this.child,
    required this.onTap,
    this.lowerBound = 0.98,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(onTap: onTap, highlight: false, child: child);
  }
}
