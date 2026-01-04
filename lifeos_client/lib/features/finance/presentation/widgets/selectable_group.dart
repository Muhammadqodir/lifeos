import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'selectable_chip.dart';

class SelectableGroupOption<T> {
  final T value;
  final String label;
  final Widget icon;

  const SelectableGroupOption({
    required this.value,
    required this.label,
    required this.icon,
  });
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
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      children: widget.options.map((option) {
        final isSelected = _selectedValue == option.value;
        return SelectableChip(
          icon: option.icon,
          label: option.label,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedValue = option.value;
            });
            widget.onChanged(option.value);
          },
        );
      }).toList(),
    );
  }
}
