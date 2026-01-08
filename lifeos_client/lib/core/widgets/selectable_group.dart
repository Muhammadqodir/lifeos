import 'package:lifeos_client/core/widgets/tappable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SelectableGroupOption<T> {
  final T value;
  final Widget widget;

  const SelectableGroupOption({required this.value, required this.widget});
}

class SelectableGroup<T> extends StatefulWidget {
  final List<SelectableGroupOption<T>> options;
  final T? initialValue;
  final ValueChanged<T> onChanged;
  final double spacing;
  final double runSpacing;

  const SelectableGroup({
    super.key,
    required this.options,
    this.initialValue,
    required this.onChanged,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  State<SelectableGroup<T>> createState() => _SelectableGroupState<T>();
}

class _SelectableGroupState<T> extends State<SelectableGroup<T>> {
  late T? _selectedValue;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _selectedValue = widget.initialValue;
    } else if (widget.options.isNotEmpty) {
      _selectedValue = widget.options.first.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      children: widget.options.map((option) {
        final isSelected = _selectedValue == option.value;
        return Tappable(
          lowerBound: 0.98,
          onTap: () {
            setState(() {
              _selectedValue = option.value;
            });
            widget.onChanged(option.value);
          },
          child: IntrinsicWidth(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
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
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
          ),
        );
      }).toList(),
    );
  }
}
