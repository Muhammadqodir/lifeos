import 'package:lifeos_client/core/widgets/tappable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MultiSelectableGroupOption<T> {
  final T value;
  final Widget widget;

  const MultiSelectableGroupOption(
      {required this.value, required this.widget});
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
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      children: widget.options.map((option) {
        final isSelected = _selectedValues.contains(option.value);
        return Tappable(
          lowerBound: 0.98,
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
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.border,
                width: 1,
              ),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.muted,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: IconTheme(
              data: IconThemeData(
                color: isSelected
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).colorScheme.primary,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.background
                      : Theme.of(context).colorScheme.primary,
                ),
                child: option.widget,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
