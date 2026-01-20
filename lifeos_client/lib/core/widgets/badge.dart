import 'package:shadcn_flutter/shadcn_flutter.dart';

class CustomBadge extends StatelessWidget {
  const CustomBadge({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).typography.xSmall.copyWith(
          color: Theme.of(context).colorScheme.background,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
