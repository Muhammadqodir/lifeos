import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';

class ColorSelector extends StatefulWidget {
  final String initialColor;
  final ValueChanged<String> onChanged;

  const ColorSelector({
    super.key,
    required this.initialColor,
    required this.onChanged,
  });

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  late String selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  void _selectColor(String hexColor) {
    setState(() {
      selectedColor = hexColor;
    });
    widget.onChanged(hexColor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Default colors grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...AppColors.palette.map((hexColor) {
              final isSelected = selectedColor == hexColor;
              final displayColor = Color(int.parse('0xFF$hexColor'));

              return GestureDetector(
                onTap: () => _selectColor(hexColor),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: displayColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.border, width: 1),
                  ),
                  child: isSelected
                      ? Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCircle,
                            size: 18,
                            strokeWidth: 4,
                            color: _getContrastColor(displayColor),
                          ),
                        )
                      : null,
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  // Helper to determine contrasting color for check icon
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }
}
