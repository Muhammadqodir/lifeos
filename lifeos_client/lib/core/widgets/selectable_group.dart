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
  final T? value; // For controlled mode
  final ValueChanged<T> onChanged;
  final double spacing;
  final double runSpacing;
  final bool scrollable;

  const SelectableGroup({
    super.key,
    required this.options,
    this.initialValue,
    this.value,
    required this.onChanged,
    this.spacing = 8,
    this.runSpacing = 8,
    this.scrollable = false,
  });

  @override
  State<SelectableGroup<T>> createState() => _SelectableGroupState<T>();
}

class _SelectableGroupState<T> extends State<SelectableGroup<T>> {
  late T? _selectedValue;
  final ScrollController _scrollController = ScrollController();
  bool _showLeftShadow = false;
  bool _showRightShadow = false;

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      _selectedValue = widget.value;
    } else if (widget.initialValue != null) {
      _selectedValue = widget.initialValue;
    } else if (widget.options.isNotEmpty) {
      _selectedValue = widget.options.first.value;
    }

    if (widget.scrollable) {
      _scrollController.addListener(_updateShadows);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateShadows();
        _scrollToSelected();
      });
    }
  }

  @override
  void didUpdateWidget(SelectableGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected value if controlled via value prop
    if (widget.value != null && widget.value != _selectedValue) {
      setState(() {
        _selectedValue = widget.value;
      });
      if (widget.scrollable) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
      }
    }
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients || _selectedValue == null) return;

    final selectedIndex = widget.options.indexWhere((opt) => opt.value == _selectedValue);
    if (selectedIndex == -1) return;

    // Calculate approximate position
    // This is a simple implementation; for more accuracy, you'd need to measure actual widget sizes
    final viewportWidth = _scrollController.position.viewportDimension;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    
    if (maxScrollExtent <= 0) return;

    // Estimate the scroll position based on the index
    final estimatedPosition = (selectedIndex / widget.options.length) * (maxScrollExtent + viewportWidth);
    final targetPosition = (estimatedPosition - viewportWidth / 2).clamp(0.0, maxScrollExtent);

    _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateShadows() {
    if (!mounted) return;
    setState(() {
      _showLeftShadow =
          _scrollController.hasClients && _scrollController.offset > 0;
      _showRightShadow =
          _scrollController.hasClients &&
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final row = Row(
      spacing: widget.spacing,
      children: widget.options.map((option) {
        final isSelected = _selectedValue == option.value;
        final child = Padding(
          padding: EdgeInsets.only(
            left: widget.options.first == option && widget.scrollable ? 12 : 0,
            right: widget.options.last == option && widget.scrollable ? 12 : 0,
          ),
          child: Tappable(
            lowerBound: 0.98,
            onTap: () {
              setState(() {
                _selectedValue = option.value;
              });
              widget.onChanged(option.value);
            },
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

        return widget.scrollable ? child : Expanded(child: child);
      }).toList(),
    );

    if (widget.scrollable) {
      return Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: row,
          ),
          if (_showLeftShadow)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Theme.of(context).colorScheme.background,
                      Theme.of(context).colorScheme.background.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          if (_showRightShadow)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Theme.of(context).colorScheme.background,
                      Theme.of(context).colorScheme.background.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return SizedBox(width: double.infinity, child: row);
  }
}
