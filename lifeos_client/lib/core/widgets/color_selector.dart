import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../ui/components/app_pressable.dart';
import '../ui/tokens.dart';

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

              return AppPressable(
                onTap: () => _selectColor(hexColor),
                highlight: false,
                borderRadius: theme.controlRadius,
                semanticLabel: isSelected ? 'Selected colour' : 'Colour',
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: theme.controlRadius,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.foreground
                          : colorScheme.foreground.withValues(alpha: 0),
                      width: 2,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: displayColor,
                      borderRadius: BorderRadius.circular(
                        theme.radiusLg - 3,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedTick02,
                              size: 16,
                              strokeWidth: 2.5,
                              color: _getContrastColor(displayColor),
                            ),
                          )
                        : null,
                  ),
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
