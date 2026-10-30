import 'package:lifeos_client/core/ui/components/app_pressable.dart';
import 'package:lifeos_client/core/ui/tokens.dart';
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
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToSelected(),
        );
      }
    }
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients || _selectedValue == null) return;

    final selectedIndex = widget.options.indexWhere(
      (opt) => opt.value == _selectedValue,
    );
    if (selectedIndex == -1) return;

    // Calculate approximate position
    // This is a simple implementation; for more accuracy, you'd need to measure actual widget sizes
    final viewportWidth = _scrollController.position.viewportDimension;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    if (maxScrollExtent <= 0) return;

    // Estimate the scroll position based on the index
    final estimatedPosition =
        (selectedIndex / widget.options.length) *
        (maxScrollExtent + viewportWidth);
    final targetPosition = (estimatedPosition - viewportWidth / 2).clamp(
      0.0,
      maxScrollExtent,
    );

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
    return widget.scrollable ? _buildChips(context) : _buildSegmented(context);
  }

  void _select(T value) {
    setState(() => _selectedValue = value);
    widget.onChanged(value);
  }

  /// Fixed set of options: a shadcn-style segmented control.
  Widget _buildSegmented(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: theme.controlRadius,
      ),
      child: Row(
        children: widget.options.map((option) {
          final isSelected = _selectedValue == option.value;
          return Expanded(
            child: AppPressable(
              onTap: () => _select(option.value),
              highlight: !isSelected,
              borderRadius: theme.controlRadius,
              child: AnimatedContainer(
                duration: AppDurations.base,
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm - 1,
                  horizontal: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.background
                      : colors.background.withValues(alpha: 0),
                  borderRadius: theme.controlRadius,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF000000,
                            ).withValues(alpha: 0.08),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: _styled(context, option.widget, isSelected),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Long or open-ended lists: horizontally scrolling filter chips.
  Widget _buildChips(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final row = Row(
      spacing: widget.spacing,
      children: [
        const SizedBox(width: AppSpacing.page - 8),
        ...widget.options.map((option) {
          final isSelected = _selectedValue == option.value;
          return AppPressable(
            onTap: () => _select(option.value),
            highlight: !isSelected,
            borderRadius: theme.chipRadius,
            child: AnimatedContainer(
              duration: AppDurations.base,
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm - 2,
                horizontal: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary
                    : colors.primary.withValues(alpha: 0),
                border: Border.all(
                  color: isSelected ? colors.primary : colors.border,
                ),
                borderRadius: theme.chipRadius,
              ),
              child: _styled(context, option.widget, isSelected, chip: true),
            ),
          );
        }),
        const SizedBox(width: AppSpacing.page - 8),
      ],
    );

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: row,
        ),
        if (_showLeftShadow) _edgeFade(context, left: true),
        if (_showRightShadow) _edgeFade(context, left: false),
      ],
    );
  }

  Widget _styled(
    BuildContext context,
    Widget child,
    bool isSelected, {
    bool chip = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final color = chip
        ? (isSelected ? colors.primaryForeground : colors.mutedForeground)
        : (isSelected ? colors.foreground : colors.mutedForeground);
    return IconTheme(
      data: IconThemeData(color: color, size: AppIconSize.sm),
      child: DefaultTextStyle(
        style: theme.typography.small.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: child,
      ),
    );
  }

  Widget _edgeFade(BuildContext context, {required bool left}) {
    final background = Theme.of(context).colorScheme.background;
    return Positioned(
      left: left ? 0 : null,
      right: left ? null : 0,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Container(
          width: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: left ? Alignment.centerLeft : Alignment.centerRight,
              end: left ? Alignment.centerRight : Alignment.centerLeft,
              colors: [background, background.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}
