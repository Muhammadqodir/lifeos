import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/tappable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ActionListItem extends StatelessWidget {
  const ActionListItem({super.key, required this.title, required this.description, required this.onTap, this.icon});
  final String title;
  final String description;
  final Function() onTap;
  final Widget? icon;
  @override
  Widget build(BuildContext context) {
    return Tappable(
      lowerBound: 0.98,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          children: [
            if(icon != null)
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: icon
            ),
            SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).typography.small.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).typography.xSmall,
                  ),
                ],
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 22,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
