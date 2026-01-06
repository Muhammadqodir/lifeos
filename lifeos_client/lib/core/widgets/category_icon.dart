import 'package:shadcn_flutter/shadcn_flutter.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.icon, required this.color});

  final String icon;
  final String color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 3, left: 3),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Color(
          int.parse('0xFF${color.replaceAll("#", "")}'),
        ).withAlpha(51),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          icon,
          textAlign: TextAlign.center,
          style: Theme.of(context).typography.normal,
        ),
      ),
    );
  }
}
