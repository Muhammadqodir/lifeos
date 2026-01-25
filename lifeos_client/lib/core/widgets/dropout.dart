import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/tappable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class DropoutWidget extends StatefulWidget {
  const DropoutWidget({
    super.key,
    required this.title,
    required this.content,
    this.isOpenByDefault = true,
  });

  final Widget title;
  final Widget content;
  final bool isOpenByDefault;
  @override
  State<DropoutWidget> createState() => _DropoutWidgetState();
}

class _DropoutWidgetState extends State<DropoutWidget> {
  bool isopen = true;
  initialRperState() {
    super.initState();
    isopen = widget.isOpenByDefault;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tappable(
            lowerBound: 0.98,
            onTap: () {
              setState(() {
                isopen = !isopen;
              });
            },
            child: Row(
              children: [
                Expanded(child: widget.title),
                IconButton.ghost(
                  size: ButtonSize.small,
                  onPressed: () {
                    setState(() {
                      isopen = !isopen;
                    });
                  },
                  icon: HugeIcon(
                    icon: isopen
                        ? HugeIcons.strokeRoundedArrowUp01
                        : HugeIcons.strokeRoundedArrowDown01,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          if (isopen) widget.content,
        ],
      ),
    );
  }
}
