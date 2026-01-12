import 'package:shadcn_flutter/shadcn_flutter.dart';

enum FeeType {
  none,
  halfPercent,
  onePercent,
  custom;

  String get label {
    switch (this) {
      case FeeType.none:
        return '0%';
      case FeeType.halfPercent:
        return '0.5%';
      case FeeType.onePercent:
        return '1%';
      case FeeType.custom:
        return 'Custom';
    }
  }

  double? get percentage {
    switch (this) {
      case FeeType.none:
        return 0;
      case FeeType.halfPercent:
        return 0.5;
      case FeeType.onePercent:
        return 1.0;
      case FeeType.custom:
        return null; // User will input custom value
    }
  }
}

class FeeSelector extends StatefulWidget {
  final FeeType selectedFeeType;
  final String customFeeValue;
  final ValueChanged<FeeType> onFeeTypeChanged;
  final ValueChanged<String> onCustomFeeChanged;

  const FeeSelector({
    super.key,
    required this.selectedFeeType,
    required this.customFeeValue,
    required this.onFeeTypeChanged,
    required this.onCustomFeeChanged,
  });

  @override
  State<FeeSelector> createState() => _FeeSelectorState();
}

class _FeeSelectorState extends State<FeeSelector> {
  late TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController(text: widget.customFeeValue);
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _updateFeeTypeFromValue(String value) {
    final numValue = double.tryParse(value);
    if (numValue == null || numValue == 0) {
      widget.onFeeTypeChanged(FeeType.none);
    } else if (numValue == 0.5) {
      widget.onFeeTypeChanged(FeeType.halfPercent);
    } else if (numValue == 1.0) {
      widget.onFeeTypeChanged(FeeType.onePercent);
    } else {
      widget.onFeeTypeChanged(FeeType.custom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transfer Fee (optional)',
          style: theme.typography.small.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 8),
        ButtonGroup(
          children: [
            _buildFeeButton(FeeType.none),
            _buildFeeButton(FeeType.halfPercent),
            _buildFeeButton(FeeType.onePercent),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      features: [
                        InputFeature.trailing(
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              '%',
                              style: theme.typography.small.copyWith(
                                color: colorScheme.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                      ],
                      controller: _customController,
                      placeholder: const Text('0.00'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      onChanged: (value) {
                        widget.onCustomFeeChanged(value);
                        _updateFeeTypeFromValue(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeeButton(FeeType type) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Check if input value matches this button's percentage
    final inputValue = double.tryParse(widget.customFeeValue) ?? 0;
    final buttonValue = type.percentage;
    final isSelected = inputValue == buttonValue;

    return GestureDetector(
      onTap: () {
        // Auto-fill input with button's percentage value
        final percentage = type.percentage;
        if (percentage != null) {
          final valueString = percentage == 0 ? '' : percentage.toString();
          _customController.text = valueString;
          widget.onCustomFeeChanged(valueString);
          _updateFeeTypeFromValue(valueString);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.border,
          ),
          color: isSelected ? colorScheme.primary : colorScheme.muted,
          borderRadius: type != FeeType.none
              ? BorderRadius.zero
              : BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
        ),
        child: Text(
          type.label,
          style: theme.typography.small.copyWith(
            fontWeight: FontWeight.w500,
            color: isSelected
                ? colorScheme.primaryForeground
                : colorScheme.foreground,
          ),
        ),
      ),
    );
  }
}
