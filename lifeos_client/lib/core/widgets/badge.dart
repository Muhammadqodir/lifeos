import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../ui/components/app_badge.dart';

/// Kept for existing call sites; renders an [AppBadge].
class CustomBadge extends StatelessWidget {
  const CustomBadge({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => AppBadge(label: label, color: color);
}
