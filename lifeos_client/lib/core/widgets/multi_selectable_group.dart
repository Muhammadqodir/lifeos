import 'package:lifeos_client/core/ui/components/app_pressable.dart';
import 'package:lifeos_client/core/ui/tokens.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MultiSelectableGroupOption<T> {
  final T value;
  final Widget widget;

  const MultiSelectableGroupOption({required this.value, required this.widget});
}

class MultiSelectableGroup<T> extends StatefulWidget {
  final List<MultiSelectableGroupOption<T>> options;
  final List<T> initialValues;
  final List<T>? values; // For controlled mode
  final ValueChanged<List<T>> onChanged;
  final double spacing;
  final double runSpacing;

  const MultiSelectableGroup({
    super.key,
    required this.options,
    this.initialValues = const [],
    this.values,
    required this.onChanged,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  State<MultiSelectableGroup<T>> createState() =>
      _MultiSelectableGroupState<T>();
}

class _MultiSelectableGroupState<T> extends State<MultiSelectableGroup<T>> {
  late List<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.values ?? List.from(widget.initialValues);
  }

  @override
  void didUpdateWidget(MultiSelectableGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.values != null && widget.values != _selectedValues) {
      setState(() {
        _selectedValues = List.from(widget.values!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      children: widget.options.map((option) {
        final isSelected = _selectedValue(option.value);
        final foreground = isSelected
            ? colors.primaryForeground
            : colors.mutedForeground;
        return AppPressable(
          highlight: !isSelected,
          borderRadius: theme.chipRadius,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedValues.remove(option.value);
              } else {
                _selectedValues.add(option.value);
              }
            });
            widget.onChanged(List.from(_selectedValues));
          },
          child: AnimatedContainer(
            duration: AppDurations.base,
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? colors.primary : colors.border,
              ),
              color: isSelected
                  ? colors.primary
                  : colors.primary.withValues(alpha: 0),
              borderRadius: theme.chipRadius,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm - 2,
              horizontal: AppSpacing.md,
            ),
            child: IconTheme(
              data: IconThemeData(color: foreground, size: AppIconSize.sm),
              child: DefaultTextStyle(
                style: theme.typography.small.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w500,
                ),
                child: option.widget,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _selectedValue(T value) => _selectedValues.contains(value);
}
